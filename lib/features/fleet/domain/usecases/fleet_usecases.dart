import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/fleet_repository.dart';

/// Get vehicles use case.
class GetVehicles {
  final FleetRepository _repository;

  const GetVehicles(this._repository);

  Future<Either<Failure, List<VehicleEntity>>> call({
    VehicleStatus? status,
    VehicleType? type,
    String? assignedDriverId,
    String? lastVehicleId,
    int limit = 20,
  }) {
    return _repository.getVehicles(
      status: status,
      type: type,
      assignedDriverId: assignedDriverId,
      lastVehicleId: lastVehicleId,
      limit: limit,
    );
  }
}

/// Get vehicle by ID use case.
class GetVehicleById {
  final FleetRepository _repository;

  const GetVehicleById(this._repository);

  Future<Either<Failure, VehicleEntity>> call(String id) {
    return _repository.getVehicleById(id);
  }
}

/// Add vehicle use case.
class AddVehicle {
  final FleetRepository _repository;

  const AddVehicle(this._repository);

  Future<Either<Failure, VehicleEntity>> call(VehicleEntity vehicle) {
    return _repository.addVehicle(vehicle);
  }
}

/// Update vehicle use case.
class UpdateVehicle {
  final FleetRepository _repository;

  const UpdateVehicle(this._repository);

  Future<Either<Failure, VehicleEntity>> call(VehicleEntity vehicle) {
    return _repository.updateVehicle(vehicle);
  }
}

/// Delete vehicle use case.
class DeleteVehicle {
  final FleetRepository _repository;

  const DeleteVehicle(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteVehicle(id);
  }
}

/// Update vehicle status use case.
class UpdateVehicleStatus {
  final FleetRepository _repository;

  const UpdateVehicleStatus(this._repository);

  Future<Either<Failure, VehicleEntity>> call(String id, VehicleStatus status) {
    return _repository.updateVehicleStatus(id, status);
  }
}

/// Assign driver to vehicle use case.
class AssignDriverToVehicle {
  final FleetRepository _repository;

  const AssignDriverToVehicle(this._repository);

  Future<Either<Failure, VehicleEntity>> call({
    required String vehicleId,
    required String driverId,
    required String driverName,
  }) {
    return _repository.assignDriver(vehicleId, driverId, driverName);
  }
}

/// Unassign driver from vehicle use case.
class UnassignDriverFromVehicle {
  final FleetRepository _repository;

  const UnassignDriverFromVehicle(this._repository);

  Future<Either<Failure, VehicleEntity>> call(String vehicleId) {
    return _repository.unassignDriver(vehicleId);
  }
}

/// Get fleet stats use case.
class GetFleetStats {
  final FleetRepository _repository;

  const GetFleetStats(this._repository);

  Future<Either<Failure, FleetStatsEntity>> call() {
    return _repository.getFleetStats();
  }
}

/// Watch vehicles use case.
class WatchVehicles {
  final FleetRepository _repository;

  const WatchVehicles(this._repository);

  Stream<Either<Failure, List<VehicleEntity>>> call({VehicleStatus? status}) {
    return _repository.watchVehicles(status: status);
  }
}

/// Search vehicles use case.
class SearchVehicles {
  final FleetRepository _repository;

  const SearchVehicles(this._repository);

  Future<Either<Failure, List<VehicleEntity>>> call(String query) {
    return _repository.searchVehicles(query);
  }
}

/// Get vehicles with alerts use case.
class GetVehiclesWithAlerts {
  final FleetRepository _repository;

  const GetVehiclesWithAlerts(this._repository);

  Future<Either<Failure, List<VehicleEntity>>> call() {
    return _repository.getVehiclesWithAlerts();
  }
}
