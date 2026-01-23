import 'package:equatable/equatable.dart';

/// Vehicle type enumeration.
enum VehicleType {
  motorcycle('motorcycle', 'دراجة نارية', '🏍️'),
  car('car', 'سيارة', '🚗'),
  van('van', 'فان', '🚐'),
  truck('truck', 'شاحنة', '🚚'),
  bicycle('bicycle', 'دراجة هوائية', '🚲');

  final String value;
  final String arabicName;
  final String emoji;

  const VehicleType(this.value, this.arabicName, this.emoji);

  static VehicleType fromValue(String value) {
    return VehicleType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => VehicleType.motorcycle,
    );
  }
}

/// Vehicle status enumeration.
enum VehicleStatus {
  available('available', 'متاح', 0xFF4CAF50),
  inUse('in_use', 'قيد الاستخدام', 0xFF2196F3),
  maintenance('maintenance', 'صيانة', 0xFFFF9800),
  outOfService('out_of_service', 'خارج الخدمة', 0xFFF44336);

  final String value;
  final String arabicName;
  final int color;

  const VehicleStatus(this.value, this.arabicName, this.color);

  static VehicleStatus fromValue(String value) {
    return VehicleStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VehicleStatus.available,
    );
  }
}

/// Vehicle entity representing a delivery vehicle.
class VehicleEntity extends Equatable {
  /// Unique vehicle identifier.
  final String id;

  /// Vehicle plate number.
  final String plateNumber;

  /// Vehicle type.
  final VehicleType type;

  /// Vehicle brand/make.
  final String brand;

  /// Vehicle model.
  final String model;

  /// Manufacturing year.
  final int year;

  /// Vehicle color.
  final String color;

  /// Current status.
  final VehicleStatus status;

  /// Assigned driver ID.
  final String? assignedDriverId;

  /// Assigned driver name.
  final String? assignedDriverName;

  /// Current latitude.
  final double? latitude;

  /// Current longitude.
  final double? longitude;

  /// Last location update time.
  final DateTime? lastLocationUpdate;

  /// Vehicle image URL.
  final String? imageUrl;

  /// License expiry date.
  final DateTime? licenseExpiry;

  /// Insurance expiry date.
  final DateTime? insuranceExpiry;

  /// Last maintenance date.
  final DateTime? lastMaintenanceDate;

  /// Next maintenance date.
  final DateTime? nextMaintenanceDate;

  /// Total kilometers driven.
  final double totalKilometers;

  /// Fuel type (petrol, diesel, electric, hybrid).
  final String fuelType;

  /// Fuel capacity in liters.
  final double? fuelCapacity;

  /// Current fuel level percentage (0-100).
  final double? currentFuelLevel;

  /// Maximum load capacity in kg.
  final double? maxLoadCapacity;

  /// Notes about the vehicle.
  final String? notes;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  const VehicleEntity({
    required this.id,
    required this.plateNumber,
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.status,
    this.assignedDriverId,
    this.assignedDriverName,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
    this.imageUrl,
    this.licenseExpiry,
    this.insuranceExpiry,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.totalKilometers = 0.0,
    this.fuelType = 'petrol',
    this.fuelCapacity,
    this.currentFuelLevel,
    this.maxLoadCapacity,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if license is expired.
  bool get isLicenseExpired =>
      licenseExpiry != null && licenseExpiry!.isBefore(DateTime.now());

  /// Check if insurance is expired.
  bool get isInsuranceExpired =>
      insuranceExpiry != null && insuranceExpiry!.isBefore(DateTime.now());

  /// Check if maintenance is due.
  bool get isMaintenanceDue =>
      nextMaintenanceDate != null &&
      nextMaintenanceDate!.isBefore(DateTime.now());

  /// Check if vehicle has any alerts.
  bool get hasAlerts =>
      isLicenseExpired || isInsuranceExpired || isMaintenanceDue;

  /// Get vehicle display name.
  String get displayName => '$brand $model ($plateNumber)';

  /// Get short display name.
  String get shortName => '$brand $model';

  /// Check if vehicle is assigned.
  bool get isAssigned => assignedDriverId != null;

  /// Check if location is available.
  bool get hasLocation => latitude != null && longitude != null;

  /// Creates a copy with updated fields.
  VehicleEntity copyWith({
    String? id,
    String? plateNumber,
    VehicleType? type,
    String? brand,
    String? model,
    int? year,
    String? color,
    VehicleStatus? status,
    String? assignedDriverId,
    String? assignedDriverName,
    double? latitude,
    double? longitude,
    DateTime? lastLocationUpdate,
    String? imageUrl,
    DateTime? licenseExpiry,
    DateTime? insuranceExpiry,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    double? totalKilometers,
    String? fuelType,
    double? fuelCapacity,
    double? currentFuelLevel,
    double? maxLoadCapacity,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      status: status ?? this.status,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      imageUrl: imageUrl ?? this.imageUrl,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      totalKilometers: totalKilometers ?? this.totalKilometers,
      fuelType: fuelType ?? this.fuelType,
      fuelCapacity: fuelCapacity ?? this.fuelCapacity,
      currentFuelLevel: currentFuelLevel ?? this.currentFuelLevel,
      maxLoadCapacity: maxLoadCapacity ?? this.maxLoadCapacity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        plateNumber,
        type,
        brand,
        model,
        year,
        color,
        status,
        assignedDriverId,
        latitude,
        longitude,
        totalKilometers,
      ];
}

/// Fleet statistics entity.
class FleetStatsEntity extends Equatable {
  final int totalVehicles;
  final int availableVehicles;
  final int inUseVehicles;
  final int maintenanceVehicles;
  final int outOfServiceVehicles;
  final int vehiclesWithExpiredLicense;
  final int vehiclesWithExpiredInsurance;
  final int vehiclesDueForMaintenance;
  final double totalKilometersDriven;
  final Map<VehicleType, int> vehiclesByType;

  const FleetStatsEntity({
    this.totalVehicles = 0,
    this.availableVehicles = 0,
    this.inUseVehicles = 0,
    this.maintenanceVehicles = 0,
    this.outOfServiceVehicles = 0,
    this.vehiclesWithExpiredLicense = 0,
    this.vehiclesWithExpiredInsurance = 0,
    this.vehiclesDueForMaintenance = 0,
    this.totalKilometersDriven = 0.0,
    this.vehiclesByType = const {},
  });

  /// Total alerts count.
  int get totalAlerts =>
      vehiclesWithExpiredLicense +
      vehiclesWithExpiredInsurance +
      vehiclesDueForMaintenance;

  /// Availability rate percentage.
  double get availabilityRate =>
      totalVehicles > 0 ? (availableVehicles / totalVehicles) * 100 : 0;

  @override
  List<Object?> get props => [
        totalVehicles,
        availableVehicles,
        inUseVehicles,
        maintenanceVehicles,
        outOfServiceVehicles,
        totalAlerts,
      ];
}
