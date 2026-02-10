import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/di/injection_container.dart';
import '../../config/routes/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/driver_cleanup_service.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_event.dart';
import '../../features/notifications/presentation/widgets/notifications_bell.dart';
import 'responsive_layout.dart';
import 'sidebar.dart';

/// Main admin shell with responsive sidebar.
class AdminShell extends StatefulWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    // Start driver cleanup service when dashboard opens
    sl<DriverCleanupService>().start();
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return BlocProvider(
      create: (_) => sl<NotificationsBloc>()..add(const WatchNotifications()),
      child: _buildScaffold(context, isDesktop),
    );
  }

  Widget _buildScaffold(BuildContext context, bool isDesktop) {
    return Scaffold(
      body: Row(
        children: [
          // Desktop sidebar
          if (isDesktop) const RepaintBoundary(child: Sidebar()),

          // Main content
          Expanded(
            child: RepaintBoundary(
              child: Stack(
                children: [
                  // Page content
                  Column(
                    children: [
                      // Mobile/Tablet app bar
                      if (!isDesktop) _buildMobileAppBar(context),

                      // Page content
                      Expanded(child: widget.child),
                    ],
                  ),

                  // Mobile drawer overlay
                  if (!isDesktop && _isDrawerOpen) ...[
                    // Backdrop
                    GestureDetector(
                      onTap: _closeDrawer,
                      child: AnimatedOpacity(
                        opacity: _isDrawerOpen ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(color: Colors.black54),
                      ),
                    ),

                    // Drawer
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: const Sidebar(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleDrawer() {
    setState(() => _isDrawerOpen = !_isDrawerOpen);
  }

  void _closeDrawer() {
    if (_isDrawerOpen) {
      setState(() => _isDrawerOpen = false);
    }
  }

  Widget _buildMobileAppBar(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Menu button
          IconButton(
            onPressed: _toggleDrawer,
            icon: AnimatedSwitcher(
              duration: AppConstants.animationFast,
              child: Icon(
                _isDrawerOpen ? Icons.close : Icons.menu,
                key: ValueKey(_isDrawerOpen),
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          // Logo Icon
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Notifications Bell
          const NotificationsBell(),
        ],
      ),
    );
  }
}

/// Sidebar navigation item data.
class SidebarItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const SidebarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// Gets all sidebar navigation items.
List<SidebarItem> getSidebarItems() {
  return const [
    SidebarItem(
      label: AppStrings.dashboard,
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: AppRoutes.dashboard,
    ),
    SidebarItem(
      label: AppStrings.orders,
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      route: AppRoutes.orders,
    ),
    SidebarItem(
      label: AppStrings.rejectionRequests,
      icon: Icons.cancel_outlined,
      activeIcon: Icons.cancel,
      route: AppRoutes.rejectionRequests,
    ),
    SidebarItem(
      label: AppStrings.driversStats,
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      route: AppRoutes.driversStats,
    ),
    SidebarItem(
      label: AppStrings.onboarding,
      icon: Icons.person_add_outlined,
      activeIcon: Icons.person_add,
      route: AppRoutes.onboarding,
    ),
    SidebarItem(
      label: AppStrings.vendors,
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      route: AppRoutes.vendors,
    ),
    SidebarItem(
      label: 'المنتجات',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      route: AppRoutes.products,
    ),
    SidebarItem(
      label: 'اقسام المتاجر',
      icon: Icons.category_outlined,
      activeIcon: Icons.category,
      route: AppRoutes.categories,
    ),
    SidebarItem(
      label: AppStrings.accounts,
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      route: AppRoutes.accounts,
    ),
    SidebarItem(
      label: 'إعدادات العمولات',
      icon: Icons.percent_outlined,
      activeIcon: Icons.percent,
      route: AppRoutes.commissionSettings,
    ),
    SidebarItem(
      label: AppStrings.simulatorSettings,
      icon: Icons.settings_input_component_outlined,
      activeIcon: Icons.settings_input_component,
      route: AppRoutes.simulatorSettings,
    ),
    SidebarItem(
      label: AppStrings.manageAdmins,
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings,
      route: AppRoutes.manageAdmins,
    ),
  ];
}
