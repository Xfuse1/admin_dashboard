/// Base class for all exceptions in the application.
///
/// Exceptions are thrown for unexpected errors that need to be caught.
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exception (API errors).
final class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Authentication exception.
final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Network exception.
final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Cache exception.
final class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Firebase exception.
final class FirebaseAppException extends AppException {
  const FirebaseAppException({
    required super.message,
    super.code,
    super.originalError,
  });
}
