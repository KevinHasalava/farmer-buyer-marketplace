import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../admin/services/admin_marketplace_service.dart';
import '../models/buyer_profile_model.dart';

class BuyerProfileManager extends ChangeNotifier {
  BuyerProfileManager._internal() {
    if (SupabaseConfig.isInitialized) {
      // Reload whenever someone signs in / out so accounts never mix.
      SupabaseConfig.auth.onAuthStateChange.listen((_) => loadProfile());
    }
    loadProfile();
  }

  static final BuyerProfileManager instance = BuyerProfileManager._internal();
  factory BuyerProfileManager() => instance;

  BuyerProfileModel _profile = BuyerProfileModel.empty;
  bool _isLoading = false;

  BuyerProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  static const String _kBuyerProfileKey = 'buyer_profile_cache_v1';

  /// Loads the signed-in buyer's profile from the `buyers` table.
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user =
          SupabaseConfig.isInitialized ? SupabaseConfig.auth.currentUser : null;
      if (user == null) {
        _profile = BuyerProfileModel.empty;
      } else {
        final row = await SupabaseConfig.client
            .from('buyers')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        _profile = BuyerProfileModel.empty.copyWith(
          id: user.id,
          email: user.email ?? '',
          name: (row?['full_name'] as String?) ??
              (user.userMetadata?['full_name'] as String?) ??
              '',
          phone: (row?['phone'] as String?) ?? '',
          deliveryAddress: (row?['delivery_address'] as String?) ?? '',
          deliveryHub: (row?['delivery_hub'] as String?) ?? '',
          buyerType: (row?['buyer_type'] as String?) ?? '',
          completedOrders: (row?['total_orders'] as num?)?.toInt() ?? 0,
          directFarmSpend: (row?['total_spent'] as num?)?.toDouble() ?? 0,
          isVerified: true,
          memberSince: row?['created_at'] != null
              ? (DateTime.tryParse(row!['created_at'].toString())?.year ?? '')
                  .toString()
              : '',
        );
      }
    } catch (e) {
      debugPrint('Error loading buyer profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called on Buyer Registration to persist real user data to Supabase and cache
  Future<void> saveRegistrationData({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String buyerType,
    required String hub,
    required List<String> preferences,
    String? userId,
  }) async {
    final effectiveId = userId ??
        (SupabaseConfig.isInitialized ? SupabaseConfig.auth.currentUser?.id : null) ??
        'b-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final shortCode = effectiveId.length >= 4
        ? '#B-${effectiveId.substring(effectiveId.length - 4).toUpperCase()}'
        : '#B-0034';

    _profile = _profile.copyWith(
      id: effectiveId,
      name: name.isNotEmpty ? name : _profile.name,
      email: email.isNotEmpty ? email : _profile.email,
      phone: phone.isNotEmpty ? phone : _profile.phone,
      deliveryAddress: address.isNotEmpty ? address : _profile.deliveryAddress,
      deliveryHub: hub.isNotEmpty ? hub : _profile.deliveryHub,
      buyerType: buyerType.isNotEmpty ? buyerType : _profile.buyerType,
      preferences: preferences.isNotEmpty ? preferences : _profile.preferences,
      buyerCode: shortCode,
      memberSince: DateTime.now().year.toString(),
    );

    // Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kBuyerProfileKey, jsonEncode(_profile.toJson()));
    } catch (_) {}

    // Dual-sync to Supabase if authenticated
    try {
      if (SupabaseConfig.isInitialized && SupabaseConfig.auth.currentUser != null) {
        await SupabaseConfig.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': _profile.name,
              'phone': _profile.phone,
              'address': _profile.deliveryAddress,
              'hub': _profile.deliveryHub,
              'buyer_type': _profile.buyerType,
              'preferences': _profile.preferences,
              'role': 'buyer',
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('[BuyerProfileManager] Supabase update note: $e');
    }

    // Two-way synchronization with Admin Panel and remote database
    try {
      AdminMarketplaceService.instance.syncBuyerFromApp(_profile);
    } catch (_) {}

    notifyListeners();
  }

  /// Updates profile details and saves to Supabase and cache
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? hub,
    String? buyerType,
    List<String>? preferences,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      phone: phone,
      email: email,
      deliveryAddress: address,
      deliveryHub: hub,
      buyerType: buyerType,
      preferences: preferences,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kBuyerProfileKey, jsonEncode(_profile.toJson()));
    } catch (_) {}

    try {
      if (SupabaseConfig.isInitialized && SupabaseConfig.auth.currentUser != null) {
        await SupabaseConfig.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': _profile.name,
              'phone': _profile.phone,
              'address': _profile.deliveryAddress,
              'hub': _profile.deliveryHub,
              'buyer_type': _profile.buyerType,
              'preferences': _profile.preferences,
            },
          ),
        );
      }
    } catch (_) {}

    // Two-way synchronization with Admin Panel and remote database
    try {
      AdminMarketplaceService.instance.syncBuyerFromApp(_profile);
    } catch (_) {}

    notifyListeners();
  }

  /// Toggle Harvest Box Active / Paused
  Future<void> toggleHarvestBoxPause() async {
    _profile = _profile.copyWith(
      hasActiveHarvestBox: !_profile.hasActiveHarvestBox,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kBuyerProfileKey, jsonEncode(_profile.toJson()));
    } catch (_) {}
    notifyListeners();
  }

  /// Top up digital wallet balance
  Future<bool> topUpWallet(double amount) async {
    if (amount <= 0) return false;
    final newBalance = _profile.walletBalance + amount;
    _profile = _profile.copyWith(walletBalance: newBalance);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kBuyerProfileKey, jsonEncode(_profile.toJson()));
    } catch (_) {}

    try {
      AdminMarketplaceService.instance.syncBuyerFromApp(_profile);
    } catch (_) {}

    notifyListeners();
    return true;
  }

  /// Deduct digital wallet balance for order payment
  Future<bool> deductWallet(double amount) async {
    if (amount <= 0 || _profile.walletBalance < amount) return false;
    final newBalance = _profile.walletBalance - amount;
    _profile = _profile.copyWith(
      walletBalance: newBalance,
      directFarmSpend: _profile.directFarmSpend + amount,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kBuyerProfileKey, jsonEncode(_profile.toJson()));
    } catch (_) {}

    try {
      AdminMarketplaceService.instance.syncBuyerFromApp(_profile);
    } catch (_) {}

    notifyListeners();
    return true;
  }
}
