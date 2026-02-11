import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
///
/// Failures represent expected error states that can be handled gracefully.
sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Server-side failure (API errors, Firebase errors).
final class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

/// Authentication failure (login, logout, session).
final class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  /// Invalid email or password
  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'بيانات الدخول غير صحيحة',
        code: 'invalid-credentials',
      );

  /// User not found
  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'المستخدم غير موجود',
        code: 'user-not-found',
      );

  /// Session expired
  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'انتهت الجلسة، يرجى تسجيل الدخول',
        code: 'session-expired',
      );

  /// Unauthorized access
  factory AuthFailure.unauthorized() => const AuthFailure(
        message: 'غير مصرح لك بالوصول',
        code: 'unauthorized',
      );
}

/// Network failure (no internet, timeout).
final class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });

  /// No internet connection
  factory NetworkFailure.noConnection() => const NetworkFailure(
        message: 'لا يوجد اتصال بالإنترنت',
        code: 'no-connection',
      );

  /// Request timeout
  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'انتهت مهلة الاتصال',
        code: 'timeout',
      );
}

/// Cache/Local storage failure.
final class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });

  /// No cached data found
  factory CacheFailure.notFound() => const CacheFailure(
        message: 'لا توجد بيانات محفوظة',
        code: 'cache-not-found',
      );
}

/// Validation failure (form validation, input errors).
final class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Firebase-specific failure.
final class FirebaseFailure extends Failure {
  const FirebaseFailure({
    required super.message,
    super.code,
  });

  /// Permission denied
  factory FirebaseFailure.permissionDenied() => const FirebaseFailure(
        message: 'ليس لديك صلاحية لهذا الإجراء',
        code: 'permission-denied',
      );

  /// Document not found
  factory FirebaseFailure.notFound() => const FirebaseFailure(
        message: 'البيانات غير موجودة',
        code: 'not-found',
      );

  /// Quota exceeded
  factory FirebaseFailure.quotaExceeded() => const FirebaseFailure(
        message: 'تم تجاوز الحد المسموح',
        code: 'quota-exceeded',
      );
}

/// Not found failure (resource doesn't exist).
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
  });

  /// Generic not found
  factory NotFoundFailure.generic(String resourceName) => NotFoundFailure(
        message: '$resourceName غير موجود',
        code: 'not-found',
      );

  /// Vendor not found
  factory NotFoundFailure.vendor() => const NotFoundFailure(
        message: 'المتجر غير موجود',
        code: 'vendor-not-found',
      );

  /// Product not found
  factory NotFoundFailure.product() => const NotFoundFailure(
        message: 'المنتج غير موجود',
        code: 'product-not-found',
      );

  /// Order not found
  factory NotFoundFailure.order() => const NotFoundFailure(
        message: 'الطلب غير موجود',
        code: 'order-not-found',
      );
}

/// Duplicate resource failure.
final class DuplicateFailure extends Failure {
  const DuplicateFailure({
    required super.message,
    super.code,
  });

  /// Generic duplicate
  factory DuplicateFailure.generic(String resourceName) => DuplicateFailure(
        message: '$resourceName موجود مسبقاً',
        code: 'duplicate',
      );
}

/// Invalid operation failure.
final class InvalidOperationFailure extends Failure {
  const InvalidOperationFailure({
    required super.message,
    super.code,
  });

  /// Operation not allowed in current state
  factory InvalidOperationFailure.notAllowed() => const InvalidOperationFailure(
        message: 'العملية غير مسموحة في الحالة الحالية',
        code: 'operation-not-allowed',
      );

  /// Insufficient permissions
  factory InvalidOperationFailure.insufficientPermissions() =>
      const InvalidOperationFailure(
        message: 'صلاحياتك غير كافية لإجراء هذه العملية',
        code: 'insufficient-permissions',
      );
}

/// Unexpected/Unknown failure.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'حدث خطأ غير متوقع',
    super.code,
  });
}
