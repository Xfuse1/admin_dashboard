import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/onboarding_entities.dart';

/// Bottom sheet for displaying request details.
class RequestDetailsSheet extends StatelessWidget {
  final OnboardingRequestEntity request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const RequestDetailsSheet({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isStore = request is StoreOnboardingEntity;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isStore
                            ? Colors.purple.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isStore ? Iconsax.shop : Iconsax.car,
                        color: isStore ? Colors.purple : Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            request.type.arabicName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(context),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSection(
                      context,
                      title: 'معلومات التواصل',
                      children: [
                        _buildInfoTile(
                          context,
                          icon: Iconsax.sms,
                          label: 'البريد الإلكتروني',
                          value: request.email,
                        ),
                        _buildInfoTile(
                          context,
                          icon: Iconsax.call,
                          label: 'رقم الهاتف',
                          value: request.phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (isStore) ...[
                      _buildStoreDetails(
                          context, request as StoreOnboardingEntity),
                    ] else ...[
                      _buildDriverDetails(
                          context, request as DriverOnboardingEntity),
                    ],
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: 'معلومات الطلب',
                      children: [
                        _buildInfoTile(
                          context,
                          icon: Iconsax.calendar,
                          label: 'تاريخ الطلب',
                          value: DateFormatter.date(request.createdAt),
                        ),
                        if (request.reviewedAt != null)
                          _buildInfoTile(
                            context,
                            icon: Iconsax.calendar_tick,
                            label: 'تاريخ المراجعة',
                            value: DateFormatter.date(request.reviewedAt!),
                          ),
                        if (request.rejectionReason != null)
                          _buildInfoTile(
                            context,
                            icon: Iconsax.danger,
                            label: 'سبب الرفض',
                            value: request.rejectionReason!,
                            valueColor: AppColors.error,
                          ),
                        if (request.notes != null)
                          _buildInfoTile(
                            context,
                            icon: Iconsax.note,
                            label: 'ملاحظات',
                            value: request.notes!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              if (request.status == OnboardingStatus.pending ||
                  request.status == OnboardingStatus.underReview)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onReject,
                            icon: const Icon(Iconsax.close_circle),
                            label: const Text('رفض الطلب'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onApprove,
                            icon: const Icon(Iconsax.tick_circle),
                            label: const Text('قبول الطلب'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
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
    final color = switch (request.status) {
      OnboardingStatus.pending => Colors.orange,
      OnboardingStatus.approved => AppColors.success,
      OnboardingStatus.rejected => AppColors.error,
      OnboardingStatus.underReview => Colors.blue,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        request.status.arabicName,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: valueColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreDetails(
    BuildContext context,
    StoreOnboardingEntity store,
  ) {
    return _buildSection(
      context,
      title: 'معلومات المتجر',
      children: [
        _buildInfoTile(
          context,
          icon: Iconsax.building,
          label: 'اسم المتجر',
          value: store.storeName,
        ),
        _buildInfoTile(
          context,
          icon: Iconsax.category,
          label: 'نوع المتجر',
          value: store.storeType,
        ),
        _buildInfoTile(
          context,
          icon: Iconsax.location,
          label: 'العنوان',
          value: store.address,
        ),
        _buildInfoTile(
          context,
          icon: Iconsax.user,
          label: 'اسم المالك',
          value: store.ownerName,
        ),
        _buildInfoTile(
          context,
          icon: Iconsax.card,
          label: 'رقم الهوية',
          value: store.ownerIdNumber,
        ),
        _buildInfoTile(
          context,
          icon: Iconsax.document,
          label: 'السجل التجاري',
          value: store.commercialRegister,
        ),
      ],
    );
  }

  Widget _buildDriverDetails(
    BuildContext context,
    DriverOnboardingEntity driver,
  ) {
    return _buildSection(
      context,
      title: 'معلومات السائق',
      children: [
        _buildInfoTile(
          context,
          icon: Iconsax.card,
          label: 'رقم الهوية',
          value: driver.idNumber,
        ),
        _buildInfoTile(
          context,
          icon: Iconsax.document,
          label: 'رقم الرخصة',
          value: driver.licenseNumber,
        ),
        _buildInfoTile(
          context,
          icon: Iconsax.calendar,
          label: 'تاريخ انتهاء الرخصة',
          value: DateFormatter.date(driver.licenseExpiryDate),
        ),
        _buildInfoTile(
          context,
          icon: Iconsax.car,
          label: 'نوع المركبة',
          value: driver.vehicleType,
        ),
        _buildInfoTile(
          context,
          icon: Iconsax.tag,
          label: 'رقم اللوحة',
          value: driver.vehiclePlate,
        ),
      ],
    );
  }
}
