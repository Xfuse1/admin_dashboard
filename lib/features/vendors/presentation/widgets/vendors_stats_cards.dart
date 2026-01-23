import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Statistics cards for vendors overview.
class VendorsStatsCards extends StatelessWidget {
  final Map<String, dynamic> stats;

  const VendorsStatsCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final totalVendors = stats['totalVendors'] ?? 0;
    final activeVendors = stats['activeVendors'] ?? 0;
    final pendingVendors = stats['pendingVendors'] ?? 0;
    final totalRevenue = (stats['totalRevenue'] ?? 0.0) as double;
    final totalOrders = stats['totalOrders'] ?? 0;

    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'إجمالي المتاجر',
              value: totalVendors.toString(),
              icon: Icons.store,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: _StatCard(
              title: 'متاجر نشطة',
              value: activeVendors.toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
              subtitle: _calculatePercentage(activeVendors, totalVendors),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: _StatCard(
              title: 'بانتظار الموافقة',
              value: pendingVendors.toString(),
              icon: Icons.pending_actions,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: _StatCard(
              title: 'إجمالي الإيرادات',
              value: currencyFormatter.format(totalRevenue),
              icon: Icons.attach_money,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: _StatCard(
              title: 'إجمالي الطلبات',
              value: NumberFormat('#,###').format(totalOrders),
              icon: Icons.shopping_bag,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  String? _calculatePercentage(int value, int total) {
    if (total == 0) return null;
    final percentage = (value / total * 100).toStringAsFixed(0);
    return '$percentage%';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(width: AppConstants.spacingSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingXs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
