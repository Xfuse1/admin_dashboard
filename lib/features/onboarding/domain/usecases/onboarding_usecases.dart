import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/onboarding_entities.dart';
import '../repositories/onboarding_repository.dart';

/// Get onboarding requests use case.
class GetOnboardingRequests {
  final OnboardingRepository _repository;

  GetOnboardingRequests(this._repository);

  Future<Either<Failure, List<OnboardingRequestEntity>>> call({
    OnboardingType? type,
    OnboardingStatus? status,
    int limit = 20,
    String? lastId,
  }) {
    return _repository.getRequests(
      type: type,
      status: status,
      limit: limit,
      lastId: lastId,
    );
  }
}

/// Get request by ID use case.
class GetOnboardingRequestById {
  final OnboardingRepository _repository;

  GetOnboardingRequestById(this._repository);

  Future<Either<Failure, OnboardingRequestEntity>> call(String id) {
    return _repository.getRequestById(id);
  }
}

/// Approve request use case.
class ApproveOnboardingRequest {
  final OnboardingRepository _repository;

  ApproveOnboardingRequest(this._repository);

  Future<Either<Failure, void>> call(String id, {String? notes}) {
    return _repository.approveRequest(id, notes: notes);
  }
}

/// Reject request use case.
class RejectOnboardingRequest {
  final OnboardingRepository _repository;

  RejectOnboardingRequest(this._repository);

  Future<Either<Failure, void>> call(String id, String reason) {
    return _repository.rejectRequest(id, reason);
  }
}

/// Mark request as under review use case.
class MarkRequestUnderReview {
  final OnboardingRepository _repository;

  MarkRequestUnderReview(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.markUnderReview(id);
  }
}

/// Get onboarding stats use case.
class GetOnboardingStats {
  final OnboardingRepository _repository;

  GetOnboardingStats(this._repository);

  Future<Either<Failure, OnboardingStats>> call() {
    return _repository.getStats();
  }
}
