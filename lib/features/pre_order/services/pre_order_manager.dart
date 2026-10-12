import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/supabase/supabase_config.dart';
import '../models/pre_order_model.dart';
import '../models/pre_order_progress_model.dart';

/// Singleton manager for Pre-Order / Contract Farming CRUD operations.
class PreOrderManager extends ChangeNotifier {
  PreOrderManager._internal() {
    loadPreOrders();
  }

  static final PreOrderManager instance = PreOrderManager._internal();
  factory PreOrderManager() => instance;

  static const String _kStorageKey = 'farmtrust_pre_orders_v1';
  static const String _kProgressKey = 'farmtrust_pre_orders_progress_v1';

  final List<PreOrderModel> _preOrders = [];
  final List<PreOrderProgressModel> _progressUpdates = [];
  bool _isLoading = false;

  List<PreOrderModel> get preOrders => List.unmodifiable(_preOrders);
  List<PreOrderProgressModel> get progressUpdates => List.unmodifiable(_progressUpdates);
  bool get isLoading => _isLoading;

  /// ──────────────────────────────────────────────────────────────────────────
  /// 1. READ (R): Load pre-orders & progress from live Supabase database
  /// ──────────────────────────────────────────────────────────────────────────
  Future<void> loadPreOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (SupabaseConfig.isInitialized) {
        try {
          final preOrderRows = await SupabaseConfig.client
              .from('pre_orders')
              .select()
              .order('created_at', ascending: false);

          final progressRows = await SupabaseConfig.client
              .from('pre_order_progress')
              .select()
              .order('date', ascending: false);

          _preOrders.clear();
          for (final item in (preOrderRows as List<dynamic>)) {
            if (item is Map<String, dynamic>) {
              _preOrders.add(PreOrderModel.fromJson(item));
            }
          }

          _progressUpdates.clear();
          for (final item in (progressRows as List<dynamic>)) {
            if (item is Map<String, dynamic>) {
              _progressUpdates.add(PreOrderProgressModel.fromJson(item));
            }
          }

          await _savePreOrdersToLocal();
          await _saveProgressToLocal();
          _isLoading = false;
          notifyListeners();
          return;
        } catch (dbErr) {
          debugPrint('[PreOrderManager] Supabase query error, fallback to local: $dbErr');
        }
      }

      // Offline / Local cache fallback
      final prefs = await SharedPreferences.getInstance();
      
