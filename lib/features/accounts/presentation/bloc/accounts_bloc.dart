import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/account_entities.dart';
import '../../domain/usecases/accounts_usecases.dart';
import 'accounts_event.dart';
import 'accounts_state.dart';

/// BLoC for managing account-related state.
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final GetCustomers _getCustomers;
  final GetCustomerById _getCustomerById;
  final ToggleCustomerStatus _toggleCustomerStatus;
  final GetStores _getStores;
  final GetStoreById _getStoreById;
  final ToggleStoreStatus _toggleStoreStatus;
  final UpdateStoreCommission _updateStoreCommission;
  final GetDrivers _getDrivers;
  final GetDriverById _getDriverById;
  final ToggleDriverStatus _toggleDriverStatus;
  final GetAccountStats _getAccountStats;

  static const int _pageSize = 20;

  AccountsBloc({
    required GetCustomers getCustomers,
    required GetCustomerById getCustomerById,
    required ToggleCustomerStatus toggleCustomerStatus,
    required GetStores getStores,
    required GetStoreById getStoreById,
    required ToggleStoreStatus toggleStoreStatus,
    required UpdateStoreCommission updateStoreCommission,
    required GetDrivers getDrivers,
    required GetDriverById getDriverById,
    required ToggleDriverStatus toggleDriverStatus,
    required GetAccountStats getAccountStats,
  })  : _getCustomers = getCustomers,
        _getCustomerById = getCustomerById,
        _toggleCustomerStatus = toggleCustomerStatus,
        _getStores = getStores,
        _getStoreById = getStoreById,
        _toggleStoreStatus = toggleStoreStatus,
        _updateStoreCommission = updateStoreCommission,
        _getDrivers = getDrivers,
        _getDriverById = getDriverById,
        _toggleDriverStatus = toggleDriverStatus,
        _getAccountStats = getAccountStats,
        super(const AccountsInitial()) {
    on<LoadAccountStats>(_onLoadAccountStats);
    on<LoadCustomers>(_onLoadCustomers);
    on<LoadMoreCustomers>(_onLoadMoreCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<ToggleCustomerStatusEvent>(_onToggleCustomerStatus);
    on<SelectCustomer>(_onSelectCustomer);
    on<LoadCustomerDetails>(_onLoadCustomerDetails);
    on<LoadStores>(_onLoadStores);
    on<LoadMoreStores>(_onLoadMoreStores);
    on<SearchStores>(_onSearchStores);
    on<ToggleStoreStatusEvent>(_onToggleStoreStatus);
    on<UpdateStoreCommissionEvent>(_onUpdateStoreCommission);
    on<SelectStore>(_onSelectStore);
    on<LoadStoreDetails>(_onLoadStoreDetails);
    on<LoadDrivers>(_onLoadDrivers);
    on<LoadMoreDrivers>(_onLoadMoreDrivers);
    on<SearchDrivers>(_onSearchDrivers);
    on<ToggleDriverStatusEvent>(_onToggleDriverStatus);
    on<SelectDriver>(_onSelectDriver);
    on<LoadDriverDetails>(_onLoadDriverDetails);
    on<SwitchAccountTab>(_onSwitchAccountTab);
    on<ClearAccountsError>(_onClearError);
  }

  // ============================================
  // 📊 STATISTICS
  // ============================================

  Future<void> _onLoadAccountStats(
    LoadAccountStats event,
    Emitter<AccountsState> emit,
  ) async {
    if (state is! AccountsLoaded) {
      emit(const AccountsLoading());
    }

    final result = await _getAccountStats();

    // Re-read state after await to get latest data from other concurrent handlers
    final freshState = state is AccountsLoaded
        ? state as AccountsLoaded
        : const AccountsLoaded();

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: freshState)),
      (stats) => emit(freshState.copyWith(stats: stats)),
    );
  }

  // ============================================
  // 👥 CUSTOMERS
  // ============================================

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<AccountsState> emit,
  ) async {
    if (state is! AccountsLoaded) {
      emit(const AccountsLoading());
    }

    final result = await _getCustomers(
      searchQuery: event.searchQuery,
      isActive: event.isActive,
      limit: _pageSize,
    );

    // Re-read state after await to get latest data from other concurrent handlers
    final freshState = state is AccountsLoaded
        ? state as AccountsLoaded
        : const AccountsLoaded();

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: freshState)),
      (customers) => emit(freshState.copyWith(
        customers: customers,
        hasMoreCustomers: customers.length >= _pageSize,
        customersSearchQuery: event.searchQuery,
      )),
    );
  }

  Future<void> _onLoadMoreCustomers(
    LoadMoreCustomers event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;
    if (currentState.isLoadingMoreCustomers || !currentState.hasMoreCustomers) {
      return;
    }

    emit(currentState.copyWith(isLoadingMoreCustomers: true));

    final lastId = currentState.customers.isNotEmpty
        ? currentState.customers.last.id
        : null;

    final result = await _getCustomers(
      searchQuery: currentState.customersSearchQuery,
      limit: _pageSize,
      lastId: lastId,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMoreCustomers: false)),
      (newCustomers) {
        final allCustomers = [...currentState.customers, ...newCustomers];
        emit(currentState.copyWith(
          customers: allCustomers,
          hasMoreCustomers: newCustomers.length >= _pageSize,
          isLoadingMoreCustomers: false,
        ));
      },
    );
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<AccountsState> emit,
  ) async {
    add(LoadCustomers(searchQuery: event.query));
  }

  Future<void> _onToggleCustomerStatus(
    ToggleCustomerStatusEvent event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    emit(AccountActionInProgress(
      accountId: event.customerId,
      action: 'تغيير حالة العميل',
      previousState: currentState,
    ));

    final result =
        await _toggleCustomerStatus(event.customerId, event.isActive);

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: currentState)),
      (_) {
        final updatedCustomers = currentState.customers.map((c) {
          if (c.id == event.customerId) {
            return c.copyWith(
              isActive: event.isActive,
              updatedAt: DateTime.now(),
            );
          }
          return c;
        }).toList();

        final updatedState = currentState.copyWith(customers: updatedCustomers);

        emit(AccountActionSuccess(
          message: event.isActive ? 'تم تفعيل العميل' : 'تم تعطيل العميل',
          updatedState: updatedState,
        ));

        // Reset state to AccountsLoaded so subsequent actions work
        emit(updatedState);
      },
    );
  }

  void _onSelectCustomer(
    SelectCustomer event,
    Emitter<AccountsState> emit,
  ) {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    if (event.customer == null) {
      emit(currentState.copyWith(clearSelectedCustomer: true));
    } else {
      emit(currentState.copyWith(selectedCustomer: event.customer));
      // Load detailed stats in background
      add(LoadCustomerDetails(event.customer!.id));
    }
  }

  Future<void> _onLoadCustomerDetails(
    LoadCustomerDetails event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    final result = await _getCustomerById(event.customerId);

    result.fold(
      (_) {}, // Silently ignore - we still show basic data
      (detailedCustomer) {
        final freshState = state;
        if (freshState is! AccountsLoaded) return;
        // Update the selected customer with detailed stats
        if (freshState.selectedCustomer?.id == event.customerId) {
          emit(freshState.copyWith(selectedCustomer: detailedCustomer));
        }
      },
    );
  }

  // ============================================
  // 🏪 STORES
  // ============================================

  Future<void> _onLoadStores(
    LoadStores event,
    Emitter<AccountsState> emit,
  ) async {
    if (state is! AccountsLoaded) {
      emit(const AccountsLoading());
    }

    final result = await _getStores(
      searchQuery: event.searchQuery,
      isActive: event.isActive,
      isApproved: event.isApproved,
      type: event.type,
      limit: _pageSize,
    );

    // Re-read state after await to get latest data from other concurrent handlers
    final freshState = state is AccountsLoaded
        ? state as AccountsLoaded
        : const AccountsLoaded();

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: freshState)),
      (stores) => emit(freshState.copyWith(
        stores: stores,
        hasMoreStores: stores.length >= _pageSize,
        storesSearchQuery: event.searchQuery,
      )),
    );
  }

  Future<void> _onLoadMoreStores(
    LoadMoreStores event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;
    if (currentState.isLoadingMoreStores || !currentState.hasMoreStores) return;

    emit(currentState.copyWith(isLoadingMoreStores: true));

    final lastId =
        currentState.stores.isNotEmpty ? currentState.stores.last.id : null;

    final result = await _getStores(
      searchQuery: currentState.storesSearchQuery,
      limit: _pageSize,
      lastId: lastId,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMoreStores: false)),
      (newStores) {
        final allStores = [...currentState.stores, ...newStores];
        emit(currentState.copyWith(
          stores: allStores,
          hasMoreStores: newStores.length >= _pageSize,
          isLoadingMoreStores: false,
        ));
      },
    );
  }

  Future<void> _onSearchStores(
    SearchStores event,
    Emitter<AccountsState> emit,
  ) async {
    add(LoadStores(searchQuery: event.query));
  }

  Future<void> _onToggleStoreStatus(
    ToggleStoreStatusEvent event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    emit(AccountActionInProgress(
      accountId: event.storeId,
      action: 'تغيير حالة المتجر',
      previousState: currentState,
    ));

    final result = await _toggleStoreStatus(event.storeId, event.isActive);

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: currentState)),
      (_) {
        final updatedStores = currentState.stores.map((s) {
          if (s.id == event.storeId) {
            return s.copyWith(
              isActive: event.isActive,
              updatedAt: DateTime.now(),
            );
          }
          return s;
        }).toList();

        final updatedState = currentState.copyWith(stores: updatedStores);

        emit(AccountActionSuccess(
          message: event.isActive ? 'تم تفعيل المتجر' : 'تم تعطيل المتجر',
          updatedState: updatedState,
        ));

        emit(updatedState);
      },
    );
  }

  Future<void> _onUpdateStoreCommission(
    UpdateStoreCommissionEvent event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    emit(AccountActionInProgress(
      accountId: event.storeId,
      action: 'تحديث نسبة العمولة',
      previousState: currentState,
    ));

    final result = await _updateStoreCommission(event.storeId, event.rate);

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: currentState)),
      (_) {
        final updatedStores = currentState.stores.map((s) {
          if (s.id == event.storeId) {
            return s.copyWith(
              commissionRate: event.rate,
              updatedAt: DateTime.now(),
            );
          }
          return s;
        }).toList();

        final updatedState = currentState.copyWith(stores: updatedStores);

        emit(AccountActionSuccess(
          message: 'تم تحديث نسبة العمولة',
          updatedState: updatedState,
        ));

        emit(updatedState);
      },
    );
  }

  void _onSelectStore(
    SelectStore event,
    Emitter<AccountsState> emit,
  ) {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    if (event.store == null) {
      emit(currentState.copyWith(clearSelectedStore: true));
    } else {
      emit(currentState.copyWith(selectedStore: event.store));
      // Load detailed stats in background
      add(LoadStoreDetails(event.store!.id));
    }
  }

  Future<void> _onLoadStoreDetails(
    LoadStoreDetails event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    final result = await _getStoreById(event.storeId);

    result.fold(
      (_) {},
      (detailedStore) {
        final freshState = state;
        if (freshState is! AccountsLoaded) return;
        if (freshState.selectedStore?.id == event.storeId) {
          emit(freshState.copyWith(selectedStore: detailedStore));
        }
      },
    );
  }

  // ============================================
  // 🚗 DRIVERS
  // ============================================

  Future<void> _onLoadDrivers(
    LoadDrivers event,
    Emitter<AccountsState> emit,
  ) async {
    if (state is! AccountsLoaded) {
      emit(const AccountsLoading());
    }

    final result = await _getDrivers(
      searchQuery: event.searchQuery,
      isActive: event.isActive,
      isApproved: event.isApproved,
      isOnline: event.isOnline,
      limit: _pageSize,
    );

    // Re-read state after await to get latest data from other concurrent handlers
    final freshState = state is AccountsLoaded
        ? state as AccountsLoaded
        : const AccountsLoaded();

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: freshState)),
      (drivers) => emit(freshState.copyWith(
        drivers: drivers,
        hasMoreDrivers: drivers.length >= _pageSize,
        driversSearchQuery: event.searchQuery,
      )),
    );
  }

  Future<void> _onLoadMoreDrivers(
    LoadMoreDrivers event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;
    if (currentState.isLoadingMoreDrivers || !currentState.hasMoreDrivers) {
      return;
    }

    emit(currentState.copyWith(isLoadingMoreDrivers: true));

    final lastId =
        currentState.drivers.isNotEmpty ? currentState.drivers.last.id : null;

    final result = await _getDrivers(
      searchQuery: currentState.driversSearchQuery,
      limit: _pageSize,
      lastId: lastId,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMoreDrivers: false)),
      (newDrivers) {
        final allDrivers = [...currentState.drivers, ...newDrivers];
        emit(currentState.copyWith(
          drivers: allDrivers,
          hasMoreDrivers: newDrivers.length >= _pageSize,
          isLoadingMoreDrivers: false,
        ));
      },
    );
  }

  Future<void> _onSearchDrivers(
    SearchDrivers event,
    Emitter<AccountsState> emit,
  ) async {
    add(LoadDrivers(searchQuery: event.query));
  }

  Future<void> _onToggleDriverStatus(
    ToggleDriverStatusEvent event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    emit(AccountActionInProgress(
      accountId: event.driverId,
      action: 'تغيير حالة السائق',
      previousState: currentState,
    ));

    final result = await _toggleDriverStatus(event.driverId, event.isActive);

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: currentState)),
      (_) {
        final updatedDrivers = currentState.drivers.map((d) {
          if (d.id == event.driverId) {
            return d.copyWith(
              isActive: event.isActive,
              updatedAt: DateTime.now(),
            );
          }
          return d;
        }).toList();

        final updatedState = currentState.copyWith(drivers: updatedDrivers);

        emit(AccountActionSuccess(
          message: event.isActive ? 'تم تفعيل السائق' : 'تم تعطيل السائق',
          updatedState: updatedState,
        ));

        emit(updatedState);
      },
    );
  }

  void _onSelectDriver(
    SelectDriver event,
    Emitter<AccountsState> emit,
  ) {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    if (event.driver == null) {
      emit(currentState.copyWith(clearSelectedDriver: true));
    } else {
      emit(currentState.copyWith(selectedDriver: event.driver));
      // Load detailed stats in background
      add(LoadDriverDetails(event.driver!.id));
    }
  }

  Future<void> _onLoadDriverDetails(
    LoadDriverDetails event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    final result = await _getDriverById(event.driverId);

    result.fold(
      (_) {},
      (detailedDriver) {
        final freshState = state;
        if (freshState is! AccountsLoaded) return;
        if (freshState.selectedDriver?.id == event.driverId) {
          emit(freshState.copyWith(selectedDriver: detailedDriver));
        }
      },
    );
  }

  // ============================================
  // 🔧 UTILITY
  // ============================================

  void _onSwitchAccountTab(
    SwitchAccountTab event,
    Emitter<AccountsState> emit,
  ) {
    final currentState = state;
    if (currentState is! AccountsLoaded) {
      emit(AccountsLoaded(currentTab: event.tab));
      return;
    }

    emit(currentState.copyWith(currentTab: event.tab));

    // Load data for the tab if empty
    switch (event.tab) {
      case AccountType.customer:
        if (currentState.customers.isEmpty) {
          add(const LoadCustomers());
        }
        break;
      case AccountType.store:
        if (currentState.stores.isEmpty) {
          add(const LoadStores());
        }
        break;
      case AccountType.driver:
        if (currentState.drivers.isEmpty) {
          add(const LoadDrivers());
        }
        break;
    }
  }

  void _onClearError(
    ClearAccountsError event,
    Emitter<AccountsState> emit,
  ) {
    final currentState = state;
    if (currentState is AccountsError && currentState.previousState != null) {
      emit(currentState.previousState!);
    }
  }
}
