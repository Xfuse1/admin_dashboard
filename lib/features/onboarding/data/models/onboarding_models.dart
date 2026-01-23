import '../../domain/entities/onboarding_entities.dart';

/// Model for store onboarding request.
class StoreOnboardingModel extends StoreOnboardingEntity {
  const StoreOnboardingModel({
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
    required super.storeName,
    required super.storeType,
    required super.address,
    required super.ownerName,
    required super.ownerIdNumber,
    required super.commercialRegister,
    super.logoUrl,
    super.commercialRegisterUrl,
    super.ownerIdUrl,
    super.categories,
  });

  factory StoreOnboardingModel.fromJson(Map<String, dynamic> json) {
    return StoreOnboardingModel(
      id: json['id'] as String,
      status: OnboardingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OnboardingStatus.pending,
      ),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt']
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      reviewedAt: json['reviewedAt'] != null
          ? (json['reviewedAt'] is DateTime
              ? json['reviewedAt']
              : DateTime.tryParse(json['reviewedAt'].toString()))
          : null,
      reviewedBy: json['reviewedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      notes: json['notes'] as String?,
      storeName: json['storeName'] as String? ?? '',
      storeType: json['storeType'] as String? ?? 'other',
      address: json['address'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      ownerIdNumber: json['ownerIdNumber'] as String? ?? '',
      commercialRegister: json['commercialRegister'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      commercialRegisterUrl: json['commercialRegisterUrl'] as String?,
      ownerIdUrl: json['ownerIdUrl'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'status': status.name,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
      'notes': notes,
      'storeName': storeName,
      'storeType': storeType,
      'address': address,
      'ownerName': ownerName,
      'ownerIdNumber': ownerIdNumber,
      'commercialRegister': commercialRegister,
      'logoUrl': logoUrl,
      'commercialRegisterUrl': commercialRegisterUrl,
      'ownerIdUrl': ownerIdUrl,
      'categories': categories,
    };
  }

  StoreOnboardingEntity toEntity() => this;
}

/// Model for driver onboarding request.
class DriverOnboardingModel extends DriverOnboardingEntity {
  const DriverOnboardingModel({
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
    required super.idNumber,
    required super.licenseNumber,
    required super.licenseExpiryDate,
    required super.vehicleType,
    required super.vehiclePlate,
    super.photoUrl,
    super.idDocumentUrl,
    super.licenseUrl,
    super.vehicleRegistrationUrl,
    super.vehicleInsuranceUrl,
  });

  factory DriverOnboardingModel.fromJson(Map<String, dynamic> json) {
    return DriverOnboardingModel(
      id: json['id'] as String,
      status: OnboardingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OnboardingStatus.pending,
      ),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt']
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      reviewedAt: json['reviewedAt'] != null
          ? (json['reviewedAt'] is DateTime
              ? json['reviewedAt']
              : DateTime.tryParse(json['reviewedAt'].toString()))
          : null,
      reviewedBy: json['reviewedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      notes: json['notes'] as String?,
      idNumber: json['idNumber'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String? ?? '',
      licenseExpiryDate: json['licenseExpiryDate'] is DateTime
          ? json['licenseExpiryDate']
          : DateTime.tryParse(json['licenseExpiryDate']?.toString() ?? '') ??
              DateTime.now(),
      vehicleType: json['vehicleType'] as String? ?? '',
      vehiclePlate: json['vehiclePlate'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      idDocumentUrl: json['idDocumentUrl'] as String?,
      licenseUrl: json['licenseUrl'] as String?,
      vehicleRegistrationUrl: json['vehicleRegistrationUrl'] as String?,
      vehicleInsuranceUrl: json['vehicleInsuranceUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'status': status.name,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
      'notes': notes,
      'idNumber': idNumber,
      'licenseNumber': licenseNumber,
      'licenseExpiryDate': licenseExpiryDate.toIso8601String(),
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'photoUrl': photoUrl,
      'idDocumentUrl': idDocumentUrl,
      'licenseUrl': licenseUrl,
      'vehicleRegistrationUrl': vehicleRegistrationUrl,
      'vehicleInsuranceUrl': vehicleInsuranceUrl,
    };
  }

  DriverOnboardingEntity toEntity() => this;
}

/// Helper to parse onboarding request from JSON.
OnboardingRequestEntity onboardingRequestFromJson(Map<String, dynamic> json) {
  final type = json['type'] as String?;
  if (type == 'driver') {
    return DriverOnboardingModel.fromJson(json);
  }
  return StoreOnboardingModel.fromJson(json);
}
