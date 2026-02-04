import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/account_entities.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';

/// Drivers statistics page showing comprehensive rejection stats.
class DriversStatsPage extends StatelessWidget {
  const DriversStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<AccountsBloc, AccountsState>(
                  builder: (context, state) {
                    if (state is AccountsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AccountsError) {
                      return Center(
                        child: Text('حدث خطأ: ${state.message}'),
                      );
                    }

                    if (state is AccountsLoaded) {
                      final drivers = state.drivers;
                      if (drivers.isEmpty) {
                        return const Center(
                            child: Text('لا يوجد سائقين معتمدين'));
                      }

                      return _buildStatsContent(context, drivers);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Iconsax.chart_1,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إحصائيات السائقين',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              Text(
                'إحصائيات شاملة عن الطلبات والرفضات',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    List<DriverEntity> drivers,
  ) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildOverviewCards(drivers),
          const SizedBox(height: 24),
          isDesktop
              ? _buildDesktopTable(context, drivers)
              : _buildMobileList(context, drivers),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(List<DriverEntity> drivers) {
    final totalDrivers = drivers.length;
    final onlineDrivers = drivers.where((d) => d.isOnline).length;
    final totalRejections =
        drivers.fold<int>(0, (sum, d) => sum + d.rejectionsCounter);
    final driversWithRejections =
        drivers.where((d) => d.rejectionsCounter > 0).length;

    // Calculate overall rejection rate
    final totalDeliveries =
        drivers.fold<int>(0, (sum, d) => sum + d.totalDeliveries);
    final totalOrders = totalDeliveries + totalRejections;
    final overallRejectionRate = totalOrders > 0
        ? (totalRejections / totalOrders * 100).toStringAsFixed(1)
        : '0.0';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1000;
        final cardWidth =
            isCompact ? double.infinity : (constraints.maxWidth - 64) / 5;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _OverviewCard(
                icon: Iconsax.user,
                label: 'إجمالي السائقين',
                value: '$totalDrivers',
                color: AppColors.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _OverviewCard(
                icon: Iconsax.status,
                label: 'متصلين حالياً',
                value: '$onlineDrivers',
                color: AppColors.success,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _OverviewCard(
                icon: Iconsax.close_circle,
                label: 'إجمالي الرفضات',
                value: '$totalRejections',
                color: AppColors.error,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _OverviewCard(
                icon: Iconsax.percentage_circle,
                label: 'معدل الرفض العام',
                value: '$overallRejectionRate%',
                color: double.parse(overallRejectionRate) > 10
                    ? AppColors.error
                    : AppColors.warning,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _OverviewCard(
                icon: Iconsax.info_circle,
                label: 'سائقين بهم رفضات',
                value: '$driversWithRejections',
                color: AppColors.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<DriverEntity> drivers,
  ) {
    // Sort by rejections count descending
    final sortedDrivers = List<DriverEntity>.from(drivers)
      ..sort((a, b) => b.rejectionsCounter.compareTo(a.rejectionsCounter));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.05),
          ),
          columns: const [
            DataColumn(label: Text('السائق')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('إجمالي التوصيلات')),
            DataColumn(label: Text('الطلبات الحالية')),
            DataColumn(label: Text('عدد الرفضات')),
            DataColumn(label: Text('نسبة الرفض')),
            DataColumn(label: Text('التقييم')),
          ],
          rows: sortedDrivers.map((driver) {
            final name = driver.name;
            final isOnline = driver.isOnline;
            final totalDeliveries = driver.totalDeliveries;
            final currentOrders = driver.currentOrdersCount;
            final rejections = driver.rejectionsCounter;
            final rating = driver.rating;

            // Calculate rejection rate: rejections / (total deliveries + rejections)
            final totalOrders = totalDeliveries + rejections;
            final rejectionRate = totalOrders > 0
                ? (rejections / totalOrders * 100).toStringAsFixed(1)
                : '0.0';

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          name.isNotEmpty ? name[0] : '؟',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(name),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isOnline ? 'متصل' : 'غير متصل',
                      style: TextStyle(
                        color: isOnline
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text('$totalDeliveries')),
                DataCell(Text('$currentOrders')),
                DataCell(
                  Text(
                    '$rejections',
                    style: TextStyle(
                      color: rejections > 0
                          ? AppColors.error
                          : AppColors.textPrimary,
                      fontWeight: rejections > 0 ? FontWeight.bold : null,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '$rejectionRate%',
                    style: TextStyle(
                      color: double.parse(rejectionRate) > 10
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1)),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    List<DriverEntity> drivers,
  ) {
    final sortedDrivers = List<DriverEntity>.from(drivers)
      ..sort((a, b) => b.rejectionsCounter.compareTo(a.rejectionsCounter));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDrivers.length,
      itemBuilder: (context, index) {
        final driver = sortedDrivers[index];
        final name = driver.name;
        final isOnline = driver.isOnline;
        final totalDeliveries = driver.totalDeliveries;
        final rejections = driver.rejectionsCounter;
        final rating = driver.rating;

        // Calculate rejection rate: rejections / (total deliveries + rejections)
        final totalOrders = totalDeliveries + rejections;
        final rejectionRate = totalOrders > 0
            ? (rejections / totalOrders * 100).toStringAsFixed(1)
            : '0.0';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        name.isNotEmpty ? name[0] : '؟',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOnline ? 'متصل' : 'غير متصل',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _MobileStatItem(
                        label: 'التوصيلات',
                        value: '$totalDeliveries',
                        icon: Iconsax.truck,
                      ),
                    ),
                    Expanded(
                      child: _MobileStatItem(
                        label: 'الرفضات',
                        value: '$rejections',
                        icon: Iconsax.close_circle,
                        color: rejections > 0 ? AppColors.error : null,
                      ),
                    ),
                    Expanded(
                      child: _MobileStatItem(
                        label: 'نسبة الرفض',
                        value: '$rejectionRate%',
                        icon: Iconsax.chart_1,
                        color: double.parse(rejectionRate) > 10
                            ? AppColors.error
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _MobileStatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? AppColors.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
