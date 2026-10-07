import 'package:flutter/foundation.dart';

enum BuyerNotificationCategory {
  all,
  orders,
  harvestAlerts,
}

enum BuyerNotificationType {
  driverAlert,
  harvestAlert,
  dispatched,
  delivered,
  priceDrop,
}

@immutable
class BuyerNotificationItem {
  const BuyerNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.tag,
    required this.timeAgo,
    required this.createdAt,
    this.isRead = false,
    this.category = BuyerNotificationCategory.orders,
    // Driver alert details
    this.driverName,
    this.driverPhoto,
    this.driverRating,
    this.driverDistance,
    this.amountDue,
    this.vanNumber,
    this.driverPhone = '+94 77 982 1450',
    // Harvest / produce alert details
    this.imageUrl,
    this.produceName,
    this.priceText,
    this.stockLeftText,
    this.harvestTimeText,
    // Dispatched details
    this.badges = const [],
    // Delivered / Review details
    this.userRating = 0,
    this.coinsReward = 50,
    // Price drop details
    this.originalPriceText,
    this.discountedPriceText,
    this.productId,
  });

  final String id;
  final BuyerNotificationType type;
  final String title;
  final String message;
  final String tag;
  final String timeAgo;
  final DateTime createdAt;
  final bool isRead;
  final BuyerNotificationCategory category;

  // Driver details
  final String? driverName;
  final String? driverPhoto;
  final String? driverRating;
  final String? driverDistance;
  final String? amountDue;
  final String? vanNumber;
  final String driverPhone;

  // Harvest alert details
  final String? imageUrl;
  final String? produceName;
  final String? priceText;
  final String? stockLeftText;
  final String? harvestTimeText;

  // Badges
  final List<String> badges;

  // Delivered details
  final int userRating;
  final int coinsReward;

  // Price drop details
  final String? originalPriceText;
  final String? discountedPriceText;
  final String? productId;

  BuyerNotificationItem copyWith({
    String? id,
    BuyerNotificationType? type,
    String? title,
    String? message,
    String? tag,
    String? timeAgo,
    DateTime? createdAt,
    bool? isRead,
    BuyerNotificationCategory? category,
    String? driverName,
    String? driverPhoto,
    String? driverRating,
    String? driverDistance,
    String? amountDue,
    String? vanNumber,
    String? driverPhone,
    String? imageUrl,
    String? produceName,
    String? priceText,
    String? stockLeftText,
    String? harvestTimeText,
    List<String>? badges,
    int? userRating,
    int? coinsReward,
    String? originalPriceText,
    String? discountedPriceText,
    String? productId,
  }) {
    return BuyerNotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      tag: tag ?? this.tag,
      timeAgo: timeAgo ?? this.timeAgo,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      category: category ?? this.category,
      driverName: driverName ?? this.driverName,
      driverPhoto: driverPhoto ?? this.driverPhoto,
      driverRating: driverRating ?? this.driverRating,
      driverDistance: driverDistance ?? this.driverDistance,
      amountDue: amountDue ?? this.amountDue,
      vanNumber: vanNumber ?? this.vanNumber,
      driverPhone: driverPhone ?? this.driverPhone,
      imageUrl: imageUrl ?? this.imageUrl,
      produceName: produceName ?? this.produceName,
      priceText: priceText ?? this.priceText,
      stockLeftText: stockLeftText ?? this.stockLeftText,
      harvestTimeText: harvestTimeText ?? this.harvestTimeText,
      badges: badges ?? this.badges,
      userRating: userRating ?? this.userRating,
      coinsReward: coinsReward ?? this.coinsReward,
      originalPriceText: originalPriceText ?? this.originalPriceText,
      discountedPriceText: discountedPriceText ?? this.discountedPriceText,
      productId: productId ?? this.productId,
    );
  }

  factory BuyerNotificationItem.fromJson(Map<String, dynamic> json) {
    BuyerNotificationType type = BuyerNotificationType.driverAlert;
    final typeStr = json['type'] as String? ?? '';
    if (typeStr == 'driverAlert') {
      type = BuyerNotificationType.driverAlert;
    } else if (typeStr == 'harvestAlert') {
      type = BuyerNotificationType.harvestAlert;
    } else if (typeStr == 'dispatched') {
      type = BuyerNotificationType.dispatched;
    } else if (typeStr == 'delivered') {
      type = BuyerNotificationType.delivered;
    } else if (typeStr == 'priceDrop') {
      type = BuyerNotificationType.priceDrop;
    }

    BuyerNotificationCategory category = BuyerNotificationCategory.orders;
    if (type == BuyerNotificationType.harvestAlert ||
        type == BuyerNotificationType.priceDrop) {
      category = BuyerNotificationCategory.harvestAlerts;
    }

    return BuyerNotificationItem(
      id: json['id'] as String? ?? 'notif-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      tag: json['tag'] as String? ?? 'Farm2Home',
      timeAgo: json['time_ago'] as String? ?? 'Just now',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      category: category,
      driverName: json['driver_name'] as String?,
      driverPhoto: json['driver_photo'] as String?,
      driverRating: json['driver_rating'] as String?,
      driverDistance: json['driver_distance'] as String?,
      amountDue: json['amount_due'] as String?,
      vanNumber: json['van_number'] as String?,
      driverPhone: json['driver_phone'] as String? ?? '+94 77 982 1450',
      imageUrl: json['image_url'] as String?,
      produceName: json['produce_name'] as String?,
      priceText: json['price_text'] as String?,
      stockLeftText: json['stock_left_text'] as String?,
      harvestTimeText: json['harvest_time_text'] as String?,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      userRating: (json['user_rating'] as num?)?.toInt() ?? 0,
      coinsReward: (json['coins_reward'] as num?)?.toInt() ?? 50,
      originalPriceText: json['original_price_text'] as String?,
      discountedPriceText: json['discounted_price_text'] as String?,
      productId: json['product_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'message': message,
        'tag': tag,
        'time_ago': timeAgo,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
        'category': category.name,
        'driver_name': driverName,
        'driver_photo': driverPhoto,
        'driver_rating': driverRating,
        'driver_distance': driverDistance,
        'amount_due': amountDue,
        'van_number': vanNumber,
        'driver_phone': driverPhone,
        'image_url': imageUrl,
        'produce_name': produceName,
        'price_text': priceText,
        'stock_left_text': stockLeftText,
        'harvest_time_text': harvestTimeText,
        'badges': badges,
        'user_rating': userRating,
        'coins_reward': coinsReward,
        'original_price_text': originalPriceText,
        'discounted_price_text': discountedPriceText,
        'product_id': productId,
      };
}
