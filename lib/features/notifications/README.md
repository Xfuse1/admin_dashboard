# 🔔 نظام الإشعارات - Admin Dashboard

## نظرة عامة

نظام إشعارات متكامل واحترافي للوحة التحكم، يتميز بـ:

- ✅ Real-time updates من Firebase
- ✅ Responsive design (Desktop, Tablet, Mobile)
- ✅ Clean Architecture
- ✅ Badge لعدد الإشعارات غير المقروءة
- ✅ قائمة منسدلة احترافية
- ✅ دعم أنواع مختلفة من الإشعارات
- ✅ Firebase Cloud Messaging جاهز للإضافة

## البنية المعمارية

```
features/notifications/
├── domain/
│   ├── entities/
│   │   └── notification_entity.dart
│   └── repositories/
│       └── notifications_repository.dart
├── data/
│   ├── datasources/
│   │   └── notifications_firebase_datasource.dart
│   └── repositories/
│       └── notifications_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── notifications_bloc.dart
    │   ├── notifications_event.dart
    │   └── notifications_state.dart
    └── widgets/
        └── notifications_bell.dart
```

## أنواع الإشعارات

### 1. طلبات الرفض (Rejection Requests)
- عند إرسال سائق طلب رفض جديد
- عند الموافقة/الرفض على طلب

### 2. الطلبات (Orders)
- عند إضافة طلب جديد
- عند تحديث حالة طلب

### 3. المتاجر (Vendors)
- عند تسجيل متجر جديد يحتاج موافقة
- عند تعديل بيانات متجر

### 4. السائقين (Drivers)
- **عند تسجيل سائق جديد**: يتم إرسال إشعار تلقائياً لجميع الأدمن عند استلام طلب تسجيل سائق
- **عند تحديث حالة سائق**: يتم إرسال إشعار عند الموافقة أو الرفض أو تحديث أي حالة

⚠️ **ملاحظة مهمة**: هذه الإشعارات تتطلب:
1. نشر Cloud Functions باستخدام `firebase deploy --only functions`
2. تفعيل المراقبة الفورية (Real-time) في التطبيق
3. التأكد من أن المستخدم مسجل كـ admin

### 5. النظام (System)
- إشعارات عامة من النظام

## بنية Firebase

### Collection Structure

```
admin_notifications/
└── {adminId}/
    └── notifications/
        └── {notificationId}
            ├── type: string
            ├── title: string
            ├── message: string
            ├── actionUrl: string (optional)
            ├── data: map (optional)
            ├── priority: string
            ├── isRead: boolean
            ├── createdAt: timestamp
            └── relatedId: string (optional)
```

### Firebase Rules Example

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /admin_notifications/{adminId}/notifications/{notificationId} {
      // الأدمن يمكنه قراءة وتعديل إشعاراته فقط
      allow read, write: if request.auth != null && 
                           request.auth.uid == adminId;
    }
  }
}
```

## الاستخدام

### 1. عرض أيقونة الجرس

الأيقونة مدمجة تلقائياً في `AdminShell`:

```dart
// في AdminShell
const NotificationsBell()
```

### 2. إنشاء إشعار جديد (للاختبار)

```dart
final notification = NotificationEntity(
  id: '', // سيتم توليده تلقائياً
  type: NotificationType.rejectionRequest,
  title: 'طلب رفض جديد',
  message: 'السائق أحمد قدم طلب رفض طلب #12345',
  actionUrl: '/rejection-requests',
  priority: NotificationPriority.high,
  isRead: false,
  createdAt: DateTime.now(),
  relatedId: 'rejection_123',
);

await notificationsDataSource.createNotification(notification);
```

### 3. إنشاء إشعار من Firebase Function

```javascript
// Firebase Cloud Function
const admin = require('firebase-admin');

exports.createNotification = functions.firestore
  .document('rejection_requests/{requestId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    await admin.firestore()
      .collection('admin_notifications')
      .doc('admin') // أو ID الأدمن المستهدف
      .collection('notifications')
      .add({
        type: 'rejectionRequest',
        title: 'طلب رفض جديد',
        message: `السائق ${data.driverName} قدم طلب رفض`,
        actionUrl: '/rejection-requests',
        priority: 'high',
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        relatedId: context.params.requestId,
      });
  });
