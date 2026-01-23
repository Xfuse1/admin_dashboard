import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// Widget for displaying onboarding statistics cards.
class OnboardingStatsCards extends StatelessWidget {
  final OnboardingStats stats;

  const OnboardingStatsCards({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            context,
            icon: Iconsax.document,
            iconColor: Colors.blue,
            title: 'إجمالي الطلبات',
            value: stats.totalRequests.toString(),
          ),
          _buildStatCard(
            context,
            icon: Iconsax.clock,
            iconColor: Colors.orange,
            title: 'قيد الانتظار',
            value: stats.pendingRequests.toString(),
          ),
          _buildStatCard(
            context,
            icon: Iconsax.tick_circle,
            iconColor: AppColors.success,
            title: 'مقبولة',
            value: stats.approvedRequests.toString(),
          ),
          _buildStatCard(
            context,
            icon: Iconsax.close_circle,
            iconColor: AppColors.error,
            title: 'مرفوضة',
            value: stats.rejectedRequests.toString(),
          ),
          _buildStatCard(
            context,
            icon: Iconsax.shop,
            iconColor: Colors.purple,
            title: 'متاجر معلقة',
            value: stats.pendingStoreRequests.toString(),
          ),
          _buildStatCard(
            context,
            icon: Iconsax.car,
            iconColor: Colors.teal,
            title: 'سائقين معلقين',
            value: stats.pendingDriverRequests.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: 140,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
