import '../../domain/entities/dashboard_entities.dart';

/// Dashboard stats data model.
class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalOrders,
    required super.pendingOrders,
    required super.completedOrders,
    required super.cancelledOrders,
    super.multiStoreOrders,
    required super.totalVendors,
    required super.activeVendors,
    required super.totalDrivers,
    required super.activeDrivers,
    required super.totalCustomers,
    required super.totalRevenue,
    required super.todayRevenue,
    required super.revenueGrowth,
    required super.ordersGrowth,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalOrders: json['totalOrders'] as int,
      pendingOrders: json['pendingOrders'] as int,
      completedOrders: json['completedOrders'] as int,
      cancelledOrders: json['cancelledOrders'] as int,
      multiStoreOrders: (json['multiStoreOrders'] as int?) ?? 0,
      totalVendors: json['totalVendors'] as int,
      activeVendors: json['activeVendors'] as int,
      totalDrivers: json['totalDrivers'] as int,
      activeDrivers: json['activeDrivers'] as int,
      totalCustomers: json['totalCustomers'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      todayRevenue: (json['todayRevenue'] as num).toDouble(),
      revenueGrowth: (json['revenueGrowth'] as num).toDouble(),
      ordersGrowth: (json['ordersGrowth'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'multiStoreOrders': multiStoreOrders,
      'totalVendors': totalVendors,
      'activeVendors': activeVendors,
      'totalDrivers': totalDrivers,
      'activeDrivers': activeDrivers,
      'totalCustomers': totalCustomers,
      'totalRevenue': totalRevenue,
      'todayRevenue': todayRevenue,
      'revenueGrowth': revenueGrowth,
      'ordersGrowth': ordersGrowth,
    };
  }
}

/// Recent order data model.
class RecentOrderModel extends RecentOrder {
  const RecentOrderModel({
    required super.id,
    required super.orderNumber,
    required super.customerName,
    required super.vendorName,
    required super.amount,
    required super.status,
    required super.createdAt,
    super.isMultiStore,
    super.storeCount,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) {
    return RecentOrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      customerName: json['customerName'] as String,
      vendorName: json['vendorName'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerName': customerName,
      'vendorName': vendorName,
      'amount': amount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Revenue data point model.
class RevenueDataPointModel extends RevenueDataPoint {
  const RevenueDataPointModel({
    required super.date,
    required super.amount,
  });

  factory RevenueDataPointModel.fromJson(Map<String, dynamic> json) {
    return RevenueDataPointModel(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

/// Orders distribution model.
class OrdersDistributionModel extends OrdersDistribution {
  const OrdersDistributionModel({
    required super.pending,
    required super.confirmed,
    required super.preparing,
    required super.ready,
    required super.pickedUp,
    required super.delivered,
    required super.cancelled,
  });

  factory OrdersDistributionModel.fromJson(Map<String, dynamic> json) {
    return OrdersDistributionModel(
      pending: json['pending'] as int,
      confirmed: json['confirmed'] as int,
      preparing: json['preparing'] as int,
      ready: json['ready'] as int,
      pickedUp: json['pickedUp'] as int,
      delivered: json['delivered'] as int,
      cancelled: json['cancelled'] as int,
    );
  }
}
