import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/admin_user.dart';
import '../repositories/auth_repository.dart';

/// Check auth status use case.
class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  const CheckAuthStatusUseCase(this._repository);

  Future<Either<Failure, AdminUser?>> call() {
    return _repository.checkAuthStatus();
  }
}
