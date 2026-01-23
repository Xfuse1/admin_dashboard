import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/onboarding_entities.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_datasource.dart';

/// Implementation of OnboardingRepository.
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingDataSource _dataSource;

  OnboardingRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<OnboardingRequestEntity>>> getRequests({
    OnboardingType? type,
    OnboardingStatus? status,
    int limit = 20,
    String? lastId,
  }) async {
    try {
      final requests = await _dataSource.getRequests(
        type: type,
        status: status,
        limit: limit,
        lastId: lastId,
      );
      return Right(requests.cast<OnboardingRequestEntity>());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnboardingRequestEntity>> getRequestById(
      String id) async {
    try {
      final request = await _dataSource.getRequestById(id);
      return Right(request as OnboardingRequestEntity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveRequest(String id,
      {String? notes}) async {
    try {
      await _dataSource.approveRequest(id, notes: notes);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectRequest(String id, String reason) async {
    try {
      await _dataSource.rejectRequest(id, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markUnderReview(String id) async {
    try {
      await _dataSource.markUnderReview(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OnboardingStats>> getStats() async {
    try {
      final stats = await _dataSource.getStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
