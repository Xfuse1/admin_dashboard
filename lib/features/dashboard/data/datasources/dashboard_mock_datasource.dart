import 'dart:math';

import '../../domain/entities/dashboard_entities.dart';
import '../models/dashboard_models.dart';
import 'dashboard_datasource.dart';

/// Mock implementation of dashboard data source.
class DashboardMockDataSource implements DashboardDataSource {
  final _random = Random();

  @override
  Future<DashboardStatsModel> getStats() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return const DashboardStatsModel(
      totalOrders: 15847,
      pendingOrders: 234,
      completedOrders: 14892,
      cancelledOrders: 721,
      totalVendors: 156,
      activeVendors: 142,
      totalDrivers: 89,
      activeDrivers: 67,
      totalCustomers: 8542,
      totalRevenue: 2547850.0,
      todayRevenue: 45670.0,
      revenueGrowth: 12.5,
      ordersGrowth: 8.3,
    );
  }

  @override
  Future<List<RecentOrderModel>> getRecentOrders({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final customerNames = [
      'أحمد محمد',
      'فاطمة علي',
      'محمد حسن',
      'سارة أحمد',
      'عمر خالد',
      'نورة سعيد',
      'يوسف إبراهيم',
      'ليلى عبدالله',
      'خالد محمود',
      'مريم حسين',
    ];

    final vendorNames = [
      'مطعم الشرق',
      'بيتزا هت',
      'ماكدونالدز',
      'كنتاكي',
      'هرفي',
      'البيك',
      'شاورمر',
      'كودو',
      'ستاربكس',
      'باسكن روبنز',
    ];

    final statuses = OrderStatus.values;

    return List.generate(limit, (index) {
      return RecentOrderModel(
        id: 'order_${1000 + index}',
        orderNumber: '#${10000 + index}',
        customerName: customerNames[_random.nextInt(customerNames.length)],
        vendorName: vendorNames[_random.nextInt(vendorNames.length)],
        amount: 50.0 + _random.nextDouble() * 200,
        status: statuses[_random.nextInt(statuses.length)],
        createdAt: DateTime.now().subtract(Duration(hours: index * 2)),
      );
    });
  }

  @override
  Future<List<RevenueDataPointModel>> getRevenueData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final days = endDate.difference(startDate).inDays;
    final points = <RevenueDataPointModel>[];

    for (int i = 0; i <= days; i++) {
      final date = startDate.add(Duration(days: i));
      final baseAmount = 30000 + _random.nextDouble() * 20000;
      // Add some weekly pattern (higher on weekends)
      final weekdayFactor = date.weekday >= 5 ? 1.3 : 1.0;

      points.add(RevenueDataPointModel(
        date: date,
        amount: baseAmount * weekdayFactor,
      ));
    }

    return points;
  }

  @override
  Future<OrdersDistributionModel> getOrdersDistribution() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const OrdersDistributionModel(
      pending: 234,
      confirmed: 156,
      preparing: 89,
      ready: 45,
      pickedUp: 78,
      delivered: 14892,
      cancelled: 721,
    );
  }
}
