import '../models/admin_user_model.dart';

/// Authentication data source contract.
abstract interface class AuthDataSource {
  /// Login with email and password.
  Future<AdminUserModel> login({
    required String email,
    required String password,
  });

  /// Logout current user.
  Future<void> logout();

  /// Check if user is authenticated.
  Future<AdminUserModel?> checkAuthStatus();

  /// Get current authenticated user.
  AdminUserModel? get currentUser;
}
