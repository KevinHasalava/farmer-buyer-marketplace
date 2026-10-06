import 'package:flutter/foundation.dart';

@immutable
class BuyerProfileModel {
  const BuyerProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatarUrl,
    this.isVerified = true,
    this.buyerCode = '#B-0034',
    this.memberSince = '2023',
    this.buyerType = 'Family',
    this.completedOrders = 34,
    this.directFarmSpend = 42500.0,
    this.co2SavedKg = 120,
    this.walletBalance = 3450.0,
    this.savedFarmersCount = 6,
    this.deliveryHub = 'Colombo Western Regional Hub (Route 07)',
    this.deliveryAddress = 'House 24, Flower Road, Colombo 07',
    this.deliverySlot = 'Direct Morning Cold Transit Slot',
    this.preferences = const [
      '100% Organic',
      'Pesticide-Free',
      'Highland Veggies',
      'Low-Country Fruits',
      'Heirloom Rice',
    ],
    this.hasActiveHarvestBox = true,
    this.nextDispatch = 'Tomorrow, 7:00 - 9:00 AM',
    this.dispatchDescription =
        'Curated fresh harvest from Nuwara Eliya & Dambulla valley',
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String? avatarUrl;
  final bool isVerified;
  final String buyerCode;
  final String memberSince;
  final String buyerType;
  final int completedOrders;
  final double directFarmSpend;
  final int co2SavedKg;
  final double walletBalance;
  final int savedFarmersCount;
  final String deliveryHub;
  final String deliveryAddress;
  final String deliverySlot;
  final List<String> preferences;
  final bool hasActiveHarvestBox;
  final String nextDispatch;
  final String dispatchDescription;

