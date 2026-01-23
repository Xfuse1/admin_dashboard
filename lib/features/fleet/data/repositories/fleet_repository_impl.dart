import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/fleet_repository.dart';
import '../datasources/fleet_datasource.dart';

/// Implementation of [FleetRepository].
class FleetRepositoryImpl implements FleetRepository {
  final FleetDataSource _dataSource;

  const FleetRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<VehicleEntity>>> getVehicles({
    VehicleStatus? status,
    VehicleType? type,
    String? assignedDriverId,
    String? lastVehicleId,
    int limit = 20,
  }) async {
    try {
      final vehicles = await _dataSource.getVehicles(
        status: status,
        type: type,
        assignedDriverId: assignedDriverId,
        lastVehicleId: lastVehicleId,
        limit: limit,
      );
      return Right(vehicles);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> getVehicleById(String id) async {
    try {
      final vehicle = await _dataSource.getVehicleById(id);
      return Right(vehicle);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> addVehicle(
      VehicleEntity vehicle) async {
    try {
      final result = await _dataSource.addVehicle(vehicle);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicle(
      VehicleEntity vehicle) async {
    try {
      final result = await _dataSource.updateVehicle(vehicle);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVehicle(String id) async {
    try {
      await _dataSource.deleteVehicle(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> updateVehicleStatus(
    String id,
    VehicleStatus status,
  ) async {
    try {
      final result = await _dataSource.updateVehicleStatus(id, status);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> assignDriver(
    String vehicleId,
    String driverId,
    String driverName,
  ) async {
    try {
      final result =
          await _dataSource.assignDriver(vehicleId, driverId, driverName);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> unassignDriver(
      String vehicleId) async {
    try {
      final result = await _dataSource.unassignDriver(vehicleId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateVehicleLocation(
    String id,
    double latitude,
    double longitude,
  ) async {
    try {
      await _dataSource.updateVehicleLocation(id, latitude, longitude);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FleetStatsEntity>> getFleetStats() async {
    try {
      final stats = await _dataSource.getFleetStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<VehicleEntity>>> watchVehicles({
    VehicleStatus? status,
  }) {
    return _dataSource.watchVehicles(status: status).map(
          (vehicles) => Right<Failure, List<VehicleEntity>>(vehicles),
        );
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> searchVehicles(
      String query) async {
    try {
      final vehicles = await _dataSource.searchVehicles(query);
      return Right(vehicles);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getVehiclesWithAlerts() async {
    try {
      final vehicles = await _dataSource.getVehiclesWithAlerts();
      return Right(vehicles);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
