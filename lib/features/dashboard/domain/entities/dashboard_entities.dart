import 'package:equatable/equatable.dart';

/// Dashboard statistics entity.
class DashboardStats extends Equatable {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int totalVendors;
  final int activeVendors;
  final int totalDrivers;
  final int activeDrivers;
  final int totalCustomers;
  final double totalRevenue;
  final double todayRevenue;
  final double revenueGrowth;
  final double ordersGrowth;

  const DashboardStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalVendors,
    required this.activeVendors,
    required this.totalDrivers,
    required this.activeDrivers,
    required this.totalCustomers,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.revenueGrowth,
    required this.ordersGrowth,
  });

  @override
  List<Object?> get props => [
        totalOrders,
        pendingOrders,
        completedOrders,
        cancelledOrders,
        totalVendors,
        activeVendors,
        totalDrivers,
        activeDrivers,
        totalCustomers,
        totalRevenue,
        todayRevenue,
        revenueGrowth,
        ordersGrowth,
      ];
}

/// Recent order entity for dashboard.
class RecentOrder extends Equatable {
  final String id;
  final String orderNumber;
  final String customerName;
  final String vendorName;
  final double amount;
  final OrderStatus status;
  final DateTime createdAt;

  const RecentOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.vendorName,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerName,
        vendorName,
        amount,
        status,
        createdAt,
      ];
}

/// Order status enum.
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  pickedUp,
  delivered,
  cancelled,
}

/// Revenue data point for charts.
class RevenueDataPoint extends Equatable {
  final DateTime date;
  final double amount;

  const RevenueDataPoint({
    required this.date,
    required this.amount,
  });

  @override
  List<Object?> get props => [date, amount];
}

/// Orders distribution data.
class OrdersDistribution extends Equatable {
  final int pending;
  final int confirmed;
  final int preparing;
  final int ready;
  final int pickedUp;
  final int delivered;
  final int cancelled;

  const OrdersDistribution({
    required this.pending,
    required this.confirmed,
    required this.preparing,
    required this.ready,
    required this.pickedUp,
    required this.delivered,
    required this.cancelled,
  });

  @override
  List<Object?> get props => [
        pending,
        confirmed,
        preparing,
        ready,
        pickedUp,
        delivered,
        cancelled,
      ];
}
