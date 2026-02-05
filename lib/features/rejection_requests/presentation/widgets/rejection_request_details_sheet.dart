import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/rejection_request_entities.dart';

/// Details sheet for rejection request (Desktop side panel).
class RejectionRequestDetailsSheet extends StatelessWidget {
  final RejectionRequestEntity request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onClose;
  final ScrollController? scrollController;

  const RejectionRequestDetailsSheet({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
    this.onClose,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'تفاصيل طلب الرفض',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.close_square),
                onPressed: () {
                  if (onClose != null) {
                    onClose!();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingLg),

          // Status badge
          _buildStatusSection(context),

          const Divider(height: 32),

          // Driver info
          _buildSection(
            context,
            title: 'معلومات السائق',
            icon: Iconsax.user,
            children: [
              _buildInfoRow(context, 'الاسم', request.driverName),
              _buildInfoRow(context, 'ID', request.driverId),
            ],
          ),

          const Divider(height: 32),

          // Order info
          _buildSection(
            context,
            title: 'معلومات الطلب',
            icon: Iconsax.receipt_item,
            children: [
              _buildInfoRow(
                  context, 'رقم الطلب', '#${request.orderId.substring(0, 8)}'),
            ],
          ),

          const Divider(height: 32),

          // Request details
          _buildSection(
            context,
            title: 'تفاصيل الطلب',
            icon: Iconsax.message_text,
            children: [
              _buildInfoRow(context, 'سبب الرفض', ''),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Text(
                  request.reason,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                'تاريخ التقديم',
                Formatters.formatDateTime(request.requestedAt),
              ),
              _buildInfoRow(
                context,
                'وقت الانتظار',
                Formatters.formatDuration(request.waitTimeMinutes),
              ),
            ],
          ),

          // Admin decision
          if (request.decidedAt != null) ...[
            const Divider(height: 32),
            _buildSection(
              context,
              title: 'قرار الإدارة',
              icon: Iconsax.task_square,
              children: [
                _buildInfoRow(
                  context,
                  'تاريخ القرار',
                  Formatters.formatDateTime(request.decidedAt!),
                ),
                if (request.adminComment != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(context, 'التعليق', ''),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      request.adminComment!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
          ],

          // Action Buttons (Only if pending)
          if (request.adminDecision == 'pending' &&
              (onApprove != null || onReject != null)) ...[
            const Divider(height: 32),
            _buildActions(context),
            // Add extra padding at bottom to avoid overlapping with bottom sheets/safe area
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onApprove != null)
          ElevatedButton.icon(
            onPressed: onApprove,
            icon: const Icon(Iconsax.tick_circle),
            label: const Text('قبول الاعتذار'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
          ),
        if (onApprove != null && onReject != null) const SizedBox(height: 12),
        if (onReject != null)
          OutlinedButton.icon(
            onPressed: onReject,
            icon: const Icon(Iconsax.close_circle),
            label: const Text('رفض الاعتذار'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context) {
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
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الحالة',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMd),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
