import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../admin/services/admin_marketplace_service.dart';
import '../models/driver_model.dart';
import 'driver_firestore_service.dart';

/// Central profile manager for the Driver role, matching FarmerProfileManager & BuyerProfileManager.
class DriverProfileManager extends ChangeNotifier {
  DriverProfileManager._internal() {
    loadProfile();
  }

  static final DriverProfileManager instance = DriverProfileManager._internal();
  factory DriverProfileManager() => instance;

  static const String _kDriverProfileKey = 'driver_profile_cache_v1';

  static final DriverModel _defaultDriver = DriverModel(
    id: '',
    fullName: 'Driver',
    licenseNumber: '',
    mobileNumber: '',
    vehicleType: 'Delivery Vehicle',
    plateNumber: '',
    cargoCapacity: '1,000 kg',
    isColdBoxEquipped: false,
    operatingCorridors: const [],
    bankName: '',
    accountNumber: '',
    isOnDuty: true,
    rating: 5.0,
    completedTrips: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  DriverModel _driver = _defaultDriver;
  bool _isLoading = false;

  DriverModel get driver => _driver;
  bool get isLoading => _isLoading;

  /// Loads driver profile from local cache and syncs with Supabase if logged in
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_kDriverProfileKey);

      if (cachedJson != null) {
        try {
          final map = jsonDecode(cachedJson) as Map<String, dynamic>;
          _driver = DriverModel.fromMap(map, map['id'] as String? ?? _driver.id);
        } catch (_) {}
      }

