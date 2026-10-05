import 'package:cloud_firestore/cloud_firestore.dart';

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
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  factory DeliveryOrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return DeliveryOrderModel(
      id: docId,
      orderNumber: map['orderNumber'] as String? ?? '#FH-8841',
      status: map['status'] as String? ?? 'Ready for Pickup',
      crateCount: map['crateCount'] as String? ?? '1 Crate',
      pickupDueText: map['pickupDueText'] as String? ?? 'Pickup Due in 20m',
      farmerName: map['farmerName'] as String? ?? 'K. M. Bandara',
      farmerAddress: map['farmerAddress'] as String? ?? 'Upper Division, Hakgala Rd, Nuwara Eliya',
      buyerName: map['buyerName'] as String? ?? 'Chaminda Perera',
      buyerAddress: map['buyerAddress'] as String? ?? 'No. 42 Havelock Rd, Colombo 05',
      produceDescription: map['produceDescription'] as String? ?? '5 kg (Carrots & Leeks)',
      producePackageType: map['producePackageType'] as String? ?? 'Cool storage packed',
      driverFee: (map['driverFee'] as num?)?.toDouble() ?? 1450.0,
      isPriority: map['isPriority'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
