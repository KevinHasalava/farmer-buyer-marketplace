/// Delivery order data model for Assigned Deliveries (CRUD 2).
class DeliveryOrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String crateCount;
  final String pickupDueText;
  final String farmerName;
  final String farmerAddress;
  final String buyerName;
  final String buyerAddress;
  final String produceDescription;
  final String producePackageType;
  final double driverFee;
  final bool isPriority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeliveryOrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.crateCount,
    required this.pickupDueText,
    required this.farmerName,
    required this.farmerAddress,
    required this.buyerName,
    required this.buyerAddress,
    required this.produceDescription,
    required this.producePackageType,
    required this.driverFee,
    this.isPriority = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'status': status,
      'crateCount': crateCount,
      'pickupDueText': pickupDueText,
      'farmerName': farmerName,
      'farmerAddress': farmerAddress,
      'buyerName': buyerName,
      'buyerAddress': buyerAddress,
      'produceDescription': produceDescription,
      'producePackageType': producePackageType,
      'driverFee': driverFee,
      'isPriority': isPriority,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
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

  factory DeliveryOrderModel.fromMap(Map<String, dynamic> map, String docId) {
    final feeVal = (map['driverFee'] as num?)?.toDouble() ??
        (map['driver_fee'] as num?)?.toDouble() ??
        (map['payout_amount'] != null
            ? double.tryParse(map['payout_amount'].toString().replaceAll(RegExp(r'[^0-9.]'), ''))
            : null) ??
        (map['cod_amount'] != null
            ? double.tryParse(map['cod_amount'].toString().replaceAll(RegExp(r'[^0-9.]'), ''))
            : null) ??
        0.0;

    return DeliveryOrderModel(
      id: docId,
      orderNumber: map['orderNumber'] as String? ??
          map['order_number'] as String? ??
          '#$docId',
      status: map['status'] as String? ?? 'Pending',
      crateCount: map['crateCount'] as String? ??
          map['crate_count'] as String? ??
          '1 Crate',
      pickupDueText: map['pickupDueText'] as String? ?? 'Pickup Pending',
      farmerName: map['farmerName'] as String? ??
          map['farmer_name'] as String? ??
          'Farmer',
      farmerAddress: map['farmerAddress'] as String? ??
          map['farmer_address'] as String? ??
          'Farm Depot',
      buyerName: map['buyerName'] as String? ??
          map['buyer_name'] as String? ??
          'Buyer',
      buyerAddress: map['buyerAddress'] as String? ??
          map['buyer_address'] as String? ??
          '',
      produceDescription: map['produceDescription'] as String? ??
          map['items_summary'] as String? ??
          'Fresh Farm Produce',
      producePackageType: map['producePackageType'] as String? ??
          'Cool storage packed',
      driverFee: feeVal,
      isPriority: map['isPriority'] as bool? ??
          map['is_priority'] as bool? ??
          false,
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  DeliveryOrderModel copyWith({
    String? id,
    String? orderNumber,
    String? status,
    String? crateCount,
    String? pickupDueText,
    String? farmerName,
    String? farmerAddress,
    String? buyerName,
    String? buyerAddress,
    String? produceDescription,
    String? producePackageType,
    double? driverFee,
    bool? isPriority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryOrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      crateCount: crateCount ?? this.crateCount,
      pickupDueText: pickupDueText ?? this.pickupDueText,
      farmerName: farmerName ?? this.farmerName,
      farmerAddress: farmerAddress ?? this.farmerAddress,
      buyerName: buyerName ?? this.buyerName,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      produceDescription: produceDescription ?? this.produceDescription,
      producePackageType: producePackageType ?? this.producePackageType,
      driverFee: driverFee ?? this.driverFee,
      isPriority: isPriority ?? this.isPriority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
