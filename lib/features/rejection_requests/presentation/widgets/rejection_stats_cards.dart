import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/rejection_request_entities.dart';

/// Statistics cards for rejection requests overview.
class RejectionStatsCards extends StatelessWidget {
  final int totalRequests;
  final int pendingCount;
  final RejectionStats? stats;

  const RejectionStatsCards({
    super.key,
    required this.totalRequests,
    required this.pendingCount,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          final isTablet = constraints.maxWidth > 600;

          final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 2);

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppConstants.spacingMd,
            mainAxisSpacing: AppConstants.spacingMd,
            childAspectRatio: isDesktop ? 1.8 : 1.5,
            children: [
              _buildStatCard(
                context,
                title: 'قيد الانتظار',
                value: '$pendingCount',
                icon: Iconsax.timer_1,
                color: Colors.orange,
              ),
              _buildStatCard(
                context,
                title: 'تم القبول',
                value: '${stats?.approvedRequests ?? 0}',
                icon: Iconsax.tick_circle,
                color: Colors.green,
              ),
              _buildStatCard(
                context,
                title: 'تم الرفض',
                value: '${stats?.rejectedRequests ?? 0}',
                icon: Iconsax.close_circle,
                color: Colors.red,
              ),
              _buildStatCard(
                context,
                title: 'متوسط الاستجابة',
                value: stats != null
                    ? '${stats!.averageResponseTimeMinutes.toStringAsFixed(1)} دقيقة'
                    : '-',
                icon: Iconsax.chart,
                color: AppColors.primary,
                isCompact: true,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isCompact = false,
  }) {
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: isCompact ? 16 : null,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
