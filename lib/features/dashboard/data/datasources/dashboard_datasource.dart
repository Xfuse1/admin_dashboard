import '../models/dashboard_models.dart';

/// Dashboard data source contract.
abstract interface class DashboardDataSource {
  /// Get dashboard statistics.
  Future<DashboardStatsModel> getStats();

  /// Get recent orders.
  Future<List<RecentOrderModel>> getRecentOrders({int limit = 10});

  /// Get revenue data.
  Future<List<RevenueDataPointModel>> getRevenueData({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get orders distribution.
  Future<OrdersDistributionModel> getOrdersDistribution();
}
