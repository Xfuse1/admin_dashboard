import 'package:equatable/equatable.dart';

/// Base account entity.
abstract class AccountEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, email, phone, isActive, createdAt];
}

/// Customer entity.
class CustomerEntity extends AccountEntity {
  final int totalOrders;
  final double totalSpent;
  final String? lastOrderId;
  final DateTime? lastOrderDate;

  const CustomerEntity({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.imageUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.lastOrderId,
    this.lastOrderDate,
  });

  CustomerEntity copyWith({
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
    return CustomerEntity(
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

  @override
  List<Object?> get props => [...super.props, totalOrders, totalSpent];
}

/// Store entity.
class StoreEntity extends AccountEntity {
  final String type;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isOpen;
  final bool isApproved;
  final double rating;
  final int totalRatings;
  final int totalOrders;
  final double totalRevenue;
  final double commissionRate;
  final String? commercialRegisterImage;
  final List<String> categories;
  final WorkingHours? workingHours;

  const StoreEntity({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.imageUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required this.type,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.isOpen = false,
    this.isApproved = false,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
    this.commissionRate = 0.15,
    this.commercialRegisterImage,
    this.categories = const [],
    this.workingHours,
  });

  StoreEntity copyWith({
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
    return StoreEntity(
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

  @override
  List<Object?> get props => [
        ...super.props,
        type,
        isOpen,
        isApproved,
        rating,
        totalOrders,
      ];
}

/// Driver entity.
class DriverEntity extends AccountEntity {
  final bool isOnline;
  final bool isApproved;
  final double rating;
  final int totalRatings;
  final int totalDeliveries;
  final double walletBalance;
  final double? latitude;
  final double? longitude;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? licenseImage;
  final String? idCardImage;
  final String? vehicleImage;
  final String? criminalRecordImage;
  final DateTime? lastActiveAt;
  final int rejectionsCounter;
  final int currentOrdersCount;

  const DriverEntity({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.imageUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    this.isOnline = false,
    this.isApproved = false,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.totalDeliveries = 0,
    this.walletBalance = 0.0,
    this.latitude,
    this.longitude,
    this.vehicleType,
    this.vehiclePlate,
    this.licenseImage,
    this.idCardImage,
    this.vehicleImage,
    this.criminalRecordImage,
    this.lastActiveAt,
    this.rejectionsCounter = 0,
    this.currentOrdersCount = 0,
  });

  DriverEntity copyWith({
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
    return DriverEntity(
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

  @override
  List<Object?> get props => [
        ...super.props,
        isOnline,
        isApproved,
        rating,
        totalDeliveries,
        rejectionsCounter,
      ];
}

/// Working hours model.
class WorkingHours extends Equatable {
  final Map<String, DaySchedule> schedule;

  const WorkingHours({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

/// Day schedule.
class DaySchedule extends Equatable {
  final bool isOpen;
  final String? openTime;
  final String? closeTime;

  const DaySchedule({
    this.isOpen = false,
    this.openTime,
    this.closeTime,
  });

  @override
  List<Object?> get props => [isOpen, openTime, closeTime];
}

/// Account type enumeration.
enum AccountType {
  customer('customers', 'العملاء'),
  store('stores', 'المتاجر'),
  driver('drivers', 'السائقين');

  final String collection;
  final String arabicName;

  const AccountType(this.collection, this.arabicName);
}
