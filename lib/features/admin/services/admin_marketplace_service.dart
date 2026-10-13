import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../buyer/models/buyer_profile_model.dart';
import '../../driver/models/driver_model.dart';
import '../../farmer/models/farmer_profile_model.dart';
import '../models/admin_models.dart';

/// Ultra-Resilient Admin / Marketplace Data Service.
///
/// Implements a Dual-Persistence Repository pattern:
/// 1. Local persistent storage (SharedPreferences) guarantees immediate,
///    offline-tolerant, and zero-loss CRUD execution with rich real-world defaults.
/// 2. Remote Supabase synchronization attempts best-effort network persistence
///    (drivers, driver_deliveries, products, orders, farmers, buyers) without
///    allowing remote schema differences or RLS restrictions to break the Admin UI.
class AdminMarketplaceService extends ChangeNotifier {
  AdminMarketplaceService._internal();

  static final AdminMarketplaceService instance =
      AdminMarketplaceService._internal();
  factory AdminMarketplaceService() => instance;

  static const String _kFarmersKey = 'admin_farmers_data_v2';
  static const String _kBuyersKey = 'admin_buyers_data_v2';
  static const String _kDriversKey = 'admin_drivers_data_v2';
  static const String _kProductsKey = 'admin_products_data_v2';
  static const String _kOrdersKey = 'admin_orders_data_v2';

  final List<AdminFarmerModel> _farmers = [];
  final List<AdminBuyerModel> _buyers = [];
  final List<AdminDriverModel> _drivers = [];
  final List<AdminProductModel> _products = [];
  final List<AdminOrderModel> _orders = [];

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _lastError;

  List<AdminFarmerModel> get farmers => List.unmodifiable(_farmers);
  List<AdminBuyerModel> get buyers => List.unmodifiable(_buyers);
  List<AdminDriverModel> get drivers => List.unmodifiable(_drivers);
  List<AdminProductModel> get products => List.unmodifiable(_products);
  List<AdminOrderModel> get orders => List.unmodifiable(_orders);

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  void clearError() {
    _lastError = null;
  }

  // ── Statistics ───────────────────────────────────────────────────────────
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

  double get totalRevenue => _orders
      .where((o) => o.status != 'Cancelled')
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  SupabaseClient? get _db {
    if (!SupabaseConfig.isInitialized) return null;
    return SupabaseConfig.client;
  }

  static final Random _rng = Random.secure();

