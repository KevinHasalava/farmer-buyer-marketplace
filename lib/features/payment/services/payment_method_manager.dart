import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../buyer/services/buyer_profile_manager.dart';
import '../models/payment_method_model.dart';

/// Singleton manager for Payment Method CRUD operations.
/// Handles:
/// - Create (C): Add new card / bank method
/// - Read (R): Fetch & stream saved cards
/// - Update (U): Edit cardholder, expiry, default status
/// - Delete (D): Remove payment methods
/// - Dual-persistence: Local SharedPreferences + Supabase table sync
class PaymentMethodManager extends ChangeNotifier {
  PaymentMethodManager._internal() {
    loadPaymentMethods();
  }

  static final PaymentMethodManager instance = PaymentMethodManager._internal();
  factory PaymentMethodManager() => instance;

  static const String _kStorageKey = 'farmtrust_saved_payment_methods_v1';

  final List<PaymentMethodModel> _methods = [];
  bool _isLoading = false;

  List<PaymentMethodModel> get methods => List.unmodifiable(_methods);
  bool get isLoading => _isLoading;

  /// Returns the designated default payment method, or the first available
  PaymentMethodModel? get defaultMethod {
    if (_methods.isEmpty) return null;
    return _methods.firstWhere((m) => m.isDefault, orElse: () => _methods.first);
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 1. READ (R): Load payment methods from local storage + Supabase
  /// ──────────────────────────────────────────────────────────────────────────
  Future<void> loadPaymentMethods() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_kStorageKey);

      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson) as List<dynamic>;
        _methods.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _methods.add(PaymentMethodModel.fromJson(item));
          }
        }
      } else {
        // Pre-populate with initial sample cards
        _methods.clear();
        _methods.addAll(PaymentMethodModel.initialSampleCards);
        await _saveToLocalCache();
      }

      // Supabase remote sync attempt
      await _syncFromSupabase();
    } catch (e) {
      debugPrint('[PaymentMethodManager] Load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 2. CREATE (C): Add a new card payment method
  /// ──────────────────────────────────────────────────────────────────────────
  Future<PaymentMethodModel> addPaymentMethod({
    required String cardHolderName,
    required String cardNumber,
    required String expiry, // MM/YY
    required String cvv,
    String? bankName,
    String cardType = 'Debit Card',
    bool isDefault = false,
    int gradientIndex = 0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');
      final last4 = cleanNumber.length >= 4
          ? cleanNumber.substring(cleanNumber.length - 4)
          : '0000';

      final parts = expiry.split('/');
      final expMonth = parts.isNotEmpty ? parts[0].trim().padLeft(2, '0') : '12';
      final expYear = parts.length > 1 ? parts[1].trim() : '28';

      final brand = CardBrand.fromNumber(cleanNumber).displayName;
      final currentUserId = BuyerProfileManager.instance.profile.id;

      // If user sets this as default, unset others
      if (isDefault || _methods.isEmpty) {
        for (int i = 0; i < _methods.length; i++) {
          _methods[i] = _methods[i].copyWith(isDefault: false);
        }
      }

      final newMethod = PaymentMethodModel(
        id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUserId,
        cardHolderName: cardHolderName.trim().toUpperCase(),
        cardNumber: cleanNumber,
        cardLast4: last4,
        expiryMonth: expMonth,
        expiryYear: expYear,
        cardBrand: brand,
        cardType: cardType,
        bankName: bankName,
        isDefault: isDefault || _methods.isEmpty,
        gradientIndex: gradientIndex,
        createdAt: DateTime.now(),
      );

      _methods.insert(0, newMethod);
      await _saveToLocalCache();

      // Remote Supabase sync
      await _syncSingleToSupabase(newMethod);

      return newMethod;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 3. UPDATE (U): Edit an existing payment method
  /// ──────────────────────────────────────────────────────────────────────────
  Future<void> updatePaymentMethod(PaymentMethodModel updated) async {
    final index = _methods.indexWhere((m) => m.id == updated.id);
    if (index == -1) return;

    if (updated.isDefault) {
      for (int i = 0; i < _methods.length; i++) {
        _methods[i] = _methods[i].copyWith(isDefault: false);
      }
    }

    _methods[index] = updated;
    await _saveToLocalCache();
    await _syncSingleToSupabase(updated);
    notifyListeners();
  }

  /// Set a specific payment method as the default
  Future<void> setDefaultPaymentMethod(String methodId) async {
    for (int i = 0; i < _methods.length; i++) {
      if (_methods[i].id == methodId) {
        _methods[i] = _methods[i].copyWith(isDefault: true);
      } else {
        _methods[i] = _methods[i].copyWith(isDefault: false);
      }
    }
    await _saveToLocalCache();
    notifyListeners();
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// 4. DELETE (D): Remove a payment method
  /// ──────────────────────────────────────────────────────────────────────────
  Future<bool> deletePaymentMethod(String methodId) async {
    final index = _methods.indexWhere((m) => m.id == methodId);
    if (index == -1) return false;

    final wasDefault = _methods[index].isDefault;
    _methods.removeAt(index);

    // If we deleted the default card, make the first remaining one default
    if (wasDefault && _methods.isNotEmpty) {
      _methods[0] = _methods[0].copyWith(isDefault: true);
    }

    await _saveToLocalCache();
    await _deleteFromSupabase(methodId);
    notifyListeners();
    return true;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Private Storage & Supabase Sync Helpers
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _saveToLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _methods.map((m) => m.toJson()).toList();
      await prefs.setString(_kStorageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[PaymentMethodManager] Local cache write error: $e');
    }
  }

  Future<void> _syncSingleToSupabase(PaymentMethodModel model) async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      await SupabaseConfig.client.from('buyer_payment_methods').upsert(
        {
          'id': model.id,
          'user_id': model.userId,
          'card_holder_name': model.cardHolderName,
          'card_last4': model.cardLast4,
          'expiry_month': model.expiryMonth,
          'expiry_year': model.expiryYear,
          'card_brand': model.cardBrand,
          'card_type': model.cardType,
          'bank_name': model.bankName,
          'is_default': model.isDefault,
          'gradient_index': model.gradientIndex,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'id',
      );
    } catch (e) {
      debugPrint('[PaymentMethodManager] Supabase sync note: $e');
    }
  }

  Future<void> _deleteFromSupabase(String methodId) async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      await SupabaseConfig.client
          .from('buyer_payment_methods')
          .delete()
          .eq('id', methodId);
    } catch (e) {
      debugPrint('[PaymentMethodManager] Supabase delete note: $e');
    }
  }

  Future<void> _syncFromSupabase() async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      final currentUserId = BuyerProfileManager.instance.profile.id;
      final response = await SupabaseConfig.client
          .from('buyer_payment_methods')
          .select()
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      final List<dynamic> records = response as List<dynamic>;
      if (records.isNotEmpty) {
        _methods.clear();
        for (final row in records) {
          if (row is Map<String, dynamic>) {
            _methods.add(PaymentMethodModel.fromJson(row));
          }
        }
        await _saveToLocalCache();
      }
    } catch (e) {
      debugPrint('[PaymentMethodManager] Supabase fetch note: $e');
    }
  }
}
