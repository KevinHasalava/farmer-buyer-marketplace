/// Driver data model representing an enrolled Agri-Transit logistics driver.
class DriverModel {
  final String id;
  final String fullName;
  final String licenseNumber;
  final String mobileNumber;
  final String vehicleType;
  final String plateNumber;
  final String cargoCapacity;
  final bool isColdBoxEquipped;
  final List<String> operatingCorridors;
  final String bankName;
  final String accountNumber;
  final bool isOnDuty;
  final double rating;
  final int completedTrips;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Dashboard Shift & Active Order metrics (READ - R)
  final int scheduledDeliveries;
  final int deliveredToday;
  final double netEarnings;
  final String activeOrderId;
  final String activeFarmerName;
  final String activeFarmLocation;
  final double activeEstPayout;
  final String activeCargoItem;
  final String activeCrate;
  final String activePickupLocation;

  const DriverModel({
    required this.id,
    required this.fullName,
    required this.licenseNumber,
    required this.mobileNumber,
    required this.vehicleType,
    required this.plateNumber,
    required this.cargoCapacity,
    required this.isColdBoxEquipped,
    required this.operatingCorridors,
    required this.bankName,
    required this.accountNumber,
    this.isOnDuty = true,
    this.rating = 4.9,
    this.completedTrips = 0,
    required this.createdAt,
    required this.updatedAt,
    this.scheduledDeliveries = 6,
    this.deliveredToday = 4,
    this.netEarnings = 7850.0,
    this.activeOrderId = '#FH-8841',
    this.activeFarmerName = 'Farmer Bandar',
    this.activeFarmLocation = 'Hakgala Organic Farm',
    this.activeEstPayout = 1450.0,
    this.activeCargoItem = '5 kg Fresh Carrots & Leeks',
    this.activeCrate = 'Crate #C',
    this.activePickupLocation = 'Upper Division Gate B, Hakgala Rd',
  });

