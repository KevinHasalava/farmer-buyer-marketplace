import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../../buyer/models/buyer_profile_model.dart';
import '../../driver/models/driver_model.dart';
import '../../farmer/models/farmer_profile_model.dart';
import '../models/admin_models.dart';

/// Admin / marketplace data service.
///
/// The Supabase database is the single source of truth. There is no seed
/// data, no local cache and no fake fallback: every list shown in the admin
/// console is read from the database and every create / update / delete is
/// written to the database first (Row Level Security only allows this for
/// users whose `profiles.role = 'admin'`).
class AdminMarketplaceService extends ChangeNotifier {
  AdminMarketplaceService._internal();

  static final AdminMarketplaceService instance =
      AdminMarketplaceService._internal();
  factory AdminMarketplaceService() => instance;

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

  /// Last database error (null when the last operation succeeded). The admin
  /// UI shows this to the user.
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

  SupabaseClient get _db {
    if (!SupabaseConfig.isInitialized) {
      throw const _DbUnavailable();
    }
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

  // ── Load ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await refreshDatabaseSync();
  }

  /// Reloads every list from the database.
  Future<void> refreshDatabaseSync() async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = _db;
      final results = await Future.wait([
        db.from('farmers').select().order('created_at', ascending: false),
        db.from('buyers').select().order('created_at', ascending: false),
        db.from('drivers').select().order('created_at', ascending: false),
        db.from('products').select().order('created_at', ascending: false),
        db.from('orders').select().order('order_date', ascending: false),
      ]);

