import 'package:equatable/equatable.dart';

/// Application status for driver accounts.
enum ApplicationStatus {
  pending('pending', 'قيد الانتظار'),
  underReview('underReview', 'قيد المراجعة'),
  approved('approved', 'مقبول'),
  rejected('rejected', 'مرفوض');

  const ApplicationStatus(this.value, this.arabicName);
  final String value;
  final String arabicName;

  static ApplicationStatus fromString(String? value) {
    return ApplicationStatus.values.firstWhere(
      (status) => status.value == value || status.name == value,
      orElse: () => ApplicationStatus.pending,
    );
  }

  bool get canAccessApp => this == ApplicationStatus.approved;
  bool get isPending =>
      this == ApplicationStatus.pending ||
      this == ApplicationStatus.underReview;
}

/// Vehicle type enum.
enum VehicleType {
  car('car', 'سيارة'),
  motorcycle('motorcycle', 'دراجة نارية'),
  bicycle('bicycle', 'دراجة هوائية');

  const VehicleType(this.value, this.arabicName);
  final String value;
  final String arabicName;

  static VehicleType fromString(String? value) {
    return VehicleType.values.firstWhere(
      (type) => type.value == value || type.name == value,
      orElse: () => VehicleType.car,
    );
  }
}

/// Driver application entity.
class DriverApplicationEntity extends Equatable {
  final String id;
  final String userId;
  final ApplicationStatus status;
  final String name;
  final String email;
  final String phone;
  final String idNumber;
  final String licenseNumber;
  final DateTime licenseExpiryDate;
  final VehicleType vehicleType;
  final String vehiclePlate;
  final String? photoUrl;
  final String? idDocumentUrl;
  final String? licenseUrl;
  final String? vehicleRegistrationUrl;
  final String? vehicleInsuranceUrl;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;
  final String? notes;

  const DriverApplicationEntity({
    required this.id,
    required this.userId,
    required this.status,
    required this.name,
    required this.email,
    required this.phone,
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
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
    this.notes,
  });

  DriverApplicationEntity copyWith({
    ApplicationStatus? status,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
  }) {
    return DriverApplicationEntity(
      id: id,
      userId: userId,
      status: status ?? this.status,
      name: name,
      email: email,
      phone: phone,
      idNumber: idNumber,
      licenseNumber: licenseNumber,
      licenseExpiryDate: licenseExpiryDate,
      vehicleType: vehicleType,
      vehiclePlate: vehiclePlate,
      photoUrl: photoUrl,
      idDocumentUrl: idDocumentUrl,
      licenseUrl: licenseUrl,
      vehicleRegistrationUrl: vehicleRegistrationUrl,
      vehicleInsuranceUrl: vehicleInsuranceUrl,
      createdAt: createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        status,
        name,
        email,
        phone,
        createdAt,
        reviewedAt,
      ];
}
