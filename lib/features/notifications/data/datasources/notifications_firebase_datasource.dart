import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';

/// Firebase datasource for notifications
class NotificationsFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final String _adminId; // معرف الأدمن الحالي

  NotificationsFirebaseDataSource({
    required FirebaseFirestore firestore,
    required String adminId,
  })  : _firestore = firestore,
        _adminId = adminId;

  CollectionReference<Map<String, dynamic>> get _notificationsRef => _firestore
      .collection('admin_notifications')
      .doc(_adminId)
      .collection('notifications');

  /// Watch notifications stream with real-time updates
  Stream<List<NotificationEntity>> watchNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) {
    Query<Map<String, dynamic>> query =
        _notificationsRef.orderBy('createdAt', descending: true).limit(limit);

    if (unreadOnly) {
      query = query.where('isRead', isEqualTo: false);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NotificationEntity.fromMap(_processNotificationData(data));
      }).toList();
    });
  }

  /// Get notifications list
  Future<List<NotificationEntity>> getNotifications({
    int limit = 50,
    bool unreadOnly = false,
    String? lastDocId,
  }) async {
    Query<Map<String, dynamic>> query =
        _notificationsRef.orderBy('createdAt', descending: true);

    if (unreadOnly) {
      query = query.where('isRead', isEqualTo: false);
    }

    if (lastDocId != null) {
      final lastDoc = await _notificationsRef.doc(lastDocId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    query = query.limit(limit);

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return NotificationEntity.fromMap(_processNotificationData(data));
    }).toList();
  }

  /// Get unread count
  Stream<int> watchUnreadCount() {
    return _notificationsRef
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    final snapshot =
        await _notificationsRef.where('isRead', isEqualTo: false).get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _notificationsRef.doc(notificationId).delete();
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    final snapshot = await _notificationsRef.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Create notification (for testing or manual creation)
  Future<void> createNotification(NotificationEntity notification) async {
    final data = notification.toMap();
    data.remove('id');
    await _notificationsRef.add(data);
  }

  Map<String, dynamic> _processNotificationData(Map<String, dynamic> data) {
    // Convert Firestore Timestamp to ISO string
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }

    return data;
  }
}
