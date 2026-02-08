import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

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
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
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
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(color: AppColors.glassBorder),
                    ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
    return Column(
      children: [
        _buildSection(
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
        ),
        // Location warning
        if (!store.hasLocation) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_off,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'لم يتم إرسال الموقع الجغرافي - قد يؤثر على التوصيل وعرض المتجر على الخريطة',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDriverDetails(
    BuildContext context,
    DriverOnboardingEntity driver,
  ) {
    return Column(
      children: [
        _buildSection(
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
        ),
        const SizedBox(height: 20),
        _buildSection(
          context,
          title: 'الوثائق والمستندات',
          children: [
            _buildDocumentSection(
              context,
              title: 'الصورة الشخصية',
              imageUrl: driver.photoUrl,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildDocumentSection(
              context,
              title: 'صورة الهوية',
              imageUrl: driver.idDocumentUrl,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildDocumentSection(
              context,
              title: 'رخصة القيادة',
              imageUrl: driver.licenseUrl,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildDocumentSection(
              context,
              title: 'استمارة المركبة',
              imageUrl: driver.vehicleRegistrationUrl,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildDocumentSection(
              context,
              title: 'تأمين المركبة',
              imageUrl: driver.vehicleInsuranceUrl,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildDocumentSection(
    BuildContext context, {
    required String title,
    String? imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 10),
          if (imageUrl != null && imageUrl.isNotEmpty)
            GestureDetector(
              onTap: () => _showFullScreenImage(context, imageUrl, title),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                            AppColors.primary.withValues(alpha: 0.5)),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: AppColors.error),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.glassBorder,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_outlined,
                        color: AppColors.textTertiary),
                    SizedBox(height: 4),
                    Text(
                      'لم يتم رفع المستند',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      barrierDismissible: true,
      barrierLabel: 'Close',
      transitionDuration: 300.ms,
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Photo View
              PhotoView(
                imageProvider: CachedNetworkImageProvider(imageUrl),
                backgroundDecoration:
                    const BoxDecoration(color: Colors.transparent),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.5,
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

              // Close Button
              Positioned(
                top: 40,
                right: 20,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ).animate().scale(delay: 200.ms, duration: 300.ms),
              ),

              // Title Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'يمكنك التكبير/التصغير لرؤية التفاصيل بوضوح',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 1.0, end: 0, delay: 100.ms),
              ),
            ],
          ),
        );
      },
    );
  }
}
