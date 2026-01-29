import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/routes/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
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

  void _toggleDrawer() {
    setState(() => _isDrawerOpen = !_isDrawerOpen);
  }

  void _closeDrawer() {
    if (_isDrawerOpen) {
      setState(() => _isDrawerOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return Scaffold(
      body: Row(
        children: [
          // Desktop sidebar
          if (isDesktop)
            const Sidebar()
                .animate()
                .fadeIn(duration: AppConstants.animationMedium)
                .slideX(begin: 0.1, end: 0),

          // Main content
          Expanded(
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
                    child: Container(color: Colors.black54),
                  ).animate().fadeIn(duration: AppConstants.animationFast),

                  // Drawer
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: const Sidebar().animate().slideX(
                          begin: 1,
                          end: 0,
                          duration: AppConstants.animationMedium,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAppBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
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
          // Logo Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          // Menu button
          IconButton(
            onPressed: _toggleDrawer,
            icon: AnimatedSwitcher(
              duration: AppConstants.animationFast,
              child: Icon(
                _isDrawerOpen ? Icons.close : Icons.menu,
                key: ValueKey(_isDrawerOpen),
                color: AppColors.textSecondary,
              ),
            ),
          ),
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
      label: AppStrings.accounts,
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      route: AppRoutes.accounts,
    ),
  ];
}
