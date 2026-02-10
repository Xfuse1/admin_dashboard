import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/orders_usecases.dart';
import 'orders_event.dart';
import 'orders_state.dart';

/// Orders BLoC for managing orders state.
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrders _getOrders;
  final GetOrderById _getOrderById;
  final UpdateOrderStatus _updateOrderStatus;
  final AssignDriverToOrder _assignDriver;
  final CancelOrder _cancelOrder;
  final WatchOrders _watchOrders;
  final GetOrderStats _getOrderStats;

  StreamSubscription? _ordersSubscription;

  OrdersBloc({
    required GetOrders getOrders,
    required GetOrderById getOrderById,
    required UpdateOrderStatus updateOrderStatus,
    required AssignDriverToOrder assignDriver,
    required CancelOrder cancelOrder,
    required WatchOrders watchOrders,
    required GetOrderStats getOrderStats,
  })  : _getOrders = getOrders,
        _getOrderById = getOrderById,
        _updateOrderStatus = updateOrderStatus,
        _assignDriver = assignDriver,
        _cancelOrder = cancelOrder,
        _watchOrders = watchOrders,
        _getOrderStats = getOrderStats,
        super(const OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadMoreOrders>(_onLoadMoreOrders);
    on<SearchOrders>(_onSearchOrders);
    on<FilterOrdersByStatus>(_onFilterByStatus);
    on<FilterOrdersByDate>(_onFilterByDate);
    on<SelectOrder>(_onSelectOrder);
    on<ClearSelectedOrder>(_onClearSelectedOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<AssignDriverEvent>(_onAssignDriver);
    on<CancelOrderEvent>(_onCancelOrder);
    on<WatchOrdersEvent>(_onWatchOrders);
    on<LoadOrderStats>(_onLoadOrderStats);
    on<FilterOrdersByType>(_onFilterByType);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());

    // Start both requests in parallel instead of sequentially
    final ordersFuture = _getOrders(status: event.status);
    final statsFuture = _getOrderStats();

    final result = await ordersFuture;

    await result.fold(
      (failure) async => emit(OrdersError(message: failure.message)),
      (orders) async {
        // Stats future was already started, just await result
        final statsResult = await statsFuture;
        statsResult.fold(
          (failure) => emit(OrdersLoaded(
            orders: orders,
            currentFilter: event.status,
            hasMore: orders.length >= 20,
            lastOrderId: orders.isNotEmpty ? orders.last.id : null,
          )),
          (stats) => emit(OrdersLoaded(
            orders: orders,
            currentFilter: event.status,
            hasMore: orders.length >= 20,
            lastOrderId: orders.isNotEmpty ? orders.last.id : null,
            stats: stats,
          )),
        );
      },
    );
  }

  Future<void> _onLoadMoreOrders(
    LoadMoreOrders event,
    Emitter<OrdersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrdersLoaded || !currentState.hasMore) return;

    emit(OrdersLoadingMore(
      orders: currentState.orders,
      currentFilter: currentState.currentFilter,
      orderTypeFilter: currentState.orderTypeFilter,
      hasMore: currentState.hasMore,
      lastOrderId: currentState.lastOrderId,
      stats: currentState.stats,
      selectedOrder: currentState.selectedOrder,
      searchQuery: currentState.searchQuery,
    ));

    final result = await _getOrders(
      status: currentState.currentFilter,
      lastOrderId: currentState.lastOrderId,
    );

    result.fold(
      (failure) => emit(currentState),
      (newOrders) {
        final allOrders = [...currentState.orders, ...newOrders];
        emit(currentState.copyWith(
          orders: allOrders,
          hasMore: newOrders.length >= 20,
          lastOrderId: newOrders.isNotEmpty ? newOrders.last.id : null,
        ));
      },
    );
  }

  Future<void> _onSearchOrders(
    SearchOrders event,
    Emitter<OrdersState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onFilterByStatus(
    FilterOrdersByStatus event,
    Emitter<OrdersState> emit,
  ) async {
    add(LoadOrders(status: event.status));
  }

  Future<void> _onFilterByDate(
    FilterOrdersByDate event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());

    final result = await _getOrders(
      fromDate: event.fromDate,
      toDate: event.toDate,
    );

    result.fold(
      (failure) => emit(OrdersError(message: failure.message)),
      (orders) => emit(OrdersLoaded(
        orders: orders,
        hasMore: orders.length >= 20,
        lastOrderId: orders.isNotEmpty ? orders.last.id : null,
      )),
    );
  }

  Future<void> _onSelectOrder(
    SelectOrder event,
    Emitter<OrdersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrdersLoaded) return;

    final result = await _getOrderById(event.orderId);

    result.fold(
      (failure) => emit(OrdersError(
        message: failure.message,
        previousOrders: currentState.orders,
      )),
      (order) => emit(currentState.copyWith(selectedOrder: order)),
    );
  }

  void _onClearSelectedOrder(
    ClearSelectedOrder event,
    Emitter<OrdersState> emit,
  ) {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(currentState.copyWith(clearSelectedOrder: true));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrdersLoaded) return;

    emit(OrderActionInProgress(
      actionOrderId: event.orderId,
      orders: currentState.orders,
      currentFilter: currentState.currentFilter,
      orderTypeFilter: currentState.orderTypeFilter,
      hasMore: currentState.hasMore,
      lastOrderId: currentState.lastOrderId,
      stats: currentState.stats,
      selectedOrder: currentState.selectedOrder,
      searchQuery: currentState.searchQuery,
    ));

    final result = await _updateOrderStatus(event.orderId, event.newStatus);

    result.fold(
      (failure) => emit(OrdersError(
        message: failure.message,
        previousOrders: currentState.orders,
      )),
      (_) {
        emit(OrderActionSuccess(
          successMessage: 'تم تحديث حالة الطلب بنجاح',
          orders: currentState.orders,
          currentFilter: currentState.currentFilter,
          orderTypeFilter: currentState.orderTypeFilter,
          hasMore: currentState.hasMore,
          lastOrderId: currentState.lastOrderId,
          stats: currentState.stats,
          selectedOrder: currentState.selectedOrder,
          searchQuery: currentState.searchQuery,
        ));

        // Reload orders to get fresh data from server
        add(LoadOrders(status: currentState.currentFilter, refresh: true));
      },
    );
  }

  Future<void> _onAssignDriver(
    AssignDriverEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrdersLoaded) return;

    emit(OrderActionInProgress(
      actionOrderId: event.orderId,
      orders: currentState.orders,
      currentFilter: currentState.currentFilter,
      orderTypeFilter: currentState.orderTypeFilter,
      hasMore: currentState.hasMore,
      lastOrderId: currentState.lastOrderId,
      stats: currentState.stats,
      selectedOrder: currentState.selectedOrder,
      searchQuery: currentState.searchQuery,
    ));

    final result = await _assignDriver(event.orderId, event.driverId);

    result.fold(
      (failure) => emit(OrdersError(
        message: failure.message,
        previousOrders: currentState.orders,
      )),
      (_) {
        emit(OrderActionSuccess(
          successMessage: 'تم تعيين السائق بنجاح',
          orders: currentState.orders,
          currentFilter: currentState.currentFilter,
          orderTypeFilter: currentState.orderTypeFilter,
          hasMore: currentState.hasMore,
          lastOrderId: currentState.lastOrderId,
          stats: currentState.stats,
          selectedOrder: currentState.selectedOrder,
          searchQuery: currentState.searchQuery,
        ));

        add(LoadOrders(status: currentState.currentFilter, refresh: true));
      },
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrdersLoaded) return;

    emit(OrderActionInProgress(
      actionOrderId: event.orderId,
      orders: currentState.orders,
      currentFilter: currentState.currentFilter,
      orderTypeFilter: currentState.orderTypeFilter,
      hasMore: currentState.hasMore,
      lastOrderId: currentState.lastOrderId,
      stats: currentState.stats,
      selectedOrder: currentState.selectedOrder,
      searchQuery: currentState.searchQuery,
    ));

    final result = await _cancelOrder(event.orderId, event.reason);

    result.fold(
      (failure) => emit(OrdersError(
        message: failure.message,
        previousOrders: currentState.orders,
      )),
      (_) {
        emit(OrderActionSuccess(
          successMessage: 'تم إلغاء الطلب بنجاح',
          orders: currentState.orders,
          currentFilter: currentState.currentFilter,
          orderTypeFilter: currentState.orderTypeFilter,
          hasMore: currentState.hasMore,
          lastOrderId: currentState.lastOrderId,
          stats: currentState.stats,
          selectedOrder: currentState.selectedOrder,
          searchQuery: currentState.searchQuery,
        ));

        add(LoadOrders(status: currentState.currentFilter, refresh: true));
      },
    );
  }

  void _onWatchOrders(
    WatchOrdersEvent event,
    Emitter<OrdersState> emit,
  ) {
    _ordersSubscription?.cancel();
    _ordersSubscription = _watchOrders(status: event.status).listen(
      (orders) {
        final currentState = state;
        if (currentState is OrdersLoaded) {
          emit(currentState.copyWith(orders: orders));
        } else {
          emit(OrdersLoaded(
            orders: orders,
            currentFilter: event.status,
            hasMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onLoadOrderStats(
    LoadOrderStats event,
    Emitter<OrdersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrdersLoaded) return;

    final result = await _getOrderStats(
      fromDate: event.fromDate,
      toDate: event.toDate,
    );

    result.fold(
      (failure) => null, // Silently fail for stats
      (stats) => emit(currentState.copyWith(stats: stats)),
    );
  }

  void _onFilterByType(
    FilterOrdersByType event,
    Emitter<OrdersState> emit,
  ) {
    final currentState = state;
    if (currentState is OrdersLoaded) {
      emit(currentState.copyWith(
        orderTypeFilter: event.orderType,
        clearOrderTypeFilter: event.orderType == null,
      ));
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