      if (SupabaseConfig.isInitialized) {
        final user = SupabaseConfig.auth.currentUser;
        if (user != null) {
          try {
            final profileRow = await SupabaseConfig.client
                .from('profiles')
                .select()
                .eq('id', user.id)
                .maybeSingle();

            final driverRow = await SupabaseConfig.client
                .from('drivers')
                .select()
                .eq('id', user.id)
                .maybeSingle();

            final metadata = user.userMetadata ?? {};
            final pMap = profileRow != null
                ? Map<String, dynamic>.from(profileRow)
                : <String, dynamic>{};
            final dMap = driverRow != null
                ? Map<String, dynamic>.from(driverRow)
                : <String, dynamic>{};

            _driver = _driver.copyWith(
              id: user.id,
              fullName: pMap['full_name'] as String? ??
                  metadata['full_name'] as String? ??
                  _driver.fullName,
              mobileNumber: pMap['phone'] as String? ??
                  metadata['phone'] as String? ??
                  user.phone ??
                  _driver.mobileNumber,
              licenseNumber: dMap['license_number'] as String? ??
                  metadata['license_number'] as String? ??
                  _driver.licenseNumber,
              vehicleType: dMap['vehicle_type'] as String? ??
                  metadata['vehicle_type'] as String? ??
                  _driver.vehicleType,
              plateNumber: dMap['plate_number'] as String? ??
                  metadata['plate_number'] as String? ??
                  _driver.plateNumber,
              cargoCapacity: dMap['cargo_capacity'] as String? ??
                  metadata['cargo_capacity'] as String? ??
                  _driver.cargoCapacity,
              isColdBoxEquipped: dMap['cold_storage'] as bool? ?? _driver.isColdBoxEquipped,
              isOnDuty: dMap['duty_status'] as bool? ?? _driver.isOnDuty,
              rating: (dMap['rating'] as num?)?.toDouble() ?? _driver.rating,
              completedTrips: (dMap['trips_completed'] as num?)?.toInt() ?? _driver.completedTrips,
            );
          } catch (e) {
            debugPrint('[DriverProfileManager] Supabase fetch error: $e');
          }
          await prefs.setString(_kDriverProfileKey, jsonEncode(_driver.toMap()));
        }
      }
    } catch (e) {
      debugPrint('[DriverProfileManager] Error loading driver profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called upon Driver Registration to persist real driver details
  Future<void> saveRegistrationData({
    required String name,
    required String phone,
    String? licenseNumber,
    String? plateNumber,
    String? vehicleType,
    String? capacity,
    String? bankName,
    String? accountNumber,
  }) async {
    final effectiveId = (SupabaseConfig.isInitialized ? SupabaseConfig.auth.currentUser?.id : null) ??
        'drv_${DateTime.now().millisecondsSinceEpoch % 10000}';

    _driver = _driver.copyWith(
      id: effectiveId,
      fullName: name.isNotEmpty ? name : _driver.fullName,
      mobileNumber: phone.isNotEmpty ? phone : _driver.mobileNumber,
      licenseNumber: (licenseNumber != null && licenseNumber.isNotEmpty)
          ? licenseNumber
          : _driver.licenseNumber,
      plateNumber: (plateNumber != null && plateNumber.isNotEmpty)
          ? plateNumber
          : _driver.plateNumber,
      vehicleType: (vehicleType != null && vehicleType.isNotEmpty)
          ? vehicleType
          : _driver.vehicleType,
      cargoCapacity: (capacity != null && capacity.isNotEmpty)
          ? capacity
          : _driver.cargoCapacity,
      bankName: (bankName != null && bankName.isNotEmpty)
          ? bankName
          : _driver.bankName,
      accountNumber: (accountNumber != null && accountNumber.isNotEmpty)
          ? accountNumber
          : _driver.accountNumber,
      updatedAt: DateTime.now(),
    );

    // Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kDriverProfileKey, jsonEncode(_driver.toMap()));
    } catch (_) {}

    // Register with DriverFirestoreService
    try {
      await DriverFirestoreService().registerDriver(_driver);
    } catch (_) {}

    // Sync to Supabase user metadata
    try {
      if (SupabaseConfig.isInitialized && SupabaseConfig.auth.currentUser != null) {
        await SupabaseConfig.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': _driver.fullName,
              'phone': _driver.mobileNumber,
              'license_number': _driver.licenseNumber,
              'plate_number': _driver.plateNumber,
              'vehicle_type': _driver.vehicleType,
              'cargo_capacity': _driver.cargoCapacity,
              'bank_name': _driver.bankName,
              'account_number': _driver.accountNumber,
              'role': 'driver',
              'is_driver': true,
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('[DriverProfileManager] Supabase update note: $e');
    }

    // Two-way synchronization with Admin Panel and remote database
    try {
      AdminMarketplaceService.instance.syncDriverFromApp(_driver);
    } catch (_) {}

    notifyListeners();
  }

  /// Updates driver details and persists locally & remotely
  Future<void> updateProfile({
    String? fullName,
    String? mobileNumber,
    String? licenseNumber,
    String? plateNumber,
    String? vehicleType,
    String? cargoCapacity,
    String? bankName,
    String? accountNumber,
  }) async {
    _driver = _driver.copyWith(
      fullName: (fullName != null && fullName.isNotEmpty) ? fullName : _driver.fullName,
      mobileNumber: (mobileNumber != null && mobileNumber.isNotEmpty) ? mobileNumber : _driver.mobileNumber,
      licenseNumber: (licenseNumber != null && licenseNumber.isNotEmpty) ? licenseNumber : _driver.licenseNumber,
      plateNumber: (plateNumber != null && plateNumber.isNotEmpty) ? plateNumber : _driver.plateNumber,
      vehicleType: (vehicleType != null && vehicleType.isNotEmpty) ? vehicleType : _driver.vehicleType,
      cargoCapacity: (cargoCapacity != null && cargoCapacity.isNotEmpty) ? cargoCapacity : _driver.cargoCapacity,
      bankName: (bankName != null && bankName.isNotEmpty) ? bankName : _driver.bankName,
      accountNumber: (accountNumber != null && accountNumber.isNotEmpty) ? accountNumber : _driver.accountNumber,
      updatedAt: DateTime.now(),
    );

    // Save locally
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kDriverProfileKey, jsonEncode(_driver.toMap()));
    } catch (_) {}

    // Update in DriverFirestoreService
    try {
      await DriverFirestoreService().registerDriver(_driver);
    } catch (_) {}

    // Sync to Supabase metadata
    try {
      if (SupabaseConfig.isInitialized && SupabaseConfig.auth.currentUser != null) {
        await SupabaseConfig.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': _driver.fullName,
              'phone': _driver.mobileNumber,
              'license_number': _driver.licenseNumber,
              'plate_number': _driver.plateNumber,
              'vehicle_type': _driver.vehicleType,
              'cargo_capacity': _driver.cargoCapacity,
              'bank_name': _driver.bankName,
              'account_number': _driver.accountNumber,
              'role': 'driver',
              'is_driver': true,
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('[DriverProfileManager] Supabase update note: $e');
    }

    // Two-way synchronization with Admin Panel and remote database
    try {
      AdminMarketplaceService.instance.syncDriverFromApp(_driver);
    } catch (_) {}

    notifyListeners();
  }
}
