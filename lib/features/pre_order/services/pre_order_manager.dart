import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  /// 1. READ (R): Load pre-orders & progress from local storage
  /// ──────────────────────────────────────────────────────────────────────────
  Future<void> loadPreOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Pre-Orders
      final rawJson = prefs.getString(_kStorageKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as List<dynamic>;
        _preOrders.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _preOrders.add(PreOrderModel.fromJson(item));
          }
        }
      } else {
        _preOrders.clear();
        _preOrders.addAll(PreOrderModel.samplePreOrders);
        await _savePreOrdersToLocal();
      }

      // Load Progress Updates
      final rawProgJson = prefs.getString(_kProgressKey);
      if (rawProgJson != null && rawProgJson.isNotEmpty) {
        final decoded = jsonDecode(rawProgJson) as List<dynamic>;
        _progressUpdates.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _progressUpdates.add(PreOrderProgressModel.fromJson(item));
          }
        }
      } else {
        _progressUpdates.clear();
        _progressUpdates.addAll(PreOrderProgressModel.sampleProgress);
        await _saveProgressToLocal();
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
    if (farmerId != null) order = order.copyWith(farmerId: farmerId);
    if (farmerName != null) order = order.copyWith(farmerName: farmerName);
    if (farmerExpectedHarvestDate != null) order = order.copyWith(farmerExpectedHarvestDate: farmerExpectedHarvestDate);
    if (farmerEstimatedYieldKg != null) order = order.copyWith(farmerEstimatedYieldKg: farmerEstimatedYieldKg);
    if (farmerLocation != null) order = order.copyWith(farmerLocation: farmerLocation);
    if (farmerNotes != null) order = order.copyWith(farmerNotes: farmerNotes);

    _preOrders[index] = order;
    await _savePreOrdersToLocal();
    notifyListeners();
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 4. CREATE PROGRESS: Add progress update (Farmer side)
  /// ──────────────────────────────────────────────────────────────────────────
  Future<PreOrderProgressModel> addProgressUpdate({
    required String preOrderId,
    required String stage,
    required String description,
    List<String> images = const [],
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
      );

      _progressUpdates.insert(0, update);
      await _saveProgressToLocal();
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
  }

  Future<void> deleteProgressUpdate(String progressId) async {
    _progressUpdates.removeWhere((p) => p.id == progressId);
    await _saveProgressToLocal();
    notifyListeners();
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
