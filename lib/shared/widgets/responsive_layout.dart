import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Responsive breakpoint types.
enum DeviceType { mobile, tablet, desktop }

/// Responsive layout builder that adapts UI based on screen size.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  /// Gets the current device type based on screen width.
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppConstants.tabletBreakpoint) {
      return DeviceType.mobile;
    } else if (width < AppConstants.desktopBreakpoint) {
      return DeviceType.tablet;
    }
    return DeviceType.desktop;
  }

  /// Checks if current device is mobile.
  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  /// Checks if current device is tablet.
  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  /// Checks if current device is desktop.
  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.desktopBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
          return tablet ?? desktop;
        }
        return mobile;
      },
    );
  }
}

/// Extension for responsive padding and sizing.
extension ResponsiveExtension on BuildContext {
  /// Gets responsive horizontal padding.
  double get horizontalPadding {
    final deviceType = ResponsiveLayout.getDeviceType(this);
    return switch (deviceType) {
      DeviceType.mobile => AppConstants.spacingMd,
      DeviceType.tablet => AppConstants.spacingLg,
      DeviceType.desktop => AppConstants.spacingXl,
    };
  }

  /// Gets responsive content max width.
  double get contentMaxWidth {
    final deviceType = ResponsiveLayout.getDeviceType(this);
    return switch (deviceType) {
      DeviceType.mobile => double.infinity,
      DeviceType.tablet => 720,
      DeviceType.desktop => 1200,
    };
  }
}
