import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/order_entities.dart';
import '../repositories/orders_repository.dart';

/// Use case to get orders list.
class GetOrders {
  final OrdersRepository repository;

  GetOrders(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call({
    OrderStatus? status,
    String? storeId,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    String? lastOrderId,
  }) {
    return repository.getOrders(
      status: status,
      storeId: storeId,
      driverId: driverId,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
      lastOrderId: lastOrderId,
    );
  }
}

/// Use case to get a single order.
class GetOrderById {
  final OrdersRepository repository;

  GetOrderById(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderId) {
    return repository.getOrderById(orderId);
  }
}

/// Use case to update order status.
class UpdateOrderStatus {
  final OrdersRepository repository;

  UpdateOrderStatus(this.repository);

  Future<Either<Failure, void>> call(String orderId, OrderStatus newStatus) {
    return repository.updateOrderStatus(orderId, newStatus);
  }
}

/// Use case to assign driver to order.
class AssignDriverToOrder {
  final OrdersRepository repository;

  AssignDriverToOrder(this.repository);

  Future<Either<Failure, void>> call(String orderId, String driverId) {
    return repository.assignDriver(orderId, driverId);
  }
}

/// Use case to cancel an order.
class CancelOrder {
  final OrdersRepository repository;

  CancelOrder(this.repository);

  Future<Either<Failure, void>> call(String orderId, String reason) {
    return repository.cancelOrder(orderId, reason);
  }
}

/// Use case to watch orders in real-time.
class WatchOrders {
  final OrdersRepository repository;

  WatchOrders(this.repository);

  Stream<List<OrderEntity>> call({OrderStatus? status}) {
    return repository.watchOrders(status: status);
  }
}

/// Use case to get order statistics.
class GetOrderStats {
  final OrdersRepository repository;

  GetOrderStats(this.repository);

  Future<Either<Failure, OrderStats>> call({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return repository.getOrderStats(fromDate: fromDate, toDate: toDate);
  }
}
