import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dashboard_entities.dart';
import '../repositories/dashboard_repository.dart';

/// Get dashboard stats use case.
class GetDashboardStatsUseCase {
  final DashboardRepository _repository;

  const GetDashboardStatsUseCase(this._repository);

  Future<Either<Failure, DashboardStats>> call() {
    return _repository.getStats();
  }
}

/// Get recent orders use case.
class GetRecentOrdersUseCase {
  final DashboardRepository _repository;

  const GetRecentOrdersUseCase(this._repository);

  Future<Either<Failure, List<RecentOrder>>> call({int limit = 10}) {
    return _repository.getRecentOrders(limit: limit);
  }
}

/// Get revenue data use case.
class GetRevenueDataUseCase {
  final DashboardRepository _repository;

  const GetRevenueDataUseCase(this._repository);

  Future<Either<Failure, List<RevenueDataPoint>>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getRevenueData(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Get orders distribution use case.
class GetOrdersDistributionUseCase {
  final DashboardRepository _repository;

  const GetOrdersDistributionUseCase(this._repository);

  Future<Either<Failure, OrdersDistribution>> call() {
    return _repository.getOrdersDistribution();
  }
}
