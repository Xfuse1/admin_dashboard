import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/usecases/dashboard_usecases.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Dashboard BLoC.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase _getStatsUseCase;
  final GetRecentOrdersUseCase _getRecentOrdersUseCase;
  final GetRevenueDataUseCase _getRevenueDataUseCase;
  final GetOrdersDistributionUseCase _getOrdersDistributionUseCase;

  DashboardBloc({
    required GetDashboardStatsUseCase getStatsUseCase,
    required GetRecentOrdersUseCase getRecentOrdersUseCase,
    required GetRevenueDataUseCase getRevenueDataUseCase,
    required GetOrdersDistributionUseCase getOrdersDistributionUseCase,
  })  : _getStatsUseCase = getStatsUseCase,
        _getRecentOrdersUseCase = getRecentOrdersUseCase,
        _getRevenueDataUseCase = getRevenueDataUseCase,
        _getOrdersDistributionUseCase = getOrdersDistributionUseCase,
        super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _loadDashboardData(emit);
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadDashboardData(emit);
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    // Fetch all data in parallel with proper types
    final statsFuture = _getStatsUseCase();
    final ordersFuture = _getRecentOrdersUseCase(limit: 10);
    final revenueFuture = _getRevenueDataUseCase(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
    final distributionFuture = _getOrdersDistributionUseCase();

    final Either<Failure, DashboardStats> statsResult = await statsFuture;
    final Either<Failure, List<RecentOrder>> ordersResult = await ordersFuture;
    final Either<Failure, List<RevenueDataPoint>> revenueResult =
        await revenueFuture;
    final Either<Failure, OrdersDistribution> distributionResult =
        await distributionFuture;

    // Check ALL results for errors
    final errors = <String>[];
    statsResult.fold((f) => errors.add(f.message), (_) {});
    ordersResult.fold((f) => errors.add(f.message), (_) {});
    revenueResult.fold((f) => errors.add(f.message), (_) {});
    distributionResult.fold((f) => errors.add(f.message), (_) {});

    if (errors.isNotEmpty) {
      emit(DashboardError(errors.first));
      return;
    }

    // Extract data safely — errors already handled above
    final stats = statsResult.getOrElse(
      () => throw StateError('Unreachable'),
    );
    final recentOrders = ordersResult.getOrElse(() => []);
    final revenueData = revenueResult.getOrElse(() => []);
    final distribution = distributionResult.getOrElse(
      () => const OrdersDistribution(
        pending: 0,
        confirmed: 0,
        preparing: 0,
        ready: 0,
        pickedUp: 0,
        delivered: 0,
        cancelled: 0,
      ),
    );

    emit(DashboardLoaded(
      stats: stats,
      recentOrders: recentOrders,
      revenueData: revenueData,
      ordersDistribution: distribution,
    ));
  }
}
