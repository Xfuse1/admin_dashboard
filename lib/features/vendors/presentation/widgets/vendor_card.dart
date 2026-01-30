import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/vendor_entity.dart';

/// Vendor card widget for the vendors list.
class VendorCard extends StatelessWidget {
  final VendorEntity vendor;
  final bool isSelected;
  final VoidCallback onTap;

  const VendorCard({
    super.key,
    required this.vendor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.border.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                // Logo
                _VendorLogo(
                  logoUrl: vendor.logoUrl,
                  category: vendor.category,
                ),
                const SizedBox(width: AppConstants.spacingMd),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    vendor.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (vendor.isVerified) ...[
                                  const SizedBox(width: AppConstants.spacingSm),
                                  Icon(
                                    Icons.verified,
                                    color: AppColors.info,
                                    size: 18,
                                  ),
                                ],
                                if (vendor.isFeatured) ...[
                                  const SizedBox(width: AppConstants.spacingSm),
                                  Icon(
                                    Icons.star,
                                    color: AppColors.warning,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          _StatusBadge(status: vendor.status),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Row(
                        children: [
                          _CategoryBadge(category: vendor.category),
                          const SizedBox(width: AppConstants.spacingSm),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              vendor.address.city,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      Row(
                        children: [
                          // Rating
                          Flexible(
                            child: _InfoChip(
                              icon: Icons.star,
                              iconColor: AppColors.warning,
                              label: vendor.rating.toStringAsFixed(1),
                              sublabel: '(${vendor.totalRatings})',
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingMd),
                          // Orders
                          Flexible(
                            child: _InfoChip(
                              icon: Icons.shopping_bag_outlined,
                              label: NumberFormat.compact()
                                  .format(vendor.totalOrders),
                              sublabel: 'طلب',
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingMd),
                          // Revenue
                          Flexible(
                            child: _InfoChip(
                              icon: Icons.attach_money,
                              iconColor: AppColors.success,
                              label: NumberFormat.compact()
                                  .format(vendor.totalRevenue),
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VendorLogo extends StatelessWidget {
  final String? logoUrl;
  final VendorCategory category;

  const _VendorLogo({
    this.logoUrl,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
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
        size: 32,
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

class _StatusBadge extends StatelessWidget {
  final VendorStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      VendorStatus.active => (AppColors.success, 'نشط'),
      VendorStatus.inactive => (AppColors.textTertiary, 'غير نشط'),
      VendorStatus.pending => (AppColors.warning, 'قيد المراجعة'),
      VendorStatus.suspended => (AppColors.error, 'موقوف'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
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
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final VendorCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            _getCategoryLabel(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
          ),
        ],
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

  String _getCategoryLabel() {
    return switch (category) {
      VendorCategory.restaurant => 'مطعم',
      VendorCategory.grocery => 'بقالة',
      VendorCategory.pharmacy => 'صيدلية',
      VendorCategory.electronics => 'إلكترونيات',
      VendorCategory.fashion => 'أزياء',
      VendorCategory.other => 'أخرى',
    };
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? sublabel;

  const _InfoChip({
    required this.icon,
    this.iconColor,
    required this.label,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (sublabel != null) ...[
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              sublabel!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
