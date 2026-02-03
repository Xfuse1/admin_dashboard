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
