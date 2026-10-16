
class PreOrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String? farmerId;
  final String? farmerName;
  final String cropName;
  final double requiredQuantityKg;
  final double offeredPricePerKg;
  final DateTime expectedDeliveryDate;
  final String qualityRequirements;
  final String deliveryLocation;
  final String paymentTerms;
  final String packagingRequirements;
  final double advancePaymentRs;
  final String status; // 'Pending', 'Accepted', 'In Progress', 'Completed', 'Cancelled'
  final DateTime createdAt;

  // Farmer's Proposal / Acceptance Details
  final DateTime? farmerExpectedHarvestDate;
  final double? farmerEstimatedYieldKg;
  final String farmerLocation;
  final String farmerNotes;

  // Rating Details
  final double? farmerRating;
  final String? farmerReview;
  final DateTime? ratedAt;

  const PreOrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    this.farmerId,
    this.farmerName,
    required this.cropName,
    required this.requiredQuantityKg,
    required this.offeredPricePerKg,
    required this.expectedDeliveryDate,
    required this.qualityRequirements,
    this.deliveryLocation = '',
    this.paymentTerms = 'Negotiable',
    this.packagingRequirements = 'Standard Packaging',
    this.advancePaymentRs = 0.0,
    this.status = 'Pending',
    required this.createdAt,
    this.farmerExpectedHarvestDate,
    this.farmerEstimatedYieldKg,
    this.farmerLocation = '',
    this.farmerNotes = '',
    this.farmerRating,
    this.farmerReview,
    this.ratedAt,
  });

  PreOrderModel copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? farmerId,
    String? farmerName,
    String? cropName,
    double? requiredQuantityKg,
    double? offeredPricePerKg,
    DateTime? expectedDeliveryDate,
    String? qualityRequirements,
    String? deliveryLocation,
    String? paymentTerms,
    String? packagingRequirements,
    double? advancePaymentRs,
    String? status,
    DateTime? createdAt,
    DateTime? farmerExpectedHarvestDate,
    double? farmerEstimatedYieldKg,
    String? farmerLocation,
    String? farmerNotes,
    double? farmerRating,
    String? farmerReview,
    DateTime? ratedAt,
  }) {
    return PreOrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      cropName: cropName ?? this.cropName,
      requiredQuantityKg: requiredQuantityKg ?? this.requiredQuantityKg,
      offeredPricePerKg: offeredPricePerKg ?? this.offeredPricePerKg,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      qualityRequirements: qualityRequirements ?? this.qualityRequirements,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      packagingRequirements: packagingRequirements ?? this.packagingRequirements,
      advancePaymentRs: advancePaymentRs ?? this.advancePaymentRs,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      farmerExpectedHarvestDate: farmerExpectedHarvestDate ?? this.farmerExpectedHarvestDate,
      farmerEstimatedYieldKg: farmerEstimatedYieldKg ?? this.farmerEstimatedYieldKg,
      farmerLocation: farmerLocation ?? this.farmerLocation,
      farmerNotes: farmerNotes ?? this.farmerNotes,
      farmerRating: farmerRating ?? this.farmerRating,
      farmerReview: farmerReview ?? this.farmerReview,
      ratedAt: ratedAt ?? this.ratedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'crop_name': cropName,
      'required_quantity_kg': requiredQuantityKg,
      'offered_price_per_kg': offeredPricePerKg,
      'expected_delivery_date': expectedDeliveryDate.toIso8601String(),
      'quality_requirements': qualityRequirements,
      'delivery_location': deliveryLocation,
      'payment_terms': paymentTerms,
      'packaging_requirements': packagingRequirements,
      'advance_payment_rs': advancePaymentRs,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'farmer_expected_harvest_date': farmerExpectedHarvestDate?.toIso8601String(),
      'farmer_estimated_yield_kg': farmerEstimatedYieldKg,
      'farmer_location': farmerLocation,
      'farmer_notes': farmerNotes,
      'farmer_rating': farmerRating,
      'farmer_review': farmerReview,
      'rated_at': ratedAt?.toIso8601String(),
    };
  }

  factory PreOrderModel.fromJson(Map<String, dynamic> map) {
    final rawStatus = (map['status'] as String? ?? 'Pending').trim();
    String normStatus;
    if (rawStatus.toUpperCase() == 'ACCEPTED') {
      normStatus = 'Accepted';
    } else if (rawStatus.toUpperCase() == 'IN PROGRESS') {
      normStatus = 'In Progress';
    } else if (rawStatus.toUpperCase() == 'COMPLETED') {
      normStatus = 'Completed';
    } else if (rawStatus.toUpperCase() == 'CANCELLED') {
      normStatus = 'Cancelled';
    } else {
      normStatus = 'Pending';
    }

    return PreOrderModel(
      id: map['id'] as String? ?? 'po_${DateTime.now().millisecondsSinceEpoch}',
      buyerId: map['buyer_id'] as String? ?? 'buyer_1',
      buyerName: map['buyer_name'] as String? ?? 'Buyer Name',
      farmerId: map['farmer_id'] as String?,
      farmerName: map['farmer_name'] as String?,
      cropName: map['crop_name'] as String? ?? 'Crop Name',
      requiredQuantityKg: (map['required_quantity_kg'] as num?)?.toDouble() ??
          (map['required_quantity'] as num?)?.toDouble() ??
          0.0,
      offeredPricePerKg: (map['offered_price_per_kg'] as num?)?.toDouble() ??
          (map['offered_price'] as num?)?.toDouble() ??
          0.0,
      expectedDeliveryDate: map['expected_delivery_date'] != null
          ? DateTime.tryParse(map['expected_delivery_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      qualityRequirements: map['quality_requirements'] as String? ?? '',
      deliveryLocation: map['delivery_location'] as String? ?? '',
      paymentTerms: map['payment_terms'] as String? ?? 'Negotiable',
      packagingRequirements: map['packaging_requirements'] as String? ?? 'Standard Packaging',
      advancePaymentRs: (map['advance_payment_rs'] as num?)?.toDouble() ?? 0.0,
      status: normStatus,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      farmerExpectedHarvestDate: map['farmer_expected_harvest_date'] != null
          ? DateTime.tryParse(map['farmer_expected_harvest_date'] as String)
          : null,
      farmerEstimatedYieldKg: (map['farmer_estimated_yield_kg'] as num?)?.toDouble(),
      farmerLocation: map['farmer_location'] as String? ?? '',
      farmerNotes: map['farmer_notes'] as String? ?? '',
      farmerRating: (map['farmer_rating'] as num?)?.toDouble(),
      farmerReview: map['farmer_review'] as String?,
      ratedAt: map['rated_at'] != null ? DateTime.tryParse(map['rated_at'] as String) : null,
    );
  }

  static List<PreOrderModel> get samplePreOrders => [
    PreOrderModel(
      id: 'po_101',
      buyerId: 'buyer_chamara',
      buyerName: 'Chamara Perera (GreenMart)',
      cropName: 'Organic Highland Carrots',
      requiredQuantityKg: 500.0,
      offeredPricePerKg: 350.0,
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 25)),
      qualityRequirements: 'Grade-A, length 15-20cm, washed & sorted, zero synthetic pesticide residues',
      deliveryLocation: 'Dambulla Dedicated Economic Centre, Bay 14',
      paymentTerms: 'Advance Payment (Partial)',
      packagingRequirements: '25Kg Ventilated Plastic Crates',
      advancePaymentRs: 50000.0,
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PreOrderModel(
      id: 'po_102',
      buyerId: 'buyer_super_fresh',
      buyerName: 'Lanka Fresh Markets Ltd',
      farmerId: 'farmer_bandara',
      farmerName: 'K. M. Bandara',
      cropName: 'Red Onions (Dambulla Big Variety)',
      requiredQuantityKg: 1200.0,
      offeredPricePerKg: 420.0,
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 45)),
      qualityRequirements: 'Cured bulbs, min diameter 45mm, skin intact, moisture below 14%',
      deliveryLocation: 'Pettah Wholesale Hub, Colombo 11',
      paymentTerms: 'Bank Transfer on Delivery',
      packagingRequirements: '50Kg Jute Gunny Bags',
      advancePaymentRs: 100000.0,
      status: 'In Progress',
      farmerExpectedHarvestDate: DateTime.now().add(const Duration(days: 40)),
      farmerEstimatedYieldKg: 1350.0,
      farmerLocation: 'Nuwara Eliya / Dambulla Belt',
      farmerNotes: 'Drip-irrigated seed beds prepared. High germination rate confirmed.',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    PreOrderModel(
      id: 'po_103',
      buyerId: 'buyer_keells',
      buyerName: 'Keells Super Procurement',
      farmerId: 'farmer_bandara',
      farmerName: 'K. M. Bandara',
      cropName: 'Green Chillies (MI-2 Variety)',
      requiredQuantityKg: 800.0,
      offeredPricePerKg: 650.0,
      expectedDeliveryDate: DateTime.now().subtract(const Duration(days: 3)),
      qualityRequirements: 'Dark green, 8-10cm, crisp texture, harvest fresh within 12 hours',
      deliveryLocation: 'Kerawalapitiya Central Logistics Centre',
      paymentTerms: 'Full Advance',
      packagingRequirements: '20Kg Aerated Corrugated Cartons',
      advancePaymentRs: 200000.0,
      status: 'Completed',
      farmerExpectedHarvestDate: DateTime.now().subtract(const Duration(days: 5)),
      farmerEstimatedYieldKg: 850.0,
      farmerLocation: 'Nuwara Eliya Agro Zone',
      farmerNotes: 'Harvest completed smoothly and packed according to supermarkets spec.',
      farmerRating: 5.0,
      farmerReview: 'Exceptional quality chillies, exactly as contracted. Perfectly graded and timely delivery!',
      ratedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];
}
