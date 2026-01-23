import 'package:get_it/get_it.dart';

// Core
import '../../core/config/app_config.dart';
import '../../core/utils/app_logger.dart';

// Auth Feature
import '../../features/auth/data/datasources/datasources.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Dashboard Feature
import '../../features/dashboard/data/datasources/datasources.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/dashboard_usecases.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Orders Feature
import '../../features/orders/data/datasources/orders_datasource.dart';
import '../../features/orders/data/datasources/orders_mock_datasource.dart';
import '../../features/orders/data/datasources/orders_firebase_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/orders_usecases.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';

// Accounts Feature
import '../../features/accounts/data/datasources/accounts_datasource.dart';
import '../../features/accounts/data/datasources/accounts_mock_datasource.dart';
import '../../features/accounts/data/datasources/accounts_firebase_datasource.dart';
import '../../features/accounts/data/repositories/accounts_repository_impl.dart';
import '../../features/accounts/data/driver_applications_repository.dart';
import '../../features/accounts/domain/repositories/accounts_repository.dart';
import '../../features/accounts/domain/usecases/accounts_usecases.dart';
import '../../features/accounts/presentation/bloc/accounts_bloc.dart';

// Onboarding Feature
import '../../features/onboarding/data/datasources/onboarding_datasource.dart';
import '../../features/onboarding/data/datasources/onboarding_firebase_datasource.dart';
import '../../features/onboarding/data/datasources/onboarding_mock_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/onboarding_usecases.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

// Settings Feature
import '../../features/settings/data/datasources/settings_datasource.dart';
import '../../features/settings/data/datasources/settings_mock_datasource.dart';
import '../../features/settings/data/datasources/settings_firebase_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/settings_usecases.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

// Fleet Feature
import '../../features/fleet/data/datasources/fleet_datasource.dart';
import '../../features/fleet/data/datasources/fleet_mock_datasource.dart';
import '../../features/fleet/data/datasources/fleet_firebase_datasource.dart';
import '../../features/fleet/data/repositories/fleet_repository_impl.dart';
import '../../features/fleet/domain/repositories/fleet_repository.dart';
import '../../features/fleet/domain/usecases/fleet_usecases.dart';
import '../../features/fleet/presentation/bloc/fleet_bloc.dart';

// Vendors Feature
import '../../features/vendors/data/datasources/vendors_datasource.dart';
import '../../features/vendors/data/datasources/vendors_mock_datasource.dart';
import '../../features/vendors/data/datasources/vendors_firebase_datasource.dart';
import '../../features/vendors/data/repositories/vendors_repository_impl.dart';
import '../../features/vendors/domain/repositories/vendors_repository.dart';
import '../../features/vendors/domain/usecases/vendors_usecases.dart';
import '../../features/vendors/presentation/bloc/vendors_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Toggle between Mock and Firebase data sources.
///
/// Uses environment variable from --dart-define or defaults based on profile.
/// Usage: flutter run --dart-define=USE_MOCK_DATA=true
bool get useMockData => AppConfig.useMockData;

/// Initializes all dependencies for the application.
///
/// Must be called before runApp().
Future<void> initDependencies() async {
  // ============================================
  // � CORE SERVICES
  // ============================================
  logger.info('Initializing dependencies (useMockData: $useMockData)');

  // ============================================
  // �🔥 FIREBASE (initialized in main.dart)
  // ============================================

  // ============================================
  // 🔐 AUTH FEATURE
  // ============================================
  await _initAuthDependencies();

  // ============================================
  // 📊 DASHBOARD FEATURE
  // ============================================
  await _initDashboardDependencies();

  // ============================================
  // 📦 ORDERS FEATURE
  // ============================================
  await _initOrdersDependencies();

  // ============================================
  // 👥 ACCOUNTS FEATURE
  // ============================================
  await _initAccountsDependencies();

  // ============================================
  // 🏪 VENDORS FEATURE
  // ============================================
  await _initVendorsDependencies();

  // ============================================
  // 🚗 FLEET FEATURE
  // ============================================
  await _initFleetDependencies();

  // ============================================
  // 📝 ONBOARDING FEATURE
  // ============================================
  await _initOnboardingDependencies();

  // ============================================
  // ⚙️ SETTINGS FEATURE
  // ============================================
  await _initSettingsDependencies();
}

