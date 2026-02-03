import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

/// Notifications state
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationsInitial extends NotificationsState {}

/// Loading state
class NotificationsLoading extends NotificationsState {}

/// Loaded state
class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool hasMore;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasMore];

  NotificationsLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? hasMore,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Error state
class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Action success state
class NotificationsActionSuccess extends NotificationsState {
  final String message;

  const NotificationsActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
