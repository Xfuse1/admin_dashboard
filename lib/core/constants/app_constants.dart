import 'package:flutter/material.dart';

/// Application-wide constant values.
///
/// Contains breakpoints, durations, sizes, and animation curves.
abstract final class AppConstants {
  // ============================================
  // 📱 BREAKPOINTS
  // ============================================

  /// Mobile breakpoint: < 600px
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint: 600px - 1023px
  static const double tabletBreakpoint = 600;

  /// Desktop breakpoint: ≥ 1024px
  static const double desktopBreakpoint = 1024;

  /// Large desktop breakpoint: ≥ 1440px
  static const double largeDesktopBreakpoint = 1440;

  // ============================================
  // 📐 LAYOUT SIZES
  // ============================================

  /// Sidebar width on desktop
  static const double sidebarWidth = 280;

  /// Collapsed sidebar width (icons only)
  static const double sidebarCollapsedWidth = 80;

  /// App bar height
  static const double appBarHeight = 64;

  /// Bottom navigation height
  static const double bottomNavHeight = 80;

  /// Card border radius
  static const double cardRadius = 24;

  /// Button border radius
  static const double buttonRadius = 12;

  /// Input field border radius
  static const double inputRadius = 12;

  // ============================================
  // ⏱️ ANIMATION DURATIONS
  // ============================================

  /// Fast animations (hover effects, micro-interactions)
  static const Duration fastAnimation = Duration(milliseconds: 150);

  /// Normal animations (most UI transitions)
  static const Duration normalAnimation = Duration(milliseconds: 300);

  /// Slow animations (page transitions, complex animations)
  static const Duration slowAnimation = Duration(milliseconds: 500);

  /// Page transition duration
  static const Duration pageTransition = Duration(milliseconds: 400);

  /// Debounce duration for search
  static const Duration searchDebounce = Duration(milliseconds: 500);

  /// Snackbar display duration
  static const Duration snackbarDuration = Duration(seconds: 4);

  // ============================================
  // 🎢 ANIMATION CURVES
  // ============================================

  /// Default animation curve (smooth ease out)
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Bounce animation curve
  static const Curve bounceCurve = Curves.elasticOut;

  /// Sharp animation curve
  static const Curve sharpCurve = Curves.easeOutExpo;

  /// Decelerate curve (for enter animations)
  static const Curve enterCurve = Curves.decelerate;

  /// Accelerate curve (for exit animations)
  static const Curve exitCurve = Curves.easeInCubic;

  // ============================================
  // 📏 SPACING
  // ============================================

  static const double spacingXxs = 4;
  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // ============================================
  // 🔢 PAGINATION
  // ============================================

  /// Default page size for lists
  static const int defaultPageSize = 20;

  /// Maximum page size
  static const int maxPageSize = 50;

  // ============================================
  // 🖼️ IMAGE SIZES
  // ============================================

  /// Avatar size (small)
  static const double avatarSm = 32;

  /// Avatar size (medium)
  static const double avatarMd = 48;

  /// Avatar size (large)
  static const double avatarLg = 64;

  /// Maximum image upload size in bytes (500KB)
  static const int maxImageSize = 500 * 1024;

  /// Image compression quality (0-100)
  static const int imageQuality = 80;

  // ============================================
  // 🔘 BORDER RADIUS
  // ============================================

  /// Extra small radius
  static const double radiusXs = 4;

  /// Small radius
  static const double radiusSm = 8;

  /// Medium radius
  static const double radiusMd = 12;

  /// Large radius
  static const double radiusLg = 16;

  /// Extra large radius
  static const double radiusXl = 24;

  /// Full radius (pill shape)
  static const double radiusFull = 999;

  // ============================================
  // ⏱️ ANIMATION DURATIONS (Alternative names)
  // ============================================

  /// Fast animation duration
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Medium animation duration
  static const Duration animationMedium = Duration(milliseconds: 300);

  /// Slow animation duration
  static const Duration animationSlow = Duration(milliseconds: 500);
}