/// Initializes Auth feature dependencies.
Future<void> _initAuthDependencies() async {
  // Data Sources
  if (useMockData) {
    sl.registerLazySingleton<AuthDataSource>(
      () => AuthMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<AuthDataSource>(
      () => AuthFirebaseDataSource(),
    );
  }

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthStatusUseCase: sl(),
    ),
  );
}

/// Initializes Dashboard feature dependencies.
Future<void> _initDashboardDependencies() async {
  // Data Sources
  if (useMockData) {
    sl.registerLazySingleton<DashboardDataSource>(
      () => DashboardMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<DashboardDataSource>(
      () => DashboardFirebaseDataSource(),
    );
  }

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetRevenueDataUseCase(sl()));
  sl.registerLazySingleton(() => GetOrdersDistributionUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => DashboardBloc(
      getStatsUseCase: sl(),
      getRecentOrdersUseCase: sl(),
      getRevenueDataUseCase: sl(),
      getOrdersDistributionUseCase: sl(),
    ),
  );
}

/// Initializes Orders feature dependencies.
Future<void> _initOrdersDependencies() async {
  // Data Sources
  if (useMockData) {
    sl.registerLazySingleton<OrdersDataSource>(
      () => OrdersMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<OrdersDataSource>(
      () => OrdersFirebaseDataSource(),
    );
  }

  // Repository
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetOrders(sl()));
  sl.registerLazySingleton(() => GetOrderById(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatus(sl()));
  sl.registerLazySingleton(() => AssignDriverToOrder(sl()));
  sl.registerLazySingleton(() => CancelOrder(sl()));
  sl.registerLazySingleton(() => WatchOrders(sl()));
  sl.registerLazySingleton(() => GetOrderStats(sl()));

  // BLoC
  sl.registerFactory(
    () => OrdersBloc(
      getOrders: sl(),
      getOrderById: sl(),
      updateOrderStatus: sl(),
      assignDriver: sl(),
      cancelOrder: sl(),
      watchOrders: sl(),
      getOrderStats: sl(),
    ),
  );
}

/// Initializes Accounts feature dependencies.
Future<void> _initAccountsDependencies() async {
  // Data Sources
  if (useMockData) {
    sl.registerLazySingleton<AccountsDataSource>(
      () => AccountsMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<AccountsDataSource>(
      () => AccountsFirebaseDataSource(),
    );
  }

  // Repository
  sl.registerLazySingleton<AccountsRepository>(
    () => AccountsRepositoryImpl(sl()),
  );

  // Driver Applications Repository
  sl.registerLazySingleton<DriverApplicationsRepository>(
    () => DriverApplicationsRepository(),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCustomers(sl()));
  sl.registerLazySingleton(() => ToggleCustomerStatus(sl()));
  sl.registerLazySingleton(() => GetStores(sl()));
  sl.registerLazySingleton(() => ToggleStoreStatus(sl()));
  sl.registerLazySingleton(() => UpdateStoreCommission(sl()));
  sl.registerLazySingleton(() => GetDrivers(sl()));
  sl.registerLazySingleton(() => ToggleDriverStatus(sl()));
  sl.registerLazySingleton(() => GetAccountStats(sl()));

  // BLoC
  sl.registerFactory(
    () => AccountsBloc(
      getCustomers: sl(),
      toggleCustomerStatus: sl(),
      getStores: sl(),
      toggleStoreStatus: sl(),
      updateStoreCommission: sl(),
      getDrivers: sl(),
      toggleDriverStatus: sl(),
      getAccountStats: sl(),
      applicationsRepository: sl(),
    ),
  );
}

/// Initializes Onboarding feature dependencies.
Future<void> _initOnboardingDependencies() async {
  // Data Sources
  if (useMockData) {
    sl.registerLazySingleton<OnboardingDataSource>(
      () => OnboardingMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<OnboardingDataSource>(
      () => OnboardingFirebaseDataSource(),
    );
  }

  // Repository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetOnboardingRequests(sl()));
  sl.registerLazySingleton(() => GetOnboardingRequestById(sl()));
  sl.registerLazySingleton(() => ApproveOnboardingRequest(sl()));
  sl.registerLazySingleton(() => RejectOnboardingRequest(sl()));
  sl.registerLazySingleton(() => MarkRequestUnderReview(sl()));
  sl.registerLazySingleton(() => GetOnboardingStats(sl()));

  // BLoC
  sl.registerFactory(
    () => OnboardingBloc(
      getRequests: sl(),
      approveRequest: sl(),
      rejectRequest: sl(),
      markUnderReview: sl(),
      getStats: sl(),
    ),
  );
}

/// Initializes Settings feature dependencies.
Future<void> _initSettingsDependencies() async {
  // Data Sources
  if (useMockData) {
    sl.registerLazySingleton<SettingsDataSource>(
      () => SettingsMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<SettingsDataSource>(
      () => SettingsFirebaseDataSource(),
    );
  }

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => UpdateGeneralSettings(sl()));
  sl.registerLazySingleton(() => UpdateDeliverySettings(sl()));
  sl.registerLazySingleton(() => UpdateCommissionSettings(sl()));
  sl.registerLazySingleton(() => UpdateNotificationSettings(sl()));
  sl.registerLazySingleton(() => AddDeliveryZone(sl()));
  sl.registerLazySingleton(() => UpdateDeliveryZone(sl()));
  sl.registerLazySingleton(() => DeleteDeliveryZone(sl()));

  // BLoC
  sl.registerFactory(
    () => SettingsBloc(
      getSettings: sl(),
      updateGeneralSettings: sl(),
      updateDeliverySettings: sl(),
      updateCommissionSettings: sl(),
      updateNotificationSettings: sl(),
      addDeliveryZone: sl(),
      updateDeliveryZone: sl(),
      deleteDeliveryZone: sl(),
    ),
  );
}

/// Initializes Fleet feature dependencies.
Future<void> _initFleetDependencies() async {
  // Data Sources
  if (useMockData) {
    sl.registerLazySingleton<FleetDataSource>(
      () => FleetMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<FleetDataSource>(
      () => FleetFirebaseDataSource(),
    );
  }

  // Repository
  sl.registerLazySingleton<FleetRepository>(
    () => FleetRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetVehicles(sl()));
  sl.registerLazySingleton(() => GetVehicleById(sl()));
  sl.registerLazySingleton(() => AddVehicle(sl()));
  sl.registerLazySingleton(() => UpdateVehicle(sl()));
  sl.registerLazySingleton(() => DeleteVehicle(sl()));
  sl.registerLazySingleton(() => UpdateVehicleStatus(sl()));
  sl.registerLazySingleton(() => AssignDriverToVehicle(sl()));
  sl.registerLazySingleton(() => UnassignDriverFromVehicle(sl()));
  sl.registerLazySingleton(() => GetFleetStats(sl()));
  sl.registerLazySingleton(() => WatchVehicles(sl()));
  sl.registerLazySingleton(() => SearchVehicles(sl()));
  sl.registerLazySingleton(() => GetVehiclesWithAlerts(sl()));

  // BLoC
  sl.registerFactory(
    () => FleetBloc(
      getVehicles: sl(),
      getVehicleById: sl(),
      addVehicle: sl(),
      updateVehicle: sl(),
      deleteVehicle: sl(),
      updateVehicleStatus: sl(),
      assignDriver: sl(),
      unassignDriver: sl(),
      getFleetStats: sl(),
      watchVehicles: sl(),
      searchVehicles: sl(),
      getVehiclesWithAlerts: sl(),
    ),
  );
}

/// Initializes Vendors feature dependencies.
Future<void> _initVendorsDependencies() async {
  // Data Sources
  if (useMockData) {
    sl.registerLazySingleton<VendorsDataSource>(
      () => VendorsMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<VendorsDataSource>(
      () => VendorsFirebaseDataSource(),
    );
  }

  // Repository
  sl.registerLazySingleton<VendorsRepository>(
    () => VendorsRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetVendors(sl()));
  sl.registerLazySingleton(() => GetVendor(sl()));
  sl.registerLazySingleton(() => AddVendor(sl()));
  sl.registerLazySingleton(() => UpdateVendor(sl()));
  sl.registerLazySingleton(() => DeleteVendor(sl()));
  sl.registerLazySingleton(() => ToggleVendorStatus(sl()));
  sl.registerLazySingleton(() => GetVendorStats(sl()));
  sl.registerLazySingleton(() => WatchVendors(sl()));
  sl.registerLazySingleton(() => UpdateVendorRating(sl()));

  // BLoC
  sl.registerFactory(
    () => VendorsBloc(
      getVendors: sl(),
      getVendor: sl(),
      addVendor: sl(),
      updateVendor: sl(),
      deleteVendor: sl(),
      toggleVendorStatus: sl(),
      getVendorStats: sl(),
      watchVendors: sl(),
      updateVendorRating: sl(),
    ),
  );
}
