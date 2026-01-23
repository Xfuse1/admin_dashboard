import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/admin_user.dart';
import '../repositories/auth_repository.dart';

/// Login use case.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Either<Failure, AdminUser>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
