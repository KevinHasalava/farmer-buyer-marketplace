import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../../services/database_service.dart';
import '../models/buyer_profile_model.dart';

class BuyerProfileManager extends ChangeNotifier {
  BuyerProfileManager._internal() {
    loadProfile();
  }

  static final BuyerProfileManager instance = BuyerProfileManager._internal();
  factory BuyerProfileManager() => instance;

  final DatabaseService _dbService = const DatabaseService();

  BuyerProfileModel _profile = BuyerProfileModel.defaultBuyer;
  bool _isLoading = false;

  BuyerProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  static const String _kBuyerProfileKey = 'buyer_profile_cache_v1';

  /// Loads profile from Supabase Database, Auth session, and SharedPreferences
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_kBuyerProfileKey);

      if (cachedJson != null) {
        try {
          final map = jsonDecode(cachedJson) as Map<String, dynamic>;
          _profile = BuyerProfileModel.fromJson(map);
        } catch (_) {}
      }

      // Check Supabase Auth and Database
      final user = SupabaseConfig.auth.currentUser;
      if (user != null) {
        String name = _profile.name;
        String email = user.email ?? _profile.email;
        String phone = user.phone ?? _profile.phone;
        String address = _profile.deliveryAddress;
        String hub = _profile.deliveryHub;
        String buyerType = _profile.buyerType;
        List<String> userPrefs = _profile.preferences;

        // 1. Check user_metadata
        final metadata = user.userMetadata;
        if (metadata != null) {
          if (metadata['full_name'] != null &&
              metadata['full_name'].toString().trim().isNotEmpty) {
            name = metadata['full_name'].toString().trim();
          }
          if (metadata['phone'] != null &&
              metadata['phone'].toString().trim().isNotEmpty) {
            phone = metadata['phone'].toString().trim();
          }
          if (metadata['address'] != null &&
              metadata['address'].toString().trim().isNotEmpty) {
            address = metadata['address'].toString().trim();
          }
          if (metadata['hub'] != null &&
              metadata['hub'].toString().trim().isNotEmpty) {
            hub = metadata['hub'].toString().trim();
          }
          if (metadata['buyer_type'] != null &&
              metadata['buyer_type'].toString().trim().isNotEmpty) {
            buyerType = metadata['buyer_type'].toString().trim();
          }
          if (metadata['preferences'] is List) {
            userPrefs = (metadata['preferences'] as List)
                .map((e) => e.toString())
                .toList();
          }
        }

        // 2. Check Supabase profiles table in DB
        try {
          final profileRow = await _dbService.fetchUserProfile(user.id);
          if (profileRow != null) {
            if (profileRow['full_name'] != null &&
                profileRow['full_name'].toString().trim().isNotEmpty) {
              name = profileRow['full_name'].toString().trim();
            }
            if (profileRow['email'] != null &&
                profileRow['email'].toString().trim().isNotEmpty) {
              email = profileRow['email'].toString().trim();
            }
            if (profileRow['phone'] != null &&
                profileRow['phone'].toString().trim().isNotEmpty) {
              phone = profileRow['phone'].toString().trim();
            }
            if (profileRow['location'] != null &&
                profileRow['location'].toString().trim().isNotEmpty) {
              address = profileRow['location'].toString().trim();
            }
          }
        } catch (_) {}

        final shortId = user.id.length >= 4
            ? '#B-${user.id.substring(user.id.length - 4).toUpperCase()}'
            : '#B-0034';

        _profile = _profile.copyWith(
          id: user.id,
          name: name,
          email: email,
          phone: phone,
          deliveryAddress: address,
          deliveryHub: hub,
          buyerType: buyerType,
          preferences: userPrefs,
          buyerCode: shortId,
        );

        await prefs.setString(_kBuyerProfileKey, jsonEncode(_profile.toJson()));
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
        SupabaseConfig.auth.currentUser?.id ??
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

    // Save to Supabase DB if user is available
    final curUser = SupabaseConfig.auth.currentUser;
    if (curUser != null) {
      try {
        await _dbService.upsertUserProfile(
          userId: curUser.id,
          fullName: _profile.name,
          email: _profile.email,
          isFarmer: false,
          phone: _profile.phone,
          location: _profile.deliveryAddress,
        );
      } catch (e) {
        debugPrint('Error upserting DB profile: $e');
      }

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
    }

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

    final user = SupabaseConfig.auth.currentUser;
    if (user != null) {
      try {
        await _dbService.upsertUserProfile(
          userId: user.id,
          fullName: _profile.name,
          email: _profile.email,
          isFarmer: false,
          phone: _profile.phone,
          location: _profile.deliveryAddress,
        );
      } catch (_) {}
    }

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
}
