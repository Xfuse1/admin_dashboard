import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_entity.dart';

/// Repository interface for Admins feature.
abstract class AdminsRepository {
  /// Get all admins (admin + superAdmin roles).
  Future<Either<Failure, List<AdminEntity>>> getAdmins();

  /// Add a new admin.
  Future<Either<Failure, AdminEntity>> addAdmin({
    required String name,
    required String email,
    required String password,
  });

  /// Delete an admin by ID.
  Future<Either<Failure, void>> deleteAdmin(String adminId);
}
