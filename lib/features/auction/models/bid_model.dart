class BidModel {
  final String id;
  final String auctionId;
  final String bidderId;
  final String bidderName;
  final double amount;
  final DateTime createdAt;
  final bool isWinning;
  final String notes;

  const BidModel({
    required this.id,
    required this.auctionId,
    required this.bidderId,
    required this.bidderName,
    required this.amount,
    required this.createdAt,
    this.isWinning = false,
    this.notes = '',
  });

  BidModel copyWith({
    String? id,
    String? auctionId,
    String? bidderId,
    String? bidderName,
    double? amount,
    DateTime? createdAt,
    bool? isWinning,
    String? notes,
  }) {
    return BidModel(
      id: id ?? this.id,
      auctionId: auctionId ?? this.auctionId,
      bidderId: bidderId ?? this.bidderId,
      bidderName: bidderName ?? this.bidderName,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      isWinning: isWinning ?? this.isWinning,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auctionId': auctionId,
      'bidderId': bidderId,
      'bidderName': bidderName,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'isWinning': isWinning,
      'notes': notes,
    };
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'auction_id': auctionId,
      'bidder_id': bidderId,
      'bidder_name': bidderName,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'is_winning': isWinning,
      'notes': notes,
    };
  }

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'] as String? ?? '',
      auctionId: (json['auction_id'] ?? json['auctionId']) as String? ?? '',
      bidderId: (json['bidder_id'] ?? json['bidderId']) as String? ?? '',
      bidderName: (json['bidder_name'] ?? json['bidderName']) as String? ?? 'Anonymous Buyer',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']) as String) ?? DateTime.now()
          : DateTime.now(),
      isWinning: (json['is_winning'] ?? json['isWinning']) as bool? ?? false,
      notes: json['notes'] as String? ?? '',
    );
  }
}
