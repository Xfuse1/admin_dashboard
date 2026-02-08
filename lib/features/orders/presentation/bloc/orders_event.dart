import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entities.dart';

/// Orders BLoC events.
sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Load orders event.
class LoadOrders extends OrdersEvent {
  final OrderStatus? status;
  final bool refresh;

  const LoadOrders({this.status, this.refresh = false});

  @override
  List<Object?> get props => [status, refresh];
}

/// Load more orders (pagination).
class LoadMoreOrders extends OrdersEvent {
  const LoadMoreOrders();
}

/// Search orders event.
class SearchOrders extends OrdersEvent {
  final String query;

  const SearchOrders(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter orders by status.
class FilterOrdersByStatus extends OrdersEvent {
  final OrderStatus? status;

  const FilterOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Filter orders by date range.
class FilterOrdersByDate extends OrdersEvent {
  final DateTime? fromDate;
  final DateTime? toDate;

  const FilterOrdersByDate({this.fromDate, this.toDate});

  @override
  List<Object?> get props => [fromDate, toDate];
}

/// Select an order for details.
class SelectOrder extends OrdersEvent {
  final String orderId;

  const SelectOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Clear selected order.
class ClearSelectedOrder extends OrdersEvent {
  const ClearSelectedOrder();
}

/// Update order status.
class UpdateOrderStatusEvent extends OrdersEvent {
  final String orderId;
  final OrderStatus newStatus;

  const UpdateOrderStatusEvent({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [orderId, newStatus];
}

/// Assign driver to order.
class AssignDriverEvent extends OrdersEvent {
  final String orderId;
  final String driverId;

  const AssignDriverEvent({
    required this.orderId,
    required this.driverId,
  });

  @override
  List<Object?> get props => [orderId, driverId];
}

/// Cancel order.
class CancelOrderEvent extends OrdersEvent {
  final String orderId;
  final String reason;

  const CancelOrderEvent({
    required this.orderId,
    required this.reason,
  });

  @override
  List<Object?> get props => [orderId, reason];
}

/// Watch orders in real-time.
class WatchOrdersEvent extends OrdersEvent {
  final OrderStatus? status;

  const WatchOrdersEvent({this.status});

  @override
  List<Object?> get props => [status];
}

/// Load order statistics.
class LoadOrderStats extends OrdersEvent {
  final DateTime? fromDate;
  final DateTime? toDate;

  const LoadOrderStats({this.fromDate, this.toDate});

  @override
  List<Object?> get props => [fromDate, toDate];
}

/// Filter orders by order type (single_store / multi_store).
class FilterOrdersByType extends OrdersEvent {
  final OrderType? orderType;

  const FilterOrdersByType(this.orderType);

  @override
  List<Object?> get props => [orderType];
}
