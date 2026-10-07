
/// Admin Farmer Data Model for CRUD management
class AdminFarmerModel {
  final String id;
  final String name;
  final String phone;
  final String farmName;
  final String district;
  final String agrarianCenter;
  final String scale;
  final String practice;
  final List<String> crops;
  final String nic;
  final String bankName;
  final String accountNumber;
  final bool isVerified;
  final String status;
  final DateTime registeredAt;

  const AdminFarmerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.farmName,
    required this.district,
    required this.agrarianCenter,
    this.scale = '1 - 3 Acres',
    this.practice = 'Certified Organic (SL-GAP)',
    this.crops = const ['Carrots', 'Leeks', 'Tomatoes'],
    this.nic = '',
    this.bankName = 'Commercial Bank',
    this.accountNumber = '',
    this.isVerified = true,
    this.status = 'Active',
    required this.registeredAt,
  });

  AdminFarmerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? farmName,
    String? district,
    String? agrarianCenter,
    String? scale,
    String? practice,
    List<String>? crops,
    String? nic,
    String? bankName,
    String? accountNumber,
    bool? isVerified,
    String? status,
    DateTime? registeredAt,
  }) {
    return AdminFarmerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      farmName: farmName ?? this.farmName,
      district: district ?? this.district,
      agrarianCenter: agrarianCenter ?? this.agrarianCenter,
      scale: scale ?? this.scale,
      practice: practice ?? this.practice,
      crops: crops ?? this.crops,
      nic: nic ?? this.nic,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'farmName': farmName,
      'district': district,
      'agrarianCenter': agrarianCenter,
      'scale': scale,
      'practice': practice,
      'crops': crops,
      'nic': nic,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'isVerified': isVerified,
      'status': status,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'full_name': name,
      'phone': phone,
      'farm_name': farmName,
      'district': district,
      'agrarian_center': agrarianCenter,
      'scale': scale,
      'practice': practice,
      'crops': crops,
      'nic': nic,
      'bank_name': bankName,
      'account_number': accountNumber,
      'is_verified': isVerified,
      'status': status,
      'created_at': registeredAt.toIso8601String(),
    };
  }

  factory AdminFarmerModel.fromMap(Map<String, dynamic> map) {
    return AdminFarmerModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? map['full_name'] ?? '',
      phone: map['phone'] ?? map['phone_number'] ?? '',
      farmName: map['farmName'] ?? map['farm_name'] ?? '',
      district: map['district'] ?? 'Nuwara Eliya',
      agrarianCenter: map['agrarianCenter'] ?? map['agrarian_center'] ?? 'Hakgala Center',
      scale: map['scale'] ?? '1 - 3 Acres',
      practice: map['practice'] ?? map['farming_practice'] ?? 'Certified Organic',
      crops: (map['crops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Vegetables'],
      nic: map['nic'] ?? '',
      bankName: map['bankName'] ?? map['bank_name'] ?? 'Commercial Bank',
      accountNumber: map['accountNumber'] ?? map['account_number'] ?? '',
      isVerified: (map['isVerified'] ?? map['is_verified']) as bool? ?? true,
      status: map['status'] ?? 'Active',
      registeredAt: map['registeredAt'] != null
          ? DateTime.tryParse(map['registeredAt'].toString()) ?? DateTime.now()
          : (map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }
}

/// Admin Buyer Data Model for CRUD management
class AdminBuyerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String hub;
  final String buyerType;
  final int totalOrders;
  final double totalSpent;
  final String status;
  final DateTime registeredAt;

  const AdminBuyerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.hub,
    this.buyerType = 'Family',
    this.totalOrders = 1,
    this.totalSpent = 3500.0,
    this.status = 'Active',
    required this.registeredAt,
  });

  AdminBuyerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? hub,
    String? buyerType,
    int? totalOrders,
    double? totalSpent,
    String? status,
    DateTime? registeredAt,
  }) {
    return AdminBuyerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      hub: hub ?? this.hub,
      buyerType: buyerType ?? this.buyerType,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'hub': hub,
      'buyerType': buyerType,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'status': status,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'delivery_address': address,
      'delivery_hub': hub,
      'buyer_type': buyerType,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'status': status,
      'created_at': registeredAt.toIso8601String(),
    };
  }

  factory AdminBuyerModel.fromMap(Map<String, dynamic> map) {
    return AdminBuyerModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? map['full_name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? map['phone_number'] ?? '',
      address: map['address'] ?? map['delivery_address'] ?? 'Colombo',
      hub: map['hub'] ?? map['delivery_hub'] ?? 'Colombo Central Hub',
      buyerType: map['buyerType'] ?? map['buyer_type'] ?? 'Family',
      totalOrders: (map['totalOrders'] ?? map['total_orders'] as num?)?.toInt() ?? 0,
      totalSpent: (map['totalSpent'] ?? map['total_spent'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Active',
      registeredAt: map['registeredAt'] != null
          ? DateTime.tryParse(map['registeredAt'].toString()) ?? DateTime.now()
          : (map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }
}

/// Admin Driver Data Model for Fleet & Transit CRUD management
class AdminDriverModel {
  final String id;
  final String name;
  final String phone;
  final String licenseNumber;
  final String vehicleType;
  final String plateNumber;
  final String cargoCapacity;
  final String bankName;
  final String accountNumber;
  final bool isOnDuty;
  final int completedTrips;
  final double rating;
  final String status;
  final DateTime registeredAt;

  const AdminDriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    required this.vehicleType,
    required this.plateNumber,
    required this.cargoCapacity,
    this.bankName = 'Commercial Bank',
    this.accountNumber = '',
    this.isOnDuty = true,
    this.completedTrips = 184,
    this.rating = 4.9,
    this.status = 'Active',
    required this.registeredAt,
  });

  AdminDriverModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? licenseNumber,
    String? vehicleType,
    String? plateNumber,
    String? cargoCapacity,
    String? bankName,
    String? accountNumber,
    bool? isOnDuty,
    int? completedTrips,
    double? rating,
    String? status,
    DateTime? registeredAt,
  }) {
    return AdminDriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      cargoCapacity: cargoCapacity ?? this.cargoCapacity,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isOnDuty: isOnDuty ?? this.isOnDuty,
      completedTrips: completedTrips ?? this.completedTrips,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'plateNumber': plateNumber,
      'cargoCapacity': cargoCapacity,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'isOnDuty': isOnDuty,
      'completedTrips': completedTrips,
      'rating': rating,
      'status': status,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  /// Exact schema matching live Supabase `drivers` table
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'full_name': name,
      'phone_number': phone,
      'license_number': licenseNumber,
      'vehicle_type': vehicleType,
      'vehicle_number': plateNumber,
      'cargo_capacity': cargoCapacity,
      'is_cold_box_equipped': true,
      'operating_corridors': const [
        'Nuwara Eliya ⇄ Colombo (A7)',
        'Dambulla ⇄ Colombo (A6)',
      ],
      'bank_name': bankName,
      'bank_account_number': accountNumber,
      'duty_status': isOnDuty,
      'rating': rating,
      'completed_deliveries': completedTrips,
      'created_at': registeredAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AdminDriverModel.fromMap(Map<String, dynamic> map) {
    final isDuty = map['isOnDuty'] ?? map['duty_status'] ?? true;
    return AdminDriverModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? map['full_name'] ?? map['fullName'] ?? 'Fleet Driver',
      phone: map['phone'] ?? map['phone_number'] ?? map['mobileNumber'] ?? '',
      licenseNumber: map['licenseNumber'] ?? map['license_number'] ?? '',
      vehicleType: map['vehicleType'] ?? map['vehicle_type'] ?? 'Insulated Agro Van',
      plateNumber: map['plateNumber'] ?? map['vehicle_number'] ?? map['plate_number'] ?? '',
      cargoCapacity: map['cargoCapacity'] ?? map['cargo_capacity'] ?? '1,000 kg',
      bankName: map['bankName'] ?? map['bank_name'] ?? 'Commercial Bank',
      accountNumber: map['accountNumber'] ?? map['bank_account_number'] ?? '',
      isOnDuty: isDuty == true,
      completedTrips: (map['completedTrips'] ?? map['completed_deliveries'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      status: map['status'] ?? (isDuty == true ? 'Active' : 'Offline'),
      registeredAt: map['registeredAt'] != null
          ? DateTime.tryParse(map['registeredAt'].toString()) ?? DateTime.now()
          : (map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }
}

/// Admin Product Data Model for Marketplace Inventory CRUD
class AdminProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final double availableQty;
  final String farmName;
  final String farmerName;
  final bool isOrganic;
  final String imageUrl;
  final String description;
  final String status;
  final DateTime createdAt;

  const AdminProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.unit = '/kg',
    required this.availableQty,
    required this.farmName,
    required this.farmerName,
    this.isOrganic = true,
    required this.imageUrl,
    this.description = 'Fresh natural produce direct from farm.',
    this.status = 'In Stock',
    required this.createdAt,
  });

  AdminProductModel copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? unit,
    double? availableQty,
    String? farmName,
    String? farmerName,
    bool? isOrganic,
    String? imageUrl,
    String? description,
    String? status,
    DateTime? createdAt,
  }) {
    return AdminProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      availableQty: availableQty ?? this.availableQty,
      farmName: farmName ?? this.farmName,
      farmerName: farmerName ?? this.farmerName,
      isOrganic: isOrganic ?? this.isOrganic,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'availableQty': availableQty,
      'farmName': farmName,
      'farmerName': farmerName,
      'isOrganic': isOrganic,
      'imageUrl': imageUrl,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'available_qty': availableQty,
      'farm_name': farmName,
      'farmer_name': farmerName,
      'is_organic': isOrganic,
      'image_url': imageUrl,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AdminProductModel.fromMap(Map<String, dynamic> map) {
    return AdminProductModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Vegetables',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '/kg',
      availableQty: (map['availableQty'] ?? map['available_qty'] as num?)?.toDouble() ?? 0.0,
      farmName: map['farmName'] ?? map['farm_name'] ?? '',
      farmerName: map['farmerName'] ?? map['farmer_name'] ?? '',
      isOrganic: (map['isOrganic'] ?? map['is_organic']) as bool? ?? true,
      imageUrl: map['imageUrl'] ?? map['image_url'] ?? '',
      description: map['description'] ?? 'Fresh natural produce direct from farm.',
      status: map['status'] ?? 'In Stock',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : (map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }
}

/// Admin Order Data Model for Marketplace Orders & Dispatch CRUD
class AdminOrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String farmName;
  final String itemsSummary;
  final double totalAmount;
  final String status; // 'Pending', 'Confirmed', 'Picked Up', 'In Transit', 'Delivered', 'Cancelled'
  final String deliveryAddress;
  final String assignedDriverName;
  final String assignedDriverPhone;
  final DateTime orderDate;

  const AdminOrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.farmName,
    required this.itemsSummary,
    required this.totalAmount,
    this.status = 'Pending',
    required this.deliveryAddress,
    this.assignedDriverName = 'Unassigned',
    this.assignedDriverPhone = '',
    required this.orderDate,
  });

  AdminOrderModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? farmName,
    String? itemsSummary,
    double? totalAmount,
    String? status,
    String? deliveryAddress,
    String? assignedDriverName,
    String? assignedDriverPhone,
    DateTime? orderDate,
  }) {
    return AdminOrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      farmName: farmName ?? this.farmName,
      itemsSummary: itemsSummary ?? this.itemsSummary,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      assignedDriverPhone: assignedDriverPhone ?? this.assignedDriverPhone,
      orderDate: orderDate ?? this.orderDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'farmName': farmName,
      'itemsSummary': itemsSummary,
      'totalAmount': totalAmount,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'assignedDriverName': assignedDriverName,
      'assignedDriverPhone': assignedDriverPhone,
      'orderDate': orderDate.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'farm_name': farmName,
      'items_summary': itemsSummary,
      'total_amount': totalAmount,
      'status': status,
      'delivery_address': deliveryAddress,
      'assigned_driver_name': assignedDriverName,
      'assigned_driver_phone': assignedDriverPhone,
      'order_date': orderDate.toIso8601String(),
    };
  }

  /// Exact mapping to Supabase `driver_deliveries` table
  Map<String, dynamic> toDeliveryMap() {
    final cleanId = id.replaceAll('#', '').trim();
    return {
      'id': cleanId,
      'order_number': id.startsWith('#') ? id : '#$id',
      'farmer_name': farmName,
      'farmer_address': 'Hakgala Organic Farm, Nuwara Eliya',
      'farmer_phone': '+94771122334',
      'buyer_name': customerName,
      'buyer_address': deliveryAddress,
      'buyer_phone': customerPhone,
      'items_summary': itemsSummary,
      'crate_count': '1 Crate',
      'status': status,
      'is_priority': false,
      'cod_amount': 'Rs. ${totalAmount.toStringAsFixed(0)}',
      'payout_amount': 'Rs. ${(totalAmount * 0.85).toStringAsFixed(0)}',
      'van_temp': '4.0°C',
      'created_at': orderDate.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static double _parseAmount(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      final cleaned = val.replaceAll('Rs.', '').replaceAll('Rs', '').replaceAll(',', '').trim();
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  factory AdminOrderModel.fromMap(Map<String, dynamic> map) {
    final idVal = map['id']?.toString() ??
        map['order_number']?.toString() ??
        map['orderNumber']?.toString() ??
        '';

    final parsedAmount = (map['totalAmount'] as num?)?.toDouble() ??
        (map['total_amount'] as num?)?.toDouble() ??
        _parseAmount(map['cod_amount'] ?? map['driverFee'] ?? map['totalAmount']);

    return AdminOrderModel(
      id: idVal,
      customerName: map['customerName'] ?? map['buyer_name'] ?? map['buyerName'] ?? 'Valued Buyer',
      customerPhone: map['customerPhone'] ?? map['buyer_phone'] ?? map['buyerPhone'] ?? '+94771234567',
      farmName: map['farmName'] ?? map['farmer_name'] ?? map['farmerName'] ?? 'Upcountry Farm',
      itemsSummary: map['itemsSummary'] ?? map['items_summary'] ?? map['produceDescription'] ?? 'Fresh Farm Produce',
      totalAmount: parsedAmount > 0 ? parsedAmount : 1760.0,
      status: map['status']?.toString() ?? 'Pending',
      deliveryAddress: map['deliveryAddress'] ?? map['buyer_address'] ?? map['buyerAddress'] ?? 'Colombo 05',
      assignedDriverName: map['assignedDriverName'] ?? map['driver_name'] ?? 'Kasun Bandara',
      assignedDriverPhone: map['assignedDriverPhone'] ?? map['driver_phone'] ?? '+94717724640',
      orderDate: map['orderDate'] != null
          ? DateTime.tryParse(map['orderDate'].toString()) ?? DateTime.now()
          : (map['created_at'] != null
              ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }
}
