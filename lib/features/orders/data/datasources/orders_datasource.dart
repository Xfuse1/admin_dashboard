import '../../domain/entities/order_entities.dart';
import '../../domain/repositories/orders_repository.dart';
import '../models/order_model.dart';

/// Abstract data source for orders.
abstract class OrdersDataSource {
  /// Gets orders list.
  Future<List<OrderModel>> getOrders({
    OrderStatus? status,
    String? storeId,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    String? lastOrderId,
  });

  /// Gets a single order by ID.
  Future<OrderModel> getOrderById(String orderId);

  /// Updates order status.
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);

  /// Assigns driver to order.
  Future<void> assignDriver(String orderId, String driverId);

  /// Cancels an order.
  Future<void> cancelOrder(String orderId, String reason);

  /// Watches orders in real-time.
  Stream<List<OrderModel>> watchOrders({OrderStatus? status});

  /// Gets order statistics.
  Future<OrderStats> getOrderStats({
    DateTime? fromDate,
    DateTime? toDate,
  });
}
