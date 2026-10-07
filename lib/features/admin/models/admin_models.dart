
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

  factory AdminFarmerModel.fromMap(Map<String, dynamic> map) {
    return AdminFarmerModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      farmName: map['farmName'] ?? '',
      district: map['district'] ?? 'Nuwara Eliya',
      agrarianCenter: map['agrarianCenter'] ?? 'Hakgala Center',
      scale: map['scale'] ?? '1 - 3 Acres',
      practice: map['practice'] ?? 'Certified Organic',
      crops: (map['crops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Vegetables'],
      nic: map['nic'] ?? '',
      bankName: map['bankName'] ?? 'Commercial Bank',
      accountNumber: map['accountNumber'] ?? '',
      isVerified: map['isVerified'] ?? true,
      status: map['status'] ?? 'Active',
      registeredAt: map['registeredAt'] != null
          ? DateTime.tryParse(map['registeredAt']) ?? DateTime.now()
          : DateTime.now(),
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

  factory AdminBuyerModel.fromMap(Map<String, dynamic> map) {
    return AdminBuyerModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? 'Colombo',
      hub: map['hub'] ?? 'Colombo Central Hub',
      buyerType: map['buyerType'] ?? 'Family',
      totalOrders: (map['totalOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Active',
      registeredAt: map['registeredAt'] != null
          ? DateTime.tryParse(map['registeredAt']) ?? DateTime.now()
          : DateTime.now(),
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

  factory AdminDriverModel.fromMap(Map<String, dynamic> map) {
    return AdminDriverModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      vehicleType: map['vehicleType'] ?? 'Van',
      plateNumber: map['plateNumber'] ?? '',
      cargoCapacity: map['cargoCapacity'] ?? '1,000 kg',
      bankName: map['bankName'] ?? 'Commercial Bank',
      accountNumber: map['accountNumber'] ?? '',
      isOnDuty: map['isOnDuty'] ?? true,
      completedTrips: (map['completedTrips'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      status: map['status'] ?? 'Active',
      registeredAt: map['registeredAt'] != null
          ? DateTime.tryParse(map['registeredAt']) ?? DateTime.now()
          : DateTime.now(),
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

  factory AdminProductModel.fromMap(Map<String, dynamic> map) {
    return AdminProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Vegetables',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '/kg',
      availableQty: (map['availableQty'] as num?)?.toDouble() ?? 0.0,
      farmName: map['farmName'] ?? '',
      farmerName: map['farmerName'] ?? '',
      isOrganic: map['isOrganic'] ?? true,
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'In Stock',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
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

  factory AdminOrderModel.fromMap(Map<String, dynamic> map) {
    return AdminOrderModel(
      id: map['id'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      farmName: map['farmName'] ?? '',
      itemsSummary: map['itemsSummary'] ?? '',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Pending',
      deliveryAddress: map['deliveryAddress'] ?? 'Colombo',
      assignedDriverName: map['assignedDriverName'] ?? 'Unassigned',
      assignedDriverPhone: map['assignedDriverPhone'] ?? '',
      orderDate: map['orderDate'] != null
          ? DateTime.tryParse(map['orderDate']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
