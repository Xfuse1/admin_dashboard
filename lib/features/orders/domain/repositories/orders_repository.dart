import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/order_entities.dart';

/// Abstract repository for orders operations.
abstract class OrdersRepository {
  /// Gets all orders with optional filtering.
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    OrderStatus? status,
    String? storeId,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    String? lastOrderId,
  });

  /// Gets a single order by ID.
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);

  /// Updates order status.
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  );

  /// Assigns a driver to an order.
  Future<Either<Failure, void>> assignDriver(
    String orderId,
    String driverId,
  );

  /// Cancels an order.
  Future<Either<Failure, void>> cancelOrder(
    String orderId,
    String reason,
  );

  /// Gets orders stream for real-time updates.
  Stream<List<OrderEntity>> watchOrders({OrderStatus? status});

  /// Gets order statistics.
  Future<Either<Failure, OrderStats>> getOrderStats({
    DateTime? fromDate,
    DateTime? toDate,
  });
}

/// Order statistics.
class OrderStats {
  final int totalOrders;
  final int pendingOrders;
  final int activeOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double averageOrderValue;

  const OrderStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
  });
}
