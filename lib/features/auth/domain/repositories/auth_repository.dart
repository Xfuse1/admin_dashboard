import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/admin_user.dart';

/// Authentication repository contract.
abstract interface class AuthRepository {
  /// Login with email and password.
  Future<Either<Failure, AdminUser>> login({
    required String email,
    required String password,
  });

  /// Logout current user.
  Future<Either<Failure, void>> logout();

  /// Check if user is authenticated.
  Future<Either<Failure, AdminUser?>> checkAuthStatus();

  /// Get current authenticated user.
  AdminUser? get currentUser;
}
