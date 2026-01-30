import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/driver_application_entity.dart';

/// Card widget for displaying driver application information.
class DriverApplicationCard extends StatelessWidget {
  final DriverApplicationEntity application;
  final VoidCallback? onTap;

  const DriverApplicationCard({
    super.key,
    required this.application,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              // Driver name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      application.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.loose,
                child: _buildStatusBadge(context),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingSm),
          const Divider(),
          const SizedBox(height: AppConstants.spacingSm),

          // Application details
          _buildInfoRow(
            context,
            Iconsax.call,
            'الهاتف',
            application.phone,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Iconsax.truck,
            'نوع المركبة',
            application.vehicleType.arabicName,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Iconsax.hashtag,
            'رقم اللوحة',
            application.vehiclePlate,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Iconsax.calendar,
            'تاريخ التقديم',
            DateFormat('dd/MM/yyyy').format(application.createdAt),
          ),

          // Show reviewed date if reviewed
          if (application.reviewedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Iconsax.calendar_tick,
              'تاريخ المراجعة',
              DateFormat('dd/MM/yyyy').format(application.reviewedAt!),
            ),
          ],

          // Show rejection reason if rejected
          if (application.status == ApplicationStatus.rejected &&
              application.rejectionReason != null) ...[
            const SizedBox(height: AppConstants.spacingSm),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.info_circle,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      application.rejectionReason!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
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
    final color = _getStatusColor(application.status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              application.status.arabicName,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    return switch (status) {
      ApplicationStatus.pending => AppColors.warning,
      ApplicationStatus.underReview => AppColors.info,
      ApplicationStatus.approved => AppColors.success,
      ApplicationStatus.rejected => AppColors.error,
    };
  }
}
