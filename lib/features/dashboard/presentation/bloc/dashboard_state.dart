import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_entities.dart';

/// Dashboard state types using sealed class.
sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state.
final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state with data.
final class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<RecentOrder> recentOrders;
  final List<RevenueDataPoint> revenueData;
  final OrdersDistribution ordersDistribution;

  const DashboardLoaded({
    required this.stats,
    required this.recentOrders,
    required this.revenueData,
    required this.ordersDistribution,
  });

  @override
  List<Object?> get props => [
        stats,
        recentOrders,
        revenueData,
        ordersDistribution,
      ];

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<RecentOrder>? recentOrders,
    List<RevenueDataPoint>? revenueData,
    OrdersDistribution? ordersDistribution,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      recentOrders: recentOrders ?? this.recentOrders,
      revenueData: revenueData ?? this.revenueData,
      ordersDistribution: ordersDistribution ?? this.ordersDistribution,
    );
  }
}

/// Error state.
final class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
