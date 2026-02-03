import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

/// Notifications BLoC
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;
  StreamSubscription<List<NotificationEntity>>? _notificationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;

  NotificationsBloc(this._repository) : super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<WatchNotifications>(_onWatchNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ClearAllNotifications>(_onClearAll);
    on<LoadMoreNotifications>(_onLoadMore);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      emit(NotificationsLoading());

      final notifications = await _repository.getNotifications(limit: 50);
      _notifications = notifications;

      emit(NotificationsLoaded(
        notifications: _notifications,
        unreadCount: _unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onWatchNotifications(
    WatchNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    await _notificationsSubscription?.cancel();
    await _unreadCountSubscription?.cancel();

    // Watch notifications
    _notificationsSubscription = _repository
        .watchNotifications(unreadOnly: event.unreadOnly)
        .listen((notifications) {
      _notifications = notifications;
      add(const LoadNotifications());
    });

    // Watch unread count
    _unreadCountSubscription = _repository.watchUnreadCount().listen((count) {
      _unreadCount = count;
      if (state is NotificationsLoaded) {
        emit((state as NotificationsLoaded).copyWith(unreadCount: count));
      }
    });
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.notificationId);
      emit(const NotificationsActionSuccess('تم تعليم الإشعار كمقروء'));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.markAllAsRead();
      emit(const NotificationsActionSuccess('تم تعليم جميع الإشعارات كمقروءة'));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.deleteNotification(event.notificationId);
      emit(const NotificationsActionSuccess('تم حذف الإشعار'));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onClearAll(
    ClearAllNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _repository.clearAllNotifications();
      emit(const NotificationsActionSuccess('تم مسح جميع الإشعارات'));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    if (!currentState.hasMore) return;

    try {
      final lastId = _notifications.isNotEmpty ? _notifications.last.id : null;
      final moreNotifications = await _repository.getNotifications(
        limit: 20,
        lastDocId: lastId,
      );

      if (moreNotifications.isEmpty) {
        emit(currentState.copyWith(hasMore: false));
        return;
      }

      _notifications = [..._notifications, ...moreNotifications];
      emit(currentState.copyWith(notifications: _notifications));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    return super.close();
  }
}