  /// Convert DriverModel into a Firestore-friendly Map.
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'licenseNumber': licenseNumber,
      'mobileNumber': mobileNumber,
      'vehicleType': vehicleType,
      'plateNumber': plateNumber,
      'cargoCapacity': cargoCapacity,
      'isColdBoxEquipped': isColdBoxEquipped,
      'operatingCorridors': operatingCorridors,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'isOnDuty': isOnDuty,
      'rating': rating,
      'completedTrips': completedTrips,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'scheduledDeliveries': scheduledDeliveries,
      'deliveredToday': deliveredToday,
      'netEarnings': netEarnings,
      'activeOrderId': activeOrderId,
      'activeFarmerName': activeFarmerName,
      'activeFarmLocation': activeFarmLocation,
      'activeEstPayout': activeEstPayout,
      'activeCargoItem': activeCargoItem,
      'activeCrate': activeCrate,
      'activePickupLocation': activePickupLocation,
    };
  }

  /// Convert DriverModel into remote Supabase `public.drivers` column format.
  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'full_name': fullName,
      'license_number': licenseNumber,
      'phone_number': mobileNumber,
      'vehicle_type': vehicleType,
      'vehicle_number': plateNumber,
      'plate_number': plateNumber,
      'cargo_capacity': cargoCapacity,
      'is_cold_box_equipped': isColdBoxEquipped,
      'operating_corridors': operatingCorridors,
      'bank_name': bankName,
      'bank_account_number': accountNumber,
      'account_number': accountNumber,
      'duty_status': isOnDuty,
      'is_on_duty': isOnDuty,
      'rating': rating,
      'completed_deliveries': completedTrips,
      'completed_trips': completedTrips,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic val) {
    if (val is DateTime) return val;
    if (val is String) {
      final parsed = DateTime.tryParse(val);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  /// Create a DriverModel from Document Snapshot, Supabase row, or Map.
  factory DriverModel.fromMap(Map<String, dynamic> map, String docId) {
    final dutyVal = map['duty_status'] ?? map['is_on_duty'] ?? map['isOnDuty'];
    final tripsVal = map['completed_deliveries'] ??
        map['completed_trips'] ??
        map['completedTrips'];

    return DriverModel(
      id: docId,
      fullName: map['full_name'] as String? ??
          map['fullName'] as String? ??
          '',
      licenseNumber: map['license_number'] as String? ??
          map['licenseNumber'] as String? ??
          '',
      mobileNumber: map['phone_number'] as String? ??
          map['mobileNumber'] as String? ??
          '',
      vehicleType: map['vehicle_type'] as String? ??
          map['vehicleType'] as String? ??
          '',
      plateNumber: map['vehicle_number'] as String? ??
          map['plate_number'] as String? ??
          map['plateNumber'] as String? ??
          '',
      cargoCapacity: map['cargo_capacity'] as String? ??
          map['cargoCapacity'] as String? ??
          '',
      isColdBoxEquipped: (map['is_cold_box_equipped'] ??
              map['isColdBoxEquipped']) as bool? ??
          false,
      operatingCorridors: List<String>.from(
          map['operating_corridors'] ?? map['operatingCorridors'] ?? []),
      bankName: map['bank_name'] as String? ??
          map['bankName'] as String? ??
          '',
      accountNumber: map['bank_account_number'] as String? ??
          map['account_number'] as String? ??
          map['accountNumber'] as String? ??
          '',
      isOnDuty: dutyVal is bool ? dutyVal : true,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      completedTrips: (tripsVal as num?)?.toInt() ?? 0,
      createdAt: _parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: _parseDate(map['updated_at'] ?? map['updatedAt']),
      scheduledDeliveries: (map['scheduledDeliveries'] as num?)?.toInt() ?? 6,
      deliveredToday: (map['deliveredToday'] as num?)?.toInt() ?? 4,
      netEarnings: (map['netEarnings'] as num?)?.toDouble() ?? 7850.0,
      activeOrderId: map['activeOrderId'] as String? ?? '#FH-8841',
      activeFarmerName: map['activeFarmerName'] as String? ?? 'Farmer Bandar',
      activeFarmLocation: map['activeFarmLocation'] as String? ?? 'Hakgala Organic Farm',
      activeEstPayout: (map['activeEstPayout'] as num?)?.toDouble() ?? 1450.0,
      activeCargoItem: map['activeCargoItem'] as String? ?? '5 kg Fresh Carrots & Leeks',
      activeCrate: map['activeCrate'] as String? ?? 'Crate #C',
      activePickupLocation: map['activePickupLocation'] as String? ?? 'Upper Division Gate B, Hakgala Rd',
    );
  }

  /// Create a copy of DriverModel with updated properties.
  DriverModel copyWith({
    String? id,
    String? fullName,
    String? licenseNumber,
    String? mobileNumber,
    String? vehicleType,
    String? plateNumber,
    String? cargoCapacity,
    bool? isColdBoxEquipped,
    List<String>? operatingCorridors,
    String? bankName,
    String? accountNumber,
    bool? isOnDuty,
    double? rating,
    int? completedTrips,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? scheduledDeliveries,
    int? deliveredToday,
    double? netEarnings,
    String? activeOrderId,
    String? activeFarmerName,
    String? activeFarmLocation,
    double? activeEstPayout,
    String? activeCargoItem,
    String? activeCrate,
    String? activePickupLocation,
  }) {
    return DriverModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      cargoCapacity: cargoCapacity ?? this.cargoCapacity,
      isColdBoxEquipped: isColdBoxEquipped ?? this.isColdBoxEquipped,
      operatingCorridors: operatingCorridors ?? this.operatingCorridors,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isOnDuty: isOnDuty ?? this.isOnDuty,
      rating: rating ?? this.rating,
      completedTrips: completedTrips ?? this.completedTrips,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduledDeliveries: scheduledDeliveries ?? this.scheduledDeliveries,
      deliveredToday: deliveredToday ?? this.deliveredToday,
      netEarnings: netEarnings ?? this.netEarnings,
      activeOrderId: activeOrderId ?? this.activeOrderId,
      activeFarmerName: activeFarmerName ?? this.activeFarmerName,
      activeFarmLocation: activeFarmLocation ?? this.activeFarmLocation,
      activeEstPayout: activeEstPayout ?? this.activeEstPayout,
      activeCargoItem: activeCargoItem ?? this.activeCargoItem,
      activeCrate: activeCrate ?? this.activeCrate,
      activePickupLocation: activePickupLocation ?? this.activePickupLocation,
    );
  }
}
