import 'package:flutter/foundation.dart';

import '../../dashboard/presentation/product_detail_screen.dart';
import '../../buyer/models/buyer_models.dart';

@immutable
class FarmerProfileModel {
  const FarmerProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.farmName,
    this.role = 'Small-Scale Farmer',
    this.location = 'Nuwara Eliya',
    this.district = 'Nuwara Eliya',
    this.agrarianCenter = 'Hakgala Agrarian Service Center',
    this.rating = '4.8',
    this.reviews = '120',
    this.yearsExperience = '5+',
    this.isOrganic = true,
    this.farmingPractice = 'Certified Organic (SL-GAP)',
    this.happyCustomers = '200+',
    this.about =
        'Dedicated to cultivating high-quality, pesticide-free fresh vegetables. Our farm follows sustainable SL-GAP practices delivering fresh harvest direct from soil to buyers.',
    this.emoji = '👨‍🌾',
    this.avatarUrl =
        'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80',
    this.coverUrl =
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1000&auto=format&fit=crop&q=80',
    this.scale = '1 - 3 Acres',
    this.crops = const ['Carrots & Root Veg', 'Leeks & Cabbage', 'Tomatoes'],
    this.nic,
    this.bankName,
    this.accountNumber,
    this.isVerified = true,
    this.ordersFulfilled = '1,420+',
    this.onTimeRate = '98.4%',
    this.directTrace = '100%',
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String farmName;
  final String role;
  final String location;
  final String district;
  final String agrarianCenter;
  final String rating;
  final String reviews;
  final String yearsExperience;
  final bool isOrganic;
  final String farmingPractice;
  final String happyCustomers;
  final String about;
  final String emoji;
  final String? avatarUrl;
  final String? coverUrl;
  final String scale;
  final List<String> crops;
  final String? nic;
  final String? bankName;
  final String? accountNumber;
  final bool isVerified;
  final String ordersFulfilled;
  final String onTimeRate;
  final String directTrace;

  /// Default fallback farmer matching the current design
  static const defaultFarmer = FarmerProfileModel(
    id: 'farmer_default_1',
    name: 'Sunil Perera',
    phone: '076 323 8225',
    email: 'sunil.perera@farm2home.lk',
    farmName: 'Sunil Organic Valley',
    role: 'Small-Scale Farmer',
    location: 'Hambantota',
    district: 'Hambantota',
    agrarianCenter: 'Hambantota Agrarian Center',
    rating: '4.8',
    reviews: '120',
    yearsExperience: '5+',
    isOrganic: true,
    farmingPractice: 'Certified Organic (SL-GAP)',
    happyCustomers: '200+',
    about:
        'I am a small-scale farmer from Hambantota. I grow fresh vegetables using natural methods. My goal is to provide healthy and fresh produce to my customers.',
    emoji: '👨‍🌾',
    avatarUrl:
        'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80',
    coverUrl:
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1000&auto=format&fit=crop&q=80',
  );

  /// Converts this model to [FarmerData] used by Dashboard screens
  FarmerData toFarmerData() {
    return FarmerData(
      name: name,
      role: role.isNotEmpty ? role : 'Small-Scale Farmer',
      location: location.isNotEmpty ? location : district,
      rating: rating,
      reviews: reviews,
      yearsExperience: yearsExperience,
      isOrganic: isOrganic,
      happyCustomers: happyCustomers,
      about: about,
      emoji: emoji,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      phone: phone,
    );
  }

  /// Converts this model to [BuyerFarmer] used by Buyer screens
  BuyerFarmer toBuyerFarmer() {
    return BuyerFarmer(
      name: name,
      farmName: farmName.isNotEmpty ? farmName : '$name Farm',
      location: location.isNotEmpty ? location : district,
      altitude: '1,868m alt',
      rating: double.tryParse(rating) ?? 4.8,
      reviewsCount: int.tryParse(reviews.replaceAll(RegExp(r'[^0-9]'), '')) ?? 120,
      yearsExperience: '$yearsExperience yrs',
      bio: about,
      ordersFulfilled: ordersFulfilled,
      onTimeRate: onTimeRate,
      directTrace: directTrace,
      avatarUrl: avatarUrl ??
          'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80',
      landscapeUrl: coverUrl ??
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1000&auto=format&fit=crop&q=80',
      phone: phone,
      isCertifiedOrganic: isOrganic,
    );
  }

  FarmerProfileModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? farmName,
    String? role,
    String? location,
    String? district,
    String? agrarianCenter,
    String? rating,
    String? reviews,
    String? yearsExperience,
    bool? isOrganic,
    String? farmingPractice,
    String? happyCustomers,
    String? about,
    String? emoji,
    String? avatarUrl,
    String? coverUrl,
    String? scale,
    List<String>? crops,
    String? nic,
    String? bankName,
    String? accountNumber,
    bool? isVerified,
    String? ordersFulfilled,
    String? onTimeRate,
    String? directTrace,
  }) {
    return FarmerProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      farmName: farmName ?? this.farmName,
      role: role ?? this.role,
      location: location ?? this.location,
      district: district ?? this.district,
      agrarianCenter: agrarianCenter ?? this.agrarianCenter,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      isOrganic: isOrganic ?? this.isOrganic,
      farmingPractice: farmingPractice ?? this.farmingPractice,
      happyCustomers: happyCustomers ?? this.happyCustomers,
      about: about ?? this.about,
      emoji: emoji ?? this.emoji,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      scale: scale ?? this.scale,
      crops: crops ?? this.crops,
      nic: nic ?? this.nic,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isVerified: isVerified ?? this.isVerified,
      ordersFulfilled: ordersFulfilled ?? this.ordersFulfilled,
      onTimeRate: onTimeRate ?? this.onTimeRate,
      directTrace: directTrace ?? this.directTrace,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'farm_name': farmName,
        'role': role,
        'location': location,
        'district': district,
        'agrarian_center': agrarianCenter,
        'rating': rating,
        'reviews': reviews,
        'years_experience': yearsExperience,
        'is_organic': isOrganic,
        'farming_practice': farmingPractice,
        'happy_customers': happyCustomers,
        'about': about,
        'emoji': emoji,
        'avatar_url': avatarUrl,
        'cover_url': coverUrl,
        'scale': scale,
        'crops': crops,
        'nic': nic,
        'bank_name': bankName,
        'account_number': accountNumber,
        'is_verified': isVerified,
        'orders_fulfilled': ordersFulfilled,
        'on_time_rate': onTimeRate,
        'direct_trace': directTrace,
      };

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    return FarmerProfileModel(
      id: json['id'] as String? ?? 'farmer_1',
      name: json['name'] as String? ?? 'Sunil Perera',
      phone: json['phone'] as String? ?? '076 323 8225',
      email: json['email'] as String? ?? '',
      farmName: json['farm_name'] as String? ?? 'Sunil Organic Valley',
      role: json['role'] as String? ?? 'Small-Scale Farmer',
      location: json['location'] as String? ?? 'Nuwara Eliya',
      district: json['district'] as String? ?? 'Nuwara Eliya',
      agrarianCenter: json['agrarian_center'] as String? ?? '',
      rating: json['rating'] as String? ?? '4.8',
      reviews: json['reviews'] as String? ?? '120',
      yearsExperience: json['years_experience'] as String? ?? '5+',
      isOrganic: json['is_organic'] as bool? ?? true,
      farmingPractice: json['farming_practice'] as String? ??
          'Certified Organic (SL-GAP)',
      happyCustomers: json['happy_customers'] as String? ?? '200+',
      about: json['about'] as String? ??
          'Cultivating fresh vegetables using sustainable organic methods.',
      emoji: json['emoji'] as String? ?? '👨‍🌾',
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      scale: json['scale'] as String? ?? '1 - 3 Acres',
      crops: (json['crops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Carrots & Root Veg', 'Leeks & Cabbage'],
      nic: json['nic'] as String?,
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      isVerified: json['is_verified'] as bool? ?? true,
      ordersFulfilled: json['orders_fulfilled'] as String? ?? '1,420+',
      onTimeRate: json['on_time_rate'] as String? ?? '98.4%',
      directTrace: json['direct_trace'] as String? ?? '100%',
    );
  }
}
