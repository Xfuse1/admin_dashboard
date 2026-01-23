import '../../domain/entities/onboarding_entities.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// Abstract data source for onboarding operations.
abstract class OnboardingDataSource {
  /// Get all onboarding requests.
  Future<List<dynamic>> getRequests({
    OnboardingType? type,
    OnboardingStatus? status,
    int limit = 20,
    String? lastId,
  });

  /// Get a specific request by ID.
  Future<dynamic> getRequestById(String id);

  /// Approve a request.
  Future<void> approveRequest(String id, {String? notes});

  /// Reject a request.
  Future<void> rejectRequest(String id, String reason);

  /// Mark request as under review.
  Future<void> markUnderReview(String id);

  /// Get onboarding statistics.
  Future<OnboardingStats> getStats();
}
