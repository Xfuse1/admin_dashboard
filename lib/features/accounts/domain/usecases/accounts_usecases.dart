import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account_entities.dart';
import '../repositories/accounts_repository.dart';

// ============================================
// 👥 CUSTOMERS USE CASES
// ============================================

/// Use case to get customers list.
class GetCustomers {
  final AccountsRepository repository;

  GetCustomers(this.repository);

  Future<Either<Failure, List<CustomerEntity>>> call({
    String? searchQuery,
    bool? isActive,
    int limit = 20,
    String? lastId,
  }) {
    return repository.getCustomers(
      searchQuery: searchQuery,
      isActive: isActive,
      limit: limit,
      lastId: lastId,
    );
  }
}

/// Use case to toggle customer status.
class ToggleCustomerStatus {
  final AccountsRepository repository;

  ToggleCustomerStatus(this.repository);

  Future<Either<Failure, void>> call(String id, bool isActive) {
    return repository.toggleCustomerStatus(id, isActive);
  }
}

// ============================================
// 🏪 STORES USE CASES
// ============================================

/// Use case to get stores list.
class GetStores {
  final AccountsRepository repository;

  GetStores(this.repository);

  Future<Either<Failure, List<StoreEntity>>> call({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    String? type,
    int limit = 20,
    String? lastId,
  }) {
    return repository.getStores(
      searchQuery: searchQuery,
      isActive: isActive,
      isApproved: isApproved,
      type: type,
      limit: limit,
      lastId: lastId,
    );
  }
}

/// Use case to toggle store status.
class ToggleStoreStatus {
  final AccountsRepository repository;

  ToggleStoreStatus(this.repository);

  Future<Either<Failure, void>> call(String id, bool isActive) {
    return repository.toggleStoreStatus(id, isActive);
  }
}

/// Use case to update store commission.
class UpdateStoreCommission {
  final AccountsRepository repository;

  UpdateStoreCommission(this.repository);

  Future<Either<Failure, void>> call(String id, double rate) {
    return repository.updateStoreCommission(id, rate);
  }
}

// ============================================
// 🚗 DRIVERS USE CASES
// ============================================

/// Use case to get drivers list.
class GetDrivers {
  final AccountsRepository repository;

  GetDrivers(this.repository);

  Future<Either<Failure, List<DriverEntity>>> call({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    bool? isOnline,
    int limit = 20,
    String? lastId,
  }) {
    return repository.getDrivers(
      searchQuery: searchQuery,
      isActive: isActive,
      isApproved: isApproved,
      isOnline: isOnline,
      limit: limit,
      lastId: lastId,
    );
  }
}

/// Use case to toggle driver status.
class ToggleDriverStatus {
  final AccountsRepository repository;

  ToggleDriverStatus(this.repository);

  Future<Either<Failure, void>> call(String id, bool isActive) {
    return repository.toggleDriverStatus(id, isActive);
  }
}

/// Use case to watch online drivers.
class WatchOnlineDrivers {
  final AccountsRepository repository;

  WatchOnlineDrivers(this.repository);

  Stream<List<DriverEntity>> call() {
    return repository.watchOnlineDrivers();
  }
}

// ============================================
// 📊 STATISTICS USE CASES
// ============================================

/// Use case to get account statistics.
class GetAccountStats {
  final AccountsRepository repository;

  GetAccountStats(this.repository);

  Future<Either<Failure, AccountStats>> call() {
    return repository.getAccountStats();
  }
}
