import 'package:flutter_bloc/flutter_bloc.dart';

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
    // Fetch all data in parallel
    final results = await Future.wait([
      _getStatsUseCase(),
      _getRecentOrdersUseCase(limit: 10),
      _getRevenueDataUseCase(
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      ),
      _getOrdersDistributionUseCase(),
    ]);

    final statsResult = results[0] as dynamic;
    final ordersResult = results[1] as dynamic;
    final revenueResult = results[2] as dynamic;
    final distributionResult = results[3] as dynamic;

    // Check for errors
    String? errorMessage;

    statsResult.fold(
      (failure) => errorMessage = failure.message,
      (_) {},
    );

    if (errorMessage != null) {
      emit(DashboardError(errorMessage!));
      return;
    }

    // Extract data
    final stats = statsResult.fold(
      (_) => null,
      (data) => data as DashboardStats,
    );

    final recentOrders = ordersResult.fold(
      (_) => <RecentOrder>[],
      (data) => data as List<RecentOrder>,
    );

    final revenueData = revenueResult.fold(
      (_) => <RevenueDataPoint>[],
      (data) => data as List<RevenueDataPoint>,
    );

    final distribution = distributionResult.fold(
      (_) => const OrdersDistribution(
        pending: 0,
        confirmed: 0,
        preparing: 0,
        ready: 0,
        pickedUp: 0,
        delivered: 0,
        cancelled: 0,
      ),
      (data) => data as OrdersDistribution,
    );

    if (stats != null) {
      emit(DashboardLoaded(
        stats: stats,
        recentOrders: recentOrders,
        revenueData: revenueData,
        ordersDistribution: distribution,
      ));
    } else {
      emit(const DashboardError('فشل تحميل البيانات'));
    }
  }
}
