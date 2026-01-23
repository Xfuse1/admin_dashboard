import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/fleet_usecases.dart';
import 'fleet_event.dart';
import 'fleet_state.dart';

/// Fleet BLoC for managing fleet/vehicles state.
class FleetBloc extends Bloc<FleetEvent, FleetState> {
  final GetVehicles _getVehicles;
  final GetVehicleById _getVehicleById;
  final AddVehicle _addVehicle;
  final UpdateVehicle _updateVehicle;
  final DeleteVehicle _deleteVehicle;
  final UpdateVehicleStatus _updateVehicleStatus;
  final AssignDriverToVehicle _assignDriver;
  final UnassignDriverFromVehicle _unassignDriver;
  final GetFleetStats _getFleetStats;
  final SearchVehicles _searchVehicles;
  final GetVehiclesWithAlerts _getVehiclesWithAlerts;
  final WatchVehicles _watchVehicles;

  StreamSubscription? _vehiclesSubscription;

  FleetBloc({
    required GetVehicles getVehicles,
    required GetVehicleById getVehicleById,
    required AddVehicle addVehicle,
    required UpdateVehicle updateVehicle,
    required DeleteVehicle deleteVehicle,
    required UpdateVehicleStatus updateVehicleStatus,
    required AssignDriverToVehicle assignDriver,
    required UnassignDriverFromVehicle unassignDriver,
    required GetFleetStats getFleetStats,
    required SearchVehicles searchVehicles,
    required GetVehiclesWithAlerts getVehiclesWithAlerts,
    required WatchVehicles watchVehicles,
  })  : _getVehicles = getVehicles,
        _getVehicleById = getVehicleById,
        _addVehicle = addVehicle,
        _updateVehicle = updateVehicle,
        _deleteVehicle = deleteVehicle,
        _updateVehicleStatus = updateVehicleStatus,
        _assignDriver = assignDriver,
        _unassignDriver = unassignDriver,
        _getFleetStats = getFleetStats,
        _searchVehicles = searchVehicles,
        _getVehiclesWithAlerts = getVehiclesWithAlerts,
        _watchVehicles = watchVehicles,
        super(const FleetInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<LoadMoreVehicles>(_onLoadMoreVehicles);
    on<SearchVehiclesEvent>(_onSearchVehicles);
    on<FilterByStatus>(_onFilterByStatus);
    on<FilterByType>(_onFilterByType);
    on<SelectVehicle>(_onSelectVehicle);
    on<ClearSelectedVehicle>(_onClearSelectedVehicle);
    on<AddVehicleEvent>(_onAddVehicle);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
    on<UpdateVehicleStatusEvent>(_onUpdateVehicleStatus);
    on<AssignDriverEvent>(_onAssignDriver);
    on<UnassignDriverEvent>(_onUnassignDriver);
    on<LoadFleetStats>(_onLoadFleetStats);
    on<LoadVehiclesWithAlerts>(_onLoadVehiclesWithAlerts);
    on<WatchVehiclesEvent>(_onWatchVehicles);
  }

  @override
  Future<void> close() {
    _vehiclesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<FleetState> emit,
  ) async {
    emit(const FleetLoading());

    final result = await _getVehicles(
      status: event.status,
      type: event.type,
    );

    await result.fold(
      (failure) async => emit(FleetError(failure.message)),
      (vehicles) async {
        // Also load stats
        final statsResult = await _getFleetStats();
        final alertsResult = await _getVehiclesWithAlerts();

        FleetStatsEntity? stats;
        List<VehicleEntity>? alerts;

        statsResult.fold(
          (failure) {},
          (s) => stats = s,
        );

        alertsResult.fold(
          (failure) {},
          (a) => alerts = a,
        );

        emit(FleetLoaded(
          vehicles: vehicles,
          currentStatusFilter: event.status,
          currentTypeFilter: event.type,
          hasMore: vehicles.length >= 20,
          lastVehicleId: vehicles.isNotEmpty ? vehicles.last.id : null,
          stats: stats,
          vehiclesWithAlerts: alerts,
        ));
      },
    );
  }

  Future<void> _onLoadMoreVehicles(
    LoadMoreVehicles event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FleetLoaded || !currentState.hasMore) return;

    emit(FleetLoadingMore(
      vehicles: currentState.vehicles,
      currentStatusFilter: currentState.currentStatusFilter,
      currentTypeFilter: currentState.currentTypeFilter,
      searchQuery: currentState.searchQuery,
      stats: currentState.stats,
      selectedVehicle: currentState.selectedVehicle,
    ));

