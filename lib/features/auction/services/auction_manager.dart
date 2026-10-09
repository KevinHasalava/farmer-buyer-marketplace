import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auction_model.dart';
import '../models/bid_model.dart';

/// Result type for placing a bid
class BidResult {
  final bool success;
  final String message;
  final AuctionModel? updatedAuction;

  const BidResult({
    required this.success,
    required this.message,
    this.updatedAuction,
  });
}

/// Singleton manager for Crop Bidding / Auction System CRUD and real-time state.
class AuctionManager extends ChangeNotifier {
  AuctionManager._internal() {
    loadAuctions();
  }

  static final AuctionManager instance = AuctionManager._internal();
  factory AuctionManager() => instance;

  static const String _kStorageKey = 'farmtrust_crop_auctions_v1';

  final List<AuctionModel> _auctions = [];
  bool _isLoading = false;

  List<AuctionModel> get auctions => List.unmodifiable(_auctions);
  bool get isLoading => _isLoading;

  /// Active auctions (not expired, status active)
  List<AuctionModel> get activeAuctions =>
      _auctions.where((a) => a.isActive).toList();

  /// Auctions ending soon (active and less than 12 hours remaining)
  List<AuctionModel> get endingSoonAuctions => _auctions
      .where((a) =>
          a.isActive && a.remainingDuration.inHours < 12)
      .toList()
    ..sort((a, b) => a.endTime.compareTo(b.endTime));

