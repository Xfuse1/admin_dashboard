import '../models/admin_model.dart';

/// Abstract datasource for Admins feature.
abstract class AdminsDataSource {
  /// Get all admins.
  Future<List<AdminModel>> getAdmins();

  /// Add a new admin.
  Future<AdminModel> addAdmin({
    required String name,
    required String email,
    required String password,
  });

  /// Delete an admin by ID.
  Future<void> deleteAdmin(String adminId);
}
