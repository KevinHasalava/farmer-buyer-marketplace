import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/supabase/supabase_config.dart';
import '../models/buyer_review_model.dart';

/// 🌟 Real-time Buyer Reviews & Farmer Ratings Service
/// Member 1 (IT23843770 Thennakoon T.M.S.N) - Buyer Feedback CRUD
/// Features:
/// - Full Create, Read, Update, Delete (CRUD)
/// - Supabase Cloud Synchronization with fast 4s timeout
/// - SharedPreferences Local Cache for offline instant reliability
/// - Dynamic Product & Farmer Rating Calculations
class BuyerReviewService extends ChangeNotifier {
  BuyerReviewService._internal() {
    loadReviews();
  }

  static final BuyerReviewService instance = BuyerReviewService._internal();
  factory BuyerReviewService() => instance;

  static const String _kReviewsCacheKey = 'farm2home_buyer_reviews_v1';

  List<BuyerReview> _reviews = [];
  bool _isLoading = false;
  String? _lastError;

  List<BuyerReview> get allReviews => List.unmodifiable(_reviews);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  /// Generates a compliant RFC-4122 v4 UUID for Supabase and local storage
  static String _generateUuid() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // v4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
    return [
      bytes.sublist(0, 4).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.sublist(4, 6).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.sublist(6, 8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.sublist(8, 10).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      bytes.sublist(10, 16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    ].join('-');
  }

  /// Loads reviews from Supabase and syncs with local cache
  Future<void> loadReviews() async {
    _isLoading = true;
    notifyListeners();

    // 1. First, load from SharedPreferences for instant UI rendering
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_kReviewsCacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List decoded = jsonDecode(cachedJson) as List;
        _reviews = decoded
            .map((e) => BuyerReview.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}

    // If cache was empty, seed with initial realistic reviews
    if (_reviews.isEmpty) {
      _reviews = _generateSeedReviews();
      await _persistToLocalCache();
    }

    notifyListeners();

    // 2. Query live Supabase table with safe timeout
    if (SupabaseConfig.isInitialized) {
      try {
        final res = await SupabaseConfig.client
            .from('marketplace_reviews')
            .select()
            .order('created_at', ascending: false)
            .timeout(const Duration(seconds: 4));

        if (res.isNotEmpty) {
          final remoteList = res
              .map((e) => BuyerReview.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
          _reviews = remoteList;
          await _persistToLocalCache();
        }
      } catch (e) {
        // Table may not exist yet or offline; fallback to cached data seamlessly
        debugPrint('[BuyerReviewService] Supabase sync note: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ➕ CREATE (C): Submit a new verified produce review
  // ═══════════════════════════════════════════════════════════════════════════
  Future<BuyerReview> createReview({
    required String buyerId,
    required String buyerName,
    String buyerAvatar = '',
    required String productId,
    required String productName,
    String productImage = '',
    required String farmerId,
    required String farmerName,
    required double rating,
    required String title,
    required String comment,
    String qualityTag = 'Grade-A Fresh',
  }) async {
    final now = DateTime.now();
    final newId = _generateUuid();

    final newReview = BuyerReview(
      id: newId,
      buyerId: buyerId.isNotEmpty ? buyerId : 'buyer_chamara',
      buyerName: buyerName.isNotEmpty ? buyerName : 'Chamara Perera',
      buyerAvatar: buyerAvatar.isNotEmpty
          ? buyerAvatar
          : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      productId: productId,
      productName: productName,
      productImage: productImage,
      farmerId: farmerId.isNotEmpty ? farmerId : 'farmer_bandara',
      farmerName: farmerName.isNotEmpty ? farmerName : 'K. M. Bandara',
      rating: rating.clamp(1.0, 5.0),
      title: title.trim(),
      comment: comment.trim(),
      qualityTag: qualityTag,
      createdAt: now,
      updatedAt: now,
    );

    // Optimistic local update
    _reviews.insert(0, newReview);
    await _persistToLocalCache();
    notifyListeners();

    // Remote sync
    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client
            .from('marketplace_reviews')
            .insert(newReview.toJson())
            .timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('[BuyerReviewService] Remote insert note: $e');
      }
    }

    return newReview;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 READ (R): Filter & Query Getters
  // ═══════════════════════════════════════════════════════════════════════════
  List<BuyerReview> myReviews([String? currentBuyerId]) {
    return _reviews.where((r) => r.isOwnedBy(currentBuyerId)).toList();
  }

  List<BuyerReview> reviewsForProduct(String productId) {
    if (productId.isEmpty) return _reviews;
    return _reviews.where((r) {
      return r.productId.toLowerCase() == productId.toLowerCase() ||
          r.productName.toLowerCase().contains(productId.toLowerCase());
    }).toList();
  }

  List<BuyerReview> reviewsForFarmer(String farmerNameOrId) {
    if (farmerNameOrId.isEmpty) return _reviews;
    final term = farmerNameOrId.toLowerCase().trim();
    return _reviews.where((r) {
      return r.farmerName.toLowerCase().contains(term) ||
          r.farmerId.toLowerCase() == term;
    }).toList();
  }

  BuyerReview? existingReviewForProduct(String? buyerId, String productId) {
    try {
      return _reviews.firstWhere(
        (r) => r.isOwnedBy(buyerId) &&
            (r.productId.toLowerCase() == productId.toLowerCase() ||
                r.productName.toLowerCase() == productId.toLowerCase()),
      );
    } catch (_) {
      return null;
    }
  }

  double getAverageRatingForProduct(String productId, [double defaultVal = 4.9]) {
    final list = reviewsForProduct(productId);
    if (list.isEmpty) return defaultVal;
    final sum = list.fold<double>(0.0, (acc, r) => acc + r.rating);
    return double.parse((sum / list.length).toStringAsFixed(1));
  }

  double getAverageRatingForFarmer(String farmerNameOrId, [double defaultVal = 4.9]) {
    final list = reviewsForFarmer(farmerNameOrId);
    if (list.isEmpty) return defaultVal;
    final sum = list.fold<double>(0.0, (acc, r) => acc + r.rating);
    return double.parse((sum / list.length).toStringAsFixed(1));
  }

  int getReviewCountForProduct(String productId, [int defaultVal = 24]) {
    final list = reviewsForProduct(productId);
    return list.isEmpty ? defaultVal : list.length;
  }

  int getReviewCountForFarmer(String farmerNameOrId, [int defaultVal = 145]) {
    final list = reviewsForFarmer(farmerNameOrId);
    return list.isEmpty ? defaultVal : list.length;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✏️ UPDATE (U): Edit an existing review & star rating
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

    final existing = _reviews[index];
    final updated = existing.copyWith(
      rating: rating.clamp(1.0, 5.0),
      title: title.trim(),
      comment: comment.trim(),
      qualityTag: qualityTag ?? existing.qualityTag,
      updatedAt: DateTime.now(),
    );

    _reviews[index] = updated;
    await _persistToLocalCache();
    notifyListeners();

    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client
            .from('marketplace_reviews')
            .update({
              'rating': updated.rating,
              'title': updated.title,
              'comment': updated.comment,
              'quality_tag': updated.qualityTag,
              'updated_at': updated.updatedAt.toIso8601String(),
            })
            .eq('id', reviewId)
            .timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('[BuyerReviewService] Remote update note: $e');
      }
    }

    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🗑️ DELETE (D): Remove a submitted review
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> deleteReview(String reviewId) async {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return false;

    _reviews.removeAt(index);
    await _persistToLocalCache();
    notifyListeners();

    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client
            .from('marketplace_reviews')
            .delete()
            .eq('id', reviewId)
            .timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('[BuyerReviewService] Remote delete note: $e');
      }
    }

    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👨‍🌾 FARMER REPLY: Connects Farmer side to feedback
  // ═══════════════════════════════════════════════════════════════════════════
  Future<bool> addFarmerReply({
    required String reviewId,
    required String replyText,
  }) async {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return false;

    final now = DateTime.now();
    final existing = _reviews[index];
    final updated = existing.copyWith(
      farmerReply: replyText.trim(),
      farmerReplyAt: now,
      updatedAt: now,
    );

    _reviews[index] = updated;
    await _persistToLocalCache();
    notifyListeners();

    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client
            .from('marketplace_reviews')
            .update({
              'farmer_reply': updated.farmerReply,
              'farmer_reply_at': updated.farmerReplyAt?.toIso8601String(),
              'updated_at': updated.updatedAt.toIso8601String(),
            })
            .eq('id', reviewId)
            .timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('[BuyerReviewService] Remote reply note: $e');
      }
    }

    return true;
  }

  // ── Helper Persistence ──────────────────────────────────────────────────
  Future<void> _persistToLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _reviews.map((r) => r.toJson()).toList();
      await prefs.setString(_kReviewsCacheKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  static List<BuyerReview> _generateSeedReviews() {
    final now = DateTime.now();
    return [
      BuyerReview(
        id: 'rev_101',
        buyerId: 'buyer_chamara',
        buyerName: 'Chamara Perera',
        buyerAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
        productId: 'prod_1',
        productName: 'Nuwara Eliya Highland Carrots',
        productImage: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5c317?w=600&auto=format&fit=crop&q=80',
        farmerId: 'farmer_bandara',
        farmerName: 'K. M. Bandara',
        rating: 5.0,
        title: 'Unbeatable Highland Sweetness & Crunch',
        comment: 'The carrots arrived fresh from Hakgala valley within 10 hours. Sweet, crunchy and 100% soil-washed. Highly recommended for hotel salads!',
        qualityTag: 'Grade-A Fresh',
        farmerReply: 'Thank you Chamara! We harvested this lot at 5:30 AM before morning mist cleared.',
        farmerReplyAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      BuyerReview(
        id: 'rev_102',
        buyerId: 'buyer_nimal',
        buyerName: 'Nimal Senanayake',
        buyerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
        productId: 'prod_3',
        productName: 'Hakgala Crispy Organic Leeks',
        productImage: 'https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?w=600&auto=format&fit=crop&q=80',
        farmerId: 'farmer_bandara',
        farmerName: 'K. M. Bandara',
        rating: 4.9,
        title: 'Certified Organic & Extremely Tender',
        comment: 'Cooked soup with these leeks. The aroma is distinct from store-bought ones. Clean packaging and zero damage during refrigerated van transit.',
        qualityTag: '100% Organic',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      BuyerReview(
        id: 'rev_103',
        buyerId: 'buyer_dharshana',
        buyerName: 'Dharshana Silva',
        buyerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
        productId: 'prod_5',
        productName: 'Dambulla Vine-Ripened Red Tomatoes',
        productImage: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80',
        farmerId: 'farmer_sunil',
        farmerName: 'Sunil Perera',
        rating: 4.8,
        title: 'Plump, Juicy & Perfect for Curries',
        comment: 'No bruises on arrival. Sun-ripened flavor is rich and tangy. Great direct price with no retail markup.',
        qualityTag: 'Crisp & Sweet',
        farmerReply: 'Appreciate your trust Dharshana! Packed in aerated crates to prevent transit heat.',
        farmerReplyAt: now.subtract(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      BuyerReview(
        id: 'rev_104',
        buyerId: 'buyer_chamara',
        buyerName: 'Chamara Perera',
        buyerAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
        productId: 'prod_2',
        productName: 'Welimada Fresh White Potatoes',
        productImage: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80',
        farmerId: 'farmer_bandara',
        farmerName: 'K. M. Bandara',
        rating: 5.0,
        title: 'Top Grade Welimada Harvest',
        comment: 'Firm skin, perfectly dry and zero hollow hearts. Made French fries and curries for family gathering, everyone loved it.',
        qualityTag: 'Grade-A Fresh',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
