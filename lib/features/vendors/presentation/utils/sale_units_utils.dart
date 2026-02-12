import 'package:flutter/material.dart';
import '../../domain/entities/vendor_entity.dart';

/// Utility class for sale units helpers.
class SaleUnitsUtils {
  SaleUnitsUtils._();

  /// Get Arabic label for a sale unit type.
  static String getSaleUnitArabicLabel(SaleUnitType unit) {
    switch (unit) {
      case SaleUnitType.kilogram:
        return 'كيلو';
      case SaleUnitType.gram:
        return 'جرام';
      case SaleUnitType.piece:
        return 'قطعة';
      case SaleUnitType.custom:
        return 'مخصص';
    }
  }

  /// Get icon for a sale unit type.
  static IconData getSaleUnitIcon(SaleUnitType unit) {
    switch (unit) {
      case SaleUnitType.kilogram:
        return Icons.scale;
      case SaleUnitType.gram:
        return Icons.monitor_weight_outlined;
      case SaleUnitType.piece:
        return Icons.shopping_bag_outlined;
      case SaleUnitType.custom:
        return Icons.edit_outlined;
    }
  }

  /// Get all standard sale units (excluding custom).
  static List<SaleUnitType> getStandardUnits() {
    return [
      SaleUnitType.kilogram,
      SaleUnitType.gram,
      SaleUnitType.piece,
    ];
  }

  /// Get default sale units for new vendors.
  static List<SaleUnitType> getDefaultSaleUnits() {
    return [SaleUnitType.piece];
  }

  /// Format sale units list as comma-separated string.
  static String formatSaleUnits(
    List<SaleUnitType> units,
    List<String> customUnits,
  ) {
    final labels = <String>[];
    for (final unit in units) {
      if (unit == SaleUnitType.custom) {
        labels.addAll(customUnits);
      } else {
        labels.add(getSaleUnitArabicLabel(unit));
      }
    }
    return labels.isEmpty ? 'غير محدد' : labels.join('، ');
  }
}
