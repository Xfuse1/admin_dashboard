import 'package:flutter/material.dart';

/// Application color palette following the design system.
///
/// Uses modern Glassmorphism design with Indigo/Purple gradients.
abstract final class AppColors {
  // ============================================
  // 🎨 PRIMARY COLORS
  // ============================================

  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF7C3AED);

  /// Primary gradient used for buttons, cards, and highlights.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  /// Subtle gradient for backgrounds.
  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  // ============================================
  // 🪟 GLASSMORPHISM COLORS
  // ============================================

  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBackground = Color(0x0DFFFFFF);

  /// Creates a glass effect decoration.
  static BoxDecoration glassDecoration({
    double borderRadius = 24,
    double blur = 10,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: glassBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ],
    );
  }

  // ============================================
  // ✅ STATUS COLORS
  // ============================================

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successBackground = Color(0x1A10B981);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningBackground = Color(0x1AF59E0B);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorBackground = Color(0x1AEF4444);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoBackground = Color(0x1A3B82F6);

  // ============================================
  // 🌑 DARK MODE COLORS (DEFAULT)
  // ============================================

  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFF334155);
  static const Color surfaceLighter = Color(0xFF475569);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // ============================================
  // ☀️ LIGHT MODE COLORS
  // ============================================

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLightMode = Color(0xFFFFFFFF);
  static const Color surfaceLightModeAlt = Color(0xFFF1F5F9);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // ============================================
  // 📊 ORDER STATUS COLORS
  // ============================================

  static const Color orderNew = Color(0xFF3B82F6);
  static const Color orderPreparing = Color(0xFFF59E0B);
  static const Color orderReady = Color(0xFF8B5CF6);
  static const Color orderOnTheWay = Color(0xFF06B6D4);
  static const Color orderDelivered = Color(0xFF10B981);
  static const Color orderCancelled = Color(0xFFEF4444);

  // ============================================
  // 🎯 UTILITY COLORS
  // ============================================

  static const Color divider = Color(0xFF334155);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color overlay = Color(0x80000000);
  static const Color shimmerBase = Color(0xFF1E293B);
  static const Color shimmerHighlight = Color(0xFF334155);

  // ============================================
  // 🔲 ADDITIONAL UI COLORS
  // ============================================

  /// Border color for cards and inputs
  static const Color border = Color(0xFF334155);
  static const Color borderLight = Color(0xFFE2E8F0);

  /// Muted text color
  static const Color textMuted = Color(0xFF64748B);

  /// Glass morphism colors
  static const Color glassLight = Color(0x0DFFFFFF);
  static const Color glassMedium = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x26FFFFFF);
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);

  /// Skeleton loading colors
  static const Color skeleton = Color(0xFF1E293B);
  static const Color skeletonHighlight = Color(0xFF334155);
}
