import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/admins_repository.dart';
import '../datasources/admins_datasource.dart';

/// Implementation of AdminsRepository.
class AdminsRepositoryImpl implements AdminsRepository {
  final AdminsDataSource _dataSource;

  AdminsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<AdminEntity>>> getAdmins() async {
    try {
      final admins = await _dataSource.getAdmins();
      return Right(admins);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminEntity>> addAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final admin = await _dataSource.addAdmin(
        name: name,
        email: email,
        password: password,
      );
      return Right(admin);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل إضافة المسؤول: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAdmin(String adminId) async {
    try {
      await _dataSource.deleteAdmin(adminId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل حذف المسؤول: $e'));
    }
  }
}
