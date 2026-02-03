import 'package:equatable/equatable.dart';

/// Notification type enum
enum NotificationType {
  rejectionRequest, // طلب رفض جديد
  orderNew, // طلب جديد
  vendorPending, // متجر يحتاج موافقة
  driverRegistration, // سائق جديد يحتاج موافقة
  system, // إشعار نظام
}

/// Notification priority
enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

/// Notification entity
class NotificationEntity extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? actionUrl; // الرابط للانتقال إليه عند الضغط
  final Map<String, dynamic>? data; // بيانات إضافية
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId; // ID الطلب/المتجر/السائق المرتبط

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.actionUrl,
    this.data,
    this.priority = NotificationPriority.medium,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        actionUrl,
        data,
        priority,
        isRead,
        createdAt,
        relatedId,
      ];

  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? actionUrl,
    Map<String, dynamic>? data,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? createdAt,
    String? relatedId,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'actionUrl': actionUrl,
      'data': data,
      'priority': priority.name,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'relatedId': relatedId,
    };
  }

  factory NotificationEntity.fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      id: map['id'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.system,
      ),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      actionUrl: map['actionUrl'],
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      relatedId: map['relatedId'],
    );
  }
}
