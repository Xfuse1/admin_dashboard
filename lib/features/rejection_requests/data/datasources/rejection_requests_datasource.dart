import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/rejection_request_models.dart';
import 'rejection_requests_datasource_interface.dart';

/// Firebase implementation of [RejectionRequestsDataSourceInterface].
class RejectionRequestsFirebaseDataSource
    implements RejectionRequestsDataSourceInterface {
  final FirebaseFirestore _firestore;

  RejectionRequestsFirebaseDataSource(this._firestore);

  /// Get all rejection requests with optional filters
  @override
  Future<List<RejectionRequestModel>> getRejectionRequests({
    String? adminDecision,
    String? driverId,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection('rejection_requests');

      if (adminDecision != null) {
        query = query.where('adminDecision', isEqualTo: adminDecision);
      }

      if (driverId != null) {
        query = query.where('driverId', isEqualTo: driverId);
      }

      // Add ordering - requires composite index if using multiple where clauses
      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => RejectionRequestModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      // If index is missing, fall back to client-side sorting
      if (e.code == 'failed-precondition' || e.code == 'unimplemented') {
        return _getRejectionRequestsWithClientSort(
          adminDecision: adminDecision,
          driverId: driverId,
        );
      }

      throw Exception('فشل في تحميل طلبات الرفض: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// Fallback method for when composite index is not available
  Future<List<RejectionRequestModel>> _getRejectionRequestsWithClientSort({
    String? adminDecision,
    String? driverId,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection('rejection_requests');

      if (adminDecision != null) {
        query = query.where('adminDecision', isEqualTo: adminDecision);
      }

      if (driverId != null) {
        query = query.where('driverId', isEqualTo: driverId);
      }

      final snapshot = await query.get();

      final requests = snapshot.docs
          .map((doc) => RejectionRequestModel.fromFirestore(doc))
          .toList();

      // Sort client-side
      requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

      return requests;
    } catch (e) {
      throw Exception('فشل في تحميل البيانات: $e');
    }
  }

  /// Watch rejection requests stream
  @override
  Stream<List<RejectionRequestModel>> watchRejectionRequests({
    String? adminDecision,
  }) {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection('rejection_requests');

      if (adminDecision != null) {
        query = query.where('adminDecision', isEqualTo: adminDecision);
      }

      return query.snapshots().map((snapshot) {
        final requests = snapshot.docs
            .map((doc) {
              try {
                return RejectionRequestModel.fromFirestore(doc);
              } catch (e) {
                // Skip invalid documents
                return null;
              }
            })
            .whereType<RejectionRequestModel>()
            .toList();

        // Sort by createdAt in memory to avoid index issues
        requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

        return requests;
      }).handleError((error) {
        throw Exception('خطأ في تحميل البيانات المباشرة: $error');
      });
    } catch (e) {
      // Return error stream
      return Stream.error(Exception('فشل في إعداد تدفق البيانات: $e'));
    }
  }

  /// Watch pending requests count stream
  @override
  Stream<int> watchPendingRequestsCount() {
    return _firestore
        .collection('rejection_requests')
        .where('adminDecision', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.size;
    }).handleError((error) {
      return 0; // Return 0 on error
    });
  }

  /// Get rejection request by ID
  @override
  Future<RejectionRequestModel> getRejectionRequestById(
    String requestId,
  ) async {
    try {
      final doc = await _firestore
          .collection('rejection_requests')
          .doc(requestId)
          .get();

      if (!doc.exists) {
        throw Exception('لم يتم العثور على طلب الرفض');
      }

      return RejectionRequestModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('فشل في تحميل طلب الرفض: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ في تحميل الطلب: $e');
    }
  }

  /// Update rejection request
  @override
  Future<void> updateRejectionRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Add timestamp for updates
      final updateData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('rejection_requests')
          .doc(requestId)
          .update(updateData);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw Exception('لم يتم العثور على طلب الرفض');
      } else if (e.code == 'permission-denied') {
        throw Exception('ليس لديك صلاحية لتحديث هذا الطلب');
      }

      throw Exception('فشل في تحديث الطلب: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ في التحديث: $e');
    }
  }

  /// Approve excuse (approve rejection request)
  @override
  Future<void> approveExcuse({
    required String requestId,
    String? adminComment,
  }) async {
    try {
      final updateData = {
        'adminDecision': 'approved',
        'adminComment': adminComment,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('rejection_requests')
          .doc(requestId)
          .update(updateData);
    } on FirebaseException catch (e) {
      throw Exception('فشل في الموافقة على الاعتذار: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ في الموافقة: $e');
    }
  }

  /// Reject excuse (reject rejection request)
  @override
  Future<void> rejectExcuse({
    required String requestId,
    required String adminComment,
  }) async {
    try {
      final updateData = {
        'adminDecision': 'rejected',
        'adminComment': adminComment,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('rejection_requests')
          .doc(requestId)
          .update(updateData);
    } on FirebaseException catch (e) {
      throw Exception('فشل في رفض الاعتذار: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ في الرفض: $e');
    }
  }

  /// Get pending requests count
  @override
  Future<int> getPendingRequestsCount() async {
    try {
      final snapshot = await _firestore
          .collection('rejection_requests')
          .where('adminDecision', isEqualTo: 'pending')
          .count()
          .get();

      return snapshot.count ?? 0;
    } on FirebaseException catch (e) {
      // Fallback to get() if count() is not available
      if (e.code == 'unimplemented') {
        final snapshot = await _firestore
            .collection('rejection_requests')
            .where('adminDecision', isEqualTo: 'pending')
            .get();
        return snapshot.size;
      }

      return 0; // Return 0 on error
    } catch (e) {
      return 0; // Return 0 on error
    }
  }

  /// Get rejection statistics
  @override
  Future<Map<String, dynamic>> getRejectionStats({
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection('rejection_requests');

      if (driverId != null) {
        query = query.where('driverId', isEqualTo: driverId);
      }

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.get();

      int totalRequests = snapshot.size;
      int pendingCount = 0;
      int approvedCount = 0;
      int rejectedCount = 0;
      int withinSLA = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final decision = data['adminDecision'] as String?;
        final slaStatus = data['slaStatus'] as String?;

        if (decision == 'pending') pendingCount++;
        if (decision == 'approved') approvedCount++;
        if (decision == 'rejected') rejectedCount++;
        if (slaStatus == 'green') withinSLA++;
      }

      return {
        'totalRequests': totalRequests,
        'pendingCount': pendingCount,
        'approvedCount': approvedCount,
        'rejectedCount': rejectedCount,
        'withinSLA': withinSLA,
        'slaCompliance': totalRequests > 0
            ? (withinSLA / totalRequests * 100).toStringAsFixed(1)
            : '0.0',
      };
    } on FirebaseException catch (e) {
      throw Exception('فشل في تحميل الإحصائيات: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ في تحميل الإحصائيات: $e');
    }
  }

  /// Delete rejection request (admin only)
  @override
  Future<void> deleteRejectionRequest(String requestId) async {
    try {
      await _firestore.collection('rejection_requests').doc(requestId).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('ليس لديك صلاحية لحذف هذا الطلب');
      }

      throw Exception('فشل في حذف الطلب: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ في الحذف: $e');
    }
  }

  /// Batch update multiple rejection requests
  @override
  Future<void> batchUpdateRequests(
    List<String> requestIds,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final batch = _firestore.batch();

      final dataWithTimestamp = {
        ...updateData,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      for (final requestId in requestIds) {
        final docRef =
            _firestore.collection('rejection_requests').doc(requestId);
        batch.update(docRef, dataWithTimestamp);
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('فشل في التحديث الجماعي: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ في التحديث الجماعي: $e');
    }
  }
}
