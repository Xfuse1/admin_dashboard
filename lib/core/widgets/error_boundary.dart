import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// Error boundary widget that catches and displays errors gracefully.
///
/// Wraps child widgets and displays a user-friendly error screen
/// when an error occurs, instead of crashing the app.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;
  final void Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    // Override Flutter's error widget builder
    ErrorWidget.builder = _buildErrorWidget;
  }

  Widget _buildErrorWidget(FlutterErrorDetails details) {
    // Log the error
    logger.error('Flutter Error', details.exception, details.stack);

    // Call custom error handler if provided
    widget.onError?.call(details);

    // Use custom error builder or default
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(details);
    }

    return _DefaultErrorWidget(details: details);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget(_error!);
    }
    return widget.child;
  }
}

/// Default error widget shown when an error occurs.
class _DefaultErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const _DefaultErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppConstants.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Error Title
              Text(
                'حدث خطأ غير متوقع',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSm),

              // Error Message
              Text(
                'نعتذر عن هذا الخطأ. يرجى إعادة تحميل الصفحة أو المحاولة لاحقاً.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Retry Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Try to rebuild the widget tree
                      if (context.mounted) {
                        (context as Element).markNeedsBuild();
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              // Error details in debug mode
              if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                const SizedBox(height: AppConstants.spacingXl),
                ExpansionTile(
                  title: Text(
                    'تفاصيل الخطأ (للمطورين)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: SelectableText(
                        '${details.exception}\n\n${details.stack}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Error screen for full-page errors.
class ErrorScreen extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const ErrorScreen({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(AppConstants.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Text(
                title ?? 'حدث خطأ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                message ?? 'يرجى المحاولة مرة أخرى',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onGoHome != null) ...[
                    OutlinedButton(
                      onPressed: onGoHome,
                      child: const Text('الصفحة الرئيسية'),
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                  ],
                  if (onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
