import 'package:equatable/equatable.dart';

import '../../domain/entities/rejection_request_entities.dart';

/// Rejection requests events
sealed class RejectionRequestsEvent extends Equatable {
  const RejectionRequestsEvent();

  @override
  List<Object?> get props => [];
}

/// Load rejection requests
class LoadRejectionRequests extends RejectionRequestsEvent {
  final String? adminDecision;
  final String? driverId;

  const LoadRejectionRequests({this.adminDecision, this.driverId});

  @override
  List<Object?> get props => [adminDecision, driverId];
}

/// Watch rejection requests stream
class WatchRejectionRequestsEvent extends RejectionRequestsEvent {
  final String? adminDecision;

  const WatchRejectionRequestsEvent({this.adminDecision});

  @override
  List<Object?> get props => [adminDecision];
}

/// Filter rejection requests by status
class FilterRejectionsByStatus extends RejectionRequestsEvent {
  final String? adminDecision;

  const FilterRejectionsByStatus(this.adminDecision);

  @override
  List<Object?> get props => [adminDecision];
}

/// Select rejection request
class SelectRejectionRequest extends RejectionRequestsEvent {
  final RejectionRequestEntity request;

  const SelectRejectionRequest(this.request);

  @override
  List<Object?> get props => [request];
}

/// Clear selected rejection request
class ClearSelectedRejectionRequest extends RejectionRequestsEvent {
  const ClearSelectedRejectionRequest();
}

/// Approve excuse
class ApproveExcuseEvent extends RejectionRequestsEvent {
  final String requestId;
  final String? adminComment;

  const ApproveExcuseEvent({
    required this.requestId,
    this.adminComment,
  });

  @override
  List<Object?> get props => [requestId, adminComment];
}

/// Reject excuse
class RejectExcuseEvent extends RejectionRequestsEvent {
  final String requestId;
  final String adminComment;

  const RejectExcuseEvent({
    required this.requestId,
    required this.adminComment,
  });

  @override
  List<Object?> get props => [requestId, adminComment];
}

/// Load rejection statistics
class LoadRejectionStats extends RejectionRequestsEvent {
  final String? driverId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadRejectionStats({
    this.driverId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [driverId, startDate, endDate];
}

/// Load pending requests count
class LoadPendingRequestsCount extends RejectionRequestsEvent {
  const LoadPendingRequestsCount();
}
