import '../../domain/entities/vehicle_entity.dart';
import 'fleet_datasource.dart';

/// Mock implementation of [FleetDataSource] for testing.
class FleetMockDataSource implements FleetDataSource {
  final List<VehicleEntity> _vehicles = _generateMockVehicles();

  static List<VehicleEntity> _generateMockVehicles() {
    final now = DateTime.now();
    return [
      VehicleEntity(
        id: 'v1',
        plateNumber: 'ABC 1234',
        type: VehicleType.motorcycle,
        brand: 'Honda',
        model: 'PCX 150',
        year: 2023,
        color: 'أحمر',
        status: VehicleStatus.available,
        totalKilometers: 15000,
        fuelType: 'petrol',
        licenseExpiry: now.add(const Duration(days: 180)),
        insuranceExpiry: now.add(const Duration(days: 90)),
        nextMaintenanceDate: now.add(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
      ),
      VehicleEntity(
        id: 'v2',
        plateNumber: 'DEF 5678',
        type: VehicleType.motorcycle,
        brand: 'Yamaha',
        model: 'NMAX 155',
        year: 2022,
        color: 'أزرق',
        status: VehicleStatus.inUse,
        assignedDriverId: 'd1',
        assignedDriverName: 'أحمد محمد',
        latitude: 30.0444,
        longitude: 31.2357,
        totalKilometers: 25000,
        fuelType: 'petrol',
        licenseExpiry: now.add(const Duration(days: 200)),
        insuranceExpiry: now.add(const Duration(days: 150)),
        nextMaintenanceDate: now.add(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 400)),
        updatedAt: now,
      ),
      VehicleEntity(
        id: 'v3',
        plateNumber: 'GHI 9012',
        type: VehicleType.car,
        brand: 'Toyota',
        model: 'Corolla',
        year: 2021,
        color: 'أبيض',
        status: VehicleStatus.maintenance,
        totalKilometers: 50000,
        fuelType: 'petrol',
        licenseExpiry: now.subtract(const Duration(days: 10)), // Expired!
        insuranceExpiry: now.add(const Duration(days: 100)),
        nextMaintenanceDate: now.subtract(const Duration(days: 5)), // Due!
        notes: 'تغيير زيت وفلتر',
        createdAt: now.subtract(const Duration(days: 500)),
        updatedAt: now,
      ),
      VehicleEntity(
        id: 'v4',
        plateNumber: 'JKL 3456',
        type: VehicleType.van,
        brand: 'Hyundai',
        model: 'H100',
        year: 2020,
        color: 'فضي',
        status: VehicleStatus.available,
        totalKilometers: 80000,
        fuelType: 'diesel',
        maxLoadCapacity: 1500,
        licenseExpiry: now.add(const Duration(days: 250)),
        insuranceExpiry: now.add(const Duration(days: 180)),
        nextMaintenanceDate: now.add(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 600)),
        updatedAt: now,
      ),
      VehicleEntity(
        id: 'v5',
        plateNumber: 'MNO 7890',
        type: VehicleType.motorcycle,
        brand: 'Suzuki',
        model: 'Address 110',
        year: 2024,
        color: 'أسود',
        status: VehicleStatus.inUse,
        assignedDriverId: 'd2',
        assignedDriverName: 'محمد علي',
        latitude: 30.0500,
        longitude: 31.2400,
        totalKilometers: 5000,
        fuelType: 'petrol',
        licenseExpiry: now.add(const Duration(days: 350)),
        insuranceExpiry: now.add(const Duration(days: 300)),
        nextMaintenanceDate: now.add(const Duration(days: 90)),
        createdAt: now.subtract(const Duration(days: 100)),
        updatedAt: now,
      ),
      VehicleEntity(
        id: 'v6',
        plateNumber: 'PQR 1234',
        type: VehicleType.truck,
        brand: 'Isuzu',
        model: 'NPR',
        year: 2019,
        color: 'أخضر',
        status: VehicleStatus.outOfService,
        totalKilometers: 120000,
        fuelType: 'diesel',
        maxLoadCapacity: 3500,
        licenseExpiry: now.subtract(const Duration(days: 30)), // Expired!
        insuranceExpiry: now.subtract(const Duration(days: 15)), // Expired!
        nextMaintenanceDate: now.subtract(const Duration(days: 20)), // Due!
        notes: 'يحتاج إصلاح المحرك',
        createdAt: now.subtract(const Duration(days: 800)),
        updatedAt: now,
      ),
      VehicleEntity(
        id: 'v7',
        plateNumber: 'STU 5678',
        type: VehicleType.bicycle,
        brand: 'Giant',
        model: 'Escape 3',
        year: 2023,
        color: 'برتقالي',
        status: VehicleStatus.available,
        totalKilometers: 2000,
        fuelType: 'none',
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now,
      ),
      VehicleEntity(
        id: 'v8',
        plateNumber: 'VWX 9012',
        type: VehicleType.motorcycle,
        brand: 'Honda',
        model: 'Click 125',
        year: 2023,
        color: 'رمادي',
        status: VehicleStatus.inUse,
        assignedDriverId: 'd3',
        assignedDriverName: 'عمر حسن',
        latitude: 30.0600,
        longitude: 31.2500,
        totalKilometers: 8000,
        fuelType: 'petrol',
        licenseExpiry: now.add(const Duration(days: 280)),
        insuranceExpiry: now.add(const Duration(days: 220)),
        nextMaintenanceDate: now.add(const Duration(days: 15)),
        createdAt: now.subtract(const Duration(days: 150)),
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<List<VehicleEntity>> getVehicles({
    VehicleStatus? status,
    VehicleType? type,
    String? assignedDriverId,
    String? lastVehicleId,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var result = _vehicles.toList();

    if (status != null) {
      result = result.where((v) => v.status == status).toList();
    }

    if (type != null) {
      result = result.where((v) => v.type == type).toList();
    }

    if (assignedDriverId != null) {
      result =
          result.where((v) => v.assignedDriverId == assignedDriverId).toList();
    }

    if (lastVehicleId != null) {
      final index = result.indexWhere((v) => v.id == lastVehicleId);
      if (index != -1 && index + 1 < result.length) {
        result = result.sublist(index + 1);
      }
    }

    return result.take(limit).toList();
  }

  @override
  Future<VehicleEntity> getVehicleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _vehicles.firstWhere(
      (v) => v.id == id,
      orElse: () => throw Exception('Vehicle not found'),
    );
  }

  @override
  Future<VehicleEntity> addVehicle(VehicleEntity vehicle) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newVehicle = vehicle.copyWith(
      id: 'v${_vehicles.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _vehicles.add(newVehicle);
    return newVehicle;
  }

  @override
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index == -1) throw Exception('Vehicle not found');

    final updated = vehicle.copyWith(updatedAt: DateTime.now());
    _vehicles[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _vehicles.removeWhere((v) => v.id == id);
  }

  @override
  Future<VehicleEntity> updateVehicleStatus(
    String id,
    VehicleStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _vehicles.indexWhere((v) => v.id == id);
    if (index == -1) throw Exception('Vehicle not found');

    final updated = _vehicles[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _vehicles[index] = updated;
    return updated;
  }

  @override
  Future<VehicleEntity> assignDriver(
    String vehicleId,
    String driverId,
    String driverName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index == -1) throw Exception('Vehicle not found');

    final updated = _vehicles[index].copyWith(
      assignedDriverId: driverId,
      assignedDriverName: driverName,
      status: VehicleStatus.inUse,
      updatedAt: DateTime.now(),
    );
    _vehicles[index] = updated;
    return updated;
  }

  @override
  Future<VehicleEntity> unassignDriver(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index == -1) throw Exception('Vehicle not found');

    // Create new vehicle without driver assignment
    final current = _vehicles[index];
    final updated = VehicleEntity(
      id: current.id,
      plateNumber: current.plateNumber,
      type: current.type,
      brand: current.brand,
      model: current.model,
      year: current.year,
      color: current.color,
      status: VehicleStatus.available,
      assignedDriverId: null,
      assignedDriverName: null,
      latitude: current.latitude,
      longitude: current.longitude,
      lastLocationUpdate: current.lastLocationUpdate,
      imageUrl: current.imageUrl,
      licenseExpiry: current.licenseExpiry,
      insuranceExpiry: current.insuranceExpiry,
      lastMaintenanceDate: current.lastMaintenanceDate,
      nextMaintenanceDate: current.nextMaintenanceDate,
      totalKilometers: current.totalKilometers,
      fuelType: current.fuelType,
      fuelCapacity: current.fuelCapacity,
      currentFuelLevel: current.currentFuelLevel,
      maxLoadCapacity: current.maxLoadCapacity,
      notes: current.notes,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    _vehicles[index] = updated;
    return updated;
  }

  @override
  Future<void> updateVehicleLocation(
    String id,
    double latitude,
    double longitude,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _vehicles.indexWhere((v) => v.id == id);
    if (index == -1) throw Exception('Vehicle not found');

    _vehicles[index] = _vehicles[index].copyWith(
      latitude: latitude,
      longitude: longitude,
      lastLocationUpdate: DateTime.now(),
    );
  }

  @override
  Future<FleetStatsEntity> getFleetStats() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    int available = 0;
    int inUse = 0;
    int maintenance = 0;
    int outOfService = 0;
    int expiredLicense = 0;
    int expiredInsurance = 0;
    int maintenanceDue = 0;
    double totalKm = 0;
    final Map<VehicleType, int> byType = {};

    for (final vehicle in _vehicles) {
      switch (vehicle.status) {
        case VehicleStatus.available:
          available++;
        case VehicleStatus.inUse:
          inUse++;
        case VehicleStatus.maintenance:
          maintenance++;
        case VehicleStatus.outOfService:
          outOfService++;
      }

      byType[vehicle.type] = (byType[vehicle.type] ?? 0) + 1;

      if (vehicle.licenseExpiry != null &&
          vehicle.licenseExpiry!.isBefore(now)) {
        expiredLicense++;
      }
      if (vehicle.insuranceExpiry != null &&
          vehicle.insuranceExpiry!.isBefore(now)) {
        expiredInsurance++;
      }
      if (vehicle.nextMaintenanceDate != null &&
          vehicle.nextMaintenanceDate!.isBefore(now)) {
        maintenanceDue++;
      }

      totalKm += vehicle.totalKilometers;
    }

    return FleetStatsEntity(
      totalVehicles: _vehicles.length,
      availableVehicles: available,
      inUseVehicles: inUse,
      maintenanceVehicles: maintenance,
      outOfServiceVehicles: outOfService,
      vehiclesWithExpiredLicense: expiredLicense,
      vehiclesWithExpiredInsurance: expiredInsurance,
      vehiclesDueForMaintenance: maintenanceDue,
      totalKilometersDriven: totalKm,
      vehiclesByType: byType,
    );
  }

  @override
  Stream<List<VehicleEntity>> watchVehicles({VehicleStatus? status}) async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      var result = _vehicles.toList();
      if (status != null) {
        result = result.where((v) => v.status == status).toList();
      }
      yield result;
    }
  }

  @override
  Future<List<VehicleEntity>> searchVehicles(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowerQuery = query.toLowerCase();
    return _vehicles.where((v) {
      return v.plateNumber.toLowerCase().contains(lowerQuery) ||
          v.brand.toLowerCase().contains(lowerQuery) ||
          v.model.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<VehicleEntity>> getVehiclesWithAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _vehicles.where((v) => v.hasAlerts).toList();
  }
}
