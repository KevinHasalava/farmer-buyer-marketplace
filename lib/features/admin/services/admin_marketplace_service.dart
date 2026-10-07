import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../buyer/models/buyer_profile_model.dart';
import '../../buyer/services/buyer_profile_manager.dart';
import '../../driver/models/driver_model.dart';
import '../../driver/services/driver_profile_manager.dart';
import '../../farmer/models/farmer_profile_model.dart';
import '../../farmer/services/farmer_profile_manager.dart';
import '../models/admin_models.dart';

/// Central Marketplace Admin Service managing full CRUD state across all portals
/// Integrates Supabase Database with Offline-First Local Cache & Real-time Profile Synchronization
class AdminMarketplaceService extends ChangeNotifier {
  AdminMarketplaceService._internal() {
    init();
  }

  static final AdminMarketplaceService instance =
      AdminMarketplaceService._internal();
  factory AdminMarketplaceService() => instance;

  static const String _kFarmersKey = 'admin_farmers_cache_v1';
  static const String _kBuyersKey = 'admin_buyers_cache_v1';
  static const String _kDriversKey = 'admin_drivers_cache_v1';
  static const String _kProductsKey = 'admin_products_cache_v1';
  static const String _kOrdersKey = 'admin_orders_cache_v1';

  final List<AdminFarmerModel> _farmers = [];
  final List<AdminBuyerModel> _buyers = [];
  final List<AdminDriverModel> _drivers = [];
  final List<AdminProductModel> _products = [];
  final List<AdminOrderModel> _orders = [];

  bool _isInitialized = false;

  List<AdminFarmerModel> get farmers => List.unmodifiable(_farmers);
  List<AdminBuyerModel> get buyers => List.unmodifiable(_buyers);
  List<AdminDriverModel> get drivers => List.unmodifiable(_drivers);
  List<AdminProductModel> get products => List.unmodifiable(_products);
  List<AdminOrderModel> get orders => List.unmodifiable(_orders);

  // ── Statistics Getters ───────────────────────────────────────────────────
  int get totalFarmers => _farmers.length;
  int get totalBuyers => _buyers.length;
  int get totalDrivers => _drivers.length;
  int get totalProducts => _products.length;
  int get totalOrders => _orders.length;

  int get activeFarmersCount =>
      _farmers.where((f) => f.status == 'Active').length;
  int get onDutyDriversCount => _drivers.where((d) => d.isOnDuty).length;
  int get pendingOrdersCount =>
      _orders.where((o) => o.status == 'Pending').length;
  int get inTransitOrdersCount =>
      _orders.where((o) => o.status == 'In Transit').length;

  double get totalRevenue =>
      _orders.fold(0.0, (sum, o) => sum + o.totalAmount);

  /// Safe accessor to Supabase client
  SupabaseClient? get _sb {
    try {
      if (SupabaseConfig.isInitialized) {
        return SupabaseConfig.client;
      }
    } catch (_) {}
    return null;
  }

  // ── Initialization & Persistence ─────────────────────────────────────────
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Load Farmers from local cache or seed
      final farmersJson = prefs.getString(_kFarmersKey);
      if (farmersJson != null) {
        final list = jsonDecode(farmersJson) as List<dynamic>;
        _farmers.clear();
        _farmers.addAll(
            list.map((m) => AdminFarmerModel.fromMap(m as Map<String, dynamic>)));
      } else {
        _seedDefaultFarmers();
      }

      // 2. Load Buyers from local cache or seed
      final buyersJson = prefs.getString(_kBuyersKey);
      if (buyersJson != null) {
        final list = jsonDecode(buyersJson) as List<dynamic>;
        _buyers.clear();
        _buyers.addAll(
            list.map((m) => AdminBuyerModel.fromMap(m as Map<String, dynamic>)));
      } else {
        _seedDefaultBuyers();
      }

      // 3. Load Drivers from local cache or seed
      final driversJson = prefs.getString(_kDriversKey);
      if (driversJson != null) {
        final list = jsonDecode(driversJson) as List<dynamic>;
        _drivers.clear();
        _drivers.addAll(
            list.map((m) => AdminDriverModel.fromMap(m as Map<String, dynamic>)));
      } else {
        _seedDefaultDrivers();
      }

