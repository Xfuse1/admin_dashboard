import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_entities.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_datasource.dart';

/// Implementation of OrdersRepository.
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource dataSource;

  OrdersRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    OrderStatus? status,
    String? storeId,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    String? lastOrderId,
  }) async {
    try {
      final orders = await dataSource.getOrders(
        status: status,
        storeId: storeId,
        driverId: driverId,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        lastOrderId: lastOrderId,
      );
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    try {
      final order = await dataSource.getOrderById(orderId);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    try {
      await dataSource.updateOrderStatus(orderId, newStatus);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignDriver(
    String orderId,
    String driverId,
  ) async {
    try {
      await dataSource.assignDriver(orderId, driverId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(
    String orderId,
    String reason,
  ) async {
    try {
      await dataSource.cancelOrder(orderId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<OrderEntity>> watchOrders({OrderStatus? status}) {
    return dataSource.watchOrders(status: status);
  }

  @override
  Future<Either<Failure, OrderStats>> getOrderStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final stats = await dataSource.getOrderStats(
        fromDate: fromDate,
        toDate: toDate,
      );
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