  /// Collision-safe readable id, e.g. FRM-8K3QZ1.
  String _newId(String prefix) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final code = List.generate(6, (_) => chars[_rng.nextInt(chars.length)]).join();
    return '$prefix-$code';
  }

  String _cleanOrderId(String id) => id.replaceAll('#', '').trim();

  // ── Initialization & Persistence ─────────────────────────────────────────
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _loadFromLocal();
    notifyListeners();
    // Non-blocking sync with remote database in background
    refreshDatabaseSync();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Farmers
      final rawFarmers = prefs.getString(_kFarmersKey);
      if (rawFarmers != null && rawFarmers.isNotEmpty) {
        final List<dynamic> list = jsonDecode(rawFarmers);
        _farmers.clear();
        _farmers.addAll(
            list.map((m) => AdminFarmerModel.fromMap(Map<String, dynamic>.from(m as Map))));
      } else {
        _farmers.clear();
        _farmers.addAll(_defaultFarmers());
        await _saveFarmers();
      }

      // 2. Buyers
      final rawBuyers = prefs.getString(_kBuyersKey);
      if (rawBuyers != null && rawBuyers.isNotEmpty) {
        final List<dynamic> list = jsonDecode(rawBuyers);
        _buyers.clear();
        _buyers.addAll(
            list.map((m) => AdminBuyerModel.fromMap(Map<String, dynamic>.from(m as Map))));
      } else {
        _buyers.clear();
        _buyers.addAll(_defaultBuyers());
        await _saveBuyers();
      }

      // 3. Drivers
      final rawDrivers = prefs.getString(_kDriversKey);
      if (rawDrivers != null && rawDrivers.isNotEmpty) {
        final List<dynamic> list = jsonDecode(rawDrivers);
        _drivers.clear();
        _drivers.addAll(
            list.map((m) => AdminDriverModel.fromMap(Map<String, dynamic>.from(m as Map))));
      } else {
        _drivers.clear();
        _drivers.addAll(_defaultDrivers());
        await _saveDrivers();
      }

      // 4. Products
      final rawProducts = prefs.getString(_kProductsKey);
      if (rawProducts != null && rawProducts.isNotEmpty) {
        final List<dynamic> list = jsonDecode(rawProducts);
        _products.clear();
        _products.addAll(
            list.map((m) => AdminProductModel.fromMap(Map<String, dynamic>.from(m as Map))));
      } else {
        _products.clear();
        _products.addAll(_defaultProducts());
        await _saveProducts();
      }

      // 5. Orders
      final rawOrders = prefs.getString(_kOrdersKey);
      if (rawOrders != null && rawOrders.isNotEmpty) {
        final List<dynamic> list = jsonDecode(rawOrders);
        _orders.clear();
        _orders.addAll(
            list.map((m) => AdminOrderModel.fromMap(Map<String, dynamic>.from(m as Map))));
      } else {
        _orders.clear();
        _orders.addAll(_defaultOrders());
        await _saveOrders();
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] _loadFromLocal error: $e');
    }
  }

  Future<void> _saveFarmers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_farmers.map((f) => f.toMap()).toList());
      await prefs.setString(_kFarmersKey, data);
    } catch (e) {
      debugPrint('[AdminMarketplaceService] _saveFarmers error: $e');
    }
  }

  Future<void> _saveBuyers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_buyers.map((b) => b.toMap()).toList());
      await prefs.setString(_kBuyersKey, data);
    } catch (e) {
      debugPrint('[AdminMarketplaceService] _saveBuyers error: $e');
    }
  }

  Future<void> _saveDrivers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_drivers.map((d) => d.toMap()).toList());
      await prefs.setString(_kDriversKey, data);
    } catch (e) {
      debugPrint('[AdminMarketplaceService] _saveDrivers error: $e');
    }
  }

  Future<void> _saveProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_products.map((p) => p.toMap()).toList());
      await prefs.setString(_kProductsKey, data);
    } catch (e) {
      debugPrint('[AdminMarketplaceService] _saveProducts error: $e');
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_orders.map((o) => o.toMap()).toList());
      await prefs.setString(_kOrdersKey, data);
    } catch (e) {
      debugPrint('[AdminMarketplaceService] _saveOrders error: $e');
    }
  }

  /// Refreshes data and syncs with Supabase database.
  /// Individual queries are isolated so a missing table or RLS policy
  /// will NEVER wipe the cache or crash the UI.
  Future<void> refreshDatabaseSync() async {
    _isLoading = true;
    notifyListeners();

    final db = _db;
    if (db == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 1. Sync Drivers from remote Supabase (drivers table exists)
    try {
      final res = await db.from('drivers').select().order('created_at', ascending: false);
      if (res.isNotEmpty) {
        final remoteDrivers = res
            .map((e) => AdminDriverModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        for (final rd in remoteDrivers) {
          final idx = _drivers.indexWhere((d) => d.id == rd.id);
          if (idx >= 0) {
            _drivers[idx] = rd;
          } else {
            _drivers.add(rd);
          }
        }
        await _saveDrivers();
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] drivers remote sync note: $e');
    }

    // 2. Sync Deliveries / Orders from remote Supabase (driver_deliveries table exists)
    try {
      final res = await db.from('driver_deliveries').select().order('created_at', ascending: false);
      if (res.isNotEmpty) {
        final remoteDeliveries = res
            .map((e) => AdminOrderModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        for (final ro in remoteDeliveries) {
          final cleanId = _cleanOrderId(ro.id);
          final idx = _orders.indexWhere((o) => _cleanOrderId(o.id) == cleanId);
          if (idx >= 0) {
            _orders[idx] = ro;
          } else {
            _orders.add(ro);
          }
        }
        await _saveOrders();
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] deliveries remote sync note: $e');
    }

    // 3. Sync Products from remote Supabase (if available)
    try {
      final res = await db.from('products').select().order('created_at', ascending: false);
      if (res.isNotEmpty) {
        final remoteProducts = res
            .map((e) => AdminProductModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        for (final rp in remoteProducts) {
          final idx = _products.indexWhere((p) => p.id == rp.id);
          if (idx >= 0) {
            _products[idx] = rp;
          } else {
            _products.add(rp);
          }
        }
        await _saveProducts();
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] products remote sync note: $e');
    }

    // 4. Sync Orders from remote Supabase (if available)
    try {
      final res = await db.from('orders').select().order('created_at', ascending: false);
      if (res.isNotEmpty) {
        final remoteOrders = res
            .map((e) => AdminOrderModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        for (final ro in remoteOrders) {
          final cleanId = _cleanOrderId(ro.id);
          final idx = _orders.indexWhere((o) => _cleanOrderId(o.id) == cleanId);
          if (idx >= 0) {
            _orders[idx] = ro;
          } else {
            _orders.add(ro);
          }
        }
        await _saveOrders();
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] orders remote sync note: $e');
    }

    // 5. Sync Farmers from remote Supabase (farmers first, then farmer_details)
    try {
      List<dynamic> res = [];
      try {
        final r = await db.from('farmers').select().order('created_at', ascending: false);
        if (r.isNotEmpty) res = r;
      } catch (_) {}
      if (res.isEmpty) {
        try {
          final r = await db.from('farmer_details').select().order('created_at', ascending: false);
          if (r.isNotEmpty) res = r;
        } catch (_) {}
      }
      if (res.isNotEmpty) {
        final remoteFarmers = res
            .map((e) => AdminFarmerModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        for (final rf in remoteFarmers) {
          final idx = _farmers.indexWhere((f) => f.id == rf.id);
          if (idx >= 0) {
            _farmers[idx] = rf;
          } else {
            _farmers.add(rf);
          }
        }
        await _saveFarmers();
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] farmers remote sync note: $e');
    }

    // 6. Sync Buyers from remote Supabase (buyers + profiles sync)
    try {
      final List<Map<String, dynamic>> res = [];
      // 6a. Fetch from buyers table
      try {
        final r = await db.from('buyers').select().order('created_at', ascending: false);
        if (r.isNotEmpty) {
          res.addAll(r.map((e) => Map<String, dynamic>.from(e as Map)));
        }
      } catch (_) {}

      // 6b. Fetch registered buyers from profiles table (source of truth for auth users)
      try {
        final profs = await db
            .from('profiles')
            .select()
            .eq('role', 'buyer')
            .order('created_at', ascending: false);
        for (final p in profs) {
          final pMap = Map<String, dynamic>.from(p as Map);
          final pid = pMap['id']?.toString() ?? '';
          if (pid.isNotEmpty) {
            final existingIdx = res.indexWhere((x) => x['id']?.toString() == pid);
            if (existingIdx < 0) {
              final buyerRow = {
                'id': pid,
                'full_name': (pMap['full_name'] as String?)?.isNotEmpty == true
                    ? pMap['full_name']
                    : 'Buyer',
                'email': pMap['email'] ?? '',
                'phone': pMap['phone'] ?? '',
                'delivery_address': pMap['address'] ?? '',
                'delivery_hub': pMap['district'] ?? 'Colombo Regional Hub',
                'buyer_type': 'Family / Household',
                'total_orders': 0,
                'total_spent': 0.0,
                'status': pMap['status'] ?? 'Active',
                'created_at': pMap['created_at'],
              };
              res.add(buyerRow);
              // Backfill into buyers table so both tables stay in sync
              try {
                await db.from('buyers').upsert(buyerRow, onConflict: 'id');
              } catch (_) {}
            }
          }
        }
      } catch (e) {
        debugPrint('[AdminMarketplaceService] profiles buyers sync note: $e');
      }

      if (res.isNotEmpty) {
        final remoteBuyers = res
            .map((e) => AdminBuyerModel.fromMap(e))
            .toList();

        // When real buyers exist, remove mock dummy buyers (BYR-201, BYR-202...)
        _buyers.removeWhere((b) =>
            b.id.startsWith('BYR-20') ||
            b.email.contains('farm2home.lk') ||
            b.email.contains('keells.lk'));

        for (final rb in remoteBuyers) {
          final idx = _buyers.indexWhere((b) =>
              b.id == rb.id ||
              (b.phone.isNotEmpty && b.phone == rb.phone) ||
              (b.email.isNotEmpty && b.email == rb.email));
          if (idx >= 0) {
            _buyers[idx] = rb;
          } else {
            _buyers.add(rb);
          }
        }
        await _saveBuyers();
      }
    } catch (e) {
      debugPrint('[AdminMarketplaceService] buyers remote sync note: $e');
    }

    _isLoading = false;
    _lastError = null;
    notifyListeners();
  }

  // ── Self-service sync from app profiles ──────────────────────────────────

  Future<void> syncFarmerFromApp(FarmerProfileModel p) async {
    final idx = _farmers.indexWhere((f) => f.id == p.id || f.phone == p.phone);
    final updated = AdminFarmerModel(
      id: idx >= 0 ? _farmers[idx].id : _newId('FRM'),
      name: p.name,
      phone: p.phone,
      farmName: p.farmName,
      district: p.district,
      agrarianCenter: p.agrarianCenter,
      scale: p.scale,
      practice: p.farmingPractice,
      crops: p.crops,
      nic: p.nic ?? '',
      bankName: p.bankName ?? '',
      accountNumber: p.accountNumber ?? '',
      isVerified: idx >= 0 ? _farmers[idx].isVerified : true,
      status: idx >= 0 ? _farmers[idx].status : 'Active',
      registeredAt: idx >= 0 ? _farmers[idx].registeredAt : DateTime.now(),
    );

    if (idx >= 0) {
      _farmers[idx] = updated;
    } else {
      _farmers.insert(0, updated);
    }
    await _saveFarmers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('farmers').upsert(updated.toSupabaseMap());
      } catch (e) {
        try {
          await db.from('farmer_details').upsert({
            'id': updated.id,
            'farm_name': updated.farmName,
            'agrarian_center': updated.agrarianCenter,
            'scale': updated.scale,
            'bank_name': updated.bankName,
          });
        } catch (_) {}
      }
    }
  }

  Future<void> syncBuyerFromApp(BuyerProfileModel p) async {
    if (!_isInitialized) {
      await init();
    }

    final realId = (p.id.isNotEmpty && !p.id.startsWith('b-'))
        ? p.id
        : _newId('BYR');

    // Remove dummy mock buyers when real buyers register
    _buyers.removeWhere((b) =>
        b.id.startsWith('BYR-20') ||
        b.email.contains('farm2home.lk') ||
        b.email.contains('keells.lk'));

    final idx = _buyers.indexWhere((b) =>
        b.id == realId ||
        b.id == p.id ||
        (b.phone.isNotEmpty && b.phone == p.phone) ||
        (b.email.isNotEmpty && b.email == p.email));

    final updated = AdminBuyerModel(
      id: idx >= 0 ? _buyers[idx].id : realId,
      name: p.name,
      email: p.email,
      phone: p.phone,
      address: p.deliveryAddress,
      hub: p.deliveryHub,
      buyerType: p.buyerType,
      totalOrders: idx >= 0 ? _buyers[idx].totalOrders : 0,
      totalSpent: idx >= 0 ? _buyers[idx].totalSpent : 0.0,
      status: idx >= 0 ? _buyers[idx].status : 'Active',
      registeredAt: idx >= 0 ? _buyers[idx].registeredAt : DateTime.now(),
    );

    if (idx >= 0) {
      _buyers[idx] = updated;
    } else {
      _buyers.insert(0, updated);
    }
    await _saveBuyers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('buyers').upsert(updated.toSupabaseMap(), onConflict: 'id');
      } catch (e) {
        debugPrint('[AdminMarketplaceService] syncBuyerFromApp buyers upsert error: $e');
      }
      try {
        await db.from('profiles').upsert({
          'id': updated.id,
          'role': 'buyer',
          'full_name': updated.name,
          'email': updated.email,
          'phone': updated.phone,
          'status': updated.status,
        }, onConflict: 'id');
      } catch (_) {}
    }
  }

  Future<void> syncDriverFromApp(DriverModel d) async {
    final idx = _drivers.indexWhere((driver) => driver.id == d.id || driver.phone == d.mobileNumber);
    final updated = AdminDriverModel(
      id: idx >= 0 ? _drivers[idx].id : _newId('DRV'),
      name: d.fullName,
      phone: d.mobileNumber,
      licenseNumber: d.licenseNumber,
      vehicleType: d.vehicleType,
      plateNumber: d.plateNumber,
      cargoCapacity: d.cargoCapacity,
      bankName: d.bankName,
      accountNumber: d.accountNumber,
      isOnDuty: d.isOnDuty,
      completedTrips: idx >= 0 ? _drivers[idx].completedTrips : 0,
      rating: idx >= 0 ? _drivers[idx].rating : 5.0,
      status: d.isOnDuty ? 'Active' : 'Offline',
      registeredAt: idx >= 0 ? _drivers[idx].registeredAt : DateTime.now(),
    );

    if (idx >= 0) {
      _drivers[idx] = updated;
    } else {
      _drivers.insert(0, updated);
    }
    await _saveDrivers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('drivers').upsert(updated.toSupabaseMap());
      } catch (e) {
        debugPrint('[AdminMarketplaceService] syncDriver remote sync note: $e');
      }
    }
  }

  // =========================================================================
  // 🌾 1. FARMERS CRUD
  // =========================================================================
  Future<void> addFarmer(AdminFarmerModel farmer) async {
    final f = farmer.copyWith(
      id: farmer.id.isNotEmpty && !farmer.id.contains('FRM-000')
          ? farmer.id
          : _newId('FRM'),
    );
    _farmers.insert(0, f);
    await _saveFarmers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('farmers').insert(f.toSupabaseMap());
      } catch (e) {
        try {
          await db.from('farmer_details').upsert({
            'id': f.id,
            'farm_name': f.farmName,
            'agrarian_center': f.agrarianCenter,
            'scale': f.scale,
            'bank_name': f.bankName,
          });
        } catch (_) {}
      }
    }
  }

  Future<void> updateFarmer(AdminFarmerModel farmer) async {
    final idx = _farmers.indexWhere((f) => f.id == farmer.id);
    if (idx >= 0) {
      _farmers[idx] = farmer;
      await _saveFarmers();
      notifyListeners();
    }

    final db = _db;
    if (db != null) {
      try {
        await db.from('farmers').update(farmer.toSupabaseMap()).eq('id', farmer.id);
      } catch (e) {
        try {
          await db.from('farmer_details').upsert({
            'id': farmer.id,
            'farm_name': farmer.farmName,
            'agrarian_center': farmer.agrarianCenter,
            'scale': farmer.scale,
            'bank_name': farmer.bankName,
          });
        } catch (_) {}
      }
    }
  }

  Future<void> deleteFarmer(String id) async {
    _farmers.removeWhere((f) => f.id == id);
    await _saveFarmers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('farmers').delete().eq('id', id);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] deleteFarmer remote sync note: $e');
      }
    }
  }

  Future<void> toggleFarmerVerification(String id) async {
    final idx = _farmers.indexWhere((f) => f.id == id);
    if (idx < 0) return;
    final cur = _farmers[idx];
    final verified = !cur.isVerified;
    final updated = cur.copyWith(
      isVerified: verified,
      status: verified ? 'Active' : 'Pending Verification',
    );
    _farmers[idx] = updated;
    await _saveFarmers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('farmers').update({
          'is_verified': verified,
          'status': updated.status,
        }).eq('id', id);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] toggleFarmer remote sync note: $e');
      }
    }
  }

  // =========================================================================
  // 🛒 2. BUYERS CRUD
  // =========================================================================
  Future<void> addBuyer(AdminBuyerModel buyer) async {
    if (!_isInitialized) {
      await init();
    }
    // Remove dummy mock buyers when user adds a real buyer
    _buyers.removeWhere((b) =>
        b.id.startsWith('BYR-20') ||
        b.email.contains('farm2home.lk') ||
        b.email.contains('keells.lk'));

    final b = buyer.copyWith(
      id: buyer.id.isNotEmpty && !buyer.id.contains('BYR-000')
          ? buyer.id
          : _newId('BYR'),
    );
    _buyers.insert(0, b);
    await _saveBuyers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('buyers').upsert(b.toSupabaseMap(), onConflict: 'id');
      } catch (e) {
        debugPrint('[AdminMarketplaceService] addBuyer error: $e');
      }
      try {
        await db.from('profiles').upsert({
          'id': b.id,
          'role': 'buyer',
          'full_name': b.name,
          'email': b.email,
          'phone': b.phone,
          'status': b.status,
        }, onConflict: 'id');
      } catch (_) {}
    }
  }

  Future<void> updateBuyer(AdminBuyerModel buyer) async {
    final idx = _buyers.indexWhere((b) => b.id == buyer.id);
    if (idx >= 0) {
      _buyers[idx] = buyer;
      await _saveBuyers();
      notifyListeners();
    }

    final db = _db;
    if (db != null) {
      try {
        await db.from('buyers').upsert(buyer.toSupabaseMap(), onConflict: 'id');
      } catch (e) {
        debugPrint('[AdminMarketplaceService] updateBuyer error: $e');
      }
      try {
        await db.from('profiles').upsert({
          'id': buyer.id,
          'role': 'buyer',
          'full_name': buyer.name,
          'email': buyer.email,
          'phone': buyer.phone,
          'status': buyer.status,
        }, onConflict: 'id');
      } catch (_) {}
    }
  }

  Future<void> deleteBuyer(String id) async {
    _buyers.removeWhere((b) => b.id == id);
    await _saveBuyers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('buyers').delete().eq('id', id);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] deleteBuyer remote sync note: $e');
      }
      try {
        await db.from('profiles').delete().eq('id', id);
      } catch (_) {}
    }
  }

  Future<void> toggleBuyerStatus(String id) async {
    final idx = _buyers.indexWhere((b) => b.id == id);
    if (idx < 0) return;
    final next = _buyers[idx].status == 'Active' ? 'Suspended' : 'Active';
    final updated = _buyers[idx].copyWith(status: next);
    _buyers[idx] = updated;
    await _saveBuyers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('buyers').update({'status': next}).eq('id', id);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] toggleBuyer remote sync note: $e');
      }
      try {
        await db.from('profiles').update({'status': next}).eq('id', id);
      } catch (_) {}
    }
  }

  // =========================================================================
  // 🚚 3. DRIVERS & FLEET CRUD
  // =========================================================================
  Future<void> addDriver(AdminDriverModel driver) async {
    final d = driver.copyWith(
      id: driver.id.isNotEmpty && !driver.id.contains('DRV-000')
          ? driver.id
          : _newId('DRV'),
    );
    _drivers.insert(0, d);
    await _saveDrivers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('drivers').insert(d.toSupabaseMap());
      } catch (e) {
        debugPrint('[AdminMarketplaceService] addDriver remote sync note: $e');
      }
    }
  }

  Future<void> updateDriver(AdminDriverModel driver) async {
    final idx = _drivers.indexWhere((d) => d.id == driver.id);
    if (idx >= 0) {
      _drivers[idx] = driver;
      await _saveDrivers();
      notifyListeners();
    }

    final db = _db;
    if (db != null) {
      try {
        await db.from('drivers').update(driver.toSupabaseMap()).eq('id', driver.id);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] updateDriver remote sync note: $e');
      }
    }
  }

  Future<void> deleteDriver(String id) async {
    _drivers.removeWhere((d) => d.id == id);
    await _saveDrivers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('drivers').delete().eq('id', id);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] deleteDriver remote sync note: $e');
      }
    }
  }

  Future<void> toggleDriverDuty(String id) async {
    final idx = _drivers.indexWhere((d) => d.id == id);
    if (idx < 0) return;
    final next = !_drivers[idx].isOnDuty;
    final updated = _drivers[idx].copyWith(
      isOnDuty: next,
      status: next ? 'Active' : 'Offline',
    );
    _drivers[idx] = updated;
    await _saveDrivers();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('drivers').update({
          'duty_status': next,
          'is_on_duty': next,
        }).eq('id', id);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] toggleDriverDuty remote sync note: $e');
      }
    }
  }

  // =========================================================================
  // 🥕 4. PRODUCTS CRUD
  // =========================================================================
  Future<void> addProduct(AdminProductModel product) async {
    final p = product.copyWith(
      id: product.id.isNotEmpty && !product.id.contains('PRD-000')
          ? product.id
          : _newId('PRD'),
    );
    _products.insert(0, p);
    await _saveProducts();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        final map = p.toSupabaseMap();
        map['farmer_id'] = '37be4352-c46e-4f8d-aeff-478857bf5d84';
        final inserted = await db.from('products').insert(map).select().maybeSingle();
        if (inserted != null && inserted['id'] != null) {
          final realId = inserted['id'].toString();
          final idx = _products.indexWhere((item) => item.id == p.id);
          if (idx >= 0) {
            _products[idx] = p.copyWith(id: realId);
            await _saveProducts();
          }
        }
      } catch (e) {
        debugPrint('[AdminMarketplaceService] addProduct remote sync note: $e');
      }
    }
  }

  Future<void> updateProduct(AdminProductModel product) async {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _products[idx] = product;
      await _saveProducts();
      notifyListeners();
    }

    final db = _db;
    if (db != null) {
      try {
        final map = product.toSupabaseMap();
        map.remove('id');
        if (AdminProductModel.isValidUuid(product.id)) {
          await db.from('products').update(map).eq('id', product.id);
        } else {
          await db.from('products').update(map).eq('name', product.name);
        }
      } catch (e) {
        debugPrint('[AdminMarketplaceService] updateProduct remote sync note: $e');
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final p = _products.where((item) => item.id == id).firstOrNull;
    _products.removeWhere((item) => item.id == id);
    await _saveProducts();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        if (AdminProductModel.isValidUuid(id)) {
          await db.from('products').delete().eq('id', id);
        } else if (p != null) {
          await db.from('products').delete().eq('name', p.name);
        }
      } catch (e) {
        debugPrint('[AdminMarketplaceService] deleteProduct remote sync note: $e');
      }
    }
  }

  // =========================================================================
  // 📦 5. ORDERS & DISPATCH CRUD
  // =========================================================================
  String? _driverIdFor(String name, String phone) {
    for (final d in _drivers) {
      if (phone.isNotEmpty && d.phone == phone) return d.id;
    }
    for (final d in _drivers) {
      if (name.isNotEmpty && name.startsWith(d.name)) return d.id;
    }
    return null;
  }

  Future<void> addOrder(AdminOrderModel order) async {
    final o = order.copyWith(
      id: order.id.isNotEmpty && !order.id.contains('FH-000')
          ? order.id
          : _newId('FH'),
    );
    _orders.insert(0, o);
    await _saveOrders();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        final delivery = o.toDeliveryMap();
        final driverId = _driverIdFor(o.assignedDriverName, o.assignedDriverPhone);
        if (driverId != null) delivery['driver_id'] = driverId;
        await db.from('driver_deliveries').upsert(delivery);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] addOrder remote sync note: $e');
      }
    }
  }

  Future<void> updateOrder(AdminOrderModel order) async {
    final clean = _cleanOrderId(order.id);
    final idx = _orders.indexWhere((o) => _cleanOrderId(o.id) == clean);
    if (idx >= 0) {
      _orders[idx] = order;
      await _saveOrders();
      notifyListeners();
    }

    final db = _db;
    if (db != null) {
      try {
        final delivery = order.toDeliveryMap();
        final driverId = _driverIdFor(order.assignedDriverName, order.assignedDriverPhone);
        if (driverId != null) delivery['driver_id'] = driverId;
        await db.from('driver_deliveries').upsert(delivery);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] updateOrder remote sync note: $e');
      }
    }
  }

  Future<void> updateOrderStatus(String id, String newStatus) async {
    final clean = _cleanOrderId(id);
    final idx = _orders.indexWhere((o) => _cleanOrderId(o.id) == clean);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(status: newStatus);
      await _saveOrders();
      notifyListeners();
    }

    final db = _db;
    if (db != null) {
      try {
        await db
            .from('driver_deliveries')
            .update({'status': newStatus}).eq('id', clean);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] updateOrderStatus remote sync note: $e');
      }
    }
  }

  Future<void> assignDriverToOrder(
      String orderId, String driverName, String driverPhone) async {
    final clean = _cleanOrderId(orderId);
    final idx = _orders.indexWhere((o) => _cleanOrderId(o.id) == clean);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(
        assignedDriverName: driverName,
        assignedDriverPhone: driverPhone,
        status: 'In Transit',
      );
      await _saveOrders();
      notifyListeners();
    }

    final db = _db;
    if (db != null) {
      try {
        final driverId = _driverIdFor(driverName, driverPhone);
        await db.from('driver_deliveries').update({
          if (driverId != null) 'driver_id': driverId,
          'status': 'In Transit',
        }).eq('id', clean);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] assignDriver remote sync note: $e');
      }
    }
  }

  Future<void> deleteOrder(String id) async {
    final clean = _cleanOrderId(id);
    _orders.removeWhere((o) => _cleanOrderId(o.id) == clean);
    await _saveOrders();
    notifyListeners();

    final db = _db;
    if (db != null) {
      try {
        await db.from('driver_deliveries').delete().eq('id', clean);
      } catch (e) {
        debugPrint('[AdminMarketplaceService] deleteOrder remote sync note: $e');
      }
    }
  }

  // =========================================================================
  // 🌟 DEFAULT REALISTIC SRI LANKAN MARKETPLACE SEED DATA
  // =========================================================================
  List<AdminFarmerModel> _defaultFarmers() {
    final now = DateTime.now();
    return [
      AdminFarmerModel(
        id: 'FRM-101',
        name: 'Sunil Shantha Perera',
        phone: '+94771122334',
        farmName: 'Hakgala Organic Highlands',
        district: 'Nuwara Eliya',
        agrarianCenter: 'Hakgala Agrarian Center',
        scale: '3 - 5 Acres',
        practice: 'Certified Organic (SL-GAP)',
        crops: const ['Highland Carrots', 'Organic Tomatoes', 'Leeks', 'Beetroot'],
        nic: '782145698V',
        bankName: 'Commercial Bank',
        accountNumber: '8002938411',
        isVerified: true,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 60)),
      ),
      AdminFarmerModel(
        id: 'FRM-102',
        name: 'Nimal Bandara',
        phone: '+94714455667',
        farmName: 'Dambulla Agro Green',
        district: 'Matale',
        agrarianCenter: 'Dambulla Center',
        scale: '5 - 10 Acres',
        practice: 'Good Agricultural Practices (GAP)',
        crops: const ['Green Chillies', 'Big Onions', 'Capsicum', 'Brinjals'],
        nic: '821098453V',
        bankName: 'Bank of Ceylon',
        accountNumber: '0029381745',
        isVerified: true,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 45)),
      ),
      AdminFarmerModel(
        id: 'FRM-103',
        name: 'Priyantha Kumara',
        phone: '+94762233445',
        farmName: 'Welimada Valley Farms',
        district: 'Badulla',
        agrarianCenter: 'Welimada Agrarian',
        scale: '1 - 3 Acres',
        practice: 'Conventional Fresh',
        crops: const ['Highland Potatoes', 'Cabbage', 'Beans'],
        nic: '852349182V',
        bankName: 'People\'s Bank',
        accountNumber: '1239840192',
        isVerified: true,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 30)),
      ),
      AdminFarmerModel(
        id: 'FRM-104',
        name: 'K. Sivagurunathan',
        phone: '+94778899001',
        farmName: 'Jaffna Red Onion Gardens',
        district: 'Jaffna',
        agrarianCenter: 'Chavakachcheri',
        scale: '2 - 4 Acres',
        practice: 'Natural Farming',
        crops: const ['Red Onions', 'Jaffna Drumsticks', 'Bananas'],
        nic: '761928374V',
        bankName: 'Hatton National Bank',
        accountNumber: '0492817201',
        isVerified: true,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 20)),
      ),
      AdminFarmerModel(
        id: 'FRM-105',
        name: 'Mahinda Jayawardena',
        phone: '+94703344556',
        farmName: 'Rambukkana Plantations',
        district: 'Kegalle',
        agrarianCenter: 'Rambukkana Center',
        scale: '4 - 8 Acres',
        practice: 'Certified Organic (SL-GAP)',
        crops: const ['Ginger', 'Turmeric', 'Papaya'],
        nic: '691029384V',
        bankName: 'Sampath Bank',
        accountNumber: '7102938491',
        isVerified: false,
        status: 'Pending Verification',
        registeredAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  List<AdminBuyerModel> _defaultBuyers() {
    final now = DateTime.now();
    return [
      AdminBuyerModel(
        id: 'BYR-201',
        name: 'Chaminda Perera',
        email: 'chaminda.perera@gmail.com',
        phone: '+94719876543',
        address: '123, Galle Road, Colombo 03',
        hub: 'Manning Market Hub, Colombo',
        buyerType: 'Supermarket / Retail Chain',
        totalOrders: 18,
        totalSpent: 184500.0,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 50)),
      ),
      AdminBuyerModel(
        id: 'BYR-202',
        name: 'Dilani Jayasinghe',
        email: 'dilani.j@yahoo.com',
        phone: '+94776543210',
        address: '45, Peradeniya Road, Kandy',
        hub: 'Kandy Central Distribution Hub',
        buyerType: 'Wholesale Distributor',
        totalOrders: 12,
        totalSpent: 96200.0,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 40)),
      ),
      AdminBuyerModel(
        id: 'BYR-203',
        name: 'K. Wickramasinghe',
        email: 'keells.procure@keells.lk',
        phone: '+94771234567',
        address: 'Keells Distribution Centre, Kerawalapitiya',
        hub: 'Peliyagoda Central Wholesale Hub',
        buyerType: 'Commercial Bulk Buyer',
        totalOrders: 34,
        totalSpent: 420000.0,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 35)),
      ),
      AdminBuyerModel(
        id: 'BYR-204',
        name: 'Sujith Fernando',
        email: 'sujithf@hotmail.com',
        phone: '+94754433221',
        address: '88, Negombo Road, Kurunegala',
        hub: 'Kurunegala Dambulla Exchange',
        buyerType: 'Restaurant / Hotel (HoReCa)',
        totalOrders: 8,
        totalSpent: 54000.0,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 15)),
      ),
      AdminBuyerModel(
        id: 'BYR-205',
        name: 'Malini Senanayake',
        email: 'malini.s@gmail.com',
        phone: '+94723322110',
        address: '12, Beach Road, Mount Lavinia',
        hub: 'Colombo South Distribution Hub',
        buyerType: 'Family / Household',
        totalOrders: 5,
        totalSpent: 22800.0,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 8)),
      ),
    ];
  }

  List<AdminDriverModel> _defaultDrivers() {
    final now = DateTime.now();
    return [
      AdminDriverModel(
        id: 'DRV-5304',
        name: 'Madushi',
        phone: '784521693',
        licenseNumber: 'G-7890',
        vehicleType: 'Covered Light Truck / Lorry',
        plateNumber: 'FK-1234',
        cargoCapacity: '100g',
        bankName: 'Seylan Bank',
        accountNumber: '789653214',
        isOnDuty: true,
        completedTrips: 14,
        rating: 4.9,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 55)),
      ),
      AdminDriverModel(
        id: 'DRV-8927',
        name: 'Gayani',
        phone: '764215967',
        licenseNumber: 'V-5678',
        vehicleType: 'Three-Wheeler / Cargo Tuk',
        plateNumber: 'BE-1234',
        cargoCapacity: '900g',
        bankName: 'Nations Trust Bank (NTB)',
        accountNumber: '7856941233',
        isOnDuty: true,
        completedTrips: 29,
        rating: 4.9,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 42)),
      ),
      AdminDriverModel(
        id: 'DRV-5205',
        name: 'Janith',
        phone: '752315698',
        licenseNumber: 'H-5678',
        vehicleType: 'Three-Wheeler / Cargo Tuk',
        plateNumber: 'RS-1234',
        cargoCapacity: '300g',
        bankName: 'Bank of Ceylon (BOC)',
        accountNumber: '147852369',
        isOnDuty: true,
        completedTrips: 8,
        rating: 4.9,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 28)),
      ),
      AdminDriverModel(
        id: 'DRV-491939',
        name: 'Lasiru Iduvara',
        phone: '+94765642127',
        licenseNumber: 'M-4567',
        vehicleType: 'Three-Wheeler / Cargo Tuk',
        plateNumber: 'WP-CA-8921',
        cargoCapacity: '250g',
        bankName: 'People\'s Bank',
        accountNumber: '1284719201',
        isOnDuty: true,
        completedTrips: 21,
        rating: 4.9,
        status: 'Active',
        registeredAt: now.subtract(const Duration(days: 18)),
      ),
    ];
  }

  List<AdminProductModel> _defaultProducts() {
    final now = DateTime.now();
    return [
      AdminProductModel(
        id: 'PRD-301',
        name: 'Nuwara Eliya Carrots',
        category: 'Vegetables',
        price: 380.0,
        unit: '/kg',
        availableQty: 450.0,
        farmName: 'Hakgala Organic Highlands',
        farmerName: 'Sunil Shantha Perera',
        isOrganic: true,
        imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500',
        description: 'Freshly harvested crisp Nuwara Eliya highland carrots, sweet and vibrant.',
        status: 'In Stock',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      AdminProductModel(
        id: 'PRD-302',
        name: 'Organic Tomatoes',
        category: 'Vegetables',
        price: 320.0,
        unit: '/kg',
        availableQty: 600.0,
        farmName: 'Hakgala Organic Highlands',
        farmerName: 'Sunil Shantha Perera',
        isOrganic: true,
        imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500',
        description: 'Vine-ripened organic red tomatoes, pesticide-free SL-GAP certified.',
        status: 'In Stock',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      AdminProductModel(
        id: 'PRD-303',
        name: 'Dambulla Green Chillies',
        category: 'Vegetables',
        price: 750.0,
        unit: '/kg',
        availableQty: 200.0,
        farmName: 'Dambulla Agro Green',
        farmerName: 'Nimal Bandara',
        isOrganic: false,
        imageUrl: 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=500',
        description: 'Spicy fresh green chillies directly picked from Dambulla fields.',
        status: 'In Stock',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      AdminProductModel(
        id: 'PRD-304',
        name: 'Highland Potatoes',
        category: 'Tubers',
        price: 420.0,
        unit: '/kg',
        availableQty: 800.0,
        farmName: 'Welimada Valley Farms',
        farmerName: 'Priyantha Kumara',
        isOrganic: false,
        imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500',
        description: 'Grade-A Welimada red soil potatoes, firm and delicious.',
        status: 'In Stock',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      AdminProductModel(
        id: 'PRD-305',
        name: 'Jaffna Red Onions',
        category: 'Vegetables',
        price: 520.0,
        unit: '/kg',
        availableQty: 350.0,
        farmName: 'Jaffna Red Onion Gardens',
        farmerName: 'K. Sivagurunathan',
        isOrganic: true,
        imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=500',
        description: 'Aromatic Jaffna small red onions, packed with strong flavor and freshness.',
        status: 'In Stock',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      AdminProductModel(
        id: 'PRD-306',
        name: 'Red Lady Papaya',
        category: 'Fruits',
        price: 260.0,
        unit: '/kg',
        availableQty: 180.0,
        farmName: 'Rambukkana Plantations',
        farmerName: 'Mahinda Jayawardena',
        isOrganic: true,
        imageUrl: 'https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=500',
        description: 'Sweet, juicy organic red lady papayas, tree-ripened naturally.',
        status: 'In Stock',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<AdminOrderModel> _defaultOrders() {
    final now = DateTime.now();
    return [
      AdminOrderModel(
        id: 'FT-1524',
        customerName: 'Chaminda Perera',
        customerPhone: '+94719876543',
        farmName: 'Sunil Perera Farm',
        itemsSummary: '2 kg Organic Tomatoes, 1 kg Fresh Carrots, 1 kg Highland Potatoes, 1 1 kg Nuwara Eliya Highland Carrots',
        totalAmount: 1071.0,
        status: 'Pending',
        deliveryAddress: '123, Main Street, Hambantota',
        assignedDriverName: 'Unassigned',
        assignedDriverPhone: '',
        orderDate: now.subtract(const Duration(hours: 4)),
      ),
      AdminOrderModel(
        id: 'FH-8841',
        customerName: 'Chaminda Perera',
        customerPhone: '+94719876543',
        farmName: 'K. M. Bandara',
        itemsSummary: '5 kg (Carrots & Leeks)',
        totalAmount: 1450.0,
        status: 'Ready for Pickup',
        deliveryAddress: 'No. 42 Havelock Rd, Colombo 05',
        assignedDriverName: 'Unassigned',
        assignedDriverPhone: '',
        orderDate: now.subtract(const Duration(hours: 6)),
      ),
      AdminOrderModel(
        id: 'FH-8850',
        customerName: 'Dilani Jayawardena',
        customerPhone: '+94719876543',
        farmName: 'Sunil Perera',
        itemsSummary: '12 kg (Tomatoes & Cabbages)',
        totalAmount: 1800.0,
        status: 'Ready for Pickup',
        deliveryAddress: 'Dehiwala Urban Center',
        assignedDriverName: 'Unassigned',
        assignedDriverPhone: '',
        orderDate: now.subtract(const Duration(hours: 8)),
      ),
      AdminOrderModel(
        id: 'FT-1560',
        customerName: 'Chaminda Perera',
        customerPhone: '+94719876543',
        farmName: 'Sunil Perera Farm',
        itemsSummary: '2 kg Organic Tomatoes, 1 kg Fresh Carrots, 1 kg Highland Potatoes, 2 1 kg Crisp Field Salad Cucumber',
        totalAmount: 1071.0,
        status: 'Pending',
        deliveryAddress: '123, Main Street, Hambantota',
        assignedDriverName: 'Unassigned',
        assignedDriverPhone: '',
        orderDate: now.subtract(const Duration(hours: 10)),
      ),
      AdminOrderModel(
        id: 'FH-8862',
        customerName: 'Anura Kumara (Cinnamon Mart)',
        customerPhone: '+94719876543',
        farmName: 'R. M. Dissanayake',
        itemsSummary: '25 kg (Bell Peppers & Fresh Tomatoes)',
        totalAmount: 2100.0,
        status: 'Ready for Pickup',
        deliveryAddress: 'No. 18 Barnes Place, Colombo 07',
        assignedDriverName: 'Unassigned',
        assignedDriverPhone: '',
        orderDate: now.subtract(const Duration(hours: 12)),
      ),
      AdminOrderModel(
        id: 'FH-8875',
        customerName: 'Nimali Jayasinghe (Fresh Choice)',
        customerPhone: '+94719876543',
        farmName: 'S. K. Gunasekara',
        itemsSummary: '8 kg (Salad Greens & Strawberries)',
        totalAmount: 1650.0,
        status: 'Ready for Pickup',
        deliveryAddress: 'Station Road, Moratuwa',
        assignedDriverName: 'Unassigned',
        assignedDriverPhone: '',
        orderDate: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
