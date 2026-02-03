import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/rejection_request_entities.dart';

/// Repository interface for rejection requests
abstract class RejectionRequestsRepository {
  /// Get all rejection requests with optional filters
  Future<Either<Failure, List<RejectionRequestEntity>>> getRejectionRequests({
    String? adminDecision,
    String? driverId,
  });

  /// Watch rejection requests stream
  Stream<Either<Failure, List<RejectionRequestEntity>>> watchRejectionRequests({
    String? adminDecision,
  });

  /// Get rejection request by ID
  Future<Either<Failure, RejectionRequestEntity>> getRejectionRequestById(
    String requestId,
  );

  /// Approve excuse (admin decision)
  Future<Either<Failure, void>> approveExcuse({
    required String requestId,
    String? adminComment,
  });

  /// Reject excuse (admin decision)
  Future<Either<Failure, void>> rejectExcuse({
    required String requestId,
    required String adminComment,
  });

  /// Get rejection statistics
  Future<Either<Failure, RejectionStats>> getRejectionStats({
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get pending requests count
  Future<Either<Failure, int>> getPendingRequestsCount();
}
