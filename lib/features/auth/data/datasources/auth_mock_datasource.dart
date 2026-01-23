import '../../../../core/errors/exceptions.dart';
import '../models/admin_user_model.dart';
import 'auth_datasource.dart';

/// Mock implementation of authentication data source.
class AuthMockDataSource implements AuthDataSource {
  AdminUserModel? _currentUser;

  // Mock admin credentials
  static const _mockEmail = 'admin@delivery.com';
  static const _mockPassword = 'admin123';

  @override
  AdminUserModel? get currentUser => _currentUser;

  @override
  Future<AdminUserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Validate credentials
    if (email != _mockEmail || password != _mockPassword) {
      throw const AuthException(
        message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      );
    }

    // Return mock admin user
    _currentUser = AdminUserModel(
      id: 'admin_001',
      email: _mockEmail,
      name: 'مدير النظام',
      role: 'super_admin',
      createdAt: DateTime(2024, 1, 1),
      lastLoginAt: DateTime.now(),
    );

    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<AdminUserModel?> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }
}