    final result = await _getVehicles(
      status: currentState.currentStatusFilter,
      type: currentState.currentTypeFilter,
      lastVehicleId: currentState.lastVehicleId,
    );

    result.fold(
      (failure) => emit(FleetError(failure.message)),
      (newVehicles) {
        final allVehicles = [...currentState.vehicles, ...newVehicles];
        emit(FleetLoaded(
          vehicles: allVehicles,
          currentStatusFilter: currentState.currentStatusFilter,
          currentTypeFilter: currentState.currentTypeFilter,
          searchQuery: currentState.searchQuery,
          stats: currentState.stats,
          selectedVehicle: currentState.selectedVehicle,
          hasMore: newVehicles.length >= 20,
          lastVehicleId: newVehicles.isNotEmpty ? newVehicles.last.id : null,
          vehiclesWithAlerts: currentState.vehiclesWithAlerts,
        ));
      },
    );
  }

  Future<void> _onSearchVehicles(
    SearchVehiclesEvent event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    if (event.query.isEmpty) {
      add(const LoadVehicles());
      return;
    }

    emit(const FleetLoading());

    final result = await _searchVehicles(event.query);

    result.fold(
      (failure) => emit(FleetError(failure.message)),
      (vehicles) => emit(FleetLoaded(
        vehicles: vehicles,
        searchQuery: event.query,
        stats: currentState is FleetLoaded ? currentState.stats : null,
        hasMore: false,
      )),
    );
  }

  Future<void> _onFilterByStatus(
    FilterByStatus event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    VehicleType? typeFilter;
    if (currentState is FleetLoaded) {
      typeFilter = currentState.currentTypeFilter;
    }

    add(LoadVehicles(status: event.status, type: typeFilter));
  }

  Future<void> _onFilterByType(
    FilterByType event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    VehicleStatus? statusFilter;
    if (currentState is FleetLoaded) {
      statusFilter = currentState.currentStatusFilter;
    }

    add(LoadVehicles(status: statusFilter, type: event.type));
  }

  Future<void> _onSelectVehicle(
    SelectVehicle event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FleetLoaded) return;

    final result = await _getVehicleById(event.vehicleId);

    result.fold(
      (failure) => emit(FleetError(failure.message)),
      (vehicle) => emit(currentState.copyWith(selectedVehicle: vehicle)),
    );
  }

  void _onClearSelectedVehicle(
    ClearSelectedVehicle event,
    Emitter<FleetState> emit,
  ) {
    final currentState = state;
    if (currentState is! FleetLoaded) return;

    emit(currentState.copyWith(clearSelectedVehicle: true));
  }

  Future<void> _onAddVehicle(
    AddVehicleEvent event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    List<VehicleEntity> currentVehicles = [];
    if (currentState is FleetLoaded) {
      currentVehicles = currentState.vehicles;
    }

    emit(FleetActionInProgress(
      vehicles: currentVehicles,
      actionMessage: 'جاري إضافة المركبة...',
    ));

    final result = await _addVehicle(event.vehicle);

    await result.fold(
      (failure) async => emit(FleetError(failure.message)),
      (vehicle) async {
        final updatedVehicles = [vehicle, ...currentVehicles];
        final statsResult = await _getFleetStats();

        FleetStatsEntity? stats;
        statsResult.fold(
          (failure) {},
          (s) => stats = s,
        );

        emit(FleetActionSuccess(
          vehicles: updatedVehicles,
          successMessage: 'تمت إضافة المركبة بنجاح',
          stats: stats,
        ));

        // Return to loaded state
        emit(FleetLoaded(
          vehicles: updatedVehicles,
          stats: stats,
          hasMore: updatedVehicles.length >= 20,
        ));
      },
    );
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicleEvent event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FleetLoaded) return;

    emit(FleetActionInProgress(
      vehicles: currentState.vehicles,
      actionMessage: 'جاري تحديث المركبة...',
    ));

    final result = await _updateVehicle(event.vehicle);

    await result.fold(
      (failure) async => emit(FleetError(failure.message)),
      (updatedVehicle) async {
        final updatedList = currentState.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        final statsResult = await _getFleetStats();
        FleetStatsEntity? stats;
        statsResult.fold(
          (failure) {},
          (s) => stats = s,
        );

        emit(FleetActionSuccess(
          vehicles: updatedList,
          successMessage: 'تم تحديث المركبة بنجاح',
          stats: stats,
        ));

        emit(currentState.copyWith(
          vehicles: updatedList,
          selectedVehicle: updatedVehicle,
          stats: stats,
        ));
      },
    );
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FleetLoaded) return;

    emit(FleetActionInProgress(
      vehicles: currentState.vehicles,
      actionMessage: 'جاري حذف المركبة...',
    ));

    final result = await _deleteVehicle(event.vehicleId);

    await result.fold(
      (failure) async => emit(FleetError(failure.message)),
      (_) async {
        final updatedList = currentState.vehicles
            .where((v) => v.id != event.vehicleId)
            .toList();

        final statsResult = await _getFleetStats();
        FleetStatsEntity? stats;
        statsResult.fold(
          (failure) {},
          (s) => stats = s,
        );

        emit(FleetActionSuccess(
          vehicles: updatedList,
          successMessage: 'تم حذف المركبة بنجاح',
          stats: stats,
        ));

        emit(currentState.copyWith(
          vehicles: updatedList,
          clearSelectedVehicle: true,
          stats: stats,
        ));
      },
    );
  }

  Future<void> _onUpdateVehicleStatus(
    UpdateVehicleStatusEvent event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FleetLoaded) return;

    final result = await _updateVehicleStatus(event.vehicleId, event.status);

    await result.fold(
      (failure) async => emit(FleetError(failure.message)),
      (updatedVehicle) async {
        final updatedList = currentState.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        final statsResult = await _getFleetStats();
        FleetStatsEntity? stats;
        statsResult.fold(
          (failure) {},
          (s) => stats = s,
        );

        emit(currentState.copyWith(
          vehicles: updatedList,
          selectedVehicle: currentState.selectedVehicle?.id == updatedVehicle.id
              ? updatedVehicle
              : currentState.selectedVehicle,
          stats: stats,
        ));
      },
    );
  }

  Future<void> _onAssignDriver(
    AssignDriverEvent event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FleetLoaded) return;

    final result = await _assignDriver(
      vehicleId: event.vehicleId,
      driverId: event.driverId,
      driverName: event.driverName,
    );

    await result.fold(
      (failure) async => emit(FleetError(failure.message)),
      (updatedVehicle) async {
        final updatedList = currentState.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        final statsResult = await _getFleetStats();
        FleetStatsEntity? stats;
        statsResult.fold(
          (failure) {},
          (s) => stats = s,
        );

        emit(FleetActionSuccess(
          vehicles: updatedList,
          successMessage: 'تم تعيين السائق بنجاح',
          stats: stats,
        ));

        emit(currentState.copyWith(
          vehicles: updatedList,
          selectedVehicle: currentState.selectedVehicle?.id == updatedVehicle.id
              ? updatedVehicle
              : currentState.selectedVehicle,
          stats: stats,
        ));
      },
    );
  }

  Future<void> _onUnassignDriver(
    UnassignDriverEvent event,
    Emitter<FleetState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FleetLoaded) return;

    final result = await _unassignDriver(event.vehicleId);

    await result.fold(
      (failure) async => emit(FleetError(failure.message)),
      (updatedVehicle) async {
        final updatedList = currentState.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        final statsResult = await _getFleetStats();
        FleetStatsEntity? stats;
        statsResult.fold(
          (failure) {},
          (s) => stats = s,
        );

        emit(currentState.copyWith(
          vehicles: updatedList,
          selectedVehicle: currentState.selectedVehicle?.id == updatedVehicle.id
              ? updatedVehicle
              : currentState.selectedVehicle,
          stats: stats,
        ));
      },
    );
  }

  Future<void> _onLoadFleetStats(
    LoadFleetStats event,
    Emitter<FleetState> emit,
  ) async {
    final result = await _getFleetStats();

    final currentState = state;
    if (currentState is FleetLoaded) {
      result.fold(
        (failure) {},
        (stats) => emit(currentState.copyWith(stats: stats)),
      );
    }
  }

  Future<void> _onLoadVehiclesWithAlerts(
    LoadVehiclesWithAlerts event,
    Emitter<FleetState> emit,
  ) async {
    final result = await _getVehiclesWithAlerts();

    final currentState = state;
    if (currentState is FleetLoaded) {
      result.fold(
        (failure) {},
        (alerts) => emit(currentState.copyWith(vehiclesWithAlerts: alerts)),
      );
    }
  }

  void _onWatchVehicles(
    WatchVehiclesEvent event,
    Emitter<FleetState> emit,
  ) {
    _vehiclesSubscription?.cancel();
    _vehiclesSubscription = _watchVehicles(status: event.status).listen(
      (result) {
        result.fold(
          (failure) {},
          (vehicles) {
            final currentState = state;
            if (currentState is FleetLoaded) {
              emit(currentState.copyWith(vehicles: vehicles));
            }
          },
        );
      },
    );
  }
}
