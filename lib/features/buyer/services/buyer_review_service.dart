import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/supabase/supabase_config.dart';
import '../models/buyer_review_model.dart';

/// A registered farmer (real row from the Supabase `farmers` table) that a
/// buyer can rate.
class RatableFarmer {
  const RatableFarmer({
    required this.id,
    required this.name,
    this.farmName = '',
    this.district = '',
  });

  final String id;
  final String name;
  final String farmName;
  final String district;

  String get label => farmName.isNotEmpty ? '$name • $farmName' : name;
}

/// A real product listed by a registered farmer.
class RatableProduct {
  const RatableProduct({
    required this.id,
    required this.name,
    this.imageUrl = '',
  });

  final String id;
  final String name;
  final String imageUrl;
}

/// 🌟 Buyer Reviews & Farmer Ratings Service (Supabase `marketplace_reviews`)
///
/// - Supabase is the source of truth (buyer app, farmer app and admin panel
///   all read/write the same table).
/// - SharedPreferences cache for instant/offline rendering.
/// - Reviews written while offline are kept in a "pending" queue and pushed
///   to Supabase on the next sync. Nothing is seeded with fake data.
class BuyerReviewService extends ChangeNotifier {
  BuyerReviewService._internal() {
    loadReviews();
  }

  static final BuyerReviewService instance = BuyerReviewService._internal();
  factory BuyerReviewService() => instance;

  static const String _kReviewsCacheKey = 'farm2home_buyer_reviews_v2';
  static const String _kPendingKey = 'farm2home_buyer_reviews_pending_v2';
  static const String _table = 'marketplace_reviews';

  List<BuyerReview> _reviews = [];
  final Set<String> _pendingUpsert = {};
  bool _isLoading = false;
  String? _lastError;

  List<BuyerReview> get allReviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  void clearError() => _lastError = null;

  /// Generates a compliant RFC-4122 v4 UUID.
  static String _generateUuid() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String h(List<int> b) =>
        b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return [
      h(bytes.sublist(0, 4)),
      h(bytes.sublist(4, 6)),
      h(bytes.sublist(6, 8)),
      h(bytes.sublist(8, 10)),
      h(bytes.sublist(10, 16)),
    ].join('-');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📥 READ (R): cache first, then Supabase (authoritative)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> loadReviews() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_kReviewsCacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List decoded = jsonDecode(cachedJson) as List;
        _reviews = decoded
            .map((e) => BuyerReview.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      _pendingUpsert
        ..clear()
        ..addAll(prefs.getStringList(_kPendingKey) ?? const []);
    } catch (_) {}
    notifyListeners();

