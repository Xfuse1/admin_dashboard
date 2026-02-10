import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/skeletons.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/orders_distribution_chart.dart';
import '../widgets/recent_orders_list.dart';
import '../widgets/revenue_chart.dart';

/// Dashboard page widget.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(const DashboardRefreshRequested());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(context.horizontalPadding),
          child: BlocBuilder<DashboardBloc, DashboardState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              return switch (state) {
                DashboardInitial() => const _DashboardSkeleton(),
                DashboardLoading() => const _DashboardSkeleton(),
                DashboardLoaded() => _DashboardContent(state: state),
                DashboardError() => ErrorState(
                    message: state.message,
                    onRetry: () => context
                        .read<DashboardBloc>()
                        .add(const DashboardLoadRequested()),
                  ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardLoaded state;

  const _DashboardContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildHeader(context),
        const SizedBox(height: AppConstants.spacingLg),

        // Stats cards
        _buildStatsGrid(context, isDesktop, isTablet),
        const SizedBox(height: AppConstants.spacingLg),

        // Charts row
        _buildChartsSection(context, isDesktop),
        const SizedBox(height: AppConstants.spacingLg),

        // Recent orders
        SizedBox(
          height: 400,
          child: RecentOrdersList(orders: state.recentOrders),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.dashboard,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              'مرحباً بك في لوحة التحكم',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
        // Refresh button
        IconButton(
          onPressed: () => context
              .read<DashboardBloc>()
              .add(const DashboardRefreshRequested()),
          icon: const Icon(Icons.refresh),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop ? 5 : (isTablet ? 2 : 1);

    final statsCards = [
      _StatCardData(
        title: AppStrings.totalOrders,
        value: Formatters.number(state.stats.totalOrders),
        icon: Icons.shopping_bag_outlined,
        iconColor: AppColors.primary,
        percentChange: state.stats.ordersGrowth,
      ),
      _StatCardData(
        title: AppStrings.totalRevenue,
        value: Formatters.currency(state.stats.totalRevenue),
        icon: Icons.monetization_on_outlined,
        iconColor: AppColors.success,
        percentChange: state.stats.revenueGrowth,
        subtitle:
            'آخر 24 ساعة: ${Formatters.currency(state.stats.todayRevenue)}',
      ),
      _StatCardData(
        title: 'طلبات متعددة المتاجر',
        value: Formatters.number(state.stats.multiStoreOrders),
        icon: Icons.store_outlined,
        iconColor: AppColors.secondary,
        subtitle: state.stats.totalOrders > 0
            ? '${((state.stats.multiStoreOrders / state.stats.totalOrders) * 100).toStringAsFixed(1)}% من الإجمالي'
            : null,
      ),
      _StatCardData(
        title: AppStrings.activeDrivers,
        value: '${state.stats.activeDrivers}/${state.stats.totalDrivers}',
        icon: Icons.local_shipping_outlined,
        iconColor: AppColors.info,
      ),
      _StatCardData(
        title: AppStrings.totalCustomers,
        value: Formatters.number(state.stats.totalCustomers),
        icon: Icons.people_outline,
        iconColor: AppColors.warning,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppConstants.spacingMd,
        mainAxisSpacing: AppConstants.spacingMd,
        mainAxisExtent: 185,
      ),
      itemCount: statsCards.length,
      itemBuilder: (context, index) {
        final card = statsCards[index];
        return StatCard(
          title: card.title,
          value: card.value,
          icon: card.icon,
          iconColor: card.iconColor,
          percentChange: card.percentChange,
          subtitle: card.subtitle,
        );
      },
    );
  }

  Widget _buildChartsSection(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return SizedBox(
        height: 350,
        child: Row(
          children: [
            // Revenue chart
            Expanded(
              flex: 2,
              child: RevenueChart(data: state.revenueData),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            // Orders distribution
            Expanded(
              child: OrdersDistributionChart(
                distribution: state.ordersDistribution,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile/Tablet layout
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: RevenueChart(data: state.revenueData),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        SizedBox(
          height: 300,
          child: OrdersDistributionChart(
            distribution: state.ordersDistribution,
          ),
        ),
      ],
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final double? percentChange;
  final String? subtitle;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.percentChange,
    this.subtitle,
  });
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final crossAxisCount = isDesktop ? 5 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        const SizedBox(height: AppConstants.spacingLg),

        // Stats grid skeleton
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppConstants.spacingMd,
            mainAxisSpacing: AppConstants.spacingMd,
            mainAxisExtent: 185,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => const StatCardSkeleton(),
        ),
        const SizedBox(height: AppConstants.spacingLg),

        // Chart skeleton
        SizedBox(
          height: 300,
          child: GlassCard(
            child: Container(),
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),

        // List skeleton
        const ListItemSkeleton(count: 5),
      ],
    );
  }
}
