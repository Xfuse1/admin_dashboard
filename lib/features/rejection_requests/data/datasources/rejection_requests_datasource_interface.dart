import '../models/rejection_request_models.dart';

/// Abstract interface for rejection requests data source.
///
/// Follows the same pattern as other features (e.g., [OrdersDataSource]).
abstract class RejectionRequestsDataSourceInterface {
  /// Get all rejection requests with optional filters.
  Future<List<RejectionRequestModel>> getRejectionRequests({
    String? adminDecision,
    String? driverId,
  });

  /// Watch rejection requests stream.
  Stream<List<RejectionRequestModel>> watchRejectionRequests({
    String? adminDecision,
  });

  /// Watch pending requests count stream.
  Stream<int> watchPendingRequestsCount();

  /// Get rejection request by ID.
  Future<RejectionRequestModel> getRejectionRequestById(String requestId);

  /// Update rejection request.
  Future<void> updateRejectionRequest(
    String requestId,
    Map<String, dynamic> data,
  );

  /// Approve excuse (approve rejection request).
  Future<void> approveExcuse({
    required String requestId,
    String? adminComment,
  });

  /// Reject excuse (reject rejection request).
  Future<void> rejectExcuse({
    required String requestId,
    required String adminComment,
  });

  /// Get pending requests count.
  Future<int> getPendingRequestsCount();

  /// Get rejection statistics.
  Future<Map<String, dynamic>> getRejectionStats({
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Delete rejection request.
  Future<void> deleteRejectionRequest(String requestId);

  /// Batch update multiple rejection requests.
  Future<void> batchUpdateRequests(
    List<String> requestIds,
    Map<String, dynamic> updateData,
  );
}
