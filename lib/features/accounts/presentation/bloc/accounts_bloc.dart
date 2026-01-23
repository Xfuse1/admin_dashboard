import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/driver_applications_repository.dart';
import '../../domain/entities/account_entities.dart';
import '../../domain/entities/driver_application_entity.dart';
import '../../domain/usecases/accounts_usecases.dart';
import 'accounts_event.dart';
import 'accounts_state.dart';

/// BLoC for managing account-related state.
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final GetCustomers _getCustomers;
  final ToggleCustomerStatus _toggleCustomerStatus;
  final GetStores _getStores;
  final ToggleStoreStatus _toggleStoreStatus;
  final UpdateStoreCommission _updateStoreCommission;
  final GetDrivers _getDrivers;
  final ToggleDriverStatus _toggleDriverStatus;
  final GetAccountStats _getAccountStats;
  final DriverApplicationsRepository _applicationsRepository;

  static const int _pageSize = 20;

  AccountsBloc({
    required GetCustomers getCustomers,
    required ToggleCustomerStatus toggleCustomerStatus,
    required GetStores getStores,
    required ToggleStoreStatus toggleStoreStatus,
    required UpdateStoreCommission updateStoreCommission,
    required GetDrivers getDrivers,
    required ToggleDriverStatus toggleDriverStatus,
    required GetAccountStats getAccountStats,
    required DriverApplicationsRepository applicationsRepository,
  })  : _getCustomers = getCustomers,
        _toggleCustomerStatus = toggleCustomerStatus,
        _getStores = getStores,
        _toggleStoreStatus = toggleStoreStatus,
        _updateStoreCommission = updateStoreCommission,
        _getDrivers = getDrivers,
        _toggleDriverStatus = toggleDriverStatus,
        _getAccountStats = getAccountStats,
        _applicationsRepository = applicationsRepository,
        super(const AccountsInitial()) {
    on<LoadAccountStats>(_onLoadAccountStats);
    on<LoadCustomers>(_onLoadCustomers);
    on<LoadMoreCustomers>(_onLoadMoreCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<ToggleCustomerStatusEvent>(_onToggleCustomerStatus);
    on<SelectCustomer>(_onSelectCustomer);
    on<LoadStores>(_onLoadStores);
    on<LoadMoreStores>(_onLoadMoreStores);
    on<SearchStores>(_onSearchStores);
    on<ToggleStoreStatusEvent>(_onToggleStoreStatus);
    on<UpdateStoreCommissionEvent>(_onUpdateStoreCommission);
    on<SelectStore>(_onSelectStore);
    on<LoadDrivers>(_onLoadDrivers);
    on<LoadMoreDrivers>(_onLoadMoreDrivers);
    on<SearchDrivers>(_onSearchDrivers);
    on<ToggleDriverStatusEvent>(_onToggleDriverStatus);
    on<SelectDriver>(_onSelectDriver);
    on<LoadDriverApplications>(_onLoadDriverApplications);
    on<FilterDriverApplications>(_onFilterDriverApplications);
    on<UpdateApplicationStatusEvent>(_onUpdateApplicationStatus);
    on<SelectDriverApplication>(_onSelectDriverApplication);
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
    final currentState = state;
    AccountsLoaded loadedState;

    if (currentState is AccountsLoaded) {
      loadedState = currentState;
    } else {
      emit(const AccountsLoading());
      loadedState = const AccountsLoaded();
    }

    final result = await _getAccountStats();

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: loadedState)),
      (stats) => emit(loadedState.copyWith(stats: stats)),
    );
  }

  // ============================================
  // 👥 CUSTOMERS
  // ============================================

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    AccountsLoaded loadedState;

    if (currentState is AccountsLoaded) {
      loadedState = currentState;
    } else {
      emit(const AccountsLoading());
      loadedState = const AccountsLoaded();
    }

    final result = await _getCustomers(
      searchQuery: event.searchQuery,
      isActive: event.isActive,
      limit: _pageSize,
    );

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: loadedState)),
      (customers) => emit(loadedState.copyWith(
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
            return CustomerEntity(
              id: c.id,
              name: c.name,
              email: c.email,
              phone: c.phone,
              isActive: event.isActive,
              createdAt: c.createdAt,
              updatedAt: DateTime.now(),
              totalOrders: c.totalOrders,
              totalSpent: c.totalSpent,
              lastOrderDate: c.lastOrderDate,
            );
          }
          return c;
        }).toList();

        emit(AccountActionSuccess(
          message: event.isActive ? 'تم تفعيل العميل' : 'تم تعطيل العميل',
          updatedState: currentState.copyWith(customers: updatedCustomers),
        ));
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
    }
  }

  // ============================================
  // 🏪 STORES
  // ============================================

  Future<void> _onLoadStores(
    LoadStores event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    AccountsLoaded loadedState;

    if (currentState is AccountsLoaded) {
      loadedState = currentState;
    } else {
      emit(const AccountsLoading());
      loadedState = const AccountsLoaded();
    }

    final result = await _getStores(
      searchQuery: event.searchQuery,
      isActive: event.isActive,
      isApproved: event.isApproved,
      type: event.type,
      limit: _pageSize,
    );

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: loadedState)),
      (stores) => emit(loadedState.copyWith(
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
            return StoreEntity(
              id: s.id,
              name: s.name,
              email: s.email,
              phone: s.phone,
              type: s.type,
              address: s.address,
              isActive: event.isActive,
              isApproved: s.isApproved,
              isOpen: s.isOpen,
              rating: s.rating,
              totalRatings: s.totalRatings,
              totalOrders: s.totalOrders,
              totalRevenue: s.totalRevenue,
              commissionRate: s.commissionRate,
              createdAt: s.createdAt,
              updatedAt: DateTime.now(),
              imageUrl: s.imageUrl,
              categories: s.categories,
              workingHours: s.workingHours,
            );
          }
          return s;
        }).toList();

        emit(AccountActionSuccess(
          message: event.isActive ? 'تم تفعيل المتجر' : 'تم تعطيل المتجر',
          updatedState: currentState.copyWith(stores: updatedStores),
        ));
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
            return StoreEntity(
              id: s.id,
              name: s.name,
              email: s.email,
              phone: s.phone,
              type: s.type,
              address: s.address,
              isActive: s.isActive,
              isApproved: s.isApproved,
              isOpen: s.isOpen,
              rating: s.rating,
              totalRatings: s.totalRatings,
              totalOrders: s.totalOrders,
              totalRevenue: s.totalRevenue,
              commissionRate: event.rate,
              createdAt: s.createdAt,
              updatedAt: DateTime.now(),
              imageUrl: s.imageUrl,
              categories: s.categories,
              workingHours: s.workingHours,
            );
          }
          return s;
        }).toList();

        emit(AccountActionSuccess(
          message: 'تم تحديث نسبة العمولة',
          updatedState: currentState.copyWith(stores: updatedStores),
        ));
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
    }
  }

  // ============================================
  // 🚗 DRIVERS
  // ============================================

  Future<void> _onLoadDrivers(
    LoadDrivers event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    AccountsLoaded loadedState;

    if (currentState is AccountsLoaded) {
      loadedState = currentState;
    } else {
      emit(const AccountsLoading());
      loadedState = const AccountsLoaded();
    }

    final result = await _getDrivers(
      searchQuery: event.searchQuery,
      isActive: event.isActive,
      isApproved: event.isApproved,
      isOnline: event.isOnline,
      limit: _pageSize,
    );

    result.fold(
      (failure) =>
          emit(AccountsError(failure.message, previousState: loadedState)),
      (drivers) => emit(loadedState.copyWith(
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
            return DriverEntity(
              id: d.id,
              name: d.name,
              email: d.email,
              phone: d.phone,
              isActive: event.isActive,
              isApproved: d.isApproved,
              isOnline: d.isOnline,
              rating: d.rating,
              totalRatings: d.totalRatings,
              totalDeliveries: d.totalDeliveries,
              walletBalance: d.walletBalance,
              latitude: d.latitude,
              longitude: d.longitude,
              vehicleType: d.vehicleType,
              vehiclePlate: d.vehiclePlate,
              createdAt: d.createdAt,
              updatedAt: DateTime.now(),
              imageUrl: d.imageUrl,
              idCardImage: d.idCardImage,
              licenseImage: d.licenseImage,
            );
          }
          return d;
        }).toList();

        emit(AccountActionSuccess(
          message: event.isActive ? 'تم تفعيل السائق' : 'تم تعطيل السائق',
          updatedState: currentState.copyWith(drivers: updatedDrivers),
        ));
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
    }
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

  // ============================================
  // 📋 DRIVER APPLICATIONS
  // ============================================

  Future<void> _onLoadDriverApplications(
    LoadDriverApplications event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    AccountsLoaded loadedState;

    if (currentState is AccountsLoaded) {
      loadedState = currentState;
    } else {
      emit(const AccountsLoading());
      loadedState = const AccountsLoaded();
    }

    await emit.forEach(
      event.status != null
          ? _applicationsRepository.getApplicationsByStatus(event.status!)
          : _applicationsRepository.getApplicationsStream(),
      onData: (applications) {
        return loadedState.copyWith(
          driverApplications: applications,
          applicationFilter: event.status,
        );
      },
      onError: (error, _) {
        return AccountsError(
          error.toString(),
          previousState: loadedState,
        );
      },
    );
  }

  Future<void> _onFilterDriverApplications(
    FilterDriverApplications event,
    Emitter<AccountsState> emit,
  ) async {
    add(LoadDriverApplications(status: event.status));
  }

  Future<void> _onUpdateApplicationStatus(
    UpdateApplicationStatusEvent event,
    Emitter<AccountsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    emit(AccountActionInProgress(
      accountId: event.applicationId,
      action: 'تحديث حالة الطلب',
      previousState: currentState,
    ));

    try {
      await _applicationsRepository.updateApplicationStatus(
        applicationId: event.applicationId,
        newStatus: event.newStatus,
        reviewedBy: event.reviewedBy,
        rejectionReason: event.rejectionReason,
      );

      final message = event.newStatus == ApplicationStatus.approved
          ? 'تم قبول الطلب بنجاح'
          : 'تم رفض الطلب';

      emit(AccountActionSuccess(
        message: message,
        updatedState: currentState,
      ));

      // Reload applications
      add(LoadDriverApplications(status: currentState.applicationFilter));
    } catch (e) {
      emit(AccountsError(
        'فشل تحديث حالة الطلب: ${e.toString()}',
        previousState: currentState,
      ));
    }
  }

  void _onSelectDriverApplication(
    SelectDriverApplication event,
    Emitter<AccountsState> emit,
  ) {
    final currentState = state;
    if (currentState is! AccountsLoaded) return;

    emit(currentState.copyWith(
      selectedApplication: event.application,
      clearSelectedApplication: event.application == null,
    ));
  }
}
