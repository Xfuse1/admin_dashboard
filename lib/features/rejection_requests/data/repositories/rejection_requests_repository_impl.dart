import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/rejection_request_entities.dart';
import '../../domain/repositories/rejection_requests_repository.dart';
import '../datasources/rejection_requests_datasource.dart';

/// Implementation of rejection requests repository
class RejectionRequestsRepositoryImpl implements RejectionRequestsRepository {
  final RejectionRequestsDataSource dataSource;
  final FirebaseFirestore firestore;

  RejectionRequestsRepositoryImpl({
    required this.dataSource,
    required this.firestore,
  });

  @override
  Future<Either<Failure, List<RejectionRequestEntity>>> getRejectionRequests({
    String? adminDecision,
    String? driverId,
  }) async {
    try {
      final requests = await dataSource.getRejectionRequests(
        adminDecision: adminDecision,
        driverId: driverId,
      );
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<RejectionRequestEntity>>> watchRejectionRequests({
    String? adminDecision,
  }) {
    try {
      return dataSource
          .watchRejectionRequests(adminDecision: adminDecision)
          .map((models) {
            // Convert models to entities
            final entities = models.map((model) => model as RejectionRequestEntity).toList();
            return Right<Failure, List<RejectionRequestEntity>>(entities);
          })
          .handleError((error) => Left<Failure, List<RejectionRequestEntity>>(
                ServerFailure(message: error.toString()),
              ));
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, RejectionRequestEntity>> getRejectionRequestById(
    String requestId,
  ) async {
    try {
      final request = await dataSource.getRejectionRequestById(requestId);
      return Right(request);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveExcuse({
    required String requestId,
    String? adminComment,
  }) async {
    try {
      // Use transaction to ensure data consistency
      await firestore.runTransaction((transaction) async {
        // Get rejection request
        final requestRef =
            firestore.collection('rejection_requests').doc(requestId);
        final requestDoc = await transaction.get(requestRef);

        if (!requestDoc.exists) {
          throw Exception('Rejection request not found');
        }

        final orderId = requestDoc.data()!['orderId'] as String;
        final driverId = requestDoc.data()!['driverId'] as String;

        // Update rejection request
        transaction.update(requestRef, {
          'adminDecision': 'approved',
          'adminComment': adminComment,
          'decidedAt': FieldValue.serverTimestamp(),
        });

        // Update order: clear driverId and set status back to pending
        final orderRef = firestore.collection('orders').doc(orderId);
        transaction.update(orderRef, {
          'deliveryId': null,
          'deliveryStatus': 'pending',
          'rejectionStatus': 'adminApproved',
        });

        // Increment driver's rejectionsCounter
        final userRef = firestore.collection('users').doc(driverId);
        transaction.update(userRef, {
          'rejectionsCounter': FieldValue.increment(1),
          'currentOrdersCount': FieldValue.increment(-1),
        });
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectExcuse({
    required String requestId,
    required String adminComment,
  }) async {
    try {
      // Use transaction to ensure data consistency
      await firestore.runTransaction((transaction) async {
        // Get rejection request
        final requestRef =
            firestore.collection('rejection_requests').doc(requestId);
        final requestDoc = await transaction.get(requestRef);

        if (!requestDoc.exists) {
          throw Exception('Rejection request not found');
        }

        final orderId = requestDoc.data()!['orderId'] as String;

        // Update rejection request
        transaction.update(requestRef, {
          'adminDecision': 'rejected',
          'adminComment': adminComment,
          'decidedAt': FieldValue.serverTimestamp(),
        });

        // Update order rejectionStatus and reset delivery status to upcoming
        final orderRef = firestore.collection('orders').doc(orderId);
        transaction.update(orderRef, {
          'rejectionStatus': 'adminRefused',
          'deliveryStatus': 'upcoming',
        });
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RejectionStats>> getRejectionStats({
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          firestore.collection('rejection_requests');

      if (driverId != null) {
        query = query.where('driverId', isEqualTo: driverId);
      }

      if (startDate != null) {
        query = query.where('requestedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('requestedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      final requests = snapshot.docs;

      final total = requests.length;
      final pending = requests
          .where((doc) => doc.data()['adminDecision'] == 'pending')
          .length;
      final approved = requests
          .where((doc) => doc.data()['adminDecision'] == 'approved')
          .length;
      final rejected = requests
          .where((doc) => doc.data()['adminDecision'] == 'rejected')
          .length;

      // Calculate average response time for decided requests
      double avgResponseTime = 0;
      final decidedRequests = requests.where((doc) {
        final decision = doc.data()['adminDecision'];
        return decision == 'approved' || decision == 'rejected';
      }).toList();

      if (decidedRequests.isNotEmpty) {
        int totalMinutes = 0;
        int validCount = 0;
        for (final doc in decidedRequests) {
          final data = doc.data();
          // Skip if requestedAt is null
          if (data['requestedAt'] == null) continue;
          
          try {
            final requestedAt = (data['requestedAt'] as Timestamp).toDate();
            final decidedAt = data['decidedAt'] != null
                ? (data['decidedAt'] as Timestamp).toDate()
                : DateTime.now();
            totalMinutes += decidedAt.difference(requestedAt).inMinutes;
            validCount++;
          } catch (e) {
            // Skip invalid documents
            continue;
          }
        }
        if (validCount > 0) {
          avgResponseTime = totalMinutes / validCount;
        }
      }

      final stats = RejectionStats(
        totalRequests: total,
        pendingRequests: pending,
        approvedRequests: approved,
        rejectedRequests: rejected,
        averageResponseTimeMinutes: avgResponseTime,
      );

      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingRequestsCount() async {
    try {
      final count = await dataSource.getPendingRequestsCount();
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
