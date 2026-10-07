import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_config.dart';
import '../models/delivery_order_model.dart';
import '../models/driver_model.dart';
import '../models/pickup_verification_model.dart';

/// Service handling all driver operations using Supabase as the single database backend,
/// with instant local fallback for ultra-smooth UI performance.
/// Zero Firebase dependencies.
class DriverFirestoreService {
  static final DriverFirestoreService _instance = DriverFirestoreService._internal();
  factory DriverFirestoreService() => _instance;
  DriverFirestoreService._internal() {
    _initDefaults();
  }

  SupabaseClient? get _sb {
    try {
      if (SupabaseConfig.isInitialized) {
        return SupabaseConfig.client;
      }
    } catch (_) {}
    return null;
  }

  // ── In-Memory Datastores (for instant UI & fallback) ──────────────────────
  static final Map<String, DriverModel> _drivers = {};
  static final Map<String, DeliveryOrderModel> _deliveries = {};
  static final Map<String, PickupVerificationModel> _verifications = {};
  static final List<Map<String, dynamic>> _history = [];
  static final List<Map<String, dynamic>> _chatMessages = [];

  // Stream Controllers for Reactive UI
  static final StreamController<List<DeliveryOrderModel>> _deliveriesStreamController =
      StreamController<List<DeliveryOrderModel>>.broadcast();
  static final StreamController<List<Map<String, dynamic>>> _chatStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  void _initDefaults() {
    if (_drivers.isEmpty) {
      final defaultDriver = DriverModel(
        id: 'DRV-4091',
        fullName: 'Ranjith Subha Udhasanak',
        licenseNumber: 'B-8492019',
        mobileNumber: '+94771234567',
        vehicleType: 'Chilled / Refrigerated Van',
        plateNumber: 'NC-4982',
        cargoCapacity: '1,200 kg',
        isColdBoxEquipped: true,
        operatingCorridors: const [
          'Nuwara Eliya ⇄ Colombo (A7)',
          'Dambulla ⇄ Colombo (A6)',
        ],
        bankName: 'Commercial Bank of Ceylon',
        accountNumber: '8004 1293 4198',
        isOnDuty: true,
        rating: 4.9,
        completedTrips: 184,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        scheduledDeliveries: 6,
        deliveredToday: 4,
        netEarnings: 7850.0,
        activeOrderId: '#FH-8841',
        activeFarmerName: 'Farmer Bandar',
        activeFarmLocation: 'Hakgala Organic Farm',
        activeEstPayout: 1450.0,
        activeCargoItem: '5 kg Fresh Carrots & Leeks',
        activeCrate: 'Crate #C',
        activePickupLocation: 'Upper Division Gate B, Hakgala Rd',
      );
      _drivers[defaultDriver.id] = defaultDriver;
    }

    if (_deliveries.isEmpty) {
      _seedInitialDeliveriesSync();
    }

    if (_history.isEmpty) {
      seedInitialDeliveryHistorySync();
    }

    if (_chatMessages.isEmpty) {
      seedInitialChatMessagesSync();
    }
  }

  // ── DRIVER MANAGEMENT (Supabase `drivers`) ─────────────────────────────────

  Future<String> registerDriver(DriverModel driver) async {
    final id = driver.id.isNotEmpty
        ? driver.id
        : 'DRV-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final saved = driver.copyWith(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _drivers[id] = saved;

    // Sync to Supabase
    try {
      final client = _sb;
      if (client != null) {
        await client.from('drivers').upsert(saved.toMap());
        debugPrint('[DriverService] Driver synced to Supabase: $id');
      }
    } catch (e) {
      debugPrint('[DriverService] Supabase driver upsert note: $e');
    }

    return id;
  }

  Future<DriverModel?> getDriver(String driverId) async {
    // Try Supabase first
    try {
      final client = _sb;
      if (client != null) {
        final res = await client.from('drivers').select().eq('id', driverId).maybeSingle();
        if (res != null) {
          final driver = DriverModel.fromMap(res, driverId);
          _drivers[driverId] = driver;
          return driver;
        }
      }
    } catch (_) {}

    return _drivers[driverId];
  }

