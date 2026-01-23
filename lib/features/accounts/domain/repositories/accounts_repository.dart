import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account_entities.dart';

/// Abstract repository for accounts operations.
abstract class AccountsRepository {
  // ============================================
  // 👥 CUSTOMERS
  // ============================================

  /// Gets customers list.
  Future<Either<Failure, List<CustomerEntity>>> getCustomers({
    String? searchQuery,
    bool? isActive,
    int limit = 20,
    String? lastId,
  });

  /// Gets a single customer by ID.
  Future<Either<Failure, CustomerEntity>> getCustomerById(String id);

  /// Toggles customer active status.
  Future<Either<Failure, void>> toggleCustomerStatus(String id, bool isActive);

  // ============================================
  // 🏪 STORES
  // ============================================

  /// Gets stores list.
  Future<Either<Failure, List<StoreEntity>>> getStores({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    String? type,
    int limit = 20,
    String? lastId,
  });

  /// Gets a single store by ID.
  Future<Either<Failure, StoreEntity>> getStoreById(String id);

  /// Toggles store active status.
  Future<Either<Failure, void>> toggleStoreStatus(String id, bool isActive);

  /// Updates store commission rate.
  Future<Either<Failure, void>> updateStoreCommission(
    String id,
    double rate,
  );

  // ============================================
  // 🚗 DRIVERS
  // ============================================

  /// Gets drivers list.
  Future<Either<Failure, List<DriverEntity>>> getDrivers({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    bool? isOnline,
    int limit = 20,
    String? lastId,
  });

  /// Gets a single driver by ID.
  Future<Either<Failure, DriverEntity>> getDriverById(String id);

  /// Toggles driver active status.
  Future<Either<Failure, void>> toggleDriverStatus(String id, bool isActive);

  /// Gets online drivers for map.
  Stream<List<DriverEntity>> watchOnlineDrivers();

  // ============================================
  // 📊 STATISTICS
  // ============================================

  /// Gets account statistics.
  Future<Either<Failure, AccountStats>> getAccountStats();
}

/// Account statistics.
class AccountStats {
  final int totalCustomers;
  final int activeCustomers;
  final int totalStores;
  final int activeStores;
  final int approvedStores;
  final int totalDrivers;
  final int activeDrivers;
  final int onlineDrivers;

  const AccountStats({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalStores,
    required this.activeStores,
    required this.approvedStores,
    required this.totalDrivers,
    required this.activeDrivers,
    required this.onlineDrivers,
  });
}
