import 'package:equatable/equatable.dart';

/// Notifications events
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications
class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
}

/// Watch notifications stream
class WatchNotifications extends NotificationsEvent {
  final bool unreadOnly;

  const WatchNotifications({this.unreadOnly = false});

  @override
  List<Object?> get props => [unreadOnly];
}

/// Mark as read
class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all as read
class MarkAllNotificationsAsRead extends NotificationsEvent {
  const MarkAllNotificationsAsRead();
}

/// Delete notification
class DeleteNotification extends NotificationsEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Clear all notifications
class ClearAllNotifications extends NotificationsEvent {
  const ClearAllNotifications();
}

/// Load more notifications
class LoadMoreNotifications extends NotificationsEvent {
  const LoadMoreNotifications();
}