  /// ──────────────────────────────────────────────────────────────────────────
  /// 1. READ (R): Load auctions from local storage or initialize with sample data
  /// ──────────────────────────────────────────────────────────────────────────
  Future<void> loadAuctions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_kStorageKey);

      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as List<dynamic>;
        _auctions.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _auctions.add(AuctionModel.fromJson(item));
          }
        }
      } else {
        _auctions.clear();
        _auctions.addAll(AuctionModel.sampleAuctions);
        await _saveToLocal();
      }
    } catch (e) {
      debugPrint('[AuctionManager] Load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _auctions.map((a) => a.toJson()).toList();
      await prefs.setString(_kStorageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[AuctionManager] Save error: $e');
    }
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 2. CREATE (C): Farmer creates a new crop auction
  /// ──────────────────────────────────────────────────────────────────────────
  Future<AuctionModel> createAuction({
    required String farmerId,
    required String farmerName,
    String farmerPhone = '',
    required String farmerLocation,
    String farmerAvatar = '',
    required String cropName,
    required String category,
    required double quantity,
    String unit = 'kg',
    required double startingPrice,
    double minBidIncrement = 5.0,
    double? reservePrice,
    double? buyNowPrice,
    required String description,
    DateTime? harvestDate,
    String deliveryTerms = 'Farmgate Pickup / Flexible',
    required String location,
    required String imageUrl,
    required Duration duration,
  }) async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final newAuction = AuctionModel(
      id: 'auc_${now.millisecondsSinceEpoch}',
      farmerId: farmerId,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      farmerLocation: farmerLocation,
      farmerAvatar: farmerAvatar,
      cropName: cropName,
      category: category,
      quantity: quantity,
      unit: unit,
      startingPrice: startingPrice,
      minBidIncrement: minBidIncrement,
      reservePrice: reservePrice,
      buyNowPrice: buyNowPrice,
      currentHighestBid: 0.0,
      totalBids: 0,
      description: description,
      harvestDate: harvestDate,
      deliveryTerms: deliveryTerms,
      location: location,
      imageUrl: imageUrl.trim().isNotEmpty
          ? imageUrl.trim()
          : 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
      startTime: now,
      endTime: now.add(duration),
      status: 'active',
      createdAt: now,
      bids: const [],
    );

    _auctions.insert(0, newAuction);
    await _saveToLocal();

    _isLoading = false;
    notifyListeners();
    return newAuction;
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 3. UPDATE (U): Farmer updates existing auction
  /// ──────────────────────────────────────────────────────────────────────────
  Future<bool> updateAuction(AuctionModel updated) async {
    final idx = _auctions.indexWhere((a) => a.id == updated.id);
    if (idx == -1) return false;

    _auctions[idx] = updated;
    await _saveToLocal();
    notifyListeners();
    return true;
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 4. DELETE (D): Delete auction
  /// ──────────────────────────────────────────────────────────────────────────
  Future<bool> deleteAuction(String auctionId) async {
    final idx = _auctions.indexWhere((a) => a.id == auctionId);
    if (idx == -1) return false;

    _auctions.removeAt(idx);
    await _saveToLocal();
    notifyListeners();
    return true;
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 5. FARMER / ADMIN: End or Cancel Auction
  /// ──────────────────────────────────────────────────────────────────────────
  Future<bool> endAuction(String auctionId, {bool markAsSold = true}) async {
    final idx = _auctions.indexWhere((a) => a.id == auctionId);
    if (idx == -1) return false;

    final target = _auctions[idx];
    _auctions[idx] = target.copyWith(
      status: markAsSold && target.totalBids > 0 ? 'sold' : 'ended',
      endTime: DateTime.now(),
    );

    await _saveToLocal();
    notifyListeners();
    return true;
  }

  Future<bool> cancelAuction(String auctionId, {String reason = ''}) async {
    final idx = _auctions.indexWhere((a) => a.id == auctionId);
    if (idx == -1) return false;

    final target = _auctions[idx];
    _auctions[idx] = target.copyWith(
      status: 'cancelled',
      description: reason.isNotEmpty ? '${target.description}\n[Cancelled: $reason]' : target.description,
    );

    await _saveToLocal();
    notifyListeners();
    return true;
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 6. BUYER BIDDING (Real-time Bid Placement)
  /// ──────────────────────────────────────────────────────────────────────────
  Future<BidResult> placeBid({
    required String auctionId,
    required String buyerId,
    required String buyerName,
    required double amount,
    String notes = '',
  }) async {
    final idx = _auctions.indexWhere((a) => a.id == auctionId);
    if (idx == -1) {
      return const BidResult(success: false, message: 'Auction not found.');
    }

    final auction = _auctions[idx];

    // Validation checks
    if (!auction.isActive) {
      return const BidResult(success: false, message: 'This auction has already ended or is inactive.');
    }

    final minRequired = auction.minNextBid;
    if (amount < minRequired) {
      return BidResult(
        success: false,
        message: 'Your bid of Rs. $amount is too low. Minimum required is Rs. ${minRequired.toStringAsFixed(2)}.',
      );
    }

    // Create new bid record
    final newBid = BidModel(
      id: 'bid_${DateTime.now().millisecondsSinceEpoch}',
      auctionId: auctionId,
      bidderId: buyerId,
      bidderName: buyerName,
      amount: amount,
      createdAt: DateTime.now(),
      isWinning: true,
      notes: notes,
    );

    // Update existing bids to not winning
    final updatedBids = auction.bids.map((b) => b.copyWith(isWinning: false)).toList();
    updatedBids.insert(0, newBid);

    // If reserve price was met, mark as winning
    final updatedAuction = auction.copyWith(
      currentHighestBid: amount,
      highestBidderId: buyerId,
      highestBidderName: buyerName,
      totalBids: auction.totalBids + 1,
      bids: updatedBids,
    );

    _auctions[idx] = updatedAuction;
    await _saveToLocal();
    notifyListeners();

    return BidResult(
      success: true,
      message: 'Bid of Rs. ${amount.toStringAsFixed(2)} placed successfully! You are currently the highest bidder 🏆',
      updatedAuction: updatedAuction,
    );
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 7. BUY NOW (Instant Purchase)
  /// ──────────────────────────────────────────────────────────────────────────
  Future<BidResult> buyNow({
    required String auctionId,
    required String buyerId,
    required String buyerName,
  }) async {
    final idx = _auctions.indexWhere((a) => a.id == auctionId);
    if (idx == -1) {
      return const BidResult(success: false, message: 'Auction not found.');
    }

    final auction = _auctions[idx];
    if (auction.buyNowPrice == null || auction.buyNowPrice! <= 0) {
      return const BidResult(success: false, message: 'Buy Now is not available for this auction.');
    }

    final buyNowPrice = auction.buyNowPrice!;
    final newBid = BidModel(
      id: 'bid_bn_${DateTime.now().millisecondsSinceEpoch}',
      auctionId: auctionId,
      bidderId: buyerId,
      bidderName: buyerName,
      amount: buyNowPrice,
      createdAt: DateTime.now(),
      isWinning: true,
      notes: 'Purchased via Buy-Now option',
    );

    final updatedBids = auction.bids.map((b) => b.copyWith(isWinning: false)).toList();
    updatedBids.insert(0, newBid);

    final updatedAuction = auction.copyWith(
      currentHighestBid: buyNowPrice,
      highestBidderId: buyerId,
      highestBidderName: buyerName,
      totalBids: auction.totalBids + 1,
      status: 'sold',
      endTime: DateTime.now(),
      bids: updatedBids,
    );

    _auctions[idx] = updatedAuction;
    await _saveToLocal();
    notifyListeners();

    return BidResult(
      success: true,
      message: 'Congratulations! You purchased the bulk crop lot for Rs. ${buyNowPrice.toStringAsFixed(2)}/unit!',
      updatedAuction: updatedAuction,
    );
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 8. QUERY HELPERS
  /// ──────────────────────────────────────────────────────────────────────────
  AuctionModel? getAuctionById(String id) {
    try {
      return _auctions.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<AuctionModel> getAuctionsByFarmer(String farmerId) {
    return _auctions.where((a) => a.farmerId == farmerId).toList();
  }

  List<AuctionModel> searchAuctions({String query = '', String category = 'All'}) {
    return _auctions.where((a) {
      final matchesQuery = query.isEmpty ||
          a.cropName.toLowerCase().contains(query.toLowerCase()) ||
          a.farmerName.toLowerCase().contains(query.toLowerCase()) ||
          a.location.toLowerCase().contains(query.toLowerCase());

      final matchesCategory = category == 'All' ||
          a.category.toLowerCase() == category.toLowerCase();

      return matchesQuery && matchesCategory;
    }).toList();
  }

  /// Admin Stats
  int get totalAuctionsCount => _auctions.length;
  int get activeAuctionsCount => activeAuctions.length;
  int get totalBidsCount => _auctions.fold<int>(0, (sum, a) => sum + a.totalBids);
  double get totalAuctionVolumeRs => _auctions.fold<double>(0.0, (sum, a) => sum + a.totalLotValue);
}
