import 'package:equatable/equatable.dart';

/// Onboarding request status.
enum OnboardingStatus {
  pending,
  approved,
  rejected,
  underReview;

  String get arabicName => switch (this) {
        OnboardingStatus.pending => 'قيد الانتظار',
        OnboardingStatus.approved => 'مقبول',
        OnboardingStatus.rejected => 'مرفوض',
        OnboardingStatus.underReview => 'قيد المراجعة',
      };
}

/// Request type.
enum OnboardingType {
  store,
  driver;

  String get arabicName => switch (this) {
        OnboardingType.store => 'متجر',
        OnboardingType.driver => 'سائق',
      };
}

/// Base class for onboarding requests.
abstract class OnboardingRequestEntity extends Equatable {
  final String id;
  final OnboardingType type;
  final OnboardingStatus status;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;
  final String? notes;

  const OnboardingRequestEntity({
    required this.id,
    required this.type,
    required this.status,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        name,
        email,
        phone,
        createdAt,
        reviewedAt,
        reviewedBy,
        rejectionReason,
        notes,
      ];
}

/// Store onboarding request entity.
class StoreOnboardingEntity extends OnboardingRequestEntity {
  final String storeName;
  final String storeType;
  final String address;
  final String? street;
  final String ownerName;
  final String ownerIdNumber;
  final String commercialRegister;
  final String? logoUrl;
  final String? commercialRegisterUrl;
  final String? ownerIdUrl;
  final String? taxCardImageUrl;
  final bool phoneVerified;
  final DateTime? phoneVerifiedAt;
  final List<String> categories;
  final double? latitude;
  final double? longitude;

  const StoreOnboardingEntity({
    required super.id,
    required super.status,
    required super.name,
    required super.email,
    required super.phone,
    required super.createdAt,
    super.reviewedAt,
    super.reviewedBy,
    super.rejectionReason,
    super.notes,
    required this.storeName,
    required this.storeType,
    required this.address,
    this.street,
    required this.ownerName,
    required this.ownerIdNumber,
    required this.commercialRegister,
    this.logoUrl,
    this.commercialRegisterUrl,
    this.ownerIdUrl,
    this.taxCardImageUrl,
    this.phoneVerified = false,
    this.phoneVerifiedAt,
    this.categories = const [],
    this.latitude,
    this.longitude,
  }) : super(type: OnboardingType.store);

  /// Whether this store has valid location coordinates.
  bool get hasLocation => latitude != null && longitude != null;

  @override
  List<Object?> get props => [
        ...super.props,
        storeName,
        storeType,
        address,
        street,
        ownerName,
        ownerIdNumber,
        commercialRegister,
        logoUrl,
        commercialRegisterUrl,
        ownerIdUrl,
        taxCardImageUrl,
        phoneVerified,
        phoneVerifiedAt,
        categories,
        latitude,
        longitude,
      ];
}

/// Driver onboarding request entity.
class DriverOnboardingEntity extends OnboardingRequestEntity {
  final String idNumber;
  final String licenseNumber;
  final DateTime licenseExpiryDate;
  final String vehicleType;
  final String vehiclePlate;
  final String? photoUrl;
  final String? idDocumentUrl;
  final String? licenseUrl;
  final String? vehicleRegistrationUrl;
  final String? vehicleInsuranceUrl;

  const DriverOnboardingEntity({
    required super.id,
    required super.status,
    required super.name,
    required super.email,
    required super.phone,
    required super.createdAt,
    super.reviewedAt,
    super.reviewedBy,
    super.rejectionReason,
    super.notes,
    required this.idNumber,
    required this.licenseNumber,
    required this.licenseExpiryDate,
    required this.vehicleType,
    required this.vehiclePlate,
    this.photoUrl,
    this.idDocumentUrl,
    this.licenseUrl,
    this.vehicleRegistrationUrl,
    this.vehicleInsuranceUrl,
  }) : super(type: OnboardingType.driver);

  @override
  List<Object?> get props => [
        ...super.props,
        idNumber,
        licenseNumber,
        licenseExpiryDate,
        vehicleType,
        vehiclePlate,
        photoUrl,
        idDocumentUrl,
        licenseUrl,
        vehicleRegistrationUrl,
        vehicleInsuranceUrl,
      ];
}