  /// Returns 2-letter uppercase initials like "CP" from "Chaminda Perera"
  String get initials {
    final clean = name.trim();
    if (clean.isEmpty) return 'CP';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Formatted spend e.g. "Rs. 42.5k"
  String get formattedSpend {
    if (directFarmSpend >= 1000) {
      final inK = directFarmSpend / 1000;
      return 'Rs. ${inK.toStringAsFixed(1)}k';
    }
    return 'Rs. ${directFarmSpend.toStringAsFixed(0)}';
  }

  /// Formatted wallet balance e.g. "Rs. 3,450"
  String get formattedWallet {
    final numStr = walletBalance.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = numStr.replaceAllMapped(reg, (match) => '${match[1]},');
    return 'Rs. $formatted';
  }

  /// Formats short city/hub display for Top App Bar
  String get topBarLocationDisplay {
    if (deliveryAddress.isNotEmpty && deliveryAddress.contains('Colombo')) {
      if (deliveryAddress.toLowerCase().contains('colombo 07') ||
          deliveryHub.toLowerCase().contains('colombo 07') ||
          deliveryHub.toLowerCase().contains('route 07')) {
        return 'Colombo 07, Western';
      }
      return 'Colombo 02, Western';
    }
    if (deliveryHub.isNotEmpty) {
      if (deliveryHub.contains('(')) {
        return deliveryHub.split('(').first.trim();
      }
      return deliveryHub;
    }
    return 'Colombo 02, Western';
  }

  BuyerProfileModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    bool? isVerified,
    String? buyerCode,
    String? memberSince,
    String? buyerType,
    int? completedOrders,
    double? directFarmSpend,
    int? co2SavedKg,
    double? walletBalance,
    int? savedFarmersCount,
    String? deliveryHub,
    String? deliveryAddress,
    String? deliverySlot,
    List<String>? preferences,
    bool? hasActiveHarvestBox,
    String? nextDispatch,
    String? dispatchDescription,
  }) {
    return BuyerProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      buyerCode: buyerCode ?? this.buyerCode,
      memberSince: memberSince ?? this.memberSince,
      buyerType: buyerType ?? this.buyerType,
      completedOrders: completedOrders ?? this.completedOrders,
      directFarmSpend: directFarmSpend ?? this.directFarmSpend,
      co2SavedKg: co2SavedKg ?? this.co2SavedKg,
      walletBalance: walletBalance ?? this.walletBalance,
      savedFarmersCount: savedFarmersCount ?? this.savedFarmersCount,
      deliveryHub: deliveryHub ?? this.deliveryHub,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliverySlot: deliverySlot ?? this.deliverySlot,
      preferences: preferences ?? this.preferences,
      hasActiveHarvestBox: hasActiveHarvestBox ?? this.hasActiveHarvestBox,
      nextDispatch: nextDispatch ?? this.nextDispatch,
      dispatchDescription: dispatchDescription ?? this.dispatchDescription,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'avatar_url': avatarUrl,
        'is_verified': isVerified,
        'buyer_code': buyerCode,
        'member_since': memberSince,
        'buyer_type': buyerType,
        'completed_orders': completedOrders,
        'direct_farm_spend': directFarmSpend,
        'co2_saved_kg': co2SavedKg,
        'wallet_balance': walletBalance,
        'saved_farmers_count': savedFarmersCount,
        'delivery_hub': deliveryHub,
        'delivery_address': deliveryAddress,
        'delivery_slot': deliverySlot,
        'preferences': preferences,
        'has_active_harvest_box': hasActiveHarvestBox,
        'next_dispatch': nextDispatch,
        'dispatch_description': dispatchDescription,
      };

  factory BuyerProfileModel.fromJson(Map<String, dynamic> json) {
    return BuyerProfileModel(
      id: json['id'] as String? ?? 'b-default',
      name: json['name'] as String? ?? 'Chaminda Perera',
      phone: json['phone'] as String? ?? '+94 77 123 4567',
      email: json['email'] as String? ?? 'chaminda.p@example.com',
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? true,
      buyerCode: json['buyer_code'] as String? ?? '#B-0034',
      memberSince: json['member_since'] as String? ?? '2023',
      buyerType: json['buyer_type'] as String? ?? 'Family',
      completedOrders: (json['completed_orders'] as num?)?.toInt() ?? 34,
      directFarmSpend: (json['direct_farm_spend'] as num?)?.toDouble() ?? 42500.0,
      co2SavedKg: (json['co2_saved_kg'] as num?)?.toInt() ?? 120,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 3450.0,
      savedFarmersCount: (json['saved_farmers_count'] as num?)?.toInt() ?? 6,
      deliveryHub: json['delivery_hub'] as String? ??
          'Colombo Western Regional Hub (Route 07)',
      deliveryAddress: json['delivery_address'] as String? ??
          'House 24, Flower Road, Colombo 07',
      deliverySlot: json['delivery_slot'] as String? ??
          'Direct Morning Cold Transit Slot',
      preferences: (json['preferences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            '100% Organic',
            'Pesticide-Free',
            'Highland Veggies',
            'Low-Country Fruits',
            'Heirloom Rice',
          ],
      hasActiveHarvestBox: json['has_active_harvest_box'] as bool? ?? true,
      nextDispatch:
          json['next_dispatch'] as String? ?? 'Tomorrow, 7:00 - 9:00 AM',
      dispatchDescription: json['dispatch_description'] as String? ??
          'Curated fresh harvest from Nuwara Eliya & Dambulla valley',
    );
  }

  static const BuyerProfileModel defaultBuyer = BuyerProfileModel(
    id: 'b-0034',
    name: 'Chaminda Perera',
    phone: '+94 77 123 4567',
    email: 'chaminda.p@example.com',
    avatarUrl: null,
    isVerified: true,
    buyerCode: '#B-0034',
    memberSince: '2023',
    buyerType: 'Family',
    completedOrders: 34,
    directFarmSpend: 42500.0,
    co2SavedKg: 120,
    walletBalance: 3450.0,
    savedFarmersCount: 6,
    deliveryHub: 'Colombo Western Regional Hub (Route 07)',
    deliveryAddress: 'House 24, Flower Road, Colombo 07',
    deliverySlot: 'Direct Morning Cold Transit Slot',
    preferences: [
      '100% Organic',
      'Pesticide-Free',
      'Highland Veggies',
      'Low-Country Fruits',
      'Heirloom Rice',
    ],
    hasActiveHarvestBox: true,
    nextDispatch: 'Tomorrow, 7:00 - 9:00 AM',
    dispatchDescription:
        'Curated fresh harvest from Nuwara Eliya & Dambulla valley',
  );
}
