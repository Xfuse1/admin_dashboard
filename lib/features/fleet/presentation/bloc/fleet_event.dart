import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle_entity.dart';

/// Fleet events.
sealed class FleetEvent extends Equatable {
  const FleetEvent();

  @override
  List<Object?> get props => [];
}

/// Load vehicles event.
final class LoadVehicles extends FleetEvent {
  final VehicleStatus? status;
  final VehicleType? type;

  const LoadVehicles({this.status, this.type});

  @override
  List<Object?> get props => [status, type];
}

/// Load more vehicles (pagination).
final class LoadMoreVehicles extends FleetEvent {
  const LoadMoreVehicles();
}

/// Search vehicles event.
final class SearchVehiclesEvent extends FleetEvent {
  final String query;

  const SearchVehiclesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter by status event.
final class FilterByStatus extends FleetEvent {
  final VehicleStatus? status;

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Filter by type event.
final class FilterByType extends FleetEvent {
  final VehicleType? type;

  const FilterByType(this.type);

  @override
  List<Object?> get props => [type];
}

/// Select vehicle event.
final class SelectVehicle extends FleetEvent {
  final String vehicleId;

  const SelectVehicle(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Clear selected vehicle event.
final class ClearSelectedVehicle extends FleetEvent {
  const ClearSelectedVehicle();
}

/// Add vehicle event.
final class AddVehicleEvent extends FleetEvent {
  final VehicleEntity vehicle;

  const AddVehicleEvent(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

/// Update vehicle event.
final class UpdateVehicleEvent extends FleetEvent {
  final VehicleEntity vehicle;

  const UpdateVehicleEvent(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

/// Delete vehicle event.
final class DeleteVehicleEvent extends FleetEvent {
  final String vehicleId;

  const DeleteVehicleEvent(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Update vehicle status event.
final class UpdateVehicleStatusEvent extends FleetEvent {
  final String vehicleId;
  final VehicleStatus status;

  const UpdateVehicleStatusEvent(this.vehicleId, this.status);

  @override
  List<Object?> get props => [vehicleId, status];
}

/// Assign driver to vehicle event.
final class AssignDriverEvent extends FleetEvent {
  final String vehicleId;
  final String driverId;
  final String driverName;

  const AssignDriverEvent({
    required this.vehicleId,
    required this.driverId,
    required this.driverName,
  });

  @override
  List<Object?> get props => [vehicleId, driverId, driverName];
}

/// Unassign driver from vehicle event.
final class UnassignDriverEvent extends FleetEvent {
  final String vehicleId;

  const UnassignDriverEvent(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Load fleet stats event.
final class LoadFleetStats extends FleetEvent {
  const LoadFleetStats();
}

/// Load vehicles with alerts event.
final class LoadVehiclesWithAlerts extends FleetEvent {
  const LoadVehiclesWithAlerts();
}

/// Watch vehicles event (real-time updates).
final class WatchVehiclesEvent extends FleetEvent {
  final VehicleStatus? status;

  const WatchVehiclesEvent({this.status});

  @override
  List<Object?> get props => [status];
}
