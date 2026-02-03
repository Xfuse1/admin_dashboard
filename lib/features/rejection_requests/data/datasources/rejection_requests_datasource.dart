import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rejection_request_models.dart';

/// Data source for rejection requests
class RejectionRequestsDataSource {
  final FirebaseFirestore _firestore;

  RejectionRequestsDataSource(this._firestore);

  /// Get all rejection requests with optional filters
  Future<List<RejectionRequestModel>> getRejectionRequests({
    String? adminDecision,
    String? driverId,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection('rejection_requests');

    if (adminDecision != null) {
      query = query.where('adminDecision', isEqualTo: adminDecision);
    }

    if (driverId != null) {
      query = query.where('driverId', isEqualTo: driverId);
    }

    final snapshot = await query.orderBy('requestedAt', descending: true).get();

    return snapshot.docs
        .map((doc) => RejectionRequestModel.fromFirestore(doc))
        .toList();
  }

  /// Watch rejection requests stream
  Stream<List<RejectionRequestModel>> watchRejectionRequests({
    String? adminDecision,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection('rejection_requests');

    if (adminDecision != null) {
      query = query.where('adminDecision', isEqualTo: adminDecision);
    }

    return query.orderBy('requestedAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => RejectionRequestModel.fromFirestore(doc))
            .toList());
  }

  /// Get rejection request by ID
  Future<RejectionRequestModel> getRejectionRequestById(
      String requestId) async {
    final doc =
        await _firestore.collection('rejection_requests').doc(requestId).get();

    if (!doc.exists) {
      throw Exception('Rejection request not found');
    }

    return RejectionRequestModel.fromFirestore(doc);
  }

  /// Update rejection request
  Future<void> updateRejectionRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('rejection_requests')
        .doc(requestId)
        .update(data);
  }

  /// Get pending requests count
  Future<int> getPendingRequestsCount() async {
    final snapshot = await _firestore
        .collection('rejection_requests')
        .where('adminDecision', isEqualTo: 'pending')
        .get();

    return snapshot.size;
  }
}
