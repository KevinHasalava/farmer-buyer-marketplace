import 'package:flutter/material.dart';

class BuyerProduct {
  const BuyerProduct({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.unit,
    required this.rating,
    required this.reviewsCount,
    required this.availableStock,
    required this.farmerName,
    required this.farmLocation,
    required this.farmName,
    required this.harvestTime,
    this.dispatchVia = 'Cold Transit Van 04',
    required this.imageUrl,
    required this.category,
    this.badge,
    this.badgeColor,
    required this.description,
    this.isOrganic = false,
    this.tags = const [],
    this.farmerAvatarUrl = 'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80',
    this.farmerBio = 'Cultivating highland produce using 100% natural and sustainable farming methods in Hakgala valley.',
    this.secondaryPrice,
    this.secondaryUnit,
  });

  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String unit;
  final double rating;
  final int reviewsCount;
  final String availableStock;
  final String farmerName;
  final String farmLocation;
  final String farmName;
  final String harvestTime;
  final String dispatchVia;
  final String imageUrl;
  final String category;
  final String? badge;
  final Color? badgeColor;
  final String description;
  final bool isOrganic;
  final List<String> tags;
  final String farmerAvatarUrl;
  final String farmerBio;
  final double? secondaryPrice;
  final String? secondaryUnit;

  String get formattedPrice => 'Rs. ${price.toStringAsFixed(0)}';
  String get formattedOriginalPrice => originalPrice != null ? 'Rs. ${originalPrice!.toStringAsFixed(0)}' : '';
}

class BuyerFarmer {
  const BuyerFarmer({
    required this.name,
    required this.farmName,
    required this.location,
    required this.altitude,
    required this.rating,
    required this.reviewsCount,
    required this.yearsExperience,
    required this.bio,
    required this.ordersFulfilled,
    required this.onTimeRate,
    required this.directTrace,
    required this.avatarUrl,
    required this.landscapeUrl,
    required this.phone,
    this.isCertifiedOrganic = true,
  });

  final String name;
  final String farmName;
  final String location;
  final String altitude;
  final double rating;
  final int reviewsCount;
  final String yearsExperience;
  final String bio;
  final String ordersFulfilled;
  final String onTimeRate;
  final String directTrace;
  final String avatarUrl;
  final String landscapeUrl;
  final String phone;
  final bool isCertifiedOrganic;

  static const defaultFarmer = BuyerFarmer(
    name: 'K. M. Bandara',
    farmName: 'Hakgala Valley Organic Gardens',
    location: 'Nuwara Eliya',
    altitude: '1,868m alt',
    rating: 4.9,
    reviewsCount: 450,
    yearsExperience: '19 yrs',
    bio: 'We cultivate fresh vegetables in the cool hills of Hakgala using sustainable and organic tradition methods passed down 3 generations. Our harvest reaches your kitchen within 12 hours of picking.',
    ordersFulfilled: '1,420+',
    onTimeRate: '98.4%',
    directTrace: '100%',
    avatarUrl: 'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80',
    landscapeUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1000&auto=format&fit=crop&q=80',
    phone: '076 323 8225',
    isCertifiedOrganic: true,
  );
}

class BuyerCategoryItem {
  const BuyerCategoryItem({
    required this.id,
    required this.name,
    required this.itemCountText,
    required this.description,
    required this.imageUrl,
    this.badge,
    this.badgeColor,
    this.actionText = 'Browse fresh picks ->',
  });

  final String id;
  final String name;
  final String itemCountText;
  final String description;
  final String imageUrl;
  final String? badge;
  final Color? badgeColor;
  final String actionText;
}
