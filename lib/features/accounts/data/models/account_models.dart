import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/account_entities.dart';

/// Customer model for data layer.
class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.imageUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.totalOrders,
    super.totalSpent,
    super.lastOrderId,
    super.lastOrderDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      lastOrderId: json['lastOrderId'] as String?,
      lastOrderDate: json['lastOrderDate'] != null
          ? _parseDateTime(json['lastOrderDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'lastOrderId': lastOrderId,
      'lastOrderDate': lastOrderDate?.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalOrders,
    double? totalSpent,
    String? lastOrderId,
    DateTime? lastOrderDate,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      lastOrderId: lastOrderId ?? this.lastOrderId,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
    );
  }
}

/// Store model for data layer.
class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.imageUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.type,
    super.description,
    super.address,
    super.latitude,
    super.longitude,
    super.isOpen,
    super.isApproved,
    super.rating,
    super.totalRatings,
    super.totalOrders,
    super.totalRevenue,
    super.commissionRate,
    super.commercialRegisterImage,
    super.categories,
    super.workingHours,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      type: json['type'] as String? ?? 'restaurant',
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isOpen: json['isOpen'] as bool? ?? false,
      isApproved: json['isApproved'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] as int? ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.15,
      commercialRegisterImage: json['commercialRegisterImage'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': type,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isOpen': isOpen,
      'isApproved': isApproved,
      'rating': rating,
      'totalRatings': totalRatings,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'commissionRate': commissionRate,
      'commercialRegisterImage': commercialRegisterImage,
      'categories': categories,
    };
  }

  StoreModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    bool? isOpen,
    bool? isApproved,
    double? rating,
    int? totalRatings,
    int? totalOrders,
    double? totalRevenue,
    double? commissionRate,
    String? commercialRegisterImage,
    List<String>? categories,
    WorkingHours? workingHours,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOpen: isOpen ?? this.isOpen,
      isApproved: isApproved ?? this.isApproved,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      commissionRate: commissionRate ?? this.commissionRate,
      commercialRegisterImage:
          commercialRegisterImage ?? this.commercialRegisterImage,
      categories: categories ?? this.categories,
      workingHours: workingHours ?? this.workingHours,
    );
  }
}

/// Driver model for data layer.
class DriverModel extends DriverEntity {
  const DriverModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.imageUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.isOnline,
    super.isApproved,
    super.rating,
    super.totalRatings,
    super.totalDeliveries,
    super.walletBalance,
    super.latitude,
    super.longitude,
    super.vehicleType,
    super.vehiclePlate,
    super.licenseImage,
    super.idCardImage,
    super.vehicleImage,
    super.criminalRecordImage,
    super.lastActiveAt,
    super.rejectionsCounter,
    super.currentOrdersCount,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      isOnline: json['isOnline'] as bool? ?? false,
      isApproved: json['isApproved'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] as int? ?? 0,
      totalDeliveries: json['totalDeliveries'] as int? ?? 0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      vehicleType: json['vehicleType'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      licenseImage: json['licenseImage'] as String?,
      idCardImage: json['idCardImage'] as String?,
      vehicleImage: json['vehicleImage'] as String?,
      criminalRecordImage: json['criminalRecordImage'] as String?,
      lastActiveAt: json['lastActiveAt'] != null
          ? _parseDateTime(json['lastActiveAt'])
          : null,
      rejectionsCounter: json['rejectionsCounter'] as int? ?? 0,
      currentOrdersCount: json['currentOrdersCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isOnline': isOnline,
      'isApproved': isApproved,
      'rating': rating,
      'totalRatings': totalRatings,
      'totalDeliveries': totalDeliveries,
      'walletBalance': walletBalance,
      'latitude': latitude,
      'longitude': longitude,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'licenseImage': licenseImage,
      'idCardImage': idCardImage,
      'vehicleImage': vehicleImage,
      'criminalRecordImage': criminalRecordImage,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'rejectionsCounter': rejectionsCounter,
      'currentOrdersCount': currentOrdersCount,
    };
  }

  DriverModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOnline,
    bool? isApproved,
    double? rating,
    int? totalRatings,
    int? totalDeliveries,
    double? walletBalance,
    double? latitude,
    double? longitude,
    String? vehicleType,
    String? vehiclePlate,
    String? licenseImage,
    String? idCardImage,
    String? vehicleImage,
    String? criminalRecordImage,
    DateTime? lastActiveAt,
    int? rejectionsCounter,
    int? currentOrdersCount,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnline: isOnline ?? this.isOnline,
      isApproved: isApproved ?? this.isApproved,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      walletBalance: walletBalance ?? this.walletBalance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      licenseImage: licenseImage ?? this.licenseImage,
      idCardImage: idCardImage ?? this.idCardImage,
      vehicleImage: vehicleImage ?? this.vehicleImage,
      criminalRecordImage: criminalRecordImage ?? this.criminalRecordImage,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      rejectionsCounter: rejectionsCounter ?? this.rejectionsCounter,
      currentOrdersCount: currentOrdersCount ?? this.currentOrdersCount,
    );
  }
}

/// Helper function to parse DateTime from either Timestamp or String
DateTime _parseDateTime(dynamic value) {
  if (value == null) {
    return DateTime.now();
  }

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is String) {
    return DateTime.parse(value);
  }

  if (value is DateTime) {
    return value;
  }

  // Fallback to current time if type is unexpected
  return DateTime.now();
}