      final rawJson = prefs.getString(_kStorageKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as List<dynamic>;
        _preOrders.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _preOrders.add(PreOrderModel.fromJson(item));
          }
        }
      }

      final rawProgJson = prefs.getString(_kProgressKey);
      if (rawProgJson != null && rawProgJson.isNotEmpty) {
        final decoded = jsonDecode(rawProgJson) as List<dynamic>;
        _progressUpdates.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _progressUpdates.add(PreOrderProgressModel.fromJson(item));
          }
        }
      }
    } catch (e) {
      debugPrint('[PreOrderManager] Load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 2. CREATE (C): Add a new pre-order
  /// ──────────────────────────────────────────────────────────────────────────
  Future<PreOrderModel> createPreOrder({
    required String buyerId,
    required String buyerName,
    required String cropName,
    required double requiredQuantityKg,
    required double offeredPricePerKg,
    required DateTime expectedDeliveryDate,
    required String qualityRequirements,
    String deliveryLocation = '',
    String paymentTerms = 'Negotiable',
    String packagingRequirements = 'Standard Packaging',
    double advancePaymentRs = 0.0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newOrder = PreOrderModel(
        id: 'po_${DateTime.now().millisecondsSinceEpoch}',
        buyerId: buyerId,
        buyerName: buyerName,
        cropName: cropName,
        requiredQuantityKg: requiredQuantityKg,
        offeredPricePerKg: offeredPricePerKg,
        expectedDeliveryDate: expectedDeliveryDate,
        qualityRequirements: qualityRequirements,
        deliveryLocation: deliveryLocation,
        paymentTerms: paymentTerms,
        packagingRequirements: packagingRequirements,
        advancePaymentRs: advancePaymentRs,
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      _preOrders.insert(0, newOrder);
      await _savePreOrdersToLocal();

      if (SupabaseConfig.isInitialized) {
        try {
          await SupabaseConfig.client.from('pre_orders').insert(newOrder.toJson());
        } catch (e) {
          debugPrint('[PreOrderManager] DB insert error: $e');
        }
      }

      return newOrder;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 3. UPDATE (U): Update pre-order status (e.g. Farmer accepts)
  /// ──────────────────────────────────────────────────────────────────────────
  Future<void> updatePreOrderStatus(
    String preOrderId, 
    String newStatus, {
    String? farmerId, 
    String? farmerName,
    DateTime? farmerExpectedHarvestDate,
    double? farmerEstimatedYieldKg,
    String? farmerLocation,
    String? farmerNotes,
  }) async {
    final index = _preOrders.indexWhere((o) => o.id == preOrderId);
    if (index == -1) return;

    var order = _preOrders[index].copyWith(status: newStatus);
    final updateData = <String, dynamic>{'status': newStatus};
    if (farmerId != null) {
      order = order.copyWith(farmerId: farmerId);
      updateData['farmer_id'] = farmerId;
    }
    if (farmerName != null) {
      order = order.copyWith(farmerName: farmerName);
      updateData['farmer_name'] = farmerName;
    }
    if (farmerExpectedHarvestDate != null) {
      order = order.copyWith(farmerExpectedHarvestDate: farmerExpectedHarvestDate);
      updateData['farmer_expected_harvest_date'] = farmerExpectedHarvestDate.toIso8601String();
    }
    if (farmerEstimatedYieldKg != null) {
      order = order.copyWith(farmerEstimatedYieldKg: farmerEstimatedYieldKg);
      updateData['farmer_estimated_yield_kg'] = farmerEstimatedYieldKg;
    }
    if (farmerLocation != null) {
      order = order.copyWith(farmerLocation: farmerLocation);
      updateData['farmer_location'] = farmerLocation;
    }
    if (farmerNotes != null) {
      order = order.copyWith(farmerNotes: farmerNotes);
      updateData['farmer_notes'] = farmerNotes;
    }

    _preOrders[index] = order;
    await _savePreOrdersToLocal();
    notifyListeners();

    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client.from('pre_orders').update(updateData).eq('id', preOrderId);
      } catch (e) {
        debugPrint('[PreOrderManager] DB update error: $e');
      }
    }
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 3.5. RATE (R): Buyer rates the Farmer
  /// ──────────────────────────────────────────────────────────────────────────
  Future<void> ratePreOrder(String preOrderId, double rating, String review) async {
    final index = _preOrders.indexWhere((o) => o.id == preOrderId);
    if (index == -1) return;

    final now = DateTime.now();
    final order = _preOrders[index].copyWith(
      farmerRating: rating,
      farmerReview: review,
      ratedAt: now,
    );

    _preOrders[index] = order;
    await _savePreOrdersToLocal();
    notifyListeners();

    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client.from('pre_orders').update({
          'farmer_rating': rating,
          'farmer_review': review,
          'rated_at': now.toIso8601String(),
        }).eq('id', preOrderId);
      } catch (e) {
        debugPrint('[PreOrderManager] DB rate error: $e');
      }
    }
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 4. CREATE PROGRESS: Add progress update (Farmer side)
  /// ──────────────────────────────────────────────────────────────────────────
  Future<PreOrderProgressModel> addProgressUpdate({
    required String preOrderId,
    required String stage,
    required String description,
    List<String> images = const [],
    String updateType = 'Progress',
    DateTime? newExpectedDate,
    String? issueType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final update = PreOrderProgressModel(
        id: 'prog_${DateTime.now().millisecondsSinceEpoch}',
        preOrderId: preOrderId,
        stage: stage,
        description: description,
        images: images,
        date: DateTime.now(),
        updateType: updateType,
        newExpectedDate: newExpectedDate,
        issueType: issueType,
      );

      _progressUpdates.insert(0, update);
      await _saveProgressToLocal();

      if (SupabaseConfig.isInitialized) {
        try {
          await SupabaseConfig.client.from('pre_order_progress').insert(update.toJson());
        } catch (e) {
          debugPrint('[PreOrderManager] DB progress insert error: $e');
        }
      }

      return update;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<PreOrderProgressModel> getProgressForOrder(String preOrderId) {
    final list = _progressUpdates.where((p) => p.preOrderId == preOrderId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 5. DELETE (D): Admin functions
  /// ──────────────────────────────────────────────────────────────────────────
  Future<void> deletePreOrder(String preOrderId) async {
    _preOrders.removeWhere((o) => o.id == preOrderId);
    await _savePreOrdersToLocal();
    // Also delete associated progress updates
    _progressUpdates.removeWhere((p) => p.preOrderId == preOrderId);
    await _saveProgressToLocal();
    notifyListeners();

    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client.from('pre_orders').delete().eq('id', preOrderId);
      } catch (e) {
        debugPrint('[PreOrderManager] DB delete error: $e');
      }
    }
  }

  Future<void> deleteProgressUpdate(String progressId) async {
    _progressUpdates.removeWhere((p) => p.id == progressId);
    await _saveProgressToLocal();
    notifyListeners();

    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client.from('pre_order_progress').delete().eq('id', progressId);
      } catch (e) {
        debugPrint('[PreOrderManager] DB progress delete error: $e');
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Private Storage Helpers
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _savePreOrdersToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _preOrders.map((m) => m.toJson()).toList();
      await prefs.setString(_kStorageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[PreOrderManager] Save error: $e');
    }
  }

  Future<void> _saveProgressToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _progressUpdates.map((m) => m.toJson()).toList();
      await prefs.setString(_kProgressKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[PreOrderManager] Save progress error: $e');
    }
  }
}