    if (SupabaseConfig.isInitialized) {
      try {
        final res = await SupabaseConfig.client
            .from(_table)
            .select()
            .order('created_at', ascending: false)
            .timeout(const Duration(seconds: 8));

        final remote = (res as List)
            .map((e) => BuyerReview.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        final remoteIds = remote.map((r) => r.id).toSet();

        // Push reviews that were written offline / failed to sync
        final stillPending = <String>{};
        final merged = [...remote];
        for (final id in _pendingUpsert) {
          final local = _reviews.where((r) => r.id == id).toList();
          if (local.isEmpty) continue;
          try {
            await SupabaseConfig.client.from(_table).upsert(local.first.toJson());
            if (!remoteIds.contains(id)) merged.insert(0, local.first);
          } catch (e) {
            stillPending.add(id);
            if (!remoteIds.contains(id)) merged.insert(0, local.first);
            debugPrint('[BuyerReviewService] pending sync failed: $e');
          }
        }
        _reviews = merged;
        _pendingUpsert
          ..clear()
          ..addAll(stillPending);
        _lastError = null;
        await _persist();
      } catch (e) {
        _lastError = 'Could not reach cloud database: $e';
        debugPrint('[BuyerReviewService] load error: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Real registered farmers from Supabase (`farmers` table).
  Future<List<RatableFarmer>> fetchRegisteredFarmers() async {
    if (!SupabaseConfig.isInitialized) return const [];
    try {
      final res = await SupabaseConfig.client
          .from('farmers')
          .select('id, full_name, farm_name, district')
          .order('full_name', ascending: true)
          .timeout(const Duration(seconds: 8));
      return (res as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((m) => (m['full_name']?.toString() ?? '').trim().isNotEmpty)
          .map((m) => RatableFarmer(
                id: m['id'].toString(),
                name: m['full_name'].toString(),
                farmName: m['farm_name']?.toString() ?? '',
                district: m['district']?.toString() ?? '',
              ))
          .toList();
    } catch (e) {
      debugPrint('[BuyerReviewService] fetch farmers error: $e');
      return const [];
    }
  }

  /// Real products listed by a registered farmer.
  Future<List<RatableProduct>> fetchProductsForFarmer(String farmerId) async {
    if (!SupabaseConfig.isInitialized || farmerId.isEmpty) return const [];
    try {
      final res = await SupabaseConfig.client
          .from('products')
          .select('id, name, image_url')
          .eq('farmer_id', farmerId)
          .timeout(const Duration(seconds: 8));
      return (res as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map((m) => RatableProduct(
                id: m['id'].toString(),
                name: m['name']?.toString() ?? 'Product',
                imageUrl: m['image_url']?.toString() ?? '',
              ))
          .toList();
    } catch (e) {
      debugPrint('[BuyerReviewService] fetch products error: $e');
      return const [];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ➕ CREATE (C)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<BuyerReview> createReview({
    required String buyerId,
    required String buyerName,
    String buyerAvatar = '',
    String productId = '',
    String productName = '',
    String productImage = '',
    required String farmerId,
    required String farmerName,
    required double rating,
    required String title,
    required String comment,
    String qualityTag = 'Grade-A Fresh',
  }) async {
    final now = DateTime.now();
    final review = BuyerReview(
      id: _generateUuid(),
      buyerId: buyerId,
      buyerName: buyerName,
      buyerAvatar: buyerAvatar,
      productId: productId,
      productName: productName,
      productImage: productImage,
      farmerId: farmerId,
      farmerName: farmerName,
      rating: rating.clamp(1.0, 5.0),
      title: title.trim(),
      comment: comment.trim(),
      qualityTag: qualityTag,
      createdAt: now,
      updatedAt: now,
    );

    _reviews.insert(0, review);
    await _upsertRemote(review);
    await _persist();
    notifyListeners();
    return review;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 READ helpers
  // ═══════════════════════════════════════════════════════════════════════════
  List<BuyerReview> myReviews([String? currentBuyerId]) =>
      _reviews.where((r) => r.isOwnedBy(currentBuyerId)).toList();

  List<BuyerReview> reviewsForProduct(String productId) {
    if (productId.isEmpty) return const [];
    return _reviews
        .where((r) => r.productId.toLowerCase() == productId.toLowerCase())
        .toList();
  }

  /// Matches by farmer id (exact) or farmer name (exact, case-insensitive).
  List<BuyerReview> reviewsForFarmer(String farmerNameOrId) {
    final term = farmerNameOrId.toLowerCase().trim();
    if (term.isEmpty) return const [];
    return _reviews
        .where((r) =>
            r.farmerId.toLowerCase() == term ||
            r.farmerName.toLowerCase().trim() == term)
        .toList();
  }

  /// A buyer's review of a given farmer (+ optional product).
  BuyerReview? existingReview(String? buyerId, String farmerId, [String productId = '']) {
    try {
      return _reviews.firstWhere((r) =>
          r.isOwnedBy(buyerId) &&
          r.farmerId == farmerId &&
          r.productId == productId);
    } catch (_) {
      return null;
    }
  }

  BuyerReview? existingReviewForProduct(String? buyerId, String productId) {
    try {
      return _reviews.firstWhere(
        (r) => r.isOwnedBy(buyerId) && r.productId.toLowerCase() == productId.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  double _avg(List<BuyerReview> list) {
    if (list.isEmpty) return 0.0;
    final sum = list.fold<double>(0.0, (acc, r) => acc + r.rating);
    return double.parse((sum / list.length).toStringAsFixed(1));
  }

  /// Returns [defaultVal] only when there are no real reviews (0 = "unrated").
  double getAverageRatingForProduct(String productId, [double defaultVal = 0.0]) {
    final list = reviewsForProduct(productId);
    return list.isEmpty ? defaultVal : _avg(list);
  }

  double getAverageRatingForFarmer(String farmerNameOrId, [double defaultVal = 0.0]) {
    final list = reviewsForFarmer(farmerNameOrId);
    return list.isEmpty ? defaultVal : _avg(list);
  }

  int getReviewCountForProduct(String productId, [int defaultVal = 0]) {
    final list = reviewsForProduct(productId);
    return list.isEmpty ? defaultVal : list.length;
  }

  int getReviewCountForFarmer(String farmerNameOrId, [int defaultVal = 0]) {
    final list = reviewsForFarmer(farmerNameOrId);
    return list.isEmpty ? defaultVal : list.length;
  }

  // Overall stats (admin dashboard)
  double get overallAverage => _avg(_reviews);
  int get fiveStarCount => _reviews.where((r) => r.rating >= 4.5).length;
  int get ratedFarmersCount => _reviews.map((r) => r.farmerId).toSet().length;
  int get repliedCount => _reviews.where((r) => r.hasFarmerReply).length;

  // ═══════════════════════════════════════════════════════════════════════════
  // ✏️ UPDATE (U) — buyer edits own review; admin may edit any review
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> updateReview({
    required String reviewId,
    required double rating,
    required String title,
    required String comment,
    String? qualityTag,
  }) async {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return false;

    final updated = _reviews[index].copyWith(
      rating: rating.clamp(1.0, 5.0),
      title: title.trim(),
      comment: comment.trim(),
      qualityTag: qualityTag ?? _reviews[index].qualityTag,
      updatedAt: DateTime.now(),
    );
    _reviews[index] = updated;
    await _upsertRemote(updated);
    await _persist();
    notifyListeners();
    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🗑️ DELETE (D)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> deleteReview(String reviewId) async {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return false;

    _reviews.removeAt(index);
    _pendingUpsert.remove(reviewId);
    await _persist();
    notifyListeners();

    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client
            .from(_table)
            .delete()
            .eq('id', reviewId)
            .timeout(const Duration(seconds: 8));
        _lastError = null;
      } catch (e) {
        _lastError = 'Deleted locally but cloud delete failed: $e';
        debugPrint('[BuyerReviewService] delete error: $e');
      }
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👨‍🌾 FARMER REPLY (farmer side) / admin moderation
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> addFarmerReply({
    required String reviewId,
    required String replyText,
  }) async {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return false;

    final now = DateTime.now();
    final updated = _reviews[index].copyWith(
      farmerReply: replyText.trim(),
      farmerReplyAt: now,
      updatedAt: now,
    );
    _reviews[index] = updated;
    await _upsertRemote(updated);
    await _persist();
    notifyListeners();
    return true;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _upsertRemote(BuyerReview review) async {
    if (!SupabaseConfig.isInitialized) {
      _pendingUpsert.add(review.id);
      return;
    }
    try {
      await SupabaseConfig.client
          .from(_table)
          .upsert(review.toJson())
          .timeout(const Duration(seconds: 8));
      _pendingUpsert.remove(review.id);
      _lastError = null;
    } catch (e) {
      _pendingUpsert.add(review.id);
      _lastError = 'Saved on device, will sync to cloud later: $e';
      debugPrint('[BuyerReviewService] upsert error: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kReviewsCacheKey,
        jsonEncode(_reviews.map((r) => r.toJson()).toList()),
      );
      await prefs.setStringList(_kPendingKey, _pendingUpsert.toList());
    } catch (_) {}
  }
}
