import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/onboarding_entities.dart';

/// Repository for onboarding operations.
abstract class OnboardingRepository {
  /// Get all onboarding requests.
  Future<Either<Failure, List<OnboardingRequestEntity>>> getRequests({
    OnboardingType? type,
    OnboardingStatus? status,
    int limit = 20,
    String? lastId,
  });

  /// Get a specific request by ID.
  Future<Either<Failure, OnboardingRequestEntity>> getRequestById(String id);

  /// Approve a request.
  Future<Either<Failure, void>> approveRequest(String id, {String? notes});

  /// Reject a request.
  Future<Either<Failure, void>> rejectRequest(String id, String reason);

  /// Mark request as under review.
  Future<Either<Failure, void>> markUnderReview(String id);

  /// Get onboarding statistics.
  Future<Either<Failure, OnboardingStats>> getStats();
}

/// Onboarding statistics.
class OnboardingStats {
  final int totalRequests;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final int pendingStoreRequests;
  final int pendingDriverRequests;
  
  // Growth rates (percentage change compared to previous period)
  final double? totalRequestsGrowth;
  final double? pendingRequestsGrowth;
  final double? approvedRequestsGrowth;
  final double? rejectedRequestsGrowth;
  final double? pendingStoreRequestsGrowth;
  final double? pendingDriverRequestsGrowth;

  const OnboardingStats({
    required this.totalRequests,
    required this.pendingRequests,
    required this.approvedRequests,
    required this.rejectedRequests,
    required this.pendingStoreRequests,
    required this.pendingDriverRequests,
    this.totalRequestsGrowth,
    this.pendingRequestsGrowth,
    this.approvedRequestsGrowth,
    this.rejectedRequestsGrowth,
    this.pendingStoreRequestsGrowth,
    this.pendingDriverRequestsGrowth,
  });
}
