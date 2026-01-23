import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dashboard_entities.dart';

/// Dashboard repository contract.
abstract interface class DashboardRepository {
  /// Get dashboard statistics.
  Future<Either<Failure, DashboardStats>> getStats();

  /// Get recent orders.
  Future<Either<Failure, List<RecentOrder>>> getRecentOrders({int limit = 10});

  /// Get revenue data for chart.
  Future<Either<Failure, List<RevenueDataPoint>>> getRevenueData({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get orders distribution.
  Future<Either<Failure, OrdersDistribution>> getOrdersDistribution();
}
