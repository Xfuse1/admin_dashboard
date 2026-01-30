import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/driver_application_entity.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';

/// Driver application details sheet with status update capability.
class DriverApplicationDetailsSheet extends StatelessWidget {
  final DriverApplicationEntity application;
  final String reviewerId; // Admin ID who is reviewing

  const DriverApplicationDetailsSheet({
    super.key,
    required this.application,
    required this.reviewerId,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تفاصيل الطلب',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '#${application.id}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
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
              ),

              const Divider(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information
                      _buildSection(
                        context,
                        'المعلومات الشخصية',
                        Iconsax.user,
                        [
                          _buildInfoRow(context, 'الاسم', application.name),
                          _buildInfoRow(
                              context, 'البريد الإلكتروني', application.email),
                          _buildInfoRow(context, 'الهاتف', application.phone),
                          _buildInfoRow(
                              context, 'رقم الهوية', application.idNumber),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spacingMd),

                      // License Information
                      _buildSection(
                        context,
                        'معلومات الرخصة',
                        Iconsax.card,
                        [
                          _buildInfoRow(
                              context, 'رقم الرخصة', application.licenseNumber),
                          _buildInfoRow(
                            context,
                            'تاريخ انتهاء الرخصة',
                            DateFormat('dd/MM/yyyy')
                                .format(application.licenseExpiryDate),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spacingMd),

                      // Vehicle Information
                      _buildSection(
                        context,
                        'معلومات المركبة',
                        Iconsax.truck,
                        [
                          _buildInfoRow(context, 'نوع المركبة',
                              application.vehicleType.arabicName),
                          _buildInfoRow(
                              context, 'رقم اللوحة', application.vehiclePlate),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spacingMd),

                      // Documents
                      _buildDocumentsSection(context),

                      const SizedBox(height: AppConstants.spacingMd),

                      // Application Timeline
                      _buildTimelineSection(context),

                      const SizedBox(height: AppConstants.spacingLg),

                      // Actions (if pending or under review)
                      if (application.status.isPending)
                        _buildActionsSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    final documents = <Map<String, String?>>{
      {'name': 'الصورة الشخصية', 'url': application.photoUrl},
      {'name': 'صورة الهوية', 'url': application.idDocumentUrl},
      {'name': 'صورة الرخصة', 'url': application.licenseUrl},
      {'name': 'رخصة السيارة', 'url': application.vehicleRegistrationUrl},
      {'name': 'تأمين السيارة', 'url': application.vehicleInsuranceUrl},
    };

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.document, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'المستندات',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          ...documents.map((doc) {
            final hasDocument = doc['url'] != null && doc['url']!.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    hasDocument ? Iconsax.tick_circle : Iconsax.close_circle,
                    size: 16,
                    color: hasDocument ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doc['name']!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (hasDocument)
                    TextButton(
                      onPressed: () => _openDocument(doc['url']!),
                      child: const Text('عرض'),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.clock, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'سجل الطلب',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _buildTimelineItem(
            context,
            'تم التقديم',
            DateFormat('dd/MM/yyyy - HH:mm').format(application.createdAt),
            isCompleted: true,
          ),
          if (application.reviewedAt != null)
            _buildTimelineItem(
              context,
              'تمت المراجعة',
              DateFormat('dd/MM/yyyy - HH:mm').format(application.reviewedAt!),
              isCompleted: true,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String time, {
    bool isCompleted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isCompleted ? Iconsax.tick_circle : Iconsax.clock,
            size: 16,
            color: isCompleted ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      children: [
        // Approve button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showConfirmDialog(
              context,
              'قبول الطلب',
              'هل أنت متأكد من قبول هذا الطلب؟ سيتمكن السائق من الوصول إلى التطبيق.',
              ApplicationStatus.approved,
            ),
            icon: const Icon(Iconsax.tick_circle),
            label: const Text('قبول الطلب'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        // Reject button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showRejectDialog(context),
            icon: const Icon(Iconsax.close_circle, color: AppColors.error),
            label: const Text(
              'رفض الطلب',
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    ApplicationStatus newStatus,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              context.read<AccountsBloc>().add(
                    UpdateApplicationStatusEvent(
                      applicationId: application.id,
                      newStatus: newStatus,
                      reviewedBy: reviewerId,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == ApplicationStatus.approved
                  ? AppColors.success
                  : AppColors.error,
            ),
            child:
                Text(newStatus == ApplicationStatus.approved ? 'قبول' : 'رفض'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل أنت متأكد من رفض هذا الطلب؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض',
                border: OutlineInputBorder(),
                hintText: 'اكتب سبب رفض الطلب...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى كتابة سبب الرفض'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              context.read<AccountsBloc>().add(
                    UpdateApplicationStatusEvent(
                      applicationId: application.id,
                      newStatus: ApplicationStatus.rejected,
                      reviewedBy: reviewerId,
                      rejectionReason: reasonController.text.trim(),
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('رفض الطلب'),
          ),
        ],
      ),
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

  /// Open document URL in new tab
  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