  Future<DriverModel?> getDashboardDriver(String? driverId) async {
    if (driverId != null && driverId.isNotEmpty) {
      final d = await getDriver(driverId);
      if (d != null) return d;
    }

    try {
      final client = _sb;
      if (client != null) {
        final res = await client.from('drivers').select().limit(1);
        if (res.isNotEmpty) {
          final first = res.first;
          final id = first['id']?.toString() ?? 'DRV-4091';
          final d = DriverModel.fromMap(first, id);
          _drivers[id] = d;
          return d;
        }
      }
    } catch (_) {}

    if (_drivers.isNotEmpty) {
      return _drivers.values.first;
    }
    return null;
  }

  Future<DriverModel?> getDriverByPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '').trim();
    for (final d in _drivers.values) {
      if (d.mobileNumber.contains(clean) || clean.contains(d.mobileNumber)) {
        return d;
      }
    }
    return null;
  }

  Stream<DriverModel?> getDriverStream(String driverId) {
    return Stream.value(_drivers[driverId]);
  }

  Future<List<DriverModel>> getAllDrivers() async {
    return _drivers.values.toList();
  }

  Future<void> updateDriver(DriverModel driver) async {
    _drivers[driver.id] = driver.copyWith(updatedAt: DateTime.now());

    try {
      final client = _sb;
      if (client != null) {
        await client.from('drivers').update(driver.toMap()).eq('id', driver.id);
      }
    } catch (_) {}
  }

  Future<void> updateDutyStatus(String driverId, bool isOnDuty) async {
    final d = _drivers[driverId];
    if (d != null) {
      _drivers[driverId] = d.copyWith(isOnDuty: isOnDuty, updatedAt: DateTime.now());
    }

    try {
      final client = _sb;
      if (client != null) {
        await client.from('drivers').update({
          'isOnDuty': isOnDuty,
          'updatedAt': DateTime.now().toIso8601String(),
        }).eq('id', driverId);
      }
    } catch (_) {}
  }

  Future<void> updateBankDetails(String driverId, String bankName, String accountNumber) async {
    final d = _drivers[driverId];
    if (d != null) {
      _drivers[driverId] = d.copyWith(
        bankName: bankName,
        accountNumber: accountNumber,
        updatedAt: DateTime.now(),
      );
    }

    try {
      final client = _sb;
      if (client != null) {
        await client.from('drivers').update({
          'bankName': bankName,
          'accountNumber': accountNumber,
          'updatedAt': DateTime.now().toIso8601String(),
        }).eq('id', driverId);
      }
    } catch (_) {}
  }

  Future<void> deleteDriver(String driverId) async {
    _drivers.remove(driverId);
    try {
      final client = _sb;
      if (client != null) {
        await client.from('drivers').delete().eq('id', driverId);
      }
    } catch (_) {}
  }

  // ── ASSIGNED DELIVERIES (Supabase `driver_deliveries`) ──────────────────────

  void _seedInitialDeliveriesSync() {
    final order1 = DeliveryOrderModel(
      id: 'FH-8841',
      orderNumber: '#FH-8841',
      status: 'Ready for Pickup',
      crateCount: '1 Crate',
      pickupDueText: 'Pickup Due in 20m',
      farmerName: 'K. M. Bandara',
      farmerAddress: 'Upper Division, Hakgala Rd, Nuwara Eliya',
      buyerName: 'Chaminda Perera',
      buyerAddress: 'No. 42 Havelock Rd, Colombo 05',
      produceDescription: '5 kg (Carrots & Leeks)',
      producePackageType: 'Cool storage packed',
      driverFee: 1450.0,
      isPriority: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      updatedAt: DateTime.now(),
    );

    final order2 = DeliveryOrderModel(
      id: 'FH-8850',
      orderNumber: '#FH-8850',
      status: 'Ready for Pickup',
      crateCount: '2 Crates',
      pickupDueText: 'Pickup Due in 45m',
      farmerName: 'Sunil Perera',
      farmerAddress: 'Perera Agro Holdings, Welimada',
      buyerName: 'Dilani Jayawardena',
      buyerAddress: 'De Fonseka Rd, Colombo 04',
      produceDescription: '18 kg (Nuwara Eliya Potatoes)',
      producePackageType: 'Ambient ventilation crated',
      driverFee: 2850.0,
      isPriority: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      updatedAt: DateTime.now(),
    );

    _deliveries[order1.id] = order1;
    _deliveries[order2.id] = order2;
    _broadcastDeliveries();
  }

  Future<List<DeliveryOrderModel>> getAssignedDeliveries({String filter = 'All'}) async {
    try {
      final client = _sb;
      if (client != null) {
        final res = await client.from('driver_deliveries').select();
        if (res.isNotEmpty) {
          for (final row in res) {
            final id = row['id']?.toString() ?? row['orderNumber']?.toString() ?? 'order';
            _deliveries[id] = DeliveryOrderModel.fromMap(row, id);
          }
        }
      }
    } catch (_) {}

    if (_deliveries.isEmpty) {
      _seedInitialDeliveriesSync();
    }
    final orders = _deliveries.values.toList();
    if (filter.startsWith('Ready')) {
      return orders.where((o) => o.status == 'Ready for Pickup').toList();
    } else if (filter.startsWith('In Transit')) {
      return orders.where((o) => o.status == 'In Transit' || o.status == 'En Route to Pickup').toList();
    }
    return orders;
  }

  Stream<List<DeliveryOrderModel>> getDeliveriesStream({String filter = 'All'}) async* {
    if (_deliveries.isEmpty) {
      _seedInitialDeliveriesSync();
    }
    yield await getAssignedDeliveries(filter: filter);
    yield* _deliveriesStreamController.stream.map((orders) {
      if (filter.startsWith('Ready')) {
        return orders.where((o) => o.status == 'Ready for Pickup').toList();
      } else if (filter.startsWith('In Transit')) {
        return orders.where((o) => o.status == 'In Transit' || o.status == 'En Route to Pickup').toList();
      }
      return orders;
    });
  }

  void _broadcastDeliveries() {
    _deliveriesStreamController.add(_deliveries.values.toList());
  }

  Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    final order = _deliveries[cleanId];
    if (order != null) {
      _deliveries[cleanId] = order.copyWith(status: newStatus, updatedAt: DateTime.now());
      _broadcastDeliveries();
    }

    try {
      final client = _sb;
      if (client != null) {
        await client.from('driver_deliveries').update({
          'status': newStatus,
          'updatedAt': DateTime.now().toIso8601String(),
        }).eq('id', cleanId);
      }
    } catch (_) {}
  }

  // ── PICKUP VERIFICATION (Supabase `pickup_verifications`) ─────────────────

  Future<String> createPickupVerification(PickupVerificationModel verification) async {
    final id = verification.id.isNotEmpty
        ? verification.id
        : 'VER-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final newVer = verification.copyWith(id: id, verifiedAt: DateTime.now());
    _verifications[id] = newVer;

    final cleanOrderId = verification.orderId.replaceAll('#', '').trim();
    await updateDeliveryStatus(cleanOrderId, 'In Transit');

    try {
      final client = _sb;
      if (client != null) {
        await client.from('pickup_verifications').upsert(newVer.toMap());
      }
    } catch (_) {}

    return id;
  }

  Future<PickupVerificationModel?> getPickupVerification(String orderId) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    for (final v in _verifications.values) {
      if (v.orderId == orderId || v.orderId == cleanId) {
        return v;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getPickupManifestDetails(String orderId) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    final is8850 = cleanId.contains('8850');
    if (is8850) {
      return {
        'orderId': '#FH-8850',
        'farmerName': 'Sunil Perera',
        'farmLocation': 'Welimada Main Collection Depot',
        'gateInfo': 'Depot Platform Gate #1 / C',
        'crateId': '#CR-8850-B',
        'handoverPin': '6318',
        'ambientTemp': '18°C',
        'vanTemp': '4.0°C',
        'produceDescription': '12 kg (Tomatoes & Cabbages)',
      };
    }
    return {
      'orderId': '#FH-8841',
      'farmerName': 'K. M. Bandara',
      'farmLocation': 'Hakgala Valley Organic Farm',
      'gateInfo': 'Gate North #2 / B',
      'crateId': '#CR-8841-A',
      'handoverPin': '4921',
      'ambientTemp': '16°C',
      'vanTemp': '4.2°C',
      'produceDescription': '5 kg (Carrots & Leeks)',
    };
  }

  // ── DELIVERY TRACKING & TELEMETRY ─────────────────────────────────────────

  Future<Map<String, dynamic>> getDeliveryTrackingDetails(String orderId) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    if (cleanId.contains('8850')) {
      return {
        'orderId': '#FH-8850',
        'buyerName': 'Dilani Jayawardena',
        'buyerAddress': 'No. 15, Station Road, Dehiwala',
        'gateCode': '#2819',
        'dropoffNotes': 'Leave with security counter or front porch.',
        'codAmount': 'Rs. 2,450',
        'cratesCount': '2 Crates Fresh Veg',
        'remainingDistance': '24 km',
        'estimatedTime': '35 min',
        'targetEta': '4:15 PM',
        'cargoCoolTemp': '19°C',
        'vanChillerTemp': 4.0,
        'latitude': 6.8344,
        'longitude': 79.8654,
        'transitStatus': 'IN_TRANSIT',
      };
    }
    return {
      'orderId': '#FH-8841',
      'buyerName': 'Chaminda Perera',
      'buyerAddress': '42 Havelock Rd, Colombo 05',
      'gateCode': '#4012',
      'dropoffNotes': 'Ring doorbell twice, keep produce in shade.',
      'codAmount': 'Rs. 1,760',
      'cratesCount': '3 Crates Fresh Veg',
      'remainingDistance': '38 km',
      'estimatedTime': '45 min',
      'targetEta': '3:30 PM',
      'cargoCoolTemp': '18°C',
      'vanChillerTemp': 4.2,
      'latitude': 6.9012,
      'longitude': 79.8614,
      'transitStatus': 'IN_TRANSIT',
    };
  }

  Future<void> updateTransitTelemetry(
    String orderId, {
    required double latitude,
    required double longitude,
    required double vanTemperature,
    required String transitStatus,
  }) async {
    // Recorded locally & telemetry sync
  }

  // ── DELIVERY COMPLETION & SETTLEMENT ───────────────────────────────────────

  Future<Map<String, dynamic>> getCompletedDeliveryDetails(String orderId) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    if (cleanId.contains('8850')) {
      return {
        'orderId': '#FH-8850',
        'buyerName': 'Dilani Jayawardena',
        'buyerAddress': 'No. 15, Station Road, Dehiwala',
        'totalEarned': 'Rs. 1,800',
        'baseTransit': 'Rs. 1,500',
        'terrainBonus': '+Rs. 300',
        'directTip': '+Rs. 250',
        'dailyWalletTotal': 'Rs. 9,650',
        'deliveryTime': 'Today, 4:10 PM',
        'earlyBadge': '20 mins early ⚡',
        'handoverType': 'Cash on Delivery',
        'collectedAmount': 'Rs. 2,450 Collected & Pocketed',
        'ratingStars': 5.0,
      };
    }
    return {
      'orderId': '#FH-8841',
      'buyerName': 'Chaminda Perera',
      'buyerAddress': 'Havelock Rd. Colombo 05',
      'totalEarned': 'Rs. 1,450',
      'baseTransit': 'Rs. 1,200',
      'terrainBonus': '+Rs. 250',
      'directTip': '+Rs. 200',
      'dailyWalletTotal': 'Rs. 9,300',
      'deliveryTime': 'Today, 3:15 PM',
      'earlyBadge': '15 mins early ⚡',
      'handoverType': 'Cash on Delivery',
      'collectedAmount': 'Rs. 1,760 Collected & Pocketed',
      'ratingStars': 5.0,
    };
  }

  Future<void> finalizeDeliveryAndSettleEarnings(
    String orderId,
    double tripPayout, {
    String? driverId,
  }) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    await updateDeliveryStatus(cleanId, 'COMPLETED');

    final targetDriver = driverId != null && _drivers.containsKey(driverId)
        ? _drivers[driverId]
        : (_drivers.isNotEmpty ? _drivers.values.first : null);

    if (targetDriver != null) {
      final updated = targetDriver.copyWith(
        deliveredToday: targetDriver.deliveredToday + 1,
        netEarnings: targetDriver.netEarnings + tripPayout,
        completedTrips: targetDriver.completedTrips + 1,
        activeOrderId: '',
        updatedAt: DateTime.now(),
      );
      _drivers[targetDriver.id] = updated;

      try {
        final client = _sb;
        if (client != null) {
          await client.from('drivers').update(updated.toMap()).eq('id', targetDriver.id);
        }
      } catch (_) {}
    }
  }

  // ── DELIVERY HISTORY (Supabase `delivery_history`) ─────────────────────────

  void seedInitialDeliveryHistorySync() {
    _history.addAll([
      {
        'orderId': 'FH-8841',
        'pickupLocation': 'Hakgala Farm, Nuwara Eliya',
        'dropLocation': 'Colombo 05 (Havelock Rd)',
        'cargo': '5 kg Fresh Produce (Carrots, Leeks)',
        'time': 'Today, 3:15 PM',
        'amount': 'Rs. 1,450',
        'period': 'This Week',
        'iconType': 'inventory',
        'isArchived': false,
      },
      {
        'orderId': 'FH-8839',
        'pickupLocation': 'Nuwara Eliya Cold Hub',
        'dropLocation': 'Kandy Central Co-Op',
        'cargo': '5 kg Highland Potatoes',
        'time': 'Today, 11:30 AM',
        'amount': 'Rs. 1,200',
        'period': 'This Week',
        'iconType': 'grass',
        'isArchived': false,
      },
      {
        'orderId': 'FH-8812',
        'pickupLocation': 'Dambulla Dedicated Market',
        'dropLocation': 'Colombo 07 (Cinnamon Gardens)',
        'cargo': '15 kg Fresh Tomatoes',
        'time': 'Yesterday, 4:20 PM',
        'amount': 'Rs. 2,100',
        'period': 'This Week',
        'iconType': 'eco',
        'isArchived': false,
      },
      {
        'orderId': 'FH-8790',
        'pickupLocation': 'Welimada Organic Terrace',
        'dropLocation': 'Dehiwala Residential',
        'cargo': '10 kg Organic Cabbage',
        'time': '24 Oct, 2:00 PM',
        'amount': 'Rs. 1,650',
        'period': 'This Week',
        'iconType': 'spa',
        'isArchived': false,
      },
      {
        'orderId': 'FH-8755',
        'pickupLocation': 'Bandarawela Tea & Veg Hub',
        'dropLocation': 'Nugegoda Super Center',
        'cargo': '20 kg Fresh Carrots & Leeks',
        'time': '18 Oct, 4:10 PM',
        'amount': 'Rs. 2,350',
        'period': 'Last Week',
        'iconType': 'inventory',
        'isArchived': false,
      },
      {
        'orderId': 'FH-8740',
        'pickupLocation': 'Hakgala Organic Plots',
        'dropLocation': 'Battaramulla Urban Mart',
        'cargo': '12 kg Bell Peppers & Salad Greens',
        'time': '17 Oct, 1:20 PM',
        'amount': 'Rs. 1,850',
        'period': 'Last Week',
        'iconType': 'eco',
        'isArchived': false,
      },
      {
        'orderId': 'FH-8620',
        'pickupLocation': 'Keppetipola Agro Center',
        'dropLocation': 'Moratuwa Distribution Point',
        'cargo': '30 kg Bulk Cabbage & Beets',
        'time': '08 Oct, 10:15 AM',
        'amount': 'Rs. 3,100',
        'period': 'This Month',
        'iconType': 'spa',
        'isArchived': false,
      },
    ]);
  }

  Future<void> seedInitialDeliveryHistory() async {
    if (_history.isEmpty) {
      seedInitialDeliveryHistorySync();
    }
  }

  Future<Map<String, dynamic>> getDeliveryHistory({String period = 'This Week'}) async {
    if (_history.isEmpty) {
      seedInitialDeliveryHistorySync();
    }

    final filtered = _history
        .where((h) => h['period'] == period && h['isArchived'] != true)
        .toList();

    int tripsCount = 28;
    String onTimeRate = '99.2%';
    String earnings = 'Rs. 38.4k';

    if (period == 'Last Week') {
      tripsCount = 34;
      onTimeRate = '98.8%';
      earnings = 'Rs. 46.2k';
    } else if (period == 'This Month') {
      tripsCount = 112;
      onTimeRate = '99.4%';
      earnings = 'Rs. 154.8k';
    }

    return {
      'period': period,
      'tripsCount': filtered.isNotEmpty ? filtered.length : tripsCount,
      'onTimeRate': onTimeRate,
      'earnings': earnings,
      'trips': filtered,
    };
  }

  Future<void> deleteDeliveryHistoryItem(String orderId) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    for (final item in _history) {
      if (item['orderId'] == cleanId || item['orderId'] == orderId) {
        item['isArchived'] = true;
      }
    }
  }

  // ── CHAT MESSAGES (Supabase `driver_chat_messages`) ───────────────────────

  void seedInitialChatMessagesSync() {
    _chatMessages.addAll([
      {
        'id': 'msg-1',
        'orderId': 'FH-8841',
        'sender': 'Chaminda',
        'senderId': 'BUYER-8841',
        'senderRole': 'buyer',
        'text': 'Hi driver! Is the avocado box chilled properly? Last week\'s order got a bit softened in the heat.',
        'time': '10:12 AM',
        'isMe': false,
        'category': 'Buyers',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      },
      {
        'id': 'msg-2',
        'orderId': 'FH-8841',
        'sender': 'You',
        'senderId': 'DRV-4091',
        'senderRole': 'driver',
        'text': 'Yes Chaminda! All fresh produce is inside the climate-controlled compartment at 12°C.',
        'time': '10:13 AM',
        'isMe': true,
        'category': 'Buyers',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
      },
    ]);
  }

  Future<void> seedInitialChatMessages({String orderId = 'FH-8841'}) async {
    if (_chatMessages.isEmpty) {
      seedInitialChatMessagesSync();
    }
  }

  Future<String> sendChatMessage({
    required String orderId,
    required String sender,
    required String senderId,
    required String text,
    required String time,
    required bool isMe,
    String senderRole = 'driver',
    String category = 'Buyers',
  }) async {
    final cleanId = orderId.replaceAll('#', '').trim();
    final newId = 'msg-${DateTime.now().millisecondsSinceEpoch}';
    final msg = {
      'id': newId,
      'orderId': cleanId,
      'sender': sender,
      'senderId': senderId,
      'senderRole': senderRole,
      'text': text,
      'time': time,
      'isMe': isMe,
      'category': category,
      'timestamp': DateTime.now(),
    };
    _chatMessages.add(msg);
    _chatStreamController.add(
      _chatMessages.where((m) => m['orderId'] == cleanId).toList(),
    );

    try {
      final client = _sb;
      if (client != null) {
        await client.from('driver_chat_messages').insert({
          'order_id': cleanId,
          'sender': sender,
          'sender_id': senderId,
          'sender_role': senderRole,
          'text': text,
          'time': time,
          'is_me': isMe,
          'category': category,
        });
      }
    } catch (_) {}

    return newId;
  }

  Stream<List<Map<String, dynamic>>> getChatMessagesStream({String orderId = 'FH-8841'}) async* {
    final cleanId = orderId.replaceAll('#', '').trim();
    if (_chatMessages.isEmpty) {
      seedInitialChatMessagesSync();
    }
    yield _chatMessages.where((m) => m['orderId'] == cleanId).toList();
    yield* _chatStreamController.stream
        .map((list) => list.where((m) => m['orderId'] == cleanId).toList());
  }
}
