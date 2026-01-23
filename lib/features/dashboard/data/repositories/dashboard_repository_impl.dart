import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_datasource.dart';

/// Implementation of dashboard repository.
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource _dataSource;

  const DashboardRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, DashboardStats>> getStats() async {
    try {
      final stats = await _dataSource.getStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecentOrder>>> getRecentOrders({
    int limit = 10,
  }) async {
    try {
      final orders = await _dataSource.getRecentOrders(limit: limit);
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RevenueDataPoint>>> getRevenueData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final data = await _dataSource.getRevenueData(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrdersDistribution>> getOrdersDistribution() async {
    try {
      final distribution = await _dataSource.getOrdersDistribution();
      return Right(distribution);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
