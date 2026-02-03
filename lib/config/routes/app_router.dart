import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_logger.dart';

import '../../config/di/injection_container.dart';
import '../../core/utils/go_router_refresh_stream.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart'
    as auth_bloc_state;
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';
import '../../features/orders/presentation/bloc/orders_event.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/rejection_requests/presentation/bloc/rejection_requests_bloc.dart';
import '../../features/rejection_requests/presentation/bloc/rejection_requests_event.dart';
import '../../features/rejection_requests/presentation/pages/rejection_requests_page.dart';
import '../../features/accounts/presentation/pages/drivers_stats_page.dart';
import '../../features/accounts/presentation/bloc/accounts_bloc.dart';
import '../../features/accounts/presentation/bloc/accounts_event.dart';
import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/onboarding/presentation/bloc/onboarding_event.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/vendors/presentation/pages/vendors_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../shared/widgets/admin_shell.dart';

/// Application route paths.
abstract final class AppRoutes {
  // Auth
  static const String login = '/login';

  // Main
  static const String dashboard = '/';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:id';
  static const String rejectionRequests = '/rejection-requests';
  static const String driversStats = '/drivers-stats';
  static const String onboarding = '/onboarding';
  static const String vendors = '/vendors';
  static const String vendorDetails = '/vendors/:id';
  static const String products = '/products';
  static const String accounts = '/accounts';
}

/// Application router configuration.
final class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  /// Creates the GoRouter instance.
  static GoRouter createRouter({required AuthBloc authBloc}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.dashboard,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;

        // Don't redirect while checking auth status
        if (authState is auth_bloc_state.AuthInitial ||
            authState is auth_bloc_state.AuthLoading) {
          return null;
        }

        final isAuthenticated = authState is auth_bloc_state.AuthAuthenticated;
        final isLoginPage = state.matchedLocation == AppRoutes.login;

        // If not authenticated and not on login page, redirect to login
        if (!isAuthenticated && !isLoginPage) {
          return AppRoutes.login;
        }

        // If authenticated and on login page, redirect to dashboard
        if (isAuthenticated && isLoginPage) {
          return AppRoutes.dashboard;
        }

        return null;
      },
      routes: [
        // Login (outside shell)
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder: _fadeTransition,
          ),
        ),

        // Main shell with sidebar
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            // Dashboard
            GoRoute(
              path: AppRoutes.dashboard,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const DashboardPage(),
                transitionsBuilder: _fadeTransition,
              ),
            ),

            // Orders
            GoRoute(
              path: AppRoutes.orders,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: BlocProvider(
                  create: (_) => sl<OrdersBloc>()..add(const LoadOrders()),
                  child: const OrdersPage(),
                ),
                transitionsBuilder: _fadeTransition,
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  pageBuilder: (context, state) {
                    final orderId = state.pathParameters['id']!;
                    return CustomTransitionPage(
                      key: state.pageKey,
                      child: _PlaceholderPage(title: 'تفاصيل الطلب #$orderId'),
                      transitionsBuilder: _slideTransition,
                    );
                  },
                ),
              ],
            ),
            // Rejection Requests
            GoRoute(
              path: AppRoutes.rejectionRequests,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: BlocProvider(
                  create: (_) => sl<RejectionRequestsBloc>()
                    ..add(const WatchRejectionRequestsEvent(
                        adminDecision: 'pending')),
                  child: const RejectionRequestsPage(),
                ),
                transitionsBuilder: _fadeTransition,
              ),
            ),
            // Drivers Statistics
            GoRoute(
              path: AppRoutes.driversStats,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const DriversStatsPage(),
                transitionsBuilder: _fadeTransition,
              ),
            ),
            // Onboarding
            GoRoute(
              path: AppRoutes.onboarding,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: BlocProvider(
                  create: (_) => sl<OnboardingBloc>(),
                  child: const OnboardingPage(),
                ),
                transitionsBuilder: _fadeTransition,
              ),
            ),

            // Vendors
            GoRoute(
              path: AppRoutes.vendors,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const VendorsPage(),
                transitionsBuilder: _fadeTransition,
              ),
              routes: [
                GoRoute(
                  path: ':id',
                  pageBuilder: (context, state) {
                    final vendorId = state.pathParameters['id']!;
                    return CustomTransitionPage(
                      key: state.pageKey,
                      child: _PlaceholderPage(title: 'المتجر #$vendorId'),
                      transitionsBuilder: _slideTransition,
                    );
                  },
                ),
              ],
            ),

            // Products
            GoRoute(
              path: AppRoutes.products,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ProductsPage(),
                transitionsBuilder: _fadeTransition,
              ),
            ),

            // Accounts
            GoRoute(
              path: AppRoutes.accounts,
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: BlocProvider(
                  create: (_) => sl<AccountsBloc>()..add(const LoadCustomers()),
                  child: const AccountsPage(),
                ),
                transitionsBuilder: _fadeTransition,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Fade transition for page changes.
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
      child: child,
    );
  }

  /// Slide transition for sub-pages.
  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Placeholder page for routes not yet implemented.
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
