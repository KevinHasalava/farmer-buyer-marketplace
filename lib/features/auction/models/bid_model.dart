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

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'] as String? ?? '',
      auctionId: json['auctionId'] as String? ?? '',
      bidderId: json['bidderId'] as String? ?? '',
      bidderName: json['bidderName'] as String? ?? 'Anonymous Buyer',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isWinning: json['isWinning'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
    );
  }
}
