import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/rejection_request_entities.dart';
import '../repositories/rejection_requests_repository.dart';

/// Use case to get all rejection requests
class GetRejectionRequests {
  final RejectionRequestsRepository repository;

  GetRejectionRequests(this.repository);

  Future<Either<Failure, List<RejectionRequestEntity>>> call({
    String? adminDecision,
    String? driverId,
  }) {
    return repository.getRejectionRequests(
      adminDecision: adminDecision,
      driverId: driverId,
    );
  }
}

/// Use case to watch rejection requests stream
class WatchRejectionRequests {
  final RejectionRequestsRepository repository;

  WatchRejectionRequests(this.repository);

  Stream<Either<Failure, List<RejectionRequestEntity>>> call({
    String? adminDecision,
  }) {
    return repository.watchRejectionRequests(adminDecision: adminDecision);
  }
}

/// Use case to approve excuse
class ApproveExcuse {
  final RejectionRequestsRepository repository;

  ApproveExcuse(this.repository);

  Future<Either<Failure, void>> call({
    required String requestId,
    String? adminComment,
  }) {
    return repository.approveExcuse(
      requestId: requestId,
      adminComment: adminComment,
    );
  }
}

/// Use case to reject excuse
class RejectExcuse {
  final RejectionRequestsRepository repository;

  RejectExcuse(this.repository);

  Future<Either<Failure, void>> call({
    required String requestId,
    required String adminComment,
  }) {
    return repository.rejectExcuse(
      requestId: requestId,
      adminComment: adminComment,
    );
  }
}

/// Use case to get rejection statistics
class GetRejectionStats {
  final RejectionRequestsRepository repository;

  GetRejectionStats(this.repository);

  Future<Either<Failure, RejectionStats>> call({
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.getRejectionStats(
      driverId: driverId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Use case to get pending requests count
class GetPendingRequestsCount {
  final RejectionRequestsRepository repository;

  GetPendingRequestsCount(this.repository);

  Future<Either<Failure, int>> call() {
    return repository.getPendingRequestsCount();
  }
}
