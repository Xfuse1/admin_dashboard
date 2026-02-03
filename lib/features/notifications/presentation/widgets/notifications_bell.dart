import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

/// Notifications bell icon with dropdown
class NotificationsBell extends StatefulWidget {
  const NotificationsBell({super.key});

  @override
  State<NotificationsBell> createState() => _NotificationsBellState();
}

class _NotificationsBellState extends State<NotificationsBell> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;

    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final unreadCount =
            state is NotificationsLoaded ? state.unreadCount : 0;

        return OverlayPortal(
          controller: _overlayController,
          overlayChildBuilder: (context) => _buildOverlay(context, isMobile),
          child: CompositedTransformTarget(
            link: _layerLink,
            child: _buildBellIcon(unreadCount, isMobile),
          ),
        );
      },
    );
  }

  Widget _buildBellIcon(int unreadCount, bool isMobile) {
    return IconButton(
      onPressed: () {
        if (_overlayController.isShowing) {
          _overlayController.hide();
        } else {
          _overlayController.show();
        }
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Iconsax.notification,
            color: AppColors.textSecondary,
            size: isMobile ? 22 : 24,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: EdgeInsets.all(unreadCount > 9 ? 3 : 4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      tooltip: 'الإشعارات',
    );
  }

  Widget _buildOverlay(BuildContext context, bool isMobile) {
    return GestureDetector(
      onTap: () => _overlayController.hide(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // Backdrop
          Container(color: Colors.black.withValues(alpha: 0.3)),

          // Dropdown
          Positioned(
            top: isMobile ? 56 : null,
            right: isMobile ? 8 : null,
            left: isMobile ? 8 : null,
            child: isMobile
                ? Material(
                    elevation: 16,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    color: AppColors.surface,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.75,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.2),
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: _buildNotificationsList(context, isMobile),
                    ),
                  )
                : CompositedTransformFollower(
                    link: _layerLink,
                    targetAnchor: Alignment.bottomRight,
                    followerAnchor: Alignment.topRight,
                    offset: const Offset(0, 8),
                    child: Material(
                      elevation: 16,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLg),
                      color: AppColors.surface,
                      child: Container(
                        width: 420,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.2),
                          ),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusLg),
                        ),
                        child: _buildNotificationsList(context, isMobile),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, bool isMobile) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        if (state is NotificationsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingXl),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is NotificationsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingXl),
              child: Text(
                'حدث خطأ في تحميل الإشعارات',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            ),
          );
        }

        if (state is NotificationsLoaded) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(context, state, isMobile),

              const Divider(height: 1),

              // Notifications list
              if (state.notifications.isEmpty)
                _buildEmptyState(context)
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingSm,
                    ),
                    itemCount: state.notifications.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.1),
                    ),
                    itemBuilder: (context, index) {
                      final notification = state.notifications[index];
                      return _NotificationItem(
                        notification: notification,
                        onTap: () {
                          _overlayController.hide();
                          _handleNotificationTap(context, notification);
                        },
                        onDelete: () {
                          context
                              .read<NotificationsBloc>()
                              .add(DeleteNotification(notification.id));
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NotificationsLoaded state,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isMobile ? AppConstants.spacingSm : AppConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'الإشعارات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          if (state.unreadCount > 0) ...[
            const SizedBox(width: AppConstants.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${state.unreadCount} جديد',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
          const Spacer(),
          if (state.notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () {
                context
                    .read<NotificationsBloc>()
                    .add(const MarkAllNotificationsAsRead());
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: 6,
                ),
              ),
              child: Text(
                'تعليم الكل كمقروء',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
          IconButton(
            onPressed: () => _overlayController.hide(),
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXl * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.notification_bing,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'لا توجد إشعارات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'سيتم عرض جميع الإشعارات هنا',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationEntity notification,
  ) {
    // Mark as read
    if (!notification.isRead) {
      context
          .read<NotificationsBloc>()
          .add(MarkNotificationAsRead(notification.id));
    }

    // Navigate to related page
    if (notification.actionUrl != null) {
      context.go(notification.actionUrl!);
    }
  }
}

/// Individual notification item
class _NotificationItem extends StatefulWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile =
        ResponsiveLayout.getDeviceType(context) == DeviceType.mobile;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: AppColors.primary.withValues(alpha: 0.03),
        child: Container(
          padding: EdgeInsets.all(
            isMobile ? AppConstants.spacingSm : AppConstants.spacingMd,
          ),
          decoration: BoxDecoration(
            color: widget.notification.isRead
                ? Colors.transparent
                : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: widget.notification.isRead
                ? null
                : BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              _buildIcon(),
              SizedBox(width: isMobile ? 10 : 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.notification.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: widget.notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: isMobile ? 13 : 14,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!widget.notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.notification.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: isMobile ? 12 : 13,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(widget.notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: isMobile ? 10 : 11,
                          ),
                    ),
                  ],
                ),
              ),

              // Delete button (show on hover or mobile)
              if (_isHovered || isMobile)
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (widget.notification.type) {
      case NotificationType.rejectionRequest:
        icon = Iconsax.warning_2;
        color = AppColors.warning;
        break;
      case NotificationType.orderNew:
        icon = Iconsax.shopping_bag;
        color = AppColors.success;
        break;
      case NotificationType.vendorPending:
        icon = Iconsax.shop;
        color = AppColors.info;
        break;
      case NotificationType.driverRegistration:
        icon = Iconsax.driver;
        color = AppColors.primary;
        break;
      case NotificationType.system:
        icon = Iconsax.info_circle;
        color = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTime(DateTime dateTime) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    return timeago.format(dateTime, locale: 'ar');
  }
}
