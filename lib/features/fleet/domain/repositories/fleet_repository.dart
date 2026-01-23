import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/vehicle_entity.dart';

/// Fleet repository interface.
abstract class FleetRepository {
  /// Gets all vehicles with optional filters.
  Future<Either<Failure, List<VehicleEntity>>> getVehicles({
    VehicleStatus? status,
    VehicleType? type,
    String? assignedDriverId,
    String? lastVehicleId,
    int limit = 20,
  });

  /// Gets a vehicle by ID.
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id);

  /// Adds a new vehicle.
  Future<Either<Failure, VehicleEntity>> addVehicle(VehicleEntity vehicle);

  /// Updates an existing vehicle.
  Future<Either<Failure, VehicleEntity>> updateVehicle(VehicleEntity vehicle);

  /// Deletes a vehicle.
  Future<Either<Failure, void>> deleteVehicle(String id);

  /// Updates vehicle status.
  Future<Either<Failure, VehicleEntity>> updateVehicleStatus(
    String id,
    VehicleStatus status,
  );

  /// Assigns a driver to a vehicle.
  Future<Either<Failure, VehicleEntity>> assignDriver(
    String vehicleId,
    String driverId,
    String driverName,
  );

  /// Unassigns driver from a vehicle.
  Future<Either<Failure, VehicleEntity>> unassignDriver(String vehicleId);

  /// Updates vehicle location.
  Future<Either<Failure, void>> updateVehicleLocation(
    String id,
    double latitude,
    double longitude,
  );

  /// Gets fleet statistics.
  Future<Either<Failure, FleetStatsEntity>> getFleetStats();

  /// Watches vehicles in real-time.
  Stream<Either<Failure, List<VehicleEntity>>> watchVehicles({
    VehicleStatus? status,
  });

  /// Searches vehicles by plate number or brand/model.
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles(String query);

  /// Gets vehicles with alerts (expired license, insurance, or maintenance due).
  Future<Either<Failure, List<VehicleEntity>>> getVehiclesWithAlerts();
}
