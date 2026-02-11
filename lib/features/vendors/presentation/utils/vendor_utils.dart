import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/vendor_entity.dart';

/// Utility class for vendor-related UI helpers.
class VendorUtils {
  VendorUtils._();

  /// Get label for vendor status.
  static String getStatusLabel(VendorStatus status) {
    return switch (status) {
      VendorStatus.active => 'نشط',
      VendorStatus.inactive => 'غير نشط',
      VendorStatus.pending => 'قيد المراجعة',
      VendorStatus.suspended => 'موقوف',
    };
  }

  /// Get color for vendor status.
  static Color getStatusColor(VendorStatus status) {
    return switch (status) {
      VendorStatus.active => AppColors.success,
      VendorStatus.inactive => AppColors.textTertiary,
      VendorStatus.pending => AppColors.warning,
      VendorStatus.suspended => AppColors.error,
    };
  }

  /// Get label for vendor category.
  static String getCategoryLabel(VendorCategory category,
      [String? customLabel]) {
    if (customLabel != null && customLabel.isNotEmpty) {
      return customLabel;
    }

    return switch (category) {
      VendorCategory.food => 'أغذية',
      VendorCategory.grocery => 'بقالة',
      VendorCategory.health => 'صحة',
      VendorCategory.electronics => 'إلكترونيات',
      VendorCategory.clothes => 'ملابس',
      VendorCategory.furniture => 'أثاث',
      VendorCategory.other => 'أخرى',
    };
  }

  /// Get icon for vendor category.
  static IconData getCategoryIcon(VendorCategory category) {
    return switch (category) {
      VendorCategory.food => Icons.restaurant,
      VendorCategory.grocery => Icons.local_grocery_store,
      VendorCategory.health => Icons.local_hospital,
      VendorCategory.electronics => Icons.devices,
      VendorCategory.clothes => Icons.checkroom,
      VendorCategory.furniture => Icons.chair,
      VendorCategory.other => Icons.category,
    };
  }
}
