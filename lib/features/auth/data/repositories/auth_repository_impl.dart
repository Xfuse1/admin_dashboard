import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// Implementation of authentication repository.
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  AdminUser? get currentUser => _dataSource.currentUser;

  @override
  Future<Either<Failure, AdminUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.login(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _dataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUser?>> checkAuthStatus() async {
    try {
      final user = await _dataSource.checkAuthStatus();
      return Right(user);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
