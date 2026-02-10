import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/rejection_request_entities.dart';

/// Card widget for displaying rejection request summary (Mobile view).
class RejectionRequestCard extends StatelessWidget {
  final RejectionRequestEntity request;
  final VoidCallback? onTap;

  const RejectionRequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Driver name, Status
          Row(
            children: [
              // Driver name
              Expanded(
                child: Row(
                  children: [
                    const Icon(Iconsax.user,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.driverName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              _buildStatusBadge(context),
            ],
          ),

          const SizedBox(height: AppConstants.spacingSm),

          // Order ID
          Row(
            children: [
              const Icon(Iconsax.receipt_item,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'طلب #${request.orderId.substring(0, 8)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingSm),

          // Reason
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.message_text,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.reason,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingSm),

          // Wait time and SLA indicator
          Row(
            children: [
              const Icon(Iconsax.timer_1,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Flexible(child: _buildWaitTimeChip(context)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  Formatters.formatRelativeTime(request.requestedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),

          // Admin comment (if exists)
          if (request.adminComment != null) ...[
            const SizedBox(height: AppConstants.spacingSm),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.message_edit,
                      size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تعليق الإدارة:',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.adminComment!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (request.adminDecision) {
      case 'pending':
        color = Colors.orange;
        label = 'قيد الانتظار';
        icon = Iconsax.timer_1;
        break;
      case 'approved':
        color = Colors.green;
        label = 'تم القبول';
        icon = Iconsax.tick_circle;
        break;
      case 'rejected':
        color = Colors.red;
        label = 'تم الرفض';
        icon = Iconsax.close_circle;
        break;
      default:
        color = Colors.grey;
        label = 'غير معروف';
        icon = Iconsax.info_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitTimeChip(BuildContext context) {
    final minutes = request.waitTimeMinutes;
    final color = _getSLAColor(request.slaStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        Formatters.formatDuration(minutes),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getSLAColor(String slaStatus) {
    switch (slaStatus) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
