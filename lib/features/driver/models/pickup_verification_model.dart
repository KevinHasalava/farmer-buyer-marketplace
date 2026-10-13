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

  /// Maps directly to remote Supabase `public.pickup_verifications` columns.
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'order_id': orderId,
      'crate_id': crateId,
      'farmer_name': farmerName,
      'farm_location': farmLocation,
      'gate_info': gateInfo,
      'handover_pin': handoverPin,
      'is_pin_matched': isPinMatched,
      'van_temp': '${vanTemperature.toStringAsFixed(1)}°C',
      'ambient_temp': '${ambientTemperature.toStringAsFixed(1)}°C',
      'verified_weight': verifiedWeight,
      'checklist_items': checklistItems,
      'status': status,
      'verified_at': verifiedAt.toIso8601String(),
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
    final vTemp = (map['vanTemperature'] as num?)?.toDouble() ??
        (map['van_temp'] != null
            ? double.tryParse(map['van_temp'].toString().replaceAll(RegExp(r'[^0-9.]'), ''))
            : null) ??
        4.2;

    final aTemp = (map['ambientTemperature'] as num?)?.toDouble() ??
        (map['ambient_temp'] != null
            ? double.tryParse(map['ambient_temp'].toString().replaceAll(RegExp(r'[^0-9.]'), ''))
            : null) ??
        16.0;

    return PickupVerificationModel(
      id: docId,
      orderId: map['order_id']?.toString() ??
          map['orderId']?.toString() ??
          '',
      crateId: map['crate_id']?.toString() ??
          map['crateId']?.toString() ??
          '',
      farmerName: map['farmer_name']?.toString() ??
          map['farmerName']?.toString() ??
          '',
      farmLocation: map['farm_location']?.toString() ??
          map['farmLocation']?.toString() ??
          '',
      gateInfo: map['gate_info']?.toString() ??
          map['gateInfo']?.toString() ??
          '',
      handoverPin: map['handover_pin']?.toString() ??
          map['handoverPin']?.toString() ??
          '',
      isPinMatched: map['is_pin_matched'] == true ||
          map['isPinMatched'] == true,
      vanTemperature: vTemp,
      ambientTemperature: aTemp,
      verifiedWeight: map['verified_weight']?.toString() ??
          map['verifiedWeight']?.toString() ??
          '5.0 kg',
      checklistItems: List<String>.from(
          map['checklist_items'] ?? map['checklistItems'] ?? []),
      status: map['status']?.toString() ?? 'VERIFIED_AND_LOADED',
      verifiedAt: _parseDate(map['verified_at'] ?? map['verifiedAt']),
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
