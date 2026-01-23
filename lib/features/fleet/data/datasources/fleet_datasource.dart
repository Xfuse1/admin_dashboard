import '../../domain/entities/vehicle_entity.dart';

/// Vehicle data source interface.
abstract class FleetDataSource {
  /// Gets all vehicles with optional filters.
  Future<List<VehicleEntity>> getVehicles({
    VehicleStatus? status,
    VehicleType? type,
    String? assignedDriverId,
    String? lastVehicleId,
    int limit = 20,
  });

  /// Gets a vehicle by ID.
  Future<VehicleEntity> getVehicleById(String id);

  /// Adds a new vehicle.
  Future<VehicleEntity> addVehicle(VehicleEntity vehicle);

  /// Updates an existing vehicle.
  Future<VehicleEntity> updateVehicle(VehicleEntity vehicle);

  /// Deletes a vehicle.
  Future<void> deleteVehicle(String id);

  /// Updates vehicle status.
  Future<VehicleEntity> updateVehicleStatus(String id, VehicleStatus status);

  /// Assigns a driver to a vehicle.
  Future<VehicleEntity> assignDriver(
    String vehicleId,
    String driverId,
    String driverName,
  );

  /// Unassigns driver from a vehicle.
  Future<VehicleEntity> unassignDriver(String vehicleId);

  /// Updates vehicle location.
  Future<void> updateVehicleLocation(
    String id,
    double latitude,
    double longitude,
  );

  /// Gets fleet statistics.
  Future<FleetStatsEntity> getFleetStats();

  /// Watches vehicles in real-time.
  Stream<List<VehicleEntity>> watchVehicles({VehicleStatus? status});

  /// Searches vehicles.
  Future<List<VehicleEntity>> searchVehicles(String query);

  /// Gets vehicles with alerts.
  Future<List<VehicleEntity>> getVehiclesWithAlerts();
}
