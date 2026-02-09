import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/product_entity.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../domain/entities/vendor_entity.dart';
import '../bloc/vendors_bloc.dart';
import '../bloc/vendors_event.dart';
import '../bloc/vendors_state.dart';

/// Vendor details side panel.
class VendorDetailsPanel extends StatelessWidget {
  final VendorEntity vendor;
  final VoidCallback onClose;

  const VendorDetailsPanel({
    super.key,
    required this.vendor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainInfo(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildStatusSection(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildContactInfo(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildAddressSection(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildStatisticsSection(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildProductsSection(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildOperatingHoursSection(context),
                if (vendor.tags.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingLg),
                  _buildTagsSection(context),
                ],
              ],
            ),
          ),
        ),
        _buildActions(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          _VendorAvatar(logoUrl: vendor.logoUrl, category: vendor.category),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vendor.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (vendor.isVerified) ...[
                      const SizedBox(width: AppConstants.spacingSm),
                      Icon(Icons.verified, color: AppColors.info, size: 18),
                    ],
                  ],
                ),
                Text(
                  _getCategoryLabel(
                    vendor.category,
                    vendor.categoryLabel,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (vendor.ownerName != null &&
                    vendor.ownerName!.trim().isNotEmpty)
                  Text(
                    vendor.ownerName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات المتجر',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        if (vendor.description != null && vendor.description!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Text(
              vendor.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        const SizedBox(height: AppConstants.spacingMd),
        _InfoCard(
          icon: Icons.star,
          iconColor: AppColors.warning,
          label: 'التقييم',
          value: vendor.rating.toStringAsFixed(1),
          sublabel: '(${vendor.totalRatings} تقييم)',
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final statusColor = switch (vendor.status) {
      VendorStatus.active => AppColors.success,
      VendorStatus.inactive => AppColors.textTertiary,
      VendorStatus.pending => AppColors.warning,
      VendorStatus.suspended => AppColors.error,
    };

    final statusLabel = switch (vendor.status) {
      VendorStatus.active => 'نشط',
      VendorStatus.inactive => 'غير نشط',
      VendorStatus.pending => 'قيد المراجعة',
      VendorStatus.suspended => 'موقوف',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحالة',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<VendorStatus>(
                icon: Icon(Icons.edit, size: 18, color: statusColor),
                tooltip: 'تغيير الحالة',
                onSelected: (newStatus) {
                  final isMissingLocation = vendor.address.latitude == null ||
                      vendor.address.longitude == null;

                  // Warn when activating a vendor without location
                  if (newStatus == VendorStatus.active && isMissingLocation) {
                    _showActivateWithoutLocationDialog(
                      context,
                      vendor,
                      newStatus,
                    );
                    return;
                  }

                  context.read<VendorsBloc>().add(
                        ToggleVendorStatusEvent(vendor.id, newStatus),
                      );
                },
                itemBuilder: (context) => VendorStatus.values
                    .where((s) => s != vendor.status)
                    .map((status) => PopupMenuItem(
                          value: status,
                          child: Text(_getStatusLabel(status)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: vendor.isFeatured ? Icons.star : Icons.star_border,
                label:
                    vendor.isFeatured ? 'إزالة من المميزين' : 'إضافة للمميزين',
                color: AppColors.warning,
                onTap: () {
                  context.read<VendorsBloc>().add(
                        ToggleFeaturedStatusEvent(
                            vendor.id, !vendor.isFeatured),
                      );
                },
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            if (!vendor.isVerified)
              Expanded(
                child: _ActionButton(
                  icon: Icons.verified,
                  label: 'تحقق',
                  color: AppColors.info,
                  onTap: () {
                    context.read<VendorsBloc>().add(
                          VerifyVendorEvent(vendor.id),
                        );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات التواصل',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _ContactRow(icon: Icons.phone, value: vendor.phone),
        if (vendor.email != null)
          _ContactRow(icon: Icons.email, value: vendor.email!),
        if (vendor.website != null)
          _ContactRow(icon: Icons.language, value: vendor.website!),
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العنوان',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Text(
                  vendor.address.fullAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        // Location warning if coordinates are missing
        if (vendor.address.latitude == null ||
            vendor.address.longitude == null) ...[
          const SizedBox(height: AppConstants.spacingSm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_off,
                  color: AppColors.error,
                  size: 16,
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Text(
                    'لم يتم إرسال الموقع الجغرافي',
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

  Widget _buildStatisticsSection(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: 'ج.م ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.shopping_bag,
                label: 'الطلبات',
                value: NumberFormat.compact().format(vendor.totalOrders),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: _StatCard(
                icon: Iconsax.wallet_3,
                label: 'الإيرادات',
                value: currencyFormatter.format(vendor.totalRevenue),
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOperatingHoursSection(BuildContext context) {
    if (vendor.operatingHours.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ساعات العمل',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Column(
            children: vendor.operatingHours.map((hours) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getDayLabel(hours.day),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      child: Text(
                        hours.isClosed
                            ? 'مغلق'
                            : '${hours.openTime} - ${hours.closeTime}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: hours.isClosed
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوسوم',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Wrap(
          spacing: AppConstants.spacingSm,
          runSpacing: AppConstants.spacingSm,
          children: vendor.tags
              .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // For narrow screens (< 360px), show icons only
          final showIconOnly = constraints.maxWidth < 360;

          return Row(
            children: [
              Expanded(
                child: showIconOnly
                    ? OutlinedButton(
                        onPressed: () => _showDeleteConfirmation(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Icon(Icons.delete_outline, size: 20),
                      )
                    : OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('حذف'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.5)),
                        ),
                      ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: showIconOnly
                    ? ElevatedButton(
                        onPressed: () {
                          // TODO: Implement edit
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Icon(Icons.edit, size: 20),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement edit
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('تعديل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المتجر'),
        content: Text(
          'هل أنت متأكد من حذف ${vendor.name}؟\nهذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<VendorsBloc>().add(DeleteVendorEvent(vendor.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(VendorCategory category, String? label) {
    final normalizedLabel = label?.trim();
    if (normalizedLabel != null && normalizedLabel.isNotEmpty) {
      return normalizedLabel;
    }
    return switch (category) {
      VendorCategory.restaurant => 'مطعم',
      VendorCategory.grocery => 'بقالة',
      VendorCategory.pharmacy => 'صيدلية',
      VendorCategory.electronics => 'إلكترونيات',
      VendorCategory.fashion => 'أزياء',
      VendorCategory.other => 'أخرى',
    };
  }

  String _getStatusLabel(VendorStatus status) {
    return switch (status) {
      VendorStatus.active => 'نشط',
      VendorStatus.inactive => 'غير نشط',
      VendorStatus.pending => 'قيد المراجعة',
      VendorStatus.suspended => 'موقوف',
    };
  }

  void _showActivateWithoutLocationDialog(
    BuildContext context,
    VendorEntity vendor,
    VendorStatus newStatus,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تنبيه: الموقع غير متوفر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'هذا المتجر لم يقم بإرسال الموقع الجغرافي. قد يؤثر ذلك على التوصيل وعرض المتجر على الخريطة.',
                      style:
                          Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'هل تريد تفعيل المتجر "${vendor.name}" بدون موقع جغرافي؟',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<VendorsBloc>().add(
                    ToggleVendorStatusEvent(vendor.id, newStatus),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('تفعيل رغم ذلك'),
          ),
        ],
      ),
    );
  }

  String _getDayLabel(DayOfWeek day) {
    return switch (day) {
      DayOfWeek.monday => 'الاثنين',
      DayOfWeek.tuesday => 'الثلاثاء',
      DayOfWeek.wednesday => 'الأربعاء',
      DayOfWeek.thursday => 'الخميس',
      DayOfWeek.friday => 'الجمعة',
      DayOfWeek.saturday => 'السبت',
      DayOfWeek.sunday => 'الأحد',
    };
  }

  Widget _buildProductsSection(BuildContext context) {
    return BlocBuilder<VendorsBloc, VendorsState>(
      builder: (context, state) {
        if (state is! VendorsLoaded) return const SizedBox.shrink();

        if (state.isProductsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingMd),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final products = state.vendorProducts;

        if (products == null || products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المنتجات (${products.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid: 1 column on small, 2 on medium
                final crossAxisCount = constraints.maxWidth > 300 ? 2 : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.8, // Adjust as needed
                    crossAxisSpacing: AppConstants.spacingSm,
                    mainAxisSpacing: AppConstants.spacingSm,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(product: product);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusMd),
              ),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image_not_supported,
                      color: AppColors.textTertiary),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${product.price} ج.م',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'بيع: ${product.ordersCount}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 10,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorAvatar extends StatelessWidget {
  final String? logoUrl;
  final VendorCategory category;

  const _VendorAvatar({this.logoUrl, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: logoUrl != null && logoUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: Image.network(
                logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        _getCategoryIcon(),
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  IconData _getCategoryIcon() {
    return switch (category) {
      VendorCategory.restaurant => Icons.restaurant,
      VendorCategory.grocery => Icons.local_grocery_store,
      VendorCategory.pharmacy => Icons.local_pharmacy,
      VendorCategory.electronics => Icons.devices,
      VendorCategory.fashion => Icons.checkroom,
      VendorCategory.other => Icons.store,
    };
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;
  final String? sublabel;

  const _InfoCard({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor ?? AppColors.textTertiary),
              const SizedBox(width: AppConstants.spacingXs),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (sublabel != null) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      sublabel!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingSm,
            vertical: AppConstants.spacingSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppConstants.spacingXs),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? AppColors.textTertiary),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