      // 4. Load Products from local cache or seed
      final productsJson = prefs.getString(_kProductsKey);
      if (productsJson != null) {
        final list = jsonDecode(productsJson) as List<dynamic>;
        _products.clear();
        _products.addAll(
            list.map((m) => AdminProductModel.fromMap(m as Map<String, dynamic>)));
      } else {
        _seedDefaultProducts();
      }

      // 5. Load Orders from local cache or seed
      final ordersJson = prefs.getString(_kOrdersKey);
      if (ordersJson != null) {
        final list = jsonDecode(ordersJson) as List<dynamic>;
        _orders.clear();
        _orders.addAll(
            list.map((m) => AdminOrderModel.fromMap(m as Map<String, dynamic>)));
      } else {
        _seedDefaultOrders();
      }

      _syncActiveAppProfiles();
      _isInitialized = true;
      notifyListeners();

      // Trigger asynchronous Two-Way Supabase Database Sync in background
      _syncWithSupabaseDatabase();
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Init note: $e');
      _seedDefaultFarmers();
      _seedDefaultBuyers();
      _seedDefaultDrivers();
      _seedDefaultProducts();
      _seedDefaultOrders();
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Public method to manually trigger real-time database synchronization from the Admin UI
  Future<void> refreshDatabaseSync() async {
    await _syncWithSupabaseDatabase();
    _syncActiveAppProfiles();
    notifyListeners();
  }

  /// Synchronize with remote Supabase Database tables
  Future<void> _syncWithSupabaseDatabase() async {
    final client = _sb;
    if (client == null) return;

    try {
      // 1. Sync Farmers Table (if table exists)
      try {
        final remoteFarmers = await client.from('farmers').select();
        if (remoteFarmers.isNotEmpty) {
          for (final row in remoteFarmers) {
            final farmer = AdminFarmerModel.fromMap(Map<String, dynamic>.from(row));
            final idx = _farmers.indexWhere((f) => f.id == farmer.id || f.phone == farmer.phone);
            if (idx >= 0) {
              _farmers[idx] = farmer;
            } else {
              _farmers.add(farmer);
            }
          }
        }
      } catch (e) {
        debugPrint('[AdminMarketplaceService] farmers table sync note: $e');
      }

      // 2. Sync Buyers Table (if table exists)
      try {
        final remoteBuyers = await client.from('buyers').select();
        if (remoteBuyers.isNotEmpty) {
          for (final row in remoteBuyers) {
            final buyer = AdminBuyerModel.fromMap(Map<String, dynamic>.from(row));
            final idx = _buyers.indexWhere((b) => b.id == buyer.id || b.phone == buyer.phone);
            if (idx >= 0) {
              _buyers[idx] = buyer;
            } else {
              _buyers.add(buyer);
            }
          }
        }
      } catch (e) {
        debugPrint('[AdminMarketplaceService] buyers table sync note: $e');
      }

      // 3. Sync Drivers Table (Live in Supabase)
      try {
        final remoteDrivers = await client.from('drivers').select();
        if (remoteDrivers.isNotEmpty) {
          for (final row in remoteDrivers) {
            final driver = AdminDriverModel.fromMap(Map<String, dynamic>.from(row));
            final idx = _drivers.indexWhere((d) => d.id == driver.id || d.phone == driver.phone);
            if (idx >= 0) {
              _drivers[idx] = driver;
            } else {
              _drivers.add(driver);
            }
          }
          debugPrint('[AdminMarketplaceService] Synced ${_drivers.length} drivers from Supabase.');
        }
      } catch (e) {
        debugPrint('[AdminMarketplaceService] drivers table sync note: $e');
      }

      // 4. Sync Products Table (if table exists)
      try {
        final remoteProducts = await client.from('products').select();
        if (remoteProducts.isNotEmpty) {
          for (final row in remoteProducts) {
            final prod = AdminProductModel.fromMap(Map<String, dynamic>.from(row));
            final idx = _products.indexWhere((p) => p.id == prod.id);
            if (idx >= 0) {
              _products[idx] = prod;
            } else {
              _products.add(prod);
            }
          }
        }
      } catch (e) {
        debugPrint('[AdminMarketplaceService] products table sync note: $e');
      }

      // 5. Sync Orders from driver_deliveries (Live in Supabase) and orders table
      try {
        final remoteDeliveries = await client.from('driver_deliveries').select();
        if (remoteDeliveries.isNotEmpty) {
          for (final row in remoteDeliveries) {
            final order = AdminOrderModel.fromMap(Map<String, dynamic>.from(row));
            final idx = _orders.indexWhere((o) =>
                o.id == order.id ||
                o.id == '#${order.id}' ||
                o.id.replaceAll('#', '') == order.id.replaceAll('#', ''));
            if (idx >= 0) {
              _orders[idx] = order;
            } else {
              _orders.insert(0, order);
            }
          }
          debugPrint('[AdminMarketplaceService] Synced deliveries from Supabase driver_deliveries.');
        }
      } catch (e) {
        debugPrint('[AdminMarketplaceService] driver_deliveries table sync note: $e');
      }

      try {
        final remoteOrders = await client.from('orders').select();
        if (remoteOrders.isNotEmpty) {
          for (final row in remoteOrders) {
            final order = AdminOrderModel.fromMap(Map<String, dynamic>.from(row));
            final idx = _orders.indexWhere((o) => o.id == order.id);
            if (idx >= 0) {
              _orders[idx] = order;
            } else {
              _orders.insert(0, order);
            }
          }
        }
      } catch (_) {}

      await _saveAll();
      notifyListeners();
      debugPrint('[AdminMarketplaceService] Supabase Database synchronization complete.');
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase general sync note: $e');
    }
  }

