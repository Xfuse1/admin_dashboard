import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

// Core
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
import '../../features/orders/data/datasources/orders_firebase_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/orders_usecases.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';

// Accounts Feature
import '../../features/accounts/data/datasources/accounts_datasource.dart';
import '../../features/accounts/data/datasources/accounts_firebase_datasource.dart';
import '../../features/accounts/data/repositories/accounts_repository_impl.dart';
import '../../features/accounts/data/driver_applications_repository.dart';
import '../../features/accounts/domain/repositories/accounts_repository.dart';
import '../../features/accounts/domain/usecases/accounts_usecases.dart';
import '../../features/accounts/presentation/bloc/accounts_bloc.dart';
import '../../features/accounts/presentation/providers/driver_cleanup_provider.dart';

// Onboarding Feature
import '../../features/onboarding/data/datasources/onboarding_datasource.dart';
import '../../features/onboarding/data/datasources/onboarding_firebase_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/onboarding_usecases.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

// Rejection Requests Feature
import '../../features/rejection_requests/data/datasources/rejection_requests_datasource.dart';
import '../../features/rejection_requests/data/repositories/rejection_requests_repository_impl.dart';
import '../../features/rejection_requests/domain/repositories/rejection_requests_repository.dart';
import '../../features/rejection_requests/domain/usecases/rejection_requests_usecases.dart';
import '../../features/rejection_requests/presentation/bloc/rejection_requests_bloc.dart';

// Notifications Feature
import '../../features/notifications/data/datasources/notifications_firebase_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

// Products Feature
import '../../features/products/data/datasources/products_firebase_datasource.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/repositories/products_repository.dart';
import '../../features/products/presentation/bloc/products_bloc.dart';

// Settings Feature
import '../../features/settings/data/datasources/settings_datasource.dart';
import '../../features/settings/data/datasources/settings_firebase_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_delivery_settings_usecase.dart';
import '../../features/settings/domain/usecases/update_delivery_price_usecase.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';
// Vendors Feature
import '../../features/vendors/data/datasources/vendors_datasource.dart';
import '../../features/vendors/data/datasources/vendors_firebase_datasource.dart';
import '../../features/vendors/data/repositories/vendors_repository_impl.dart';
import '../../features/vendors/domain/repositories/vendors_repository.dart';
import '../../features/vendors/domain/usecases/vendors_usecases.dart';
import '../../features/vendors/presentation/bloc/vendors_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes all dependencies for the application.
///
/// Must be called before runApp().
Future<void> initDependencies() async {
  // ============================================
  // � CORE SERVICES
  // ============================================
  logger.info('Initializing dependencies');

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

  // ============================================
  // 🚫 REJECTION REQUESTS FEATURE
  // ============================================
  await _initRejectionRequestsDependencies();

  // ============================================
  // 🔔 NOTIFICATIONS FEATURE
  // ============================================
  await _initNotificationsDependencies();

  // ============================================
  // 📦 PRODUCTS FEATURE
  // ============================================
  await _initProductsDependencies();

  // ============================================
  // ⚙️ SETTINGS FEATURE
  // ============================================
  await _initSettingsDependencies();
}

/// Initializes Auth feature dependencies.
Future<void> _initAuthDependencies() async {
  // Data Sources
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthFirebaseDataSource(),
  );

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
  sl.registerLazySingleton<DashboardDataSource>(
    () => DashboardFirebaseDataSource(),
  );

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
  sl.registerLazySingleton<OrdersDataSource>(
    () => OrdersFirebaseDataSource(),
  );

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
  sl.registerLazySingleton<AccountsDataSource>(
    () => AccountsFirebaseDataSource(),
  );

  // Repository
  sl.registerLazySingleton<AccountsRepository>(
    () => AccountsRepositoryImpl(sl()),
  );

  // Driver Applications Repository
  sl.registerLazySingleton<DriverApplicationsRepository>(
    () => DriverApplicationsRepository(),
  );

  // Driver Cleanup Provider
  sl.registerLazySingleton<DriverCleanupProvider>(
    () => DriverCleanupProvider(),
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
  sl.registerLazySingleton<OnboardingDataSource>(
    () => OnboardingFirebaseDataSource(),
  );

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
  sl.registerLazySingleton<VendorsDataSource>(
    () => VendorsFirebaseDataSource(),
  );

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
  sl.registerLazySingleton(() => GetVendorProducts(sl()));

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
      getVendorProducts: sl(),
    ),
  );
}

/// Initializes Rejection Requests feature dependencies.
Future<void> _initRejectionRequestsDependencies() async {
  // Data Sources
  sl.registerLazySingleton<RejectionRequestsDataSource>(
    () => RejectionRequestsDataSource(FirebaseFirestore.instance),
  );

  // Repository
  sl.registerLazySingleton<RejectionRequestsRepository>(
    () => RejectionRequestsRepositoryImpl(
      dataSource: sl(),
      firestore: FirebaseFirestore.instance,
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetRejectionRequests(sl()));
  sl.registerLazySingleton(() => WatchRejectionRequests(sl()));
  sl.registerLazySingleton(() => ApproveExcuse(sl()));
  sl.registerLazySingleton(() => RejectExcuse(sl()));
  sl.registerLazySingleton(() => GetRejectionStats(sl()));
  sl.registerLazySingleton(() => GetPendingRequestsCount(sl()));

  // BLoC
  sl.registerFactory(
    () => RejectionRequestsBloc(
      getRejectionRequests: sl(),
      watchRejectionRequests: sl(),
      approveExcuse: sl(),
      rejectExcuse: sl(),
      getRejectionStats: sl(),
      getPendingRequestsCount: sl(),
    ),
  );
}

/// Initializes Notifications feature dependencies.
Future<void> _initNotificationsDependencies() async {
  // Data Sources
  sl.registerLazySingleton<NotificationsFirebaseDataSource>(
    () => NotificationsFirebaseDataSource(
      firestore: FirebaseFirestore.instance,
      adminId: 'admin', // يمكن استبداله بـ ID الأدمن الحالي من Auth
    ),
  );

  // Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl()),
  );

  // BLoC
  sl.registerFactory(
    () => NotificationsBloc(sl()),
  );
}

/// Initializes Products feature dependencies.
Future<void> _initProductsDependencies() async {
  // Data Sources
  sl.registerLazySingleton<ProductsFirebaseDatasource>(
    () => ProductsFirebaseDatasource(FirebaseFirestore.instance),
  );

  // Repository
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(sl()),
  );

  // BLoC
  sl.registerFactory(
    () => ProductsBloc(sl()),
  );
}

/// Initializes Settings feature dependencies.
Future<void> _initSettingsDependencies() async {
  // Data Sources
  sl.registerLazySingleton<SettingsDataSource>(
    () => SettingsFirebaseDataSource(firestore: FirebaseFirestore.instance),
  );

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDeliverySettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeliveryPriceUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => SettingsCubit(
      getDeliverySettingsUseCase: sl(),
      updateDeliveryPriceUseCase: sl(),
      repository: sl(),
    ),
  );
}
