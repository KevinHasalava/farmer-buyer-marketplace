/// Data model representing a Pickup Verification Audit Log entry.
/// Used for CREATE (C) and READ (R) on the Pickup Verification Screen.
class PickupVerificationModel {
  final String id;
  final String orderId;
  final String crateId;
  final String farmerName;
  final String farmLocation;
  final String gateInfo;
  final String handoverPin;
  final bool isPinMatched;
  final double vanTemperature;
  final double ambientTemperature;
  final String verifiedWeight;
  final List<String> checklistItems;
  final String status;
  final DateTime verifiedAt;

  PickupVerificationModel({
    required this.id,
    required this.orderId,
    required this.crateId,
    required this.farmerName,
    required this.farmLocation,
    required this.gateInfo,
    required this.handoverPin,
    required this.isPinMatched,
    required this.vanTemperature,
    required this.ambientTemperature,
    required this.verifiedWeight,
    required this.checklistItems,
    required this.status,
    required this.verifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'crateId': crateId,
      'farmerName': farmerName,
      'farmLocation': farmLocation,
      'gateInfo': gateInfo,
      'handoverPin': handoverPin,
      'isPinMatched': isPinMatched,
      'vanTemperature': vanTemperature,
      'ambientTemperature': ambientTemperature,
      'verifiedWeight': verifiedWeight,
      'checklistItems': checklistItems,
      'status': status,
      'verifiedAt': verifiedAt.toIso8601String(),
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

  factory PickupVerificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return PickupVerificationModel(
      id: docId,
      orderId: map['orderId']?.toString() ?? '',
      crateId: map['crateId']?.toString() ?? '',
      farmerName: map['farmerName']?.toString() ?? '',
      farmLocation: map['farmLocation']?.toString() ?? '',
      gateInfo: map['gateInfo']?.toString() ?? '',
      handoverPin: map['handoverPin']?.toString() ?? '',
      isPinMatched: map['isPinMatched'] == true,
      vanTemperature: (map['vanTemperature'] as num?)?.toDouble() ?? 4.2,
      ambientTemperature: (map['ambientTemperature'] as num?)?.toDouble() ?? 16.0,
      verifiedWeight: map['verifiedWeight']?.toString() ?? '5.0 kg',
      checklistItems: List<String>.from(map['checklistItems'] ?? []),
      status: map['status']?.toString() ?? 'VERIFIED_AND_LOADED',
      verifiedAt: _parseDate(map['verifiedAt']),
    );
  }

  PickupVerificationModel copyWith({
    String? id,
    String? orderId,
    String? crateId,
    String? farmerName,
    String? farmLocation,
    String? gateInfo,
    String? handoverPin,
    bool? isPinMatched,
    double? vanTemperature,
    double? ambientTemperature,
    String? verifiedWeight,
    List<String>? checklistItems,
    String? status,
    DateTime? verifiedAt,
  }) {
    return PickupVerificationModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      crateId: crateId ?? this.crateId,
      farmerName: farmerName ?? this.farmerName,
      farmLocation: farmLocation ?? this.farmLocation,
      gateInfo: gateInfo ?? this.gateInfo,
      handoverPin: handoverPin ?? this.handoverPin,
      isPinMatched: isPinMatched ?? this.isPinMatched,
      vanTemperature: vanTemperature ?? this.vanTemperature,
      ambientTemperature: ambientTemperature ?? this.ambientTemperature,
      verifiedWeight: verifiedWeight ?? this.verifiedWeight,
      checklistItems: checklistItems ?? this.checklistItems,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