      List<Map<String, dynamic>> rows(int i) =>
          (results[i] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

      _farmers
        ..clear()
        ..addAll(rows(0).map(AdminFarmerModel.fromMap));
      _buyers
        ..clear()
        ..addAll(rows(1).map(AdminBuyerModel.fromMap));
      _drivers
        ..clear()
        ..addAll(rows(2).map(AdminDriverModel.fromMap));
      _products
        ..clear()
        ..addAll(rows(3).map(AdminProductModel.fromMap));
      _orders
        ..clear()
        ..addAll(rows(4).map(AdminOrderModel.fromMap));
      _lastError = null;
    } catch (e) {
      _lastError = _friendly(e);
      debugPrint('[AdminMarketplaceService] load failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _friendly(Object e) {
    if (e is _DbUnavailable) return 'Cannot reach the database.';
    if (e is PostgrestException) {
      if (e.code == '42501') return 'Permission denied. Admin access required.';
      if (e.code == '23505') return 'A record with the same unique value already exists.';
      if (e.code == '23503') return 'This record is linked to other data and cannot be changed.';
      if (e.code == '42P01') {
        return 'Database table is missing. Run supabase/schema.sql in the Supabase SQL editor.';
      }
      return e.message;
    }
    return e.toString();
  }

  /// Runs a database write; on failure records [lastError] and reloads so the
  /// UI never shows data that is not in the database.
  Future<bool> _write(Future<void> Function(SupabaseClient db) action) async {
    try {
      await action(_db);
      _lastError = null;
      return true;
    } catch (e) {
      _lastError = _friendly(e);
      debugPrint('[AdminMarketplaceService] write failed: $e');
      return false;
    } finally {
      await refreshDatabaseSync();
    }
  }

  // ── Self-service sync (a signed-in farmer / buyer / driver editing their own row)
  String? get _uid {
    try {
      return SupabaseConfig.isInitialized
          ? SupabaseConfig.auth.currentUser?.id
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> syncFarmerFromApp(FarmerProfileModel p) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db.from('farmers').update({
        if (p.name.isNotEmpty) 'full_name': p.name,
        if (p.phone.isNotEmpty) 'phone': p.phone,
        if (p.farmName.isNotEmpty) 'farm_name': p.farmName,
        if (p.district.isNotEmpty) 'district': p.district,
        if (p.agrarianCenter.isNotEmpty) 'agrarian_center': p.agrarianCenter,
        if (p.scale.isNotEmpty) 'scale': p.scale,
        if (p.farmingPractice.isNotEmpty) 'practice': p.farmingPractice,
        'crops': p.crops,
        if ((p.nic ?? '').isNotEmpty) 'nic': p.nic,
        if ((p.bankName ?? '').isNotEmpty) 'bank_name': p.bankName,
        if ((p.accountNumber ?? '').isNotEmpty) 'account_number': p.accountNumber,
      }).eq('id', uid);
    } catch (e) {
      debugPrint('[AdminMarketplaceService] syncFarmerFromApp: $e');
    }
  }

  Future<void> syncBuyerFromApp(BuyerProfileModel p) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db.from('buyers').update({
        if (p.name.isNotEmpty) 'full_name': p.name,
        if (p.phone.isNotEmpty) 'phone': p.phone,
        if (p.deliveryAddress.isNotEmpty) 'delivery_address': p.deliveryAddress,
        if (p.deliveryHub.isNotEmpty) 'delivery_hub': p.deliveryHub,
        if (p.buyerType.isNotEmpty) 'buyer_type': p.buyerType,
      }).eq('id', uid);
    } catch (e) {
      debugPrint('[AdminMarketplaceService] syncBuyerFromApp: $e');
    }
  }

  Future<void> syncDriverFromApp(DriverModel d) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db.from('drivers').update({
        if (d.fullName.isNotEmpty) 'full_name': d.fullName,
        if (d.mobileNumber.isNotEmpty) 'phone_number': d.mobileNumber,
        if (d.licenseNumber.isNotEmpty) 'license_number': d.licenseNumber,
        if (d.vehicleType.isNotEmpty) 'vehicle_type': d.vehicleType,
        if (d.plateNumber.isNotEmpty) 'vehicle_number': d.plateNumber,
        if (d.cargoCapacity.isNotEmpty) 'cargo_capacity': d.cargoCapacity,
        if (d.bankName.isNotEmpty) 'bank_name': d.bankName,
        if (d.accountNumber.isNotEmpty) 'bank_account_number': d.accountNumber,
        'duty_status': d.isOnDuty,
      }).eq('id', uid);
    } catch (e) {
      debugPrint('[AdminMarketplaceService] syncDriverFromApp: $e');
    }
  }

  // =========================================================================
  // FARMERS
  // =========================================================================
  Future<void> addFarmer(AdminFarmerModel farmer) async {
    final f = farmer.copyWith(id: _newId('FRM'));
    await _write((db) => db.from('farmers').insert(f.toSupabaseMap()));
  }

  Future<void> updateFarmer(AdminFarmerModel farmer) async {
    await _write((db) =>
        db.from('farmers').update(farmer.toSupabaseMap()).eq('id', farmer.id));
  }

  Future<void> deleteFarmer(String id) async {
    await _write((db) => db.from('farmers').delete().eq('id', id));
  }

  Future<void> toggleFarmerVerification(String id) async {
    final idx = _farmers.indexWhere((f) => f.id == id);
    if (idx < 0) return;
    final cur = _farmers[idx];
    final verified = !cur.isVerified;
    await _write((db) => db.from('farmers').update({
          'is_verified': verified,
          'status': verified ? 'Active' : 'Pending Verification',
        }).eq('id', id));
  }

  // =========================================================================
  // BUYERS
  // =========================================================================
  Future<void> addBuyer(AdminBuyerModel buyer) async {
    final b = buyer.copyWith(id: _newId('BYR'));
    await _write((db) => db.from('buyers').insert(b.toSupabaseMap()));
  }

  Future<void> updateBuyer(AdminBuyerModel buyer) async {
    await _write((db) =>
        db.from('buyers').update(buyer.toSupabaseMap()).eq('id', buyer.id));
  }

  Future<void> deleteBuyer(String id) async {
    await _write((db) => db.from('buyers').delete().eq('id', id));
  }

  Future<void> toggleBuyerStatus(String id) async {
    final idx = _buyers.indexWhere((b) => b.id == id);
    if (idx < 0) return;
    final next = _buyers[idx].status == 'Active' ? 'Suspended' : 'Active';
    await _write((db) => db.from('buyers').update({'status': next}).eq('id', id));
  }

  // =========================================================================
  // DRIVERS
  // =========================================================================
  Future<void> addDriver(AdminDriverModel driver) async {
    final d = driver.copyWith(id: _newId('DRV'));
    await _write((db) => db.from('drivers').insert(d.toSupabaseMap()));
  }

  Future<void> updateDriver(AdminDriverModel driver) async {
    await _write((db) =>
        db.from('drivers').update(driver.toSupabaseMap()).eq('id', driver.id));
  }

  Future<void> deleteDriver(String id) async {
    await _write((db) => db.from('drivers').delete().eq('id', id));
  }

  Future<void> toggleDriverDuty(String id) async {
    final idx = _drivers.indexWhere((d) => d.id == id);
    if (idx < 0) return;
    final next = !_drivers[idx].isOnDuty;
    await _write((db) => db.from('drivers').update({
          'duty_status': next,
          'status': next ? 'Active' : 'Offline',
        }).eq('id', id));
  }

  // =========================================================================
  // PRODUCTS
  // =========================================================================
  Future<void> addProduct(AdminProductModel product) async {
    final p = product.copyWith(id: _newId('PRD'));
    // Link the product to a registered farmer when the name matches one.
    final farmer = _farmers.where((f) => f.name == p.farmerName).toList();
    final map = p.toSupabaseMap();
    if (farmer.isNotEmpty) map['farmer_id'] = farmer.first.id;
    await _write((db) => db.from('products').insert(map));
  }

  Future<void> updateProduct(AdminProductModel product) async {
    await _write((db) =>
        db.from('products').update(product.toSupabaseMap()).eq('id', product.id));
  }

  Future<void> deleteProduct(String id) async {
    await _write((db) => db.from('products').delete().eq('id', id));
  }

  // =========================================================================
  // ORDERS & DISPATCH
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

  Future<void> _upsertOrder(SupabaseClient db, AdminOrderModel order) async {
    final map = order.toSupabaseMap();
    final driverId = _driverIdFor(order.assignedDriverName, order.assignedDriverPhone);
    map['driver_id'] = driverId;
    await db.from('orders').upsert(map);
    final delivery = order.toDeliveryMap();
    delivery['driver_id'] = driverId;
    await db.from('driver_deliveries').upsert(delivery);
  }

  Future<void> addOrder(AdminOrderModel order) async {
    final o = order.copyWith(id: _newId('FH'));
    await _write((db) => _upsertOrder(db, o));
  }

  Future<void> updateOrder(AdminOrderModel order) async {
    await _write((db) => _upsertOrder(db, order));
  }

  Future<void> updateOrderStatus(String id, String newStatus) async {
    final clean = _cleanOrderId(id);
    await _write((db) async {
      await db.from('orders').update({'status': newStatus}).eq('id', clean);
      await db
          .from('driver_deliveries')
          .update({'status': newStatus}).eq('id', clean);
    });
  }

  Future<void> assignDriverToOrder(
      String orderId, String driverName, String driverPhone) async {
    final clean = _cleanOrderId(orderId);
    final driverId = _driverIdFor(driverName, driverPhone);
    await _write((db) async {
      await db.from('orders').update({
        'assigned_driver_name': driverName,
        'assigned_driver_phone': driverPhone,
        'driver_id': driverId,
        'status': 'In Transit',
      }).eq('id', clean);
      await db.from('driver_deliveries').update({
        'driver_id': driverId,
        'status': 'In Transit',
      }).eq('id', clean);
    });
  }

  Future<void> deleteOrder(String id) async {
    final clean = _cleanOrderId(id);
    await _write((db) async {
      await db.from('driver_deliveries').delete().eq('id', clean);
      await db.from('orders').delete().eq('id', clean);
    });
  }
}

class _DbUnavailable implements Exception {
  const _DbUnavailable();
}
