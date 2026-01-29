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
  // 📝 ONBOARDING FEATURE
  // ============================================
  await _initOnboardingDependencies();
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
