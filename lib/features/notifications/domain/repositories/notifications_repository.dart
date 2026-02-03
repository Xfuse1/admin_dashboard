import '../entities/notification_entity.dart';

/// Notifications repository abstract class
abstract class NotificationsRepository {
  /// Watch notifications stream
  Stream<List<NotificationEntity>> watchNotifications({
    int limit = 50,
    bool unreadOnly = false,
  });

  /// Get notifications list
  Future<List<NotificationEntity>> getNotifications({
    int limit = 50,
    bool unreadOnly = false,
    String? lastDocId,
  });

  /// Watch unread count
  Stream<int> watchUnreadCount();

  /// Mark as read
  Future<void> markAsRead(String notificationId);

  /// Mark all as read
  Future<void> markAllAsRead();

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Clear all
  Future<void> clearAllNotifications();
}
