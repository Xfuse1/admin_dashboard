import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Statistics cards for fleet overview.
class FleetStatsCards extends StatelessWidget {
  final FleetStatsEntity stats;

  const FleetStatsCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'إجمالي المركبات',
              value: stats.totalVehicles.toString(),
              icon: Icons.directions_car,
              color: AppColors.primary,
              trend: null,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: _StatCard(
              title: 'متاحة',
              value: stats.availableVehicles.toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
              trend: _calculatePercentage(
                  stats.availableVehicles, stats.totalVehicles),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: _StatCard(
              title: 'في الصيانة',
              value: stats.maintenanceVehicles.toString(),
              icon: Icons.build,
              color: AppColors.warning,
              trend: _calculatePercentage(
                  stats.maintenanceVehicles, stats.totalVehicles),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: _StatCard(
              title: 'خارج الخدمة',
              value: stats.outOfServiceVehicles.toString(),
              icon: Icons.pause_circle,
              color: AppColors.error,
              trend: _calculatePercentage(
                  stats.outOfServiceVehicles, stats.totalVehicles),
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
  final String? trend;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Icon(icon, color: color, size: 28),
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
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                    ),
                    if (trend != null) ...[
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
                          trend!,
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
