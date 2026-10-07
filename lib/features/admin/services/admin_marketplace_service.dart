import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../buyer/services/buyer_profile_manager.dart';
import '../../driver/services/driver_profile_manager.dart';
import '../../farmer/services/farmer_profile_manager.dart';
import '../models/admin_models.dart';

/// Central Marketplace Admin Service managing full CRUD state across all portals
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

  // ── Initialization & Persistence ─────────────────────────────────────────
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Farmers
      final farmersJson = prefs.getString(_kFarmersKey);
      if (farmersJson != null) {
        final list = jsonDecode(farmersJson) as List<dynamic>;
        _farmers.clear();
        _farmers.addAll(
            list.map((m) => AdminFarmerModel.fromMap(m as Map<String, dynamic>)));
      } else {
        _seedDefaultFarmers();
      }

      // Load Buyers
      final buyersJson = prefs.getString(_kBuyersKey);
      if (buyersJson != null) {
        final list = jsonDecode(buyersJson) as List<dynamic>;
        _buyers.clear();
        _buyers.addAll(
            list.map((m) => AdminBuyerModel.fromMap(m as Map<String, dynamic>)));
      } else {
        _seedDefaultBuyers();
      }

      // Load Drivers
      final driversJson = prefs.getString(_kDriversKey);
      if (driversJson != null) {
        final list = jsonDecode(driversJson) as List<dynamic>;
        _drivers.clear();
        _drivers.addAll(
            list.map((m) => AdminDriverModel.fromMap(m as Map<String, dynamic>)));
      } else {
        _seedDefaultDrivers();
      }

      // Load Products
      final productsJson = prefs.getString(_kProductsKey);
      if (productsJson != null) {
        final list = jsonDecode(productsJson) as List<dynamic>;
        _products.clear();
        _products.addAll(
            list.map((m) => AdminProductModel.fromMap(m as Map<String, dynamic>)));
      } else {
        _seedDefaultProducts();
      }

      // Load Orders
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

  /// Syncs currently logged-in user profile from each manager into admin listings
  void _syncActiveAppProfiles() {
    // 1. Farmer profile sync
    final farmerProfile = FarmerProfileManager.instance.profile;
    if (farmerProfile.name.isNotEmpty) {
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
    }

    // 2. Buyer profile sync
    final buyerProfile = BuyerProfileManager.instance.profile;
    if (buyerProfile.name.isNotEmpty) {
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
    }

    // 3. Driver profile sync
    final driverModel = DriverProfileManager.instance.driver;
    if (driverModel.fullName.isNotEmpty) {
      final index = _drivers.indexWhere((d) => d.phone == driverModel.mobileNumber);
      final driverData = AdminDriverModel(
        id: driverModel.id.isNotEmpty ? driverModel.id : 'DRV-001',
        name: driverModel.fullName,
        phone: driverModel.mobileNumber,
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
    }
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
  // 🌾 1. FARMERS CRUD OPERATIONS
  // =========================================================================
  Future<void> addFarmer(AdminFarmerModel farmer) async {
    _farmers.insert(0, farmer);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateFarmer(AdminFarmerModel farmer) async {
    final idx = _farmers.indexWhere((f) => f.id == farmer.id);
    if (idx >= 0) {
      _farmers[idx] = farmer;
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteFarmer(String id) async {
    _farmers.removeWhere((f) => f.id == id);
    await _saveAll();
    notifyListeners();
  }

  Future<void> toggleFarmerVerification(String id) async {
    final idx = _farmers.indexWhere((f) => f.id == id);
    if (idx >= 0) {
      final cur = _farmers[idx];
      _farmers[idx] = cur.copyWith(
        isVerified: !cur.isVerified,
        status: !cur.isVerified ? 'Active' : 'Pending Verification',
      );
      await _saveAll();
      notifyListeners();
    }
  }

  // =========================================================================
  // 🛒 2. BUYERS CRUD OPERATIONS
  // =========================================================================
  Future<void> addBuyer(AdminBuyerModel buyer) async {
    _buyers.insert(0, buyer);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateBuyer(AdminBuyerModel buyer) async {
    final idx = _buyers.indexWhere((b) => b.id == buyer.id);
    if (idx >= 0) {
      _buyers[idx] = buyer;
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteBuyer(String id) async {
    _buyers.removeWhere((b) => b.id == id);
    await _saveAll();
    notifyListeners();
  }

  Future<void> toggleBuyerStatus(String id) async {
    final idx = _buyers.indexWhere((b) => b.id == id);
    if (idx >= 0) {
      final cur = _buyers[idx];
      final newStatus = cur.status == 'Active' ? 'Suspended' : 'Active';
      _buyers[idx] = cur.copyWith(status: newStatus);
      await _saveAll();
      notifyListeners();
    }
  }

  // =========================================================================
  // 🚚 3. DRIVERS & FLEET CRUD OPERATIONS
  // =========================================================================
  Future<void> addDriver(AdminDriverModel driver) async {
    _drivers.insert(0, driver);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateDriver(AdminDriverModel driver) async {
    final idx = _drivers.indexWhere((d) => d.id == driver.id);
    if (idx >= 0) {
      _drivers[idx] = driver;
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteDriver(String id) async {
    _drivers.removeWhere((d) => d.id == id);
    await _saveAll();
    notifyListeners();
  }

  Future<void> toggleDriverDuty(String id) async {
    final idx = _drivers.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      final cur = _drivers[idx];
      _drivers[idx] = cur.copyWith(isOnDuty: !cur.isOnDuty);
      await _saveAll();
      notifyListeners();
    }
  }

  // =========================================================================
  // 🥦 4. MARKETPLACE PRODUCTS CRUD OPERATIONS
  // =========================================================================
  Future<void> addProduct(AdminProductModel product) async {
    _products.insert(0, product);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateProduct(AdminProductModel product) async {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _products[idx] = product;
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await _saveAll();
    notifyListeners();
  }

  // =========================================================================
  // 📦 5. ORDERS & DISPATCH CRUD OPERATIONS
  // =========================================================================
  Future<void> addOrder(AdminOrderModel order) async {
    _orders.insert(0, order);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateOrder(AdminOrderModel order) async {
    final idx = _orders.indexWhere((o) => o.id == order.id);
    if (idx >= 0) {
      _orders[idx] = order;
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String id, String newStatus) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(status: newStatus);
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> assignDriverToOrder(
      String orderId, String driverName, String driverPhone) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx] = _orders[idx].copyWith(
        assignedDriverName: driverName,
        assignedDriverPhone: driverPhone,
        status: 'In Transit',
      );
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
    await _saveAll();
    notifyListeners();
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
        crops: ['Carrots', 'Leeks', 'Highland Potatoes'],
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
        crops: ['Cabbage', 'Beetroot', 'Strawberries'],
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
        crops: ['Tomatoes', 'Green Chillies', 'Capsicum'],
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
        totalOrders: 14,
        totalSpent: 42800.0,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      AdminBuyerModel(
        id: 'BYR-202',
        name: 'Nadeesha Fernando',
        email: 'nadeesha.rest@gmail.com',
        phone: '+94773829104',
        address: 'Harbor View Bistro, Galle Road, Colombo 03',
        hub: 'Colombo Central Regional Hub',
        buyerType: 'Restaurant & Hospitality',
        totalOrders: 32,
        totalSpent: 184500.0,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      AdminBuyerModel(
        id: 'BYR-203',
        name: 'Kasun Wickramasinghe',
        email: 'kasun.kandy@gmail.com',
        phone: '+94784920194',
        address: 'Peradeniya Road, Kandy',
        hub: 'Kandy Regional Hub (Central)',
        buyerType: 'Retail Organic Store',
        totalOrders: 8,
        totalSpent: 26400.0,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 12)),
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
        accountNumber: '800412934198',
        isOnDuty: true,
        completedTrips: 184,
        rating: 4.95,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      AdminDriverModel(
        id: 'DRV-302',
        name: 'Samantha Jayawardena',
        phone: '+94719482012',
        licenseNumber: 'B-9201948',
        vehicleType: 'Insulated Medium Truck',
        plateNumber: 'CP LY-3819',
        cargoCapacity: '2,500 kg',
        bankName: 'Sampath Bank PLC',
        accountNumber: '10928401928',
        isOnDuty: true,
        completedTrips: 92,
        rating: 4.88,
        status: 'Active',
        registeredAt: DateTime.now().subtract(const Duration(days: 80)),
      ),
      AdminDriverModel(
        id: 'DRV-303',
        name: 'Priyashantha Kumara',
        phone: '+94754820194',
        licenseNumber: 'B-7482019',
        vehicleType: 'Cold Transit Van',
        plateNumber: 'SP DA-8291',
        cargoCapacity: '800 kg',
        bankName: 'Bank of Ceylon',
        accountNumber: '0029481029',
        isOnDuty: false,
        completedTrips: 45,
        rating: 4.75,
        status: 'On Standby',
        registeredAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
    ]);
  }

  void _seedDefaultProducts() {
    _products.clear();
    _products.addAll([
      AdminProductModel(
        id: 'PRD-501',
        name: 'Hakgala Sweet Carrots',
        category: 'Root Vegetables',
        price: 320.0,
        unit: '/kg',
        availableQty: 180.0,
        farmName: 'Hakgala Organic Highlands',
        farmerName: 'Sunil Shantha',
        isOrganic: true,
        imageUrl:
            'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&auto=format&fit=crop&q=80',
        description: 'Crisp, naturally grown highland carrots from Nuwara Eliya soil.',
        status: 'In Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      AdminProductModel(
        id: 'PRD-502',
        name: 'Farm Fresh Ripe Tomatoes',
        category: 'Vegetables',
        price: 260.0,
        unit: '/kg',
        availableQty: 240.0,
        farmName: 'Ambewela Green Valley',
        farmerName: 'K. M. Bandara',
        isOrganic: true,
        imageUrl:
            'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80',
        description: 'Juicy, naturally ripened organic tomatoes for culinary perfection.',
        status: 'In Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AdminProductModel(
        id: 'PRD-503',
        name: 'Highland Crisp Leeks',
        category: 'Leafy Greens',
        price: 290.0,
        unit: '/kg',
        availableQty: 95.0,
        farmName: 'Hakgala Organic Highlands',
        farmerName: 'Sunil Shantha',
        isOrganic: true,
        imageUrl:
            'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=500&auto=format&fit=crop&q=80',
        description: 'Freshly harvested cool highland leeks with pristine aroma.',
        status: 'In Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AdminProductModel(
        id: 'PRD-504',
        name: 'Nuwara Eliya Strawberries',
        category: 'Highland Fruits',
        price: 850.0,
        unit: '/pack (250g)',
        availableQty: 40.0,
        farmName: 'Ambewela Green Valley',
        farmerName: 'K. M. Bandara',
        isOrganic: true,
        imageUrl:
            'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=500&auto=format&fit=crop&q=80',
        description: 'Sweet highland strawberries packed in temperature controlled punnets.',
        status: 'Low Stock',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
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
        itemsSummary: '5 kg Carrots, 2 kg Leeks, 1 kg Tomatoes',
        totalAmount: 2450.0,
        status: 'In Transit',
        deliveryAddress: 'No 45, Flower Road, Colombo 07',
        assignedDriverName: 'Ranjith Subha (NC-4982)',
        assignedDriverPhone: '+94771234567',
        orderDate: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AdminOrderModel(
        id: 'FH-8842',
        customerName: 'Nadeesha Fernando',
        customerPhone: '+94773829104',
        farmName: 'Ambewela Green Valley Farm',
        itemsSummary: '20 kg Tomatoes, 10 kg Carrots, 5 packs Strawberries',
        totalAmount: 12650.0,
        status: 'Confirmed',
        deliveryAddress: 'Harbor View Bistro, Galle Road, Colombo 03',
        assignedDriverName: 'Samantha Jayawardena (LY-3819)',
        assignedDriverPhone: '+94719482012',
        orderDate: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AdminOrderModel(
        id: 'FH-8843',
        customerName: 'Kasun Wickramasinghe',
        customerPhone: '+94784920194',
        farmName: 'Hakgala Organic Highlands',
        itemsSummary: '8 kg Carrots, 4 kg Highland Leeks',
        totalAmount: 3720.0,
        status: 'Pending',
        deliveryAddress: 'Peradeniya Road, Kandy',
        assignedDriverName: 'Unassigned',
        assignedDriverPhone: '',
        orderDate: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ]);
  }
}
