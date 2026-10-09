import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../admin/services/admin_marketplace_service.dart';
import '../models/farmer_profile_model.dart';

class FarmerProfileManager extends ChangeNotifier {
  FarmerProfileManager._internal() {
    loadProfile();
  }

  static final FarmerProfileManager instance = FarmerProfileManager._internal();
  factory FarmerProfileManager() => instance;

  FarmerProfileModel _profile = FarmerProfileModel.defaultFarmer;
  bool _isLoading = false;

  FarmerProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  static const String _kFarmerProfileKey = 'farmer_profile_cache_v1';

  /// Loads farmer profile from local cache and syncs with Supabase if logged in
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_kFarmerProfileKey);

      if (cachedJson != null) {
        try {
          final map = jsonDecode(cachedJson) as Map<String, dynamic>;
          _profile = FarmerProfileModel.fromJson(map);
        } catch (_) {}
      }

      if (SupabaseConfig.isInitialized) {
        final user = SupabaseConfig.auth.currentUser;
        if (user != null) {
          final metadata = user.userMetadata;
          if (metadata != null) {
            _profile = _profile.copyWith(
              id: user.id,
              name: metadata['full_name'] as String? ?? _profile.name,
              phone: metadata['phone'] as String? ?? user.phone ?? _profile.phone,
              email: user.email ?? _profile.email,
              farmName: metadata['farm_name'] as String? ?? _profile.farmName,
              district: metadata['district'] as String? ?? _profile.district,
              location: metadata['location'] as String? ?? _profile.location,
              agrarianCenter: metadata['agrarian_center'] as String? ?? _profile.agrarianCenter,
              scale: metadata['scale'] as String? ?? _profile.scale,
              farmingPractice: metadata['practice'] as String? ?? _profile.farmingPractice,
              avatarUrl: metadata['avatar_url'] as String? ?? _profile.avatarUrl,
            );
          }
          await prefs.setString(_kFarmerProfileKey, jsonEncode(_profile.toJson()));
        }
      }
    } catch (e) {
      debugPrint('Error loading farmer profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called upon Farmer Registration to persist real farmer details
  Future<void> saveRegistrationData({
    required String name,
    required String phone,
    required String farmName,
    required String district,
    required String agrarianCenter,
    required String scale,
    required String practice,
    required List<String> crops,
    String? nic,
    String? bankName,
    String? accountNumber,
    String? email,
  }) async {
    final effectiveId = (SupabaseConfig.isInitialized ? SupabaseConfig.auth.currentUser?.id : null) ??
        'farmer_${DateTime.now().millisecondsSinceEpoch % 10000}';

    _profile = _profile.copyWith(
      id: effectiveId,
      name: name.isNotEmpty ? name : _profile.name,
      phone: phone.isNotEmpty ? phone : _profile.phone,
      email: email?.isNotEmpty == true ? email : _profile.email,
      farmName: farmName.isNotEmpty ? farmName : _profile.farmName,
      location: district.isNotEmpty ? district : _profile.location,
      district: district.isNotEmpty ? district : _profile.district,
      agrarianCenter: agrarianCenter.isNotEmpty ? agrarianCenter : _profile.agrarianCenter,
      scale: scale.isNotEmpty ? scale : _profile.scale,
      farmingPractice: practice.isNotEmpty ? practice : _profile.farmingPractice,
      crops: crops.isNotEmpty ? crops : _profile.crops,
      nic: nic,
      bankName: bankName,
      accountNumber: accountNumber,
    );

    // Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kFarmerProfileKey, jsonEncode(_profile.toJson()));
    } catch (_) {}

    // Save to Supabase if authenticated
    try {
      if (SupabaseConfig.isInitialized && SupabaseConfig.auth.currentUser != null) {
        await SupabaseConfig.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': _profile.name,
              'phone': _profile.phone,
              'farm_name': _profile.farmName,
              'district': _profile.district,
              'location': _profile.location,
              'agrarian_center': _profile.agrarianCenter,
              'scale': _profile.scale,
              'practice': _profile.farmingPractice,
              'crops': _profile.crops,
              'role': 'farmer',
              'is_farmer': true,
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('[FarmerProfileManager] Supabase update note: $e');
    }

    // Two-way synchronization with Admin Panel and remote database
    try {
      AdminMarketplaceService.instance.syncFarmerFromApp(_profile);
    } catch (_) {}

    notifyListeners();
  }

  /// Updates farmer details and persists to Supabase and cache
  Future<void> updateProfile({
    String? name,
    String? role,
    String? farmName,
    String? location,
    String? district,
    String? agrarianCenter,
    String? phone,
    String? email,
    String? yearsExperience,
    String? happyCustomers,
    String? about,
    String? avatarUrl,
    String? coverUrl,
    String? bankName,
    String? accountNumber,
    String? farmingPractice,
    String? scale,
    String? nic,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      role: role,
      farmName: farmName,
      location: location,
      district: district ?? location,
      agrarianCenter: agrarianCenter,
      phone: phone,
      email: email,
      yearsExperience: yearsExperience,
      happyCustomers: happyCustomers,
      about: about,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      bankName: bankName,
      accountNumber: accountNumber,
      farmingPractice: farmingPractice,
      scale: scale,
      nic: nic,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kFarmerProfileKey, jsonEncode(_profile.toJson()));
    } catch (_) {}

    try {
      if (SupabaseConfig.isInitialized && SupabaseConfig.auth.currentUser != null) {
        await SupabaseConfig.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': _profile.name,
              'phone': _profile.phone,
              'farm_name': _profile.farmName,
              'location': _profile.location,
              'district': _profile.district,
              'agrarian_center': _profile.agrarianCenter,
              'role': _profile.role,
              'about': _profile.about,
              'bank_name': _profile.bankName,
              'account_number': _profile.accountNumber,
              'practice': _profile.farmingPractice,
              'scale': _profile.scale,
              'avatar_url': _profile.avatarUrl,
            },
          ),
        );
      }
    } catch (_) {}

    // Two-way synchronization with Admin Panel and remote database
    try {
      AdminMarketplaceService.instance.syncFarmerFromApp(_profile);
    } catch (_) {}

    notifyListeners();
  }
}
