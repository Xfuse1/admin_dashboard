import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/account_entities.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/accounts_datasource.dart';

/// Implementation of AccountsRepository.
class AccountsRepositoryImpl implements AccountsRepository {
  final AccountsDataSource _dataSource;

  AccountsRepositoryImpl(this._dataSource);

  // ============================================
  // 👥 CUSTOMERS
  // ============================================

  @override
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({
    String? searchQuery,
    bool? isActive,
    int limit = 20,
    String? lastId,
  }) async {
    try {
      final customers = await _dataSource.getCustomers(
        searchQuery: searchQuery,
        isActive: isActive,
        limit: limit,
        lastId: lastId,
      );
      return Right(customers.map((m) => m as CustomerEntity).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id) async {
    try {
      final customer = await _dataSource.getCustomerById(id);
      return Right(customer);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCustomerStatus(
      String id, bool isActive) async {
    try {
      await _dataSource.toggleCustomerStatus(id, isActive);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ============================================
  // 🏪 STORES
  // ============================================

  @override
  Future<Either<Failure, List<StoreEntity>>> getStores({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    String? type,
    int limit = 20,
    String? lastId,
  }) async {
    try {
      final stores = await _dataSource.getStores(
        searchQuery: searchQuery,
        isActive: isActive,
        isApproved: isApproved,
        type: type,
        limit: limit,
        lastId: lastId,
      );
      return Right(stores.map((m) => m as StoreEntity).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StoreEntity>> getStoreById(String id) async {
    try {
      final store = await _dataSource.getStoreById(id);
      return Right(store);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleStoreStatus(
      String id, bool isActive) async {
    try {
      await _dataSource.toggleStoreStatus(id, isActive);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStoreCommission(
      String id, double rate) async {
    try {
      await _dataSource.updateStoreCommission(id, rate);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ============================================
  // 🚗 DRIVERS
  // ============================================

  @override
  Future<Either<Failure, List<DriverEntity>>> getDrivers({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    bool? isOnline,
    int limit = 20,
    String? lastId,
  }) async {
    try {
      final drivers = await _dataSource.getDrivers(
        searchQuery: searchQuery,
        isActive: isActive,
        isApproved: isApproved,
        isOnline: isOnline,
        limit: limit,
        lastId: lastId,
      );
      return Right(drivers.map((m) => m as DriverEntity).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DriverEntity>> getDriverById(String id) async {
    try {
      final driver = await _dataSource.getDriverById(id);
      return Right(driver);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleDriverStatus(
      String id, bool isActive) async {
    try {
      await _dataSource.toggleDriverStatus(id, isActive);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<DriverEntity>> watchOnlineDrivers() {
    return _dataSource.watchOnlineDrivers().map((drivers) {
      return drivers.map((m) => m as DriverEntity).toList();
    });
  }

  // ============================================
  // 📊 STATISTICS
  // ============================================

  @override
  Future<Either<Failure, AccountStats>> getAccountStats() async {
    try {
      final stats = await _dataSource.getAccountStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
