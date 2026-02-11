import 'package:equatable/equatable.dart';

import '../../domain/entities/account_entities.dart';
import '../../domain/repositories/accounts_repository.dart';

/// Base class for Accounts states.
sealed class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class AccountsInitial extends AccountsState {
  const AccountsInitial();
}

/// Loading state.
class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

/// Main loaded state with all account data.
class AccountsLoaded extends AccountsState {
  final AccountType currentTab;
  final AccountStats? stats;

  // Customers
  final List<CustomerEntity> customers;
  final bool hasMoreCustomers;
  final bool isLoadingMoreCustomers;
  final String? customersSearchQuery;
  final CustomerEntity? selectedCustomer;

  // Stores
  final List<StoreEntity> stores;
  final bool hasMoreStores;
  final bool isLoadingMoreStores;
  final String? storesSearchQuery;
  final StoreEntity? selectedStore;

  // Drivers
  final List<DriverEntity> drivers;
  final bool hasMoreDrivers;
  final bool isLoadingMoreDrivers;
  final String? driversSearchQuery;
  final DriverEntity? selectedDriver;

  const AccountsLoaded({
    this.currentTab = AccountType.customer,
    this.stats,
    this.customers = const [],
    this.hasMoreCustomers = true,
    this.isLoadingMoreCustomers = false,
    this.customersSearchQuery,
    this.selectedCustomer,
    this.stores = const [],
    this.hasMoreStores = true,
    this.isLoadingMoreStores = false,
    this.storesSearchQuery,
    this.selectedStore,
    this.drivers = const [],
    this.hasMoreDrivers = true,
    this.isLoadingMoreDrivers = false,
    this.driversSearchQuery,
    this.selectedDriver,
  });

  AccountsLoaded copyWith({
    AccountType? currentTab,
    AccountStats? stats,
    List<CustomerEntity>? customers,
    bool? hasMoreCustomers,
    bool? isLoadingMoreCustomers,
    String? customersSearchQuery,
    CustomerEntity? selectedCustomer,
    bool clearSelectedCustomer = false,
    List<StoreEntity>? stores,
    bool? hasMoreStores,
    bool? isLoadingMoreStores,
    String? storesSearchQuery,
    StoreEntity? selectedStore,
    bool clearSelectedStore = false,
    List<DriverEntity>? drivers,
    bool? hasMoreDrivers,
    bool? isLoadingMoreDrivers,
    String? driversSearchQuery,
    DriverEntity? selectedDriver,
    bool clearSelectedDriver = false,
  }) {
    return AccountsLoaded(
      currentTab: currentTab ?? this.currentTab,
      stats: stats ?? this.stats,
      customers: customers ?? this.customers,
      hasMoreCustomers: hasMoreCustomers ?? this.hasMoreCustomers,
      isLoadingMoreCustomers:
          isLoadingMoreCustomers ?? this.isLoadingMoreCustomers,
      customersSearchQuery: customersSearchQuery ?? this.customersSearchQuery,
      selectedCustomer: clearSelectedCustomer
          ? null
          : selectedCustomer ?? this.selectedCustomer,
      stores: stores ?? this.stores,
      hasMoreStores: hasMoreStores ?? this.hasMoreStores,
      isLoadingMoreStores: isLoadingMoreStores ?? this.isLoadingMoreStores,
      storesSearchQuery: storesSearchQuery ?? this.storesSearchQuery,
      selectedStore:
          clearSelectedStore ? null : selectedStore ?? this.selectedStore,
      drivers: drivers ?? this.drivers,
      hasMoreDrivers: hasMoreDrivers ?? this.hasMoreDrivers,
      isLoadingMoreDrivers: isLoadingMoreDrivers ?? this.isLoadingMoreDrivers,
      driversSearchQuery: driversSearchQuery ?? this.driversSearchQuery,
      selectedDriver:
          clearSelectedDriver ? null : selectedDriver ?? this.selectedDriver,
    );
  }

  @override
  List<Object?> get props => [
        currentTab,
        stats,
        customers,
        hasMoreCustomers,
        isLoadingMoreCustomers,
        customersSearchQuery,
        selectedCustomer,
        stores,
        hasMoreStores,
        isLoadingMoreStores,
        storesSearchQuery,
        selectedStore,
        drivers,
        hasMoreDrivers,
        isLoadingMoreDrivers,
        driversSearchQuery,
        selectedDriver,
      ];
}

/// Error state.
class AccountsError extends AccountsState {
  final String message;
  final AccountsState? previousState;

  const AccountsError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// Action in progress (toggle status, update commission).
class AccountActionInProgress extends AccountsState {
  final String accountId;
  final String action;
  final AccountsLoaded previousState;

  const AccountActionInProgress({
    required this.accountId,
    required this.action,
    required this.previousState,
  });

  @override
  List<Object?> get props => [accountId, action, previousState];
}

/// Action completed successfully.
class AccountActionSuccess extends AccountsState {
  final String message;
  final AccountsLoaded updatedState;

  const AccountActionSuccess({
    required this.message,
    required this.updatedState,
  });

  @override
  List<Object?> get props => [message, updatedState];
}
