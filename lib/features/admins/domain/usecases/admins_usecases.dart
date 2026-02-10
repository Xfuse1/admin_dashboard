import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_entity.dart';
import '../repositories/admins_repository.dart';

/// Use case: Get all admins.
class GetAdmins {
  final AdminsRepository _repository;

  GetAdmins(this._repository);

  Future<Either<Failure, List<AdminEntity>>> call() {
    return _repository.getAdmins();
  }
}

/// Use case: Add a new admin.
class AddAdmin {
  final AdminsRepository _repository;

  AddAdmin(this._repository);

  Future<Either<Failure, AdminEntity>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.addAdmin(
      name: name,
      email: email,
      password: password,
    );
  }
}

/// Use case: Delete an admin.
class DeleteAdmin {
  final AdminsRepository _repository;

  DeleteAdmin(this._repository);

  Future<Either<Failure, void>> call(String adminId) {
    return _repository.deleteAdmin(adminId);
  }
}
