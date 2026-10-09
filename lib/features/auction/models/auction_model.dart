import 'bid_model.dart';

class AuctionModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String farmerLocation;
  final String farmerAvatar;
  final String cropName;
  final String category;
  final double quantity;
  final String unit; // 'kg', 'crates', 'bags', etc.
  final double startingPrice; // Per unit
  final double minBidIncrement;
  final double? reservePrice; // Minimum acceptable price per unit
  final double? buyNowPrice; // Instant buy price per unit
  final double currentHighestBid; // Current top bid per unit
  final String? highestBidderId;
  final String? highestBidderName;
  final int totalBids;
  final String description;
  final DateTime? harvestDate;
  final String deliveryTerms;
  final String location;
  final String imageUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'active', 'ended', 'sold', 'cancelled'
  final DateTime createdAt;
  final List<BidModel> bids;

  const AuctionModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    this.farmerPhone = '',
    required this.farmerLocation,
    this.farmerAvatar = '',
    required this.cropName,
    required this.category,
    required this.quantity,
    this.unit = 'kg',
    required this.startingPrice,
    this.minBidIncrement = 5.0,
    this.reservePrice,
    this.buyNowPrice,
    this.currentHighestBid = 0.0,
    this.highestBidderId,
    this.highestBidderName,
    this.totalBids = 0,
    required this.description,
    this.harvestDate,
    this.deliveryTerms = 'Farmgate Pickup / Flexible',
    required this.location,
    required this.imageUrl,
    required this.startTime,
    required this.endTime,
    this.status = 'active',
    required this.createdAt,
    this.bids = const [],
  });

  bool get isActive {
    if (status != 'active') return false;
    return DateTime.now().isBefore(endTime);
  }

  bool get isEnded => status == 'ended' || (status == 'active' && DateTime.now().isAfter(endTime));

  bool get isSold => status == 'sold';

  bool get isCancelled => status == 'cancelled';

  Duration get remainingDuration {
    final now = DateTime.now();
    if (endTime.isAfter(now)) {
      return endTime.difference(now);
    }
    return Duration.zero;
  }

  String get remainingTimeString {
    if (isEnded) return 'Auction Closed';
    if (isSold) return 'Sold';
    if (isCancelled) return 'Cancelled';

    final dur = remainingDuration;
    if (dur.inDays > 0) {
      final hours = dur.inHours % 24;
      return '${dur.inDays}d ${hours}h left';
    } else if (dur.inHours > 0) {
      final minutes = dur.inMinutes % 60;
      return '${dur.inHours}h ${minutes}m left';
    } else if (dur.inMinutes > 0) {
      final seconds = dur.inSeconds % 60;
      return '${dur.inMinutes}m ${seconds}s left';
    } else {
      return '${dur.inSeconds}s left';
    }
  }

  double get minNextBid {
    if (currentHighestBid > 0) {
      return currentHighestBid + minBidIncrement;
    }
    return startingPrice;
  }

  double get effectivePrice => currentHighestBid > 0 ? currentHighestBid : startingPrice;

  double get totalLotValue => effectivePrice * quantity;

  AuctionModel copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? farmerPhone,
    String? farmerLocation,
    String? farmerAvatar,
    String? cropName,
    String? category,
    double? quantity,
    String? unit,
    double? startingPrice,
    double? minBidIncrement,
    double? reservePrice,
    double? buyNowPrice,
    double? currentHighestBid,
    String? highestBidderId,
    String? highestBidderName,
    int? totalBids,
    String? description,
    DateTime? harvestDate,
    String? deliveryTerms,
    String? location,
    String? imageUrl,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    DateTime? createdAt,
    List<BidModel>? bids,
  }) {
    return AuctionModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      farmerLocation: farmerLocation ?? this.farmerLocation,
      farmerAvatar: farmerAvatar ?? this.farmerAvatar,
      cropName: cropName ?? this.cropName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      startingPrice: startingPrice ?? this.startingPrice,
      minBidIncrement: minBidIncrement ?? this.minBidIncrement,
      reservePrice: reservePrice ?? this.reservePrice,
      buyNowPrice: buyNowPrice ?? this.buyNowPrice,
      currentHighestBid: currentHighestBid ?? this.currentHighestBid,
      highestBidderId: highestBidderId ?? this.highestBidderId,
      highestBidderName: highestBidderName ?? this.highestBidderName,
      totalBids: totalBids ?? this.totalBids,
      description: description ?? this.description,
      harvestDate: harvestDate ?? this.harvestDate,
      deliveryTerms: deliveryTerms ?? this.deliveryTerms,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      bids: bids ?? this.bids,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'farmerLocation': farmerLocation,
      'farmerAvatar': farmerAvatar,
      'cropName': cropName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'startingPrice': startingPrice,
      'minBidIncrement': minBidIncrement,
      'reservePrice': reservePrice,
      'buyNowPrice': buyNowPrice,
      'currentHighestBid': currentHighestBid,
      'highestBidderId': highestBidderId,
      'highestBidderName': highestBidderName,
      'totalBids': totalBids,
      'description': description,
      'harvestDate': harvestDate?.toIso8601String(),
      'deliveryTerms': deliveryTerms,
      'location': location,
      'imageUrl': imageUrl,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'bids': bids.map((b) => b.toJson()).toList(),
    };
  }

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    return AuctionModel(
      id: json['id'] as String? ?? '',
      farmerId: json['farmerId'] as String? ?? '',
      farmerName: json['farmerName'] as String? ?? 'Farmer',
      farmerPhone: json['farmerPhone'] as String? ?? '',
      farmerLocation: json['farmerLocation'] as String? ?? '',
      farmerAvatar: json['farmerAvatar'] as String? ?? '',
      cropName: json['cropName'] as String? ?? '',
      category: json['category'] as String? ?? 'Vegetables',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'kg',
      startingPrice: (json['startingPrice'] as num?)?.toDouble() ?? 0.0,
      minBidIncrement: (json['minBidIncrement'] as num?)?.toDouble() ?? 5.0,
      reservePrice: (json['reservePrice'] as num?)?.toDouble(),
      buyNowPrice: (json['buyNowPrice'] as num?)?.toDouble(),
      currentHighestBid: (json['currentHighestBid'] as num?)?.toDouble() ?? 0.0,
      highestBidderId: json['highestBidderId'] as String?,
      highestBidderName: json['highestBidderName'] as String?,
      totalBids: json['totalBids'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      harvestDate: json['harvestDate'] != null
          ? DateTime.tryParse(json['harvestDate'] as String)
          : null,
      deliveryTerms: json['deliveryTerms'] as String? ?? 'Farmgate Pickup',
      location: json['location'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String) ?? DateTime.now().add(const Duration(days: 1))
          : DateTime.now().add(const Duration(days: 1)),
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      bids: (json['bids'] as List<dynamic>?)
              ?.map((e) => BidModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static List<AuctionModel> get sampleAuctions {
    final now = DateTime.now();
    return [
      AuctionModel(
        id: 'auc_101',
        farmerId: 'farmer_01',
        farmerName: 'Sunil Bandara',
        farmerPhone: '+94 77 123 4567',
        farmerLocation: 'Polonnaruwa, North Central',
        farmerAvatar: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=200&auto=format&fit=crop&q=80',
        cropName: 'Keeri Samba Paddy (Grade A)',
        category: 'Grains & Rice',
        quantity: 2500,
        unit: 'kg',
        startingPrice: 195.0,
        minBidIncrement: 5.0,
        reservePrice: 215.0,
        buyNowPrice: 240.0,
        currentHighestBid: 210.0,
        highestBidderId: 'buyer_05',
        highestBidderName: 'Lakshmi Wholesale Stores',
        totalBids: 14,
        description: 'Naturally sun-dried premium Keeri Samba harvest. Low moisture content (<12%), freshly bagged in 50kg standard jute sacks.',
        harvestDate: now.subtract(const Duration(days: 3)),
        deliveryTerms: 'Truck delivery arranged to Western / Central Province or Farmgate pickup.',
        location: 'Polonnaruwa Paddy Complex',
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80',
        startTime: now.subtract(const Duration(hours: 18)),
        endTime: now.add(const Duration(hours: 6, minutes: 45)),
        status: 'active',
        createdAt: now.subtract(const Duration(hours: 18)),
        bids: [
          BidModel(
            id: 'bid_101_3',
            auctionId: 'auc_101',
            bidderId: 'buyer_05',
            bidderName: 'Lakshmi Wholesale Stores',
            amount: 210.0,
            createdAt: now.subtract(const Duration(minutes: 15)),
            isWinning: true,
            notes: 'Ready for full lot pickup on Friday.',
          ),
          BidModel(
            id: 'bid_101_2',
            auctionId: 'auc_101',
            bidderId: 'buyer_02',
            bidderName: 'Royal Rice Millers',
            amount: 205.0,
            createdAt: now.subtract(const Duration(hours: 2)),
            isWinning: false,
          ),
          BidModel(
            id: 'bid_101_1',
            auctionId: 'auc_101',
            bidderId: 'buyer_08',
            bidderName: 'Sampath Traders',
            amount: 200.0,
            createdAt: now.subtract(const Duration(hours: 8)),
            isWinning: false,
          ),
        ],
      ),
      AuctionModel(
        id: 'auc_102',
        farmerId: 'farmer_02',
        farmerName: 'Kavinda Jayasinghe',
        farmerPhone: '+94 71 889 2211',
        farmerLocation: 'Nuwara Eliya, Central',
        farmerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
        cropName: 'Highland Red Potatoes (Export Quality)',
        category: 'Vegetables',
        quantity: 1200,
        unit: 'kg',
        startingPrice: 320.0,
        minBidIncrement: 10.0,
        reservePrice: 360.0,
        buyNowPrice: 400.0,
        currentHighestBid: 350.0,
        highestBidderId: 'buyer_03',
        highestBidderName: 'FreshBasket Supermarkets',
        totalBids: 9,
        description: 'Freshly dug Nuwara Eliya potatoes. Uniform size, washed, sorted, free of soil clumps. Packed in 25kg aerated plastic crates.',
        harvestDate: now.add(const Duration(days: 1)),
        deliveryTerms: 'Cooled truck dispatch available directly to Manning Market Colombo or Kandy.',
        location: 'Meepilimana Farm, Nuwara Eliya',
        imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80',
        startTime: now.subtract(const Duration(hours: 10)),
        endTime: now.add(const Duration(hours: 14, minutes: 20)),
        status: 'active',
        createdAt: now.subtract(const Duration(hours: 10)),
        bids: [
          BidModel(
            id: 'bid_102_2',
            auctionId: 'auc_102',
            bidderId: 'buyer_03',
            bidderName: 'FreshBasket Supermarkets',
            amount: 350.0,
            createdAt: now.subtract(const Duration(minutes: 45)),
            isWinning: true,
          ),
          BidModel(
            id: 'bid_102_1',
            auctionId: 'auc_102',
            bidderId: 'buyer_11',
            bidderName: 'Lanka Agro Mart',
            amount: 335.0,
            createdAt: now.subtract(const Duration(hours: 4)),
            isWinning: false,
          ),
        ],
      ),
      AuctionModel(
        id: 'auc_103',
        farmerId: 'farmer_03',
        farmerName: 'Tharindu Rathnayake',
        farmerPhone: '+94 76 554 1122',
        farmerLocation: 'Dambulla, Central',
        farmerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
        cropName: 'Spicy Green Chillies (Dambulla Fresh)',
        category: 'Vegetables',
        quantity: 450,
        unit: 'kg',
        startingPrice: 650.0,
        minBidIncrement: 20.0,
        reservePrice: 720.0,
        buyNowPrice: 850.0,
        currentHighestBid: 740.0,
        highestBidderId: 'buyer_09',
        highestBidderName: 'SpiceRoute Exporters',
        totalBids: 18,
        description: 'Crisp, fiery green chillies picked at dawn. Cleaned and packed in breathable cardboard boxes. Zero pesticide residue.',
        harvestDate: now,
        deliveryTerms: 'Immediate pickup at Dambulla Dedicated Economic Centre.',
        location: 'Dambulla DEC, Gate 4',
        imageUrl: 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80',
        startTime: now.subtract(const Duration(hours: 22)),
        endTime: now.add(const Duration(hours: 1, minutes: 50)), // Ending very soon!
        status: 'active',
        createdAt: now.subtract(const Duration(hours: 22)),
        bids: [
          BidModel(
            id: 'bid_103_1',
            auctionId: 'auc_103',
            bidderId: 'buyer_09',
            bidderName: 'SpiceRoute Exporters',
            amount: 740.0,
            createdAt: now.subtract(const Duration(minutes: 8)),
            isWinning: true,
          ),
        ],
      ),
      AuctionModel(
        id: 'auc_104',
        farmerId: 'farmer_04',
        farmerName: 'Sivakumaran Nadarajah',
        farmerPhone: '+94 77 332 9988',
        farmerLocation: 'Jaffna, Northern',
        farmerAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&auto=format&fit=crop&q=80',
        cropName: 'Jaffna Red Onions (Direct Farm Lot)',
        category: 'Vegetables',
        quantity: 1800,
        unit: 'kg',
        startingPrice: 280.0,
        minBidIncrement: 5.0,
        reservePrice: 310.0,
        buyNowPrice: 350.0,
        currentHighestBid: 305.0,
        highestBidderId: 'buyer_01',
        highestBidderName: 'Cargills Food Distribution',
        totalBids: 11,
        description: 'Authentic Jaffna small red onions, well cured and dried. High pungency, firm skin, suitable for long shelf life storage.',
        harvestDate: now.subtract(const Duration(days: 2)),
        deliveryTerms: 'Railway transport to Fort Station or highway container transport.',
        location: 'Chavakachcheri, Jaffna',
        imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80',
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now.add(const Duration(days: 1, hours: 8)),
        status: 'active',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AuctionModel(
        id: 'auc_105',
        farmerId: 'farmer_05',
        farmerName: 'Mahinda Senanayake',
        farmerPhone: '+94 70 445 6677',
        farmerLocation: 'Matale, Central',
        farmerAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200&auto=format&fit=crop&q=80',
        cropName: 'Organic Ceylon Cinnamon Quills (Alba Grade)',
        category: 'Spices & Herbs',
        quantity: 120,
        unit: 'kg',
        startingPrice: 3800.0,
        minBidIncrement: 50.0,
        reservePrice: 4200.0,
        buyNowPrice: 4800.0,
        currentHighestBid: 4350.0,
        highestBidderId: 'buyer_07',
        highestBidderName: 'Ceylon Naturals Organic Exporters',
        totalBids: 22,
        description: 'Certified Alba grade pure Ceylon cinnamon rolls. Sweet aroma, paper-thin golden layers, harvested from certified organic family estate.',
        harvestDate: now.subtract(const Duration(days: 5)),
        deliveryTerms: 'Secure courier / insured freight across Sri Lanka.',
        location: 'Ukuwela Spice Estate, Matale',
        imageUrl: 'https://images.unsplash.com/photo-1509358271058-acd22cc93898?w=600&auto=format&fit=crop&q=80',
        startTime: now.subtract(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 2)),
        status: 'active',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      AuctionModel(
        id: 'auc_106',
        farmerId: 'farmer_01',
        farmerName: 'Sunil Bandara',
        farmerPhone: '+94 77 123 4567',
        farmerLocation: 'Polonnaruwa, North Central',
        farmerAvatar: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=200&auto=format&fit=crop&q=80',
        cropName: 'Sweet Papaya (Red Lady Variety)',
        category: 'Fruits',
        quantity: 900,
        unit: 'kg',
        startingPrice: 110.0,
        minBidIncrement: 5.0,
        reservePrice: 130.0,
        buyNowPrice: 160.0,
        currentHighestBid: 145.0,
        highestBidderId: 'buyer_04',
        highestBidderName: 'SunFresh Juice Bars PLC',
        totalBids: 8,
        description: 'Semi-ripe Red Lady Papaya. High sugar content (Brix 12+), ideal for supermarket retail and fresh juice production.',
        harvestDate: now.subtract(const Duration(days: 1)),
        deliveryTerms: 'Crated farmgate pickup.',
        location: 'Manampitiya Farm, Polonnaruwa',
        imageUrl: 'https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=600&auto=format&fit=crop&q=80',
        startTime: now.subtract(const Duration(days: 3)),
        endTime: now.subtract(const Duration(hours: 2)),
        status: 'sold',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}