  /// Syncs currently logged-in user profile from each manager into admin listings
  void _syncActiveAppProfiles() {
    // 1. Farmer profile sync
    final farmerProfile = FarmerProfileManager.instance.profile;
    if (farmerProfile.name.isNotEmpty) {
      syncFarmerFromApp(farmerProfile);
    }

    // 2. Buyer profile sync
    final buyerProfile = BuyerProfileManager.instance.profile;
    if (buyerProfile.name.isNotEmpty) {
      syncBuyerFromApp(buyerProfile);
    }

    // 3. Driver profile sync
    final driverModel = DriverProfileManager.instance.driver;
    if (driverModel.fullName.isNotEmpty) {
      syncDriverFromApp(driverModel);
    }
  }

  /// Bridge: Called when a Farmer registers or updates their profile in the app
  Future<void> syncFarmerFromApp(FarmerProfileModel farmerProfile) async {
    final index = _farmers.indexWhere((f) => f.phone == farmerProfile.phone);
    final farmerData = AdminFarmerModel(
      id: farmerProfile.id.isNotEmpty ? farmerProfile.id : 'FRM-001',
      name: farmerProfile.name,
      phone: farmerProfile.phone.isNotEmpty ? farmerProfile.phone : '+94763238225',
      farmName: farmerProfile.farmName,
      district: farmerProfile.district,
      agrarianCenter: farmerProfile.agrarianCenter,
      scale: farmerProfile.scale,
      practice: farmerProfile.farmingPractice,
      crops: farmerProfile.crops,
      nic: farmerProfile.nic ?? '',
      bankName: farmerProfile.bankName ?? 'Commercial Bank',
      accountNumber: farmerProfile.accountNumber ?? '',
      isVerified: farmerProfile.isVerified,
      status: 'Active',
      registeredAt: DateTime.now().subtract(const Duration(days: 4)),
    );

    if (index >= 0) {
      _farmers[index] = farmerData;
    } else {
      _farmers.insert(0, farmerData);
    }
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('farmers').upsert(farmerData.toMap());
      }
    } catch (_) {}
  }

  /// Bridge: Called when a Buyer registers or updates their profile in the app
  Future<void> syncBuyerFromApp(BuyerProfileModel buyerProfile) async {
    final index = _buyers.indexWhere((b) => b.phone == buyerProfile.phone);
    final buyerData = AdminBuyerModel(
      id: buyerProfile.id.isNotEmpty ? buyerProfile.id : 'BYR-001',
      name: buyerProfile.name,
      email: buyerProfile.email.isNotEmpty ? buyerProfile.email : 'buyer@farm2home.lk',
      phone: buyerProfile.phone.isNotEmpty ? buyerProfile.phone : '+94771234567',
      address: buyerProfile.deliveryAddress,
      hub: buyerProfile.deliveryHub,
      buyerType: buyerProfile.buyerType,
      totalOrders: 3,
      totalSpent: 8450.0,
      status: 'Active',
      registeredAt: DateTime.now().subtract(const Duration(days: 2)),
    );

    if (index >= 0) {
      _buyers[index] = buyerData;
    } else {
      _buyers.insert(0, buyerData);
    }
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('buyers').upsert(buyerData.toMap());
      }
    } catch (_) {}
  }

  /// Bridge: Called when a Driver registers or updates their profile in the app
  Future<void> syncDriverFromApp(DriverModel driverModel) async {
    final index = _drivers.indexWhere((d) => d.id == driverModel.id || (driverModel.mobileNumber.isNotEmpty && d.phone == driverModel.mobileNumber));
    final driverData = AdminDriverModel(
      id: driverModel.id.isNotEmpty ? driverModel.id : 'DRV-001',
      name: driverModel.fullName,
      phone: driverModel.mobileNumber.isNotEmpty ? driverModel.mobileNumber : '+94771234567',
      licenseNumber: driverModel.licenseNumber,
      vehicleType: driverModel.vehicleType,
      plateNumber: driverModel.plateNumber,
      cargoCapacity: driverModel.cargoCapacity,
      bankName: driverModel.bankName,
      accountNumber: driverModel.accountNumber,
      isOnDuty: driverModel.isOnDuty,
      completedTrips: driverModel.completedTrips,
      rating: driverModel.rating,
      status: 'Active',
      registeredAt: driverModel.createdAt,
    );

    if (index >= 0) {
      _drivers[index] = driverData;
    } else {
      _drivers.insert(0, driverData);
    }
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('drivers').upsert(driverData.toMap());
      }
    } catch (_) {}
  }

  Future<void> _saveAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kFarmersKey, jsonEncode(_farmers.map((e) => e.toMap()).toList()));
      await prefs.setString(
          _kBuyersKey, jsonEncode(_buyers.map((e) => e.toMap()).toList()));
      await prefs.setString(
          _kDriversKey, jsonEncode(_drivers.map((e) => e.toMap()).toList()));
      await prefs.setString(
          _kProductsKey, jsonEncode(_products.map((e) => e.toMap()).toList()));
      await prefs.setString(
          _kOrdersKey, jsonEncode(_orders.map((e) => e.toMap()).toList()));
    } catch (_) {}
  }

  // =========================================================================
  // 🌾 1. FARMERS CRUD OPERATIONS (LOCAL + SUPABASE)
  // =========================================================================
  Future<void> addFarmer(AdminFarmerModel farmer) async {
    _farmers.insert(0, farmer);
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('farmers').upsert(farmer.toSupabaseMap());
        debugPrint('[AdminMarketplaceService] Farmer added to Supabase: ${farmer.id}');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase addFarmer note: $e');
    }
  }

  Future<void> updateFarmer(AdminFarmerModel farmer) async {
    final idx = _farmers.indexWhere((f) => f.id == farmer.id);
    if (idx >= 0) {
      _farmers[idx] = farmer;
      await _saveAll();
      notifyListeners();
    }

    try {
      final client = _sb;
      if (client != null) {
        await client.from('farmers').upsert(farmer.toSupabaseMap());
        debugPrint('[AdminMarketplaceService] Farmer updated in Supabase: ${farmer.id}');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase updateFarmer note: $e');
    }
  }

  Future<void> deleteFarmer(String id) async {
    _farmers.removeWhere((f) => f.id == id);
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('farmers').delete().eq('id', id);
        debugPrint('[AdminMarketplaceService] Farmer deleted from Supabase: $id');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase deleteFarmer note: $e');
    }
  }

  Future<void> toggleFarmerVerification(String id) async {
    final idx = _farmers.indexWhere((f) => f.id == id);
    if (idx >= 0) {
      final cur = _farmers[idx];
      final updated = cur.copyWith(
        isVerified: !cur.isVerified,
        status: !cur.isVerified ? 'Active' : 'Pending Verification',
      );
      _farmers[idx] = updated;
      await _saveAll();
      notifyListeners();

      try {
        final client = _sb;
        if (client != null) {
          await client.from('farmers').upsert(updated.toSupabaseMap());
        }
      } catch (_) {}
    }
  }

  // =========================================================================
  // 🛒 2. BUYERS CRUD OPERATIONS (LOCAL + SUPABASE)
  // =========================================================================
  Future<void> addBuyer(AdminBuyerModel buyer) async {
    _buyers.insert(0, buyer);
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('buyers').upsert(buyer.toSupabaseMap());
        debugPrint('[AdminMarketplaceService] Buyer added to Supabase: ${buyer.id}');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase addBuyer note: $e');
    }
  }

  Future<void> updateBuyer(AdminBuyerModel buyer) async {
    final idx = _buyers.indexWhere((b) => b.id == buyer.id);
    if (idx >= 0) {
      _buyers[idx] = buyer;
      await _saveAll();
      notifyListeners();
    }

    try {
      final client = _sb;
      if (client != null) {
        await client.from('buyers').upsert(buyer.toSupabaseMap());
        debugPrint('[AdminMarketplaceService] Buyer updated in Supabase: ${buyer.id}');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase updateBuyer note: $e');
    }
  }

  Future<void> deleteBuyer(String id) async {
    _buyers.removeWhere((b) => b.id == id);
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('buyers').delete().eq('id', id);
        debugPrint('[AdminMarketplaceService] Buyer deleted from Supabase: $id');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase deleteBuyer note: $e');
    }
  }

  Future<void> toggleBuyerStatus(String id) async {
    final idx = _buyers.indexWhere((b) => b.id == id);
    if (idx >= 0) {
      final cur = _buyers[idx];
      final newStatus = cur.status == 'Active' ? 'Suspended' : 'Active';
      final updated = cur.copyWith(status: newStatus);
      _buyers[idx] = updated;
      await _saveAll();
      notifyListeners();

      try {
        final client = _sb;
        if (client != null) {
          await client.from('buyers').upsert(updated.toSupabaseMap());
        }
      } catch (_) {}
    }
  }

  // =========================================================================
  // 🚚 3. DRIVERS & FLEET CRUD OPERATIONS (LOCAL + SUPABASE)
  // =========================================================================
  Future<void> addDriver(AdminDriverModel driver) async {
    _drivers.insert(0, driver);
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('drivers').upsert(driver.toSupabaseMap());
        debugPrint('[AdminMarketplaceService] Driver added to Supabase: ${driver.id}');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase addDriver note: $e');
    }
  }

  Future<void> updateDriver(AdminDriverModel driver) async {
    final idx = _drivers.indexWhere((d) => d.id == driver.id);
    if (idx >= 0) {
      _drivers[idx] = driver;
      await _saveAll();
      notifyListeners();
    }

    try {
      final client = _sb;
      if (client != null) {
        await client.from('drivers').upsert(driver.toSupabaseMap());
        debugPrint('[AdminMarketplaceService] Driver updated in Supabase: ${driver.id}');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase updateDriver note: $e');
    }
  }

  Future<void> deleteDriver(String id) async {
    _drivers.removeWhere((d) => d.id == id);
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('drivers').delete().eq('id', id);
        debugPrint('[AdminMarketplaceService] Driver deleted from Supabase: $id');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase deleteDriver note: $e');
    }
  }

  Future<void> toggleDriverDuty(String id) async {
    final idx = _drivers.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      final cur = _drivers[idx];
      final updated = cur.copyWith(isOnDuty: !cur.isOnDuty);
      _drivers[idx] = updated;
      await _saveAll();
      notifyListeners();

      try {
        final client = _sb;
        if (client != null) {
          await client.from('drivers').upsert(updated.toSupabaseMap());
        }
      } catch (_) {}
    }
  }

  // =========================================================================
  // 🥦 4. MARKETPLACE PRODUCTS CRUD OPERATIONS (LOCAL + SUPABASE)
  // =========================================================================
  Future<void> addProduct(AdminProductModel product) async {
    _products.insert(0, product);
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('products').upsert(product.toSupabaseMap());
        debugPrint('[AdminMarketplaceService] Product added to Supabase: ${product.id}');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase addProduct note: $e');
    }
  }

  Future<void> updateProduct(AdminProductModel product) async {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _products[idx] = product;
      await _saveAll();
      notifyListeners();
    }

    try {
      final client = _sb;
      if (client != null) {
        await client.from('products').upsert(product.toSupabaseMap());
        debugPrint('[AdminMarketplaceService] Product updated in Supabase: ${product.id}');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase updateProduct note: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        await client.from('products').delete().eq('id', id);
        debugPrint('[AdminMarketplaceService] Product deleted from Supabase: $id');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase deleteProduct note: $e');
    }
  }

  // =========================================================================
  // 📦 5. ORDERS & DISPATCH CRUD OPERATIONS (LOCAL + SUPABASE)
  // =========================================================================
  Future<void> addOrder(AdminOrderModel order) async {
    _orders.insert(0, order);
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        // Upsert to Supabase live deliveries table
        await client.from('driver_deliveries').upsert(order.toDeliveryMap());
        try {
          await client.from('orders').upsert(order.toSupabaseMap());
        } catch (_) {}
        debugPrint('[AdminMarketplaceService] Order added to Supabase: ${order.id}');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase addOrder note: $e');
    }
  }

  Future<void> updateOrder(AdminOrderModel order) async {
    final idx = _orders.indexWhere((o) => o.id == order.id);
    if (idx >= 0) {
      _orders[idx] = order;
      await _saveAll();
      notifyListeners();
    }

    try {
      final client = _sb;
      if (client != null) {
        await client.from('driver_deliveries').upsert(order.toDeliveryMap());
        try {
          await client.from('orders').upsert(order.toSupabaseMap());
        } catch (_) {}
        debugPrint('[AdminMarketplaceService] Order updated in Supabase: ${order.id}');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase updateOrder note: $e');
    }
  }

  Future<void> updateOrderStatus(String id, String newStatus) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      final updated = _orders[idx].copyWith(status: newStatus);
      _orders[idx] = updated;
      await _saveAll();
      notifyListeners();

      try {
        final client = _sb;
        if (client != null) {
          final cleanId = id.replaceAll('#', '').trim();
          await client.from('driver_deliveries').update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', cleanId);
          try {
            await client.from('orders').update({
              'status': newStatus,
            }).eq('id', id);
          } catch (_) {}
        }
      } catch (_) {}
    }
  }

  Future<void> assignDriverToOrder(
      String orderId, String driverName, String driverPhone) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final updated = _orders[idx].copyWith(
        assignedDriverName: driverName,
        assignedDriverPhone: driverPhone,
        status: 'In Transit',
      );
      _orders[idx] = updated;
      await _saveAll();
      notifyListeners();

      try {
        final client = _sb;
        if (client != null) {
          final cleanId = orderId.replaceAll('#', '').trim();
          await client.from('driver_deliveries').update({
            'status': 'In Transit',
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', cleanId);
          try {
            await client.from('orders').update({
              'assigned_driver_name': driverName,
              'assigned_driver_phone': driverPhone,
              'status': 'In Transit',
            }).eq('id', orderId);
          } catch (_) {}
        }
      } catch (_) {}
    }
  }

  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
    await _saveAll();
    notifyListeners();

    try {
      final client = _sb;
      if (client != null) {
        final cleanId = id.replaceAll('#', '').trim();
        try {
          await client.from('driver_deliveries').delete().eq('id', cleanId);
        } catch (_) {}
        try {
          await client.from('orders').delete().eq('id', id);
        } catch (_) {}
        debugPrint('[AdminMarketplaceService] Order deleted from Supabase: $id');
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] Supabase deleteOrder note: $e');
    }
  }

  // =========================================================================
  // 🔍 SEEDING REALISTIC SRI LANKAN DATA
  // =========================================================================
  void _seedDefaultFarmers() {
    _farmers.clear();
    _farmers.addAll([
      AdminFarmerModel(
        id: 'FRM-101',
        name: 'Sunil Shantha Perera',
        phone: '+94763238225',
        farmName: 'Hakgala Organic Highlands',
        district: 'Nuwara Eliya',
        agrarianCenter: 'Hakgala Agrarian Center',
        scale: '2 - 3 Acres',
        practice: 'Certified Organic (SL-GAP)',
        crops: const ['Carrots', 'Leeks', 'Highland Potatoes'],
        nic: '197829401928',
        bankName: 'Commercial Bank of Ceylon',
        accountNumber: '8004129381',
        isVerified: true,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AdminFarmerModel(
        id: 'FRM-102',
        name: 'K. M. Bandara',
        phone: '+94778192014',
        farmName: 'Ambewela Green Valley Farm',
        district: 'Nuwara Eliya',
        agrarianCenter: 'Nuwara Eliya Central',
        scale: '3 - 5 Acres',
        practice: 'Chemical-Free Natural',
        crops: const ['Cabbage', 'Beetroot', 'Strawberries'],
        nic: '198420194812',
        bankName: 'Bank of Ceylon',
        accountNumber: '00392019481',
        isVerified: true,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 24)),
      ),
      AdminFarmerModel(
        id: 'FRM-103',
        name: 'Dharmasena Senanayake',
        phone: '+94719482019',
        farmName: 'Dambulla Agro Bio Fields',
        district: 'Matale',
        agrarianCenter: 'Dambulla Agro Center',
        scale: '5+ Acres',
        practice: 'Conventional GAP',
        crops: const ['Tomatoes', 'Green Chillies', 'Capsicum'],
        nic: '196929401948',
        bankName: 'People\'s Bank',
        accountNumber: '294019481029',
        isVerified: false,
        status: 'Pending Verification',
        registeredAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }

  void _seedDefaultBuyers() {
    _buyers.clear();
    _buyers.addAll([
      AdminBuyerModel(
        id: 'BYR-201',
        name: 'Chaminda Perera',
        email: 'chaminda@gmail.com',
        phone: '+94771234567',
        address: 'No 45, Flower Road, Colombo 07',
        hub: 'Colombo Regional Hub (Western)',
        buyerType: 'Family / Household',
        totalOrders: 6,
        totalSpent: 18450.0,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      AdminBuyerModel(
        id: 'BYR-202',
        name: 'Cinnamon Grand Hospitality',
        email: 'procurement@cinnamonhotels.lk',
        phone: '+94112497300',
        address: '77 Galle Road, Colombo 03',
        hub: 'Colombo Central Regional Hub',
        buyerType: 'Restaurant & Hospitality',
        totalOrders: 28,
        totalSpent: 342500.0,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      AdminBuyerModel(
        id: 'BYR-203',
        name: 'Good Market Organic Store',
        email: 'supply@goodmarket.lk',
        phone: '+94777129840',
        address: 'Philip Gunewardena Mawatha, Colombo 07',
        hub: 'Colombo Regional Hub (Western)',
        buyerType: 'Retail Organic Store',
        totalOrders: 14,
        totalSpent: 96200.0,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
    ]);
  }

  void _seedDefaultDrivers() {
    _drivers.clear();
    _drivers.addAll([
      AdminDriverModel(
        id: 'DRV-301',
        name: 'Ranjith Subha Udhasanak',
        phone: '+94771234567',
        licenseNumber: 'B-8492019',
        vehicleType: 'Chilled / Refrigerated Van',
        plateNumber: 'WP NC-4982',
        cargoCapacity: '1,200 kg',
        bankName: 'Commercial Bank of Ceylon',
        accountNumber: '8004 1293 4198',
        isOnDuty: true,
        completedTrips: 184,
        rating: 4.95,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 70)),
      ),
      AdminDriverModel(
        id: 'DRV-302',
        name: 'Samantha Jayawardena',
        phone: '+94718491029',
        licenseNumber: 'B-9201842',
        vehicleType: 'Insulated High-Roof Truck',
        plateNumber: 'CP LY-3819',
        cargoCapacity: '2,500 kg',
        bankName: 'Bank of Ceylon',
        accountNumber: '10924810294',
        isOnDuty: true,
        completedTrips: 92,
        rating: 4.88,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      AdminDriverModel(
        id: 'DRV-303',
        name: 'Priyashantha Kumara',
        phone: '+94769201847',
        licenseNumber: 'B-3829104',
        vehicleType: 'Standard Cargo Van',
        plateNumber: 'WP DA-8291',
        cargoCapacity: '950 kg',
        bankName: 'Hatton National Bank',
        accountNumber: '02910481029',
        isOnDuty: false,
        completedTrips: 45,
        rating: 4.75,
        status: 'On Standby',
        registeredAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ]);
  }

  void _seedDefaultProducts() {
    _products.clear();
    _products.addAll([
      AdminProductModel(
        id: 'PRD-401',
        name: 'Hakgala Sweet Carrots',
        category: 'Root Vegetables',
        price: 260.0,
        unit: '/kg',
        availableQty: 180.0,
        farmName: 'Hakgala Organic Highlands',
        farmerName: 'Sunil Shantha Perera',
        isOrganic: true,
        imageUrl:
            'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&auto=format&fit=crop&q=80',
        description: 'Fresh crisp highland carrots cultivated at 2,000m altitude.',
        status: 'In Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      AdminProductModel(
        id: 'PRD-402',
        name: 'Highland Leeks (Grade A)',
        category: 'Leafy Greens',
        price: 220.0,
        unit: '/kg',
        availableQty: 120.0,
        farmName: 'Hakgala Organic Highlands',
        farmerName: 'Sunil Shantha Perera',
        isOrganic: true,
        imageUrl:
            'https://images.unsplash.com/photo-1590779033100-9f60a05a013d?w=500&auto=format&fit=crop&q=80',
        description: 'Tender leeks harvested fresh with organic certification.',
        status: 'In Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      AdminProductModel(
        id: 'PRD-403',
        name: 'Ambewela Fresh Strawberries',
        category: 'Highland Fruits',
        price: 850.0,
        unit: '/pack',
        availableQty: 40.0,
        farmName: 'Ambewela Green Valley Farm',
        farmerName: 'K. M. Bandara',
        isOrganic: true,
        imageUrl:
            'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500&auto=format&fit=crop&q=80',
        description: 'Sweet luscious strawberries freshly packed in chilled cartons.',
        status: 'Low Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AdminProductModel(
        id: 'PRD-404',
        name: 'Dambulla Ripe Tomatoes',
        category: 'Vegetables',
        price: 180.0,
        unit: '/kg',
        availableQty: 350.0,
        farmName: 'Dambulla Agro Bio Fields',
        farmerName: 'Dharmasena Senanayake',
        isOrganic: false,
        imageUrl:
            'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80',
        description: 'Plump sun-ripened tomatoes ideal for restaurants and households.',
        status: 'In Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }

  void _seedDefaultOrders() {
    _orders.clear();
    _orders.addAll([
      AdminOrderModel(
        id: 'FH-8841',
        customerName: 'Chaminda Perera',
        customerPhone: '+94771234567',
        farmName: 'Hakgala Organic Highlands',
        itemsSummary: '10 kg Carrots, 5 kg Leeks',
        totalAmount: 3700.0,
        status: 'In Transit',
        deliveryAddress: 'No 45, Flower Road, Colombo 07',
        assignedDriverName: 'Ranjith Subha (NC-4982)',
        assignedDriverPhone: '+94771234567',
        orderDate: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AdminOrderModel(
        id: 'FH-8842',
        customerName: 'Cinnamon Grand Hospitality',
        customerPhone: '+94112497300',
        farmName: 'Ambewela Green Valley Farm',
        itemsSummary: '20 packs Strawberries, 15 kg Cabbage',
        totalAmount: 21500.0,
        status: 'Confirmed',
        deliveryAddress: '77 Galle Road, Colombo 03',
        assignedDriverName: 'Samantha Jayawardena (LY-3819)',
        assignedDriverPhone: '+94718491029',
        orderDate: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      AdminOrderModel(
        id: 'FH-8843',
        customerName: 'Good Market Organic Store',
        customerPhone: '+94777129840',
        farmName: 'Dambulla Agro Bio Fields',
        itemsSummary: '50 kg Tomatoes, 20 kg Potatoes',
        totalAmount: 14200.0,
        status: 'Pending',
        deliveryAddress: 'Philip Gunewardena Mw, Colombo 07',
        assignedDriverName: 'Unassigned',
        assignedDriverPhone: '',
        orderDate: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ]);
  }
}
