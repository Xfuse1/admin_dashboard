import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle_entity.dart';

/// Fleet states.
sealed class FleetState extends Equatable {
  const FleetState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class FleetInitial extends FleetState {
  const FleetInitial();
}

/// Loading state.
final class FleetLoading extends FleetState {
  const FleetLoading();
}

/// Loading more (pagination).
final class FleetLoadingMore extends FleetState {
  final List<VehicleEntity> vehicles;
  final VehicleStatus? currentStatusFilter;
  final VehicleType? currentTypeFilter;
  final String? searchQuery;
  final FleetStatsEntity? stats;
  final VehicleEntity? selectedVehicle;

  const FleetLoadingMore({
    required this.vehicles,
    this.currentStatusFilter,
    this.currentTypeFilter,
    this.searchQuery,
    this.stats,
    this.selectedVehicle,
  });

  @override
  List<Object?> get props => [
        vehicles,
        currentStatusFilter,
        currentTypeFilter,
        searchQuery,
        stats,
        selectedVehicle,
      ];
}

/// Loaded state.
final class FleetLoaded extends FleetState {
  final List<VehicleEntity> vehicles;
  final VehicleStatus? currentStatusFilter;
  final VehicleType? currentTypeFilter;
  final String? searchQuery;
  final FleetStatsEntity? stats;
  final VehicleEntity? selectedVehicle;
  final bool hasMore;
  final String? lastVehicleId;
  final List<VehicleEntity>? vehiclesWithAlerts;

  const FleetLoaded({
    required this.vehicles,
    this.currentStatusFilter,
    this.currentTypeFilter,
    this.searchQuery,
    this.stats,
    this.selectedVehicle,
    this.hasMore = false,
    this.lastVehicleId,
    this.vehiclesWithAlerts,
  });

  FleetLoaded copyWith({
    List<VehicleEntity>? vehicles,
    VehicleStatus? currentStatusFilter,
    VehicleType? currentTypeFilter,
    String? searchQuery,
    FleetStatsEntity? stats,
    VehicleEntity? selectedVehicle,
    bool? hasMore,
    String? lastVehicleId,
    List<VehicleEntity>? vehiclesWithAlerts,
    bool clearStatusFilter = false,
    bool clearTypeFilter = false,
    bool clearSearchQuery = false,
    bool clearSelectedVehicle = false,
  }) {
    return FleetLoaded(
      vehicles: vehicles ?? this.vehicles,
      currentStatusFilter: clearStatusFilter
          ? null
          : (currentStatusFilter ?? this.currentStatusFilter),
      currentTypeFilter: clearTypeFilter
          ? null
          : (currentTypeFilter ?? this.currentTypeFilter),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      stats: stats ?? this.stats,
      selectedVehicle: clearSelectedVehicle
          ? null
          : (selectedVehicle ?? this.selectedVehicle),
      hasMore: hasMore ?? this.hasMore,
      lastVehicleId: lastVehicleId ?? this.lastVehicleId,
      vehiclesWithAlerts: vehiclesWithAlerts ?? this.vehiclesWithAlerts,
    );
  }

  @override
  List<Object?> get props => [
        vehicles,
        currentStatusFilter,
        currentTypeFilter,
        searchQuery,
        stats,
        selectedVehicle,
        hasMore,
        lastVehicleId,
        vehiclesWithAlerts,
      ];
}

/// Error state.
final class FleetError extends FleetState {
  final String message;

  const FleetError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Vehicle action in progress (add, update, delete).
final class FleetActionInProgress extends FleetState {
  final List<VehicleEntity> vehicles;
  final String actionMessage;

  const FleetActionInProgress({
    required this.vehicles,
    required this.actionMessage,
  });

  @override
  List<Object?> get props => [vehicles, actionMessage];
}

/// Vehicle action success.
final class FleetActionSuccess extends FleetState {
  final List<VehicleEntity> vehicles;
  final String successMessage;
  final FleetStatsEntity? stats;

  const FleetActionSuccess({
    required this.vehicles,
    required this.successMessage,
    this.stats,
  });

  @override
  List<Object?> get props => [vehicles, successMessage, stats];
}
