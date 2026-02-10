import 'package:equatable/equatable.dart';

import '../../domain/entities/order_entities.dart';
import '../../domain/repositories/orders_repository.dart';

/// Orders BLoC states.
sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

/// Loading state.
class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

/// Orders loaded successfully.
class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final OrderStatus? currentFilter;
  final OrderType? orderTypeFilter;
  final bool hasMore;
  final String? lastOrderId;
  final OrderStats? stats;
  final OrderEntity? selectedOrder;
  final String searchQuery;

  const OrdersLoaded({
    required this.orders,
    this.currentFilter,
    this.orderTypeFilter,
    this.hasMore = true,
    this.lastOrderId,
    this.stats,
    this.selectedOrder,
    this.searchQuery = '',
  });

  OrdersLoaded copyWith({
    List<OrderEntity>? orders,
    OrderStatus? currentFilter,
    OrderType? orderTypeFilter,
    bool? hasMore,
    String? lastOrderId,
    OrderStats? stats,
    OrderEntity? selectedOrder,
    String? searchQuery,
    bool clearFilter = false,
    bool clearSelectedOrder = false,
    bool clearOrderTypeFilter = false,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      currentFilter: clearFilter ? null : (currentFilter ?? this.currentFilter),
      orderTypeFilter: clearOrderTypeFilter
          ? null
          : (orderTypeFilter ?? this.orderTypeFilter),
      hasMore: hasMore ?? this.hasMore,
      lastOrderId: lastOrderId ?? this.lastOrderId,
      stats: stats ?? this.stats,
      selectedOrder:
          clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Get orders filtered by search query and order type.
  /// Returns the original list when no filters are active (avoids allocation).
  List<OrderEntity> get filteredOrders {
    // Fast path: no filtering needed
    if (orderTypeFilter == null && searchQuery.isEmpty) return orders;
    var result = orders;

    // Filter by order type
    if (orderTypeFilter != null) {
      result =
          result.where((order) => order.orderType == orderTypeFilter).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((order) {
        return order.id.toLowerCase().contains(query) ||
            order.customerName.toLowerCase().contains(query) ||
            order.customerPhone.contains(query) ||
            (order.storeName?.toLowerCase().contains(query) ?? false) ||
            order.pickupStops.any(
              (stop) => stop.storeName.toLowerCase().contains(query),
            );
      }).toList();
    }

    return result;
  }

  @override
  List<Object?> get props => [
        orders,
        currentFilter,
        orderTypeFilter,
        hasMore,
        lastOrderId,
        stats,
        selectedOrder,
        searchQuery,
      ];
}

/// Loading more orders (pagination).
class OrdersLoadingMore extends OrdersLoaded {
  const OrdersLoadingMore({
    required super.orders,
    super.currentFilter,
    super.orderTypeFilter,
    super.hasMore,
    super.lastOrderId,
    super.stats,
    super.selectedOrder,
    super.searchQuery,
  });
}

/// Error state.
class OrdersError extends OrdersState {
  final String message;
  final List<OrderEntity>? previousOrders;

  const OrdersError({
    required this.message,
    this.previousOrders,
  });

  @override
  List<Object?> get props => [message, previousOrders];
}

/// Order action in progress (updating, cancelling, etc.).
class OrderActionInProgress extends OrdersLoaded {
  final String actionOrderId;

  const OrderActionInProgress({
    required this.actionOrderId,
    required super.orders,
    super.currentFilter,
    super.orderTypeFilter,
    super.hasMore,
    super.lastOrderId,
    super.stats,
    super.selectedOrder,
    super.searchQuery,
  });

  @override
  List<Object?> get props => [...super.props, actionOrderId];
}

/// Order action completed successfully.
class OrderActionSuccess extends OrdersLoaded {
  final String successMessage;

  const OrderActionSuccess({
    required this.successMessage,
    required super.orders,
    super.currentFilter,
    super.orderTypeFilter,
    super.hasMore,
    super.lastOrderId,
    super.stats,
    super.selectedOrder,
    super.searchQuery,
  });

  @override
  List<Object?> get props => [...super.props, successMessage];
}
