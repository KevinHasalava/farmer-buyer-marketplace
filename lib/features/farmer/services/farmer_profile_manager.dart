import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../../services/database_service.dart';
import '../models/farmer_profile_model.dart';

class FarmerProfileManager extends ChangeNotifier {
  FarmerProfileManager._internal() {
    loadProfile();
  }

  static final FarmerProfileManager instance = FarmerProfileManager._internal();
  factory FarmerProfileManager() => instance;

  final DatabaseService _dbService = const DatabaseService();

  FarmerProfileModel _profile = FarmerProfileModel.defaultFarmer;
  bool _isLoading = false;

  FarmerProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  static const String _kFarmerProfileKey = 'farmer_profile_cache_v1';

  /// Loads real farmer profile from Supabase DB, Auth userMetadata, and SharedPreferences
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

      // Check Supabase Auth and Database
      final user = SupabaseConfig.auth.currentUser;
      if (user != null) {
        String name = _profile.name;
        String email = user.email ?? _profile.email;
        String phone = user.phone ?? _profile.phone;
        String farmName = _profile.farmName;
        String district = _profile.district;
        String location = _profile.location;
        String role = _profile.role;
        String agrarianCenter = _profile.agrarianCenter;
        String practice = _profile.farmingPractice;
        String scale = _profile.scale;
        String about = _profile.about;
        String yearsExp = _profile.yearsExperience;
        String happyCust = _profile.happyCustomers;
        List<String> crops = _profile.crops;

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
          if (metadata['farm_name'] != null &&
              metadata['farm_name'].toString().trim().isNotEmpty) {
            farmName = metadata['farm_name'].toString().trim();
          }
          if (metadata['district'] != null &&
              metadata['district'].toString().trim().isNotEmpty) {
            district = metadata['district'].toString().trim();
            location = district;
          }
          if (metadata['location'] != null &&
              metadata['location'].toString().trim().isNotEmpty) {
            location = metadata['location'].toString().trim();
          }
          if (metadata['role'] != null &&
              metadata['role'].toString().trim().isNotEmpty) {
            role = metadata['role'].toString().trim();
          }
          if (metadata['agrarian_center'] != null &&
              metadata['agrarian_center'].toString().trim().isNotEmpty) {
            agrarianCenter = metadata['agrarian_center'].toString().trim();
          }
          if (metadata['practice'] != null &&
              metadata['practice'].toString().trim().isNotEmpty) {
            practice = metadata['practice'].toString().trim();
          }
          if (metadata['scale'] != null &&
              metadata['scale'].toString().trim().isNotEmpty) {
            scale = metadata['scale'].toString().trim();
          }
          if (metadata['about'] != null &&
              metadata['about'].toString().trim().isNotEmpty) {
            about = metadata['about'].toString().trim();
          }
          if (metadata['years_experience'] != null &&
              metadata['years_experience'].toString().trim().isNotEmpty) {
            yearsExp = metadata['years_experience'].toString().trim();
          }
          if (metadata['happy_customers'] != null &&
              metadata['happy_customers'].toString().trim().isNotEmpty) {
            happyCust = metadata['happy_customers'].toString().trim();
          }
          if (metadata['crops'] is List) {
            crops = (metadata['crops'] as List).map((e) => e.toString()).toList();
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
              location = profileRow['location'].toString().trim();
              district = location;
            }
          }
        } catch (_) {}

        _profile = _profile.copyWith(
          id: user.id,
          name: name,
          email: email,
          phone: phone,
          farmName: farmName,
          role: role,
          location: location,
          district: district,
          agrarianCenter: agrarianCenter,
          farmingPractice: practice,
          scale: scale,
          about: about,
          yearsExperience: yearsExp,
          happyCustomers: happyCust,
          crops: crops,
        );

        await prefs.setString(_kFarmerProfileKey, jsonEncode(_profile.toJson()));
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
    final curUser = SupabaseConfig.auth.currentUser;
    final effectiveId = curUser?.id ?? 'farmer_${DateTime.now().millisecondsSinceEpoch % 10000}';

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

    // Save to Supabase DB if user is authenticated
    if (curUser != null) {
      try {
        await _dbService.upsertUserProfile(
          userId: curUser.id,
          fullName: _profile.name,
          email: _profile.email,
          isFarmer: true,
          phone: _profile.phone,
          location: _profile.location,
        );
      } catch (e) {
        debugPrint('Error upserting farmer DB profile: $e');
      }

      try {
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
      } catch (_) {}
    }

    notifyListeners();
  }

  /// Updates farmer details and persists to Supabase and cache
  Future<void> updateProfile({
    String? name,
    String? role,
    String? farmName,
    String? location,
    String? district,
    String? phone,
    String? yearsExperience,
    String? happyCustomers,
    String? about,
    String? avatarUrl,
    String? coverUrl,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      role: role,
      farmName: farmName,
      location: location,
      district: district ?? location,
      phone: phone,
      yearsExperience: yearsExperience,
      happyCustomers: happyCustomers,
      about: about,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kFarmerProfileKey, jsonEncode(_profile.toJson()));
    } catch (_) {}

    final user = SupabaseConfig.auth.currentUser;
    if (user != null) {
      try {
        await _dbService.upsertUserProfile(
          userId: user.id,
          fullName: _profile.name,
          email: _profile.email,
          isFarmer: true,
          phone: _profile.phone,
          location: _profile.location,
        );
      } catch (_) {}

      try {
        await SupabaseConfig.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': _profile.name,
              'phone': _profile.phone,
              'farm_name': _profile.farmName,
              'location': _profile.location,
              'role': _profile.role,
              'about': _profile.about,
              'years_experience': _profile.yearsExperience,
              'happy_customers': _profile.happyCustomers,
            },
          ),
        );
      } catch (_) {}
    }

    notifyListeners();
  }
}
