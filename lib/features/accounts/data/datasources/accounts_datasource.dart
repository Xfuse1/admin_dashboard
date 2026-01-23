import '../../domain/repositories/accounts_repository.dart';
import '../models/account_models.dart';

/// Abstract data source for accounts.
abstract class AccountsDataSource {
  // ============================================
  // 👥 CUSTOMERS
  // ============================================

  Future<List<CustomerModel>> getCustomers({
    String? searchQuery,
    bool? isActive,
    int limit = 20,
    String? lastId,
  });

  Future<CustomerModel> getCustomerById(String id);

  Future<void> toggleCustomerStatus(String id, bool isActive);

  // ============================================
  // 🏪 STORES
  // ============================================

  Future<List<StoreModel>> getStores({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    String? type,
    int limit = 20,
    String? lastId,
  });

  Future<StoreModel> getStoreById(String id);

  Future<void> toggleStoreStatus(String id, bool isActive);

  Future<void> updateStoreCommission(String id, double rate);

  // ============================================
  // 🚗 DRIVERS
  // ============================================

  Future<List<DriverModel>> getDrivers({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    bool? isOnline,
    int limit = 20,
    String? lastId,
  });

  Future<DriverModel> getDriverById(String id);

  Future<void> toggleDriverStatus(String id, bool isActive);

  Stream<List<DriverModel>> watchOnlineDrivers();

  // ============================================
  // 📊 STATISTICS
  // ============================================

  Future<AccountStats> getAccountStats();
}
