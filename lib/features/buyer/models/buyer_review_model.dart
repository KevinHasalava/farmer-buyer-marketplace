import 'package:flutter/foundation.dart';

/// 🌟 Buyer Review & Rating Model (Member 1 - IT23843770 Thennakoon T.M.S.N)
/// Represents a verified customer review for a farm harvest batch & farmer.
@immutable
class BuyerReview {
  const BuyerReview({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    this.buyerAvatar = '',
    required this.productId,
    required this.productName,
    this.productImage = '',
    required this.farmerId,
    required this.farmerName,
    required this.rating,
    required this.title,
    required this.comment,
    this.qualityTag = 'Grade-A Fresh',
    this.farmerReply,
    this.farmerReplyAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String buyerId;
  final String buyerName;
  final String buyerAvatar;
  final String productId;
  final String productName;
  final String productImage;
  final String farmerId;
  final String farmerName;
  final double rating; // 1.0 to 5.0
  final String title;
  final String comment;
  final String qualityTag;
  final String? farmerReply;
  final DateTime? farmerReplyAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasFarmerReply => farmerReply != null && farmerReply!.trim().isNotEmpty;

  String get formattedRating => rating.toStringAsFixed(1);

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '$months ${months == 1 ? "month" : "months"} ago';
    } else if (diff.inDays >= 2) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} ${diff.inHours == 1 ? "hr" : "hrs"} ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} mins ago';
    } else {
      return 'Just now';
    }
  }

  bool isOwnedBy(String? currentBuyerId) {
    if (currentBuyerId == null || currentBuyerId.isEmpty || currentBuyerId == 'buyer_chamara') {
      // Fallback: match default local buyer if unauthenticated or demo user Chamara
      return buyerId == 'buyer_chamara' || buyerName.toLowerCase().contains('chamara');
    }
    return buyerId == currentBuyerId;
  }

  BuyerReview copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? buyerAvatar,
    String? productId,
    String? productName,
    String? productImage,
    String? farmerId,
    String? farmerName,
    double? rating,
    String? title,
    String? comment,
    String? qualityTag,
    String? farmerReply,
    DateTime? farmerReplyAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BuyerReview(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerAvatar: buyerAvatar ?? this.buyerAvatar,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      qualityTag: qualityTag ?? this.qualityTag,
      farmerReply: farmerReply ?? this.farmerReply,
      farmerReplyAt: farmerReplyAt ?? this.farmerReplyAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'buyer_id': buyerId,
        'buyer_name': buyerName,
        'buyer_avatar': buyerAvatar,
        'product_id': productId,
        'product_name': productName,
        'product_image': productImage,
        'farmer_id': farmerId,
        'farmer_name': farmerName,
        'rating': rating,
        'title': title,
        'comment': comment,
        'quality_tag': qualityTag,
        'farmer_reply': farmerReply,
        'farmer_reply_at': farmerReplyAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory BuyerReview.fromJson(Map<String, dynamic> json) {
    return BuyerReview(
      id: json['id']?.toString() ?? '',
      buyerId: json['buyer_id']?.toString() ?? 'buyer_chamara',
      buyerName: json['buyer_name']?.toString() ?? 'Chamara Perera',
      buyerAvatar: json['buyer_avatar']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productImage: json['product_image']?.toString() ?? '',
      farmerId: json['farmer_id']?.toString() ?? '',
      farmerName: json['farmer_name']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      title: json['title']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      qualityTag: json['quality_tag']?.toString() ?? 'Grade-A Fresh',
      farmerReply: json['farmer_reply']?.toString(),
      farmerReplyAt: json['farmer_reply_at'] != null
          ? DateTime.tryParse(json['farmer_reply_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
