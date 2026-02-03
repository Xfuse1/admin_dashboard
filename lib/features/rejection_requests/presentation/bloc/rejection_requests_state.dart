import 'package:equatable/equatable.dart';

import '../../domain/entities/rejection_request_entities.dart';

/// Rejection requests states
sealed class RejectionRequestsState extends Equatable {
  const RejectionRequestsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RejectionRequestsInitial extends RejectionRequestsState {
  const RejectionRequestsInitial();
}

/// Loading state
class RejectionRequestsLoading extends RejectionRequestsState {
  const RejectionRequestsLoading();
}

/// Rejection requests loaded successfully
class RejectionRequestsLoaded extends RejectionRequestsState {
  final List<RejectionRequestEntity> requests;
  final String? currentFilter;
  final RejectionRequestEntity? selectedRequest;
  final RejectionStats? stats;
  final int pendingCount;

  const RejectionRequestsLoaded({
    required this.requests,
    this.currentFilter,
    this.selectedRequest,
    this.stats,
    this.pendingCount = 0,
  });

  RejectionRequestsLoaded copyWith({
    List<RejectionRequestEntity>? requests,
    String? currentFilter,
    RejectionRequestEntity? selectedRequest,
    RejectionStats? stats,
    int? pendingCount,
    bool clearSelectedRequest = false,
  }) {
    return RejectionRequestsLoaded(
      requests: requests ?? this.requests,
      currentFilter: currentFilter ?? this.currentFilter,
      selectedRequest: clearSelectedRequest
          ? null
          : (selectedRequest ?? this.selectedRequest),
      stats: stats ?? this.stats,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  @override
  List<Object?> get props => [
        requests,
        currentFilter,
        selectedRequest,
        stats,
        pendingCount,
      ];
}

/// Error state
class RejectionRequestsError extends RejectionRequestsState {
  final String message;

  const RejectionRequestsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Operation in progress state
class RejectionRequestsOperationInProgress extends RejectionRequestsState {
  final String operation;

  const RejectionRequestsOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}

/// Operation success state
class RejectionRequestsOperationSuccess extends RejectionRequestsState {
  final String message;
  final RejectionRequestsLoaded previousState;

  const RejectionRequestsOperationSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}
