import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_firebase_datasource.dart';

/// Implementation of NotificationsRepository
class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsFirebaseDataSource _dataSource;

  NotificationsRepositoryImpl(this._dataSource);

  @override
  Stream<List<NotificationEntity>> watchNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) {
    return _dataSource.watchNotifications(
      limit: limit,
      unreadOnly: unreadOnly,
    );
  }

  @override
  Future<List<NotificationEntity>> getNotifications({
    int limit = 50,
    bool unreadOnly = false,
    String? lastDocId,
  }) {
    return _dataSource.getNotifications(
      limit: limit,
      unreadOnly: unreadOnly,
      lastDocId: lastDocId,
    );
  }

  @override
  Stream<int> watchUnreadCount() {
    return _dataSource.watchUnreadCount();
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _dataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() {
    return _dataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String notificationId) {
    return _dataSource.deleteNotification(notificationId);
  }

  @override
  Future<void> clearAllNotifications() {
    return _dataSource.clearAllNotifications();
  }
}
