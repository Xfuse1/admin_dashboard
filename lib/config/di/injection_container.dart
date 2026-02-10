import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

// Core
import '../../core/utils/app_logger.dart';
import '../../core/services/firestore_lookup_service.dart';

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
import '../../core/services/driver_cleanup_service.dart';

// Onboarding Feature
import '../../features/onboarding/data/datasources/onboarding_datasource.dart';
import '../../features/onboarding/data/datasources/onboarding_firebase_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/onboarding_usecases.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

// Rejection Requests Feature
import '../../features/rejection_requests/data/datasources/rejection_requests_datasource.dart';
import '../../features/rejection_requests/data/datasources/rejection_requests_datasource_interface.dart';
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
import '../../features/settings/domain/usecases/simulator_usecases.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/bloc/simulator_settings_bloc.dart';
// Admins Feature
import '../../features/admins/data/datasources/admins_datasource.dart';
import '../../features/admins/data/datasources/admins_firebase_datasource.dart';
import '../../features/admins/data/repositories/admins_repository_impl.dart';
import '../../features/admins/domain/repositories/admins_repository.dart';
import '../../features/admins/domain/usecases/admins_usecases.dart';
import '../../features/admins/presentation/bloc/admins_bloc.dart';

// Categories Feature
import '../../features/categories/data/datasources/categories_firebase_datasource.dart';
import '../../features/categories/presentation/bloc/categories_bloc.dart';

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
  // 🛠 CORE SERVICES
  // ============================================
  logger.info('Initializing dependencies');

  // Firestore Lookup Service
  sl.registerLazySingleton<FirestoreLookupService>(
    () => FirestoreLookupService(),
  );

  // ============================================
  // 🔥 FIREBASE (initialized in main.dart)
  // ============================================

  // ============================================
  // 🔐 AUTH FEATURE
  // ============================================
  _initAuthDependencies();

  // ============================================
  // 📊 DASHBOARD FEATURE
  // ============================================
  _initDashboardDependencies();

  // ============================================
  // 📦 ORDERS FEATURE
  // ============================================
  _initOrdersDependencies();

  // ============================================
  // 👥 ACCOUNTS FEATURE
  // ============================================
  _initAccountsDependencies();

  // ============================================
  // 🏪 VENDORS FEATURE
  // ============================================
  _initVendorsDependencies();

  // ============================================
  // 📝 ONBOARDING FEATURE
  // ============================================
  _initOnboardingDependencies();

  // ============================================
  // 🚫 REJECTION REQUESTS FEATURE
  // ============================================
  _initRejectionRequestsDependencies();

  // ============================================
  // 🔔 NOTIFICATIONS FEATURE
  // ============================================
  _initNotificationsDependencies();

  // ============================================
  // 📦 PRODUCTS FEATURE
  // ============================================
  _initProductsDependencies();

  // ============================================
  // ⚙️ SETTINGS FEATURE
  // ============================================
  _initSettingsDependencies();

  // ============================================
  // 👤 ADMINS FEATURE
  // ============================================
  _initAdminsDependencies();

  // ============================================
  // 📂 CATEGORIES FEATURE
  // ============================================
  _initCategoriesDependencies();
}

/// Initializes Auth feature dependencies.
void _initAuthDependencies() {
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
void _initDashboardDependencies() {
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
void _initOrdersDependencies() {
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
void _initAccountsDependencies() {
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

  // Driver Cleanup Service
  sl.registerLazySingleton<DriverCleanupService>(
    () => DriverCleanupService(),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCustomers(sl()));
  sl.registerLazySingleton(() => GetCustomerById(sl()));
  sl.registerLazySingleton(() => ToggleCustomerStatus(sl()));
  sl.registerLazySingleton(() => GetStores(sl()));
  sl.registerLazySingleton(() => GetStoreById(sl()));
  sl.registerLazySingleton(() => ToggleStoreStatus(sl()));
  sl.registerLazySingleton(() => UpdateStoreCommission(sl()));
  sl.registerLazySingleton(() => GetDrivers(sl()));
  sl.registerLazySingleton(() => GetDriverById(sl()));
  sl.registerLazySingleton(() => ToggleDriverStatus(sl()));
  sl.registerLazySingleton(() => GetAccountStats(sl()));

  // BLoC
  sl.registerFactory(
    () => AccountsBloc(
      getCustomers: sl(),
      getCustomerById: sl(),
      toggleCustomerStatus: sl(),
      getStores: sl(),
      getStoreById: sl(),
      toggleStoreStatus: sl(),
      updateStoreCommission: sl(),
      getDrivers: sl(),
      getDriverById: sl(),
      toggleDriverStatus: sl(),
      getAccountStats: sl(),
      applicationsRepository: sl(),
    ),
  );
}

/// Initializes Onboarding feature dependencies.
void _initOnboardingDependencies() {
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
void _initVendorsDependencies() {
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
  sl.registerLazySingleton(() => ToggleFeaturedStatus(sl()));
  sl.registerLazySingleton(() => VerifyVendor(sl()));

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
      toggleFeaturedStatus: sl(),
      verifyVendor: sl(),
    ),
  );
}

/// Initializes Rejection Requests feature dependencies.
void _initRejectionRequestsDependencies() {
  // Data Sources
  sl.registerLazySingleton<RejectionRequestsDataSourceInterface>(
    () => RejectionRequestsFirebaseDataSource(FirebaseFirestore.instance),
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
void _initNotificationsDependencies() {
  // Data Sources
  sl.registerLazySingleton<NotificationsFirebaseDataSource>(
    () => NotificationsFirebaseDataSource(
      firestore: FirebaseFirestore.instance,
      adminId: sl<AuthRepository>().currentUser?.id ?? 'admin',
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
void _initProductsDependencies() {
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
void _initSettingsDependencies() {
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

  // Simulator Use Cases
  sl.registerLazySingleton(() => GetSimulatorSettings(sl()));
  sl.registerLazySingleton(() => ToggleSimulator(sl()));
  sl.registerLazySingleton(() => SaveSimulatorSettings(sl()));

  // BLoC
  sl.registerFactory(
    () => SettingsBloc(
      getDeliverySettingsUseCase: sl(),
      updateDeliveryPriceUseCase: sl(),
      repository: sl(),
    ),
  );

  // Simulator BLoC
  sl.registerFactory(
    () => SimulatorSettingsBloc(
      getSimulatorSettings: sl(),
      toggleSimulator: sl(),
      saveSimulatorSettings: sl(),
    ),
  );
}

/// Initializes Admins feature dependencies.
void _initAdminsDependencies() {
  // Data Sources
  sl.registerLazySingleton<AdminsDataSource>(
    () => AdminsFirebaseDataSource(),
  );

  // Repository
  sl.registerLazySingleton<AdminsRepository>(
    () => AdminsRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAdmins(sl()));
  sl.registerLazySingleton(() => AddAdmin(sl()));
  sl.registerLazySingleton(() => DeleteAdmin(sl()));

  // BLoC
  sl.registerFactory(
    () => AdminsBloc(
      getAdmins: sl(),
      addAdmin: sl(),
      deleteAdmin: sl(),
    ),
  );
}

/// Initializes Categories feature dependencies.
void _initCategoriesDependencies() {
  // Data Sources
  sl.registerLazySingleton<CategoriesFirebaseDatasource>(
    () => CategoriesFirebaseDatasource(FirebaseFirestore.instance),
  );

  // BLoC
  sl.registerFactory(
    () => CategoriesBloc(sl()),
  );
}
