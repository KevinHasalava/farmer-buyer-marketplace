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

  /// Loads the signed-in buyer's profile from the `buyers` table or cache.
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user =
          SupabaseConfig.isInitialized ? SupabaseConfig.auth.currentUser : null;
      if (user == null) {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_kBuyerProfileKey);
        if (raw != null) {
          _profile = BuyerProfileModel.fromJson(jsonDecode(raw));
        } else {
          _profile = BuyerProfileModel.empty;
        }
      } else {
        Map<String, dynamic>? row;
        try {
          row = await SupabaseConfig.client
              .from('buyers')
              .select()
              .eq('id', user.id)
              .maybeSingle();
        } catch (_) {}

        final metadata = user.userMetadata ?? {};
        final code = user.id.length >= 4
            ? '#B-${user.id.substring(user.id.length - 4).toUpperCase()}'
            : '#B-0034';
        _profile = BuyerProfileModel.empty.copyWith(
          id: user.id,
          buyerCode: code,
          email: (row?['email'] as String?) ?? user.email ?? '',
          name: (row?['full_name'] as String?) ??
              (metadata['full_name'] as String?) ??
              '',
          phone: (row?['phone'] as String?) ??
              (metadata['phone'] as String?) ??
              '',
          deliveryAddress: (row?['delivery_address'] as String?) ??
              (metadata['delivery_address'] as String?) ??
              (metadata['address'] as String?) ??
              '',
          deliveryHub: (row?['delivery_hub'] as String?) ??
              (metadata['delivery_hub'] as String?) ??
              (metadata['hub'] as String?) ??
              '',
          buyerType: (row?['buyer_type'] as String?) ??
              (metadata['buyer_type'] as String?) ??
              '',
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

    // Direct persistence to Supabase buyers & profiles tables
    try {
      if (SupabaseConfig.isInitialized) {
        final targetId = (userId != null && userId.isNotEmpty && !userId.startsWith('b-'))
            ? userId
            : (SupabaseConfig.auth.currentUser?.id ?? effectiveId);

        // 1) Always upsert the buyer row into the `buyers` table directly
        try {
          await SupabaseConfig.client.from('buyers').upsert({
            'id': targetId,
            'full_name': _profile.name,
            'email': _profile.email,
            'phone': _profile.phone,
            'delivery_address': _profile.deliveryAddress,
            'delivery_hub': _profile.deliveryHub,
            'buyer_type': _profile.buyerType,
            'status': 'Active',
          }, onConflict: 'id');
          debugPrint('[BuyerProfileManager] Buyer upserted to buyers table: $targetId');
        } catch (be) {
          debugPrint('[BuyerProfileManager] buyers upsert error: $be');
        }

        // 2) If authenticated or session available, update auth user and profiles
        if (SupabaseConfig.auth.currentUser != null) {
          final uid = SupabaseConfig.auth.currentUser!.id;
          try {
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
          } catch (_) {}

          try {
            await SupabaseConfig.client.from('profiles').upsert({
              'id': uid,
              'role': 'buyer',
              'full_name': _profile.name,
              'email': _profile.email,
              'phone': _profile.phone,
              'status': 'Active',
            }, onConflict: 'id');
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('[BuyerProfileManager] Supabase upsert error: $e');
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
        // Update auth metadata
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

        // Sync updated fields back to the profiles and buyers tables
        final uid = SupabaseConfig.auth.currentUser!.id;
        try {
          await SupabaseConfig.client.from('profiles').upsert({
            'id': uid,
            'role': 'buyer',
            'full_name': _profile.name,
            'email': _profile.email,
            'phone': _profile.phone,
          }, onConflict: 'id');
        } catch (_) {}

        await SupabaseConfig.client.from('buyers').upsert({
          'id': uid,
          'full_name': _profile.name,
          'email': _profile.email,
          'phone': _profile.phone,
          'delivery_address': _profile.deliveryAddress,
          'delivery_hub': _profile.deliveryHub,
          'buyer_type': _profile.buyerType,
        }, onConflict: 'id');
      }
    } catch (e) {
      debugPrint('[BuyerProfileManager] updateProfile Supabase error: $e');
    }

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