```

## الميزات المتقدمة

### 1. Responsive Design

```dart
// يتكيف تلقائياً مع حجم الشاشة
- Desktop: قائمة منسدلة بعرض 420px
- Mobile: قائمة تأخذ 95% من عرض الشاشة
```

### 2. Real-time Updates

```dart
// التحديثات الفورية عبر Stream
context.read<NotificationsBloc>().add(const WatchNotifications());
```

### 3. Badge Count

```dart
// عداد تلقائي للإشعارات غير المقروءة
unreadCount: state.unreadCount
```

### 4. Mark as Read

```dart
// تعليم كمقروء عند الضغط
context.read<NotificationsBloc>()
  .add(MarkNotificationAsRead(notificationId));
```

## تفعيل الإشعارات

### 1. نشر Cloud Functions

لتفعيل الإشعارات التلقائية، يجب نشر Firebase Cloud Functions:

```bash
cd functions
npm install
firebase deploy --only functions
```

هذا سينشر الدوال التالية:
- `onDriverRequestCreated` - عند تسجيل سائق جديد
- `onDriverRequestStatusUpdated` - عند تحديث حالة السائق
- `senddevices` - عند تحديث حالة الطلب
- `onReviewCreated` - عند إضافة تقييم متجر

### 2. تحديث Firestore Rules

تأكد من أن firestore.rules تسمح للأدمن بقراءة الإشعارات:

```javascript
match /admin_notifications/{adminId}/notifications/{notificationId} {
  allow read, write: if request.auth != null && 
                       request.auth.uid == adminId;
}
```

### 3. تفعيل Real-time Updates في التطبيق

في `AdminShell`، يجب تفعيل مراقبة الإشعارات:

```dart
BlocProvider(
  create: (context) => NotificationsBloc(
    getIt<NotificationsRepository>(),
    adminId: currentAdminId,
  )..add(const WatchNotifications()), // تفعيل المراقبة الفورية
  child: const NotificationsBell(),
)
```

## Firebase Cloud Messaging (للموبايل)

### إضافة FCM للإشعارات الخلفية

1. أضف Firebase Messaging للمشروع:

```yaml
# pubspec.yaml
dependencies:
  firebase_messaging: ^15.0.0
  flutter_local_notifications: ^17.0.0
```

2. طلب الإذن:

```dart
final messaging = FirebaseMessaging.instance;
final settings = await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  print('User granted permission');
}
```

3. معالجة الإشعارات:

```dart
// Foreground
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // عرض إشعار محلي
});

// Background
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

## Best Practices

### 1. أولويات الإشعارات

```dart
// استخدم الأولويات بحكمة
NotificationPriority.urgent // للطوارئ فقط
NotificationPriority.high    // مهم
NotificationPriority.medium  // عادي (افتراضي)
NotificationPriority.low     // معلومات إضافية
```

### 2. تنظيف الإشعارات القديمة

```dart
// امسح الإشعارات القديمة دورياً (Firebase Function)
const deleteOldNotifications = functions.pubsub
  .schedule('every 7 days')
  .onRun(async (context) => {
    const sevenDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    );
    
    // حذف الإشعارات المقروءة الأقدم من 7 أيام
  });
```

### 3. Batch Operations

```dart
// استخدم Batch للكفاءة
await notificationsBloc.add(const MarkAllNotificationsAsRead());
```

## التخصيص

### تغيير الألوان

```dart
// في notification_entity.dart
Color getTypeColor() {
  switch (type) {
    case NotificationType.rejectionRequest:
      return AppColors.warning;
    // ...
  }
}
```

### تخصيص الأيقونات

```dart
// في _NotificationItem._buildIcon()
IconData getTypeIcon() {
  switch (type) {
    case NotificationType.rejectionRequest:
      return Iconsax.warning_2;
    // ...
  }
}
```

## الاختبار

### إنشاء إشعار تجريبي

```dart
// في Firebase Console أو من خلال Cloud Functions
await FirebaseFirestore.instance
  .collection('admin_notifications')
  .doc('admin')
  .collection('notifications')
  .add({
    'type': 'system',
    'title': 'مرحباً بك!',
    'message': 'نظام الإشعارات يعمل بنجاح',
    'priority': 'medium',
    'isRead': false,
    'createdAt': FieldValue.serverTimestamp(),
  });
```

## التطوير المستقبلي

- [ ] إضافة فلاتر متقدمة
- [ ] إشعارات صوتية
- [ ] تجميع الإشعارات المتشابهة
- [ ] إحصائيات الإشعارات
- [ ] إعدادات تخصيص الإشعارات

## المساهمة

للمساهمة في تطوير النظام:
1. Fork المشروع
2. أنشئ branch جديد
3. قم بالتعديلات
4. اعمل Pull Request

## الترخيص

هذا المشروع مرخص تحت MIT License.
