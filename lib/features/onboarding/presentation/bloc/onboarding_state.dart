import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding_entities.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// Base class for Onboarding states.
sealed class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Loading state.
class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// Loaded state with requests data.
class OnboardingLoaded extends OnboardingState {
  final List<OnboardingRequestEntity> requests;
  final OnboardingStats? stats;
  final OnboardingType? filterType;
  final OnboardingStatus? filterStatus;
  final bool hasMore;
  final bool isLoadingMore;
  final OnboardingRequestEntity? selectedRequest;

  const OnboardingLoaded({
    this.requests = const [],
    this.stats,
    this.filterType,
    this.filterStatus,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.selectedRequest,
  });

  OnboardingLoaded copyWith({
    List<OnboardingRequestEntity>? requests,
    OnboardingStats? stats,
    OnboardingType? filterType,
    bool clearFilterType = false,
    OnboardingStatus? filterStatus,
    bool clearFilterStatus = false,
    bool? hasMore,
    bool? isLoadingMore,
    OnboardingRequestEntity? selectedRequest,
    bool clearSelectedRequest = false,
  }) {
    return OnboardingLoaded(
      requests: requests ?? this.requests,
      stats: stats ?? this.stats,
      filterType: clearFilterType ? null : filterType ?? this.filterType,
      filterStatus:
          clearFilterStatus ? null : filterStatus ?? this.filterStatus,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedRequest:
          clearSelectedRequest ? null : selectedRequest ?? this.selectedRequest,
    );
  }

  @override
  List<Object?> get props => [
        requests,
        stats,
        filterType,
        filterStatus,
        hasMore,
        isLoadingMore,
        selectedRequest,
      ];
}

/// Error state.
class OnboardingError extends OnboardingState {
  final String message;
  final OnboardingState? previousState;

  const OnboardingError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// Action in progress (approve, reject, etc.).
class OnboardingActionInProgress extends OnboardingState {
  final String requestId;
  final String action;
  final OnboardingLoaded previousState;

  const OnboardingActionInProgress({
    required this.requestId,
    required this.action,
    required this.previousState,
  });

  @override
  List<Object?> get props => [requestId, action, previousState];
}

/// Action completed successfully.
class OnboardingActionSuccess extends OnboardingState {
  final String message;
  final OnboardingLoaded updatedState;

  const OnboardingActionSuccess({
    required this.message,
    required this.updatedState,
  });

  @override
  List<Object?> get props => [message, updatedState];
}
