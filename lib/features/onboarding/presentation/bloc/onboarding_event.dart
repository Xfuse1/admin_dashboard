import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding_entities.dart';

/// Base class for Onboarding events.
sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Load onboarding requests.
class LoadOnboardingRequests extends OnboardingEvent {
  final OnboardingType? type;
  final OnboardingStatus? status;

  const LoadOnboardingRequests({this.type, this.status});

  @override
  List<Object?> get props => [type, status];
}

/// Load more requests (pagination).
class LoadMoreRequests extends OnboardingEvent {
  const LoadMoreRequests();
}

/// Load onboarding statistics.
class LoadOnboardingStats extends OnboardingEvent {
  const LoadOnboardingStats();
}

/// Filter by type.
class FilterByType extends OnboardingEvent {
  final OnboardingType? type;

  const FilterByType(this.type);

  @override
  List<Object?> get props => [type];
}

/// Filter by status.
class FilterByStatus extends OnboardingEvent {
  final OnboardingStatus? status;

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Select a request to view details.
class SelectRequest extends OnboardingEvent {
  final OnboardingRequestEntity? request;

  const SelectRequest(this.request);

  @override
  List<Object?> get props => [request];
}

/// Approve a request.
class ApproveRequestEvent extends OnboardingEvent {
  final String requestId;
  final String? notes;

  const ApproveRequestEvent({required this.requestId, this.notes});

  @override
  List<Object?> get props => [requestId, notes];
}

/// Reject a request.
class RejectRequestEvent extends OnboardingEvent {
  final String requestId;
  final String reason;

  const RejectRequestEvent({required this.requestId, required this.reason});

  @override
  List<Object?> get props => [requestId, reason];
}

/// Mark request as under review.
class MarkUnderReviewEvent extends OnboardingEvent {
  final String requestId;

  const MarkUnderReviewEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// Clear error state.
class ClearOnboardingError extends OnboardingEvent {
  const ClearOnboardingError();
}
