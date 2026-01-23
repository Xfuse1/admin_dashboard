import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_service.dart';
import '../../domain/entities/onboarding_entities.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../models/onboarding_models.dart';
import 'onboarding_datasource.dart';

/// Firebase implementation of [OnboardingDataSource].
///
/// Connects to the same Firestore collections used by Deliverzler app
/// to manage driver onboarding requests.
class OnboardingFirebaseDataSource implements OnboardingDataSource {
  OnboardingFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseService.instance.firestore;

  final FirebaseFirestore _firestore;

  /// Collection path for driver requests (matches Deliverzler).
  static const String _driverRequestsCollection =
      FirestoreCollections.driverRequests;

  /// Collection path for store requests.
  static const String _storeRequestsCollection =
      FirestoreCollections.storeRequests;

  @override
  Future<List<dynamic>> getRequests({
    OnboardingType? type,
    OnboardingStatus? status,
    int limit = 20,
    String? lastId,
  }) async {
    final requests = <dynamic>[];

    // Fetch driver requests if type is null or driver
    if (type == null || type == OnboardingType.driver) {
      final driverRequests = await _fetchDriverRequests(
        status: status,
        limit: limit,
        lastId: lastId,
      );
      requests.addAll(driverRequests);
    }

    // Fetch store requests if type is null or store
    if (type == null || type == OnboardingType.store) {
      final storeRequests = await _fetchStoreRequests(
        status: status,
        limit: limit,
        lastId: lastId,
      );
      requests.addAll(storeRequests);
    }

    // Sort by creation date (newest first)
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply limit after combining
    return requests.take(limit).toList();
  }

  Future<List<DriverOnboardingModel>> _fetchDriverRequests({
    OnboardingStatus? status,
    int limit = 20,
    String? lastId,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection(_driverRequestsCollection);

    // Get all documents and sort in memory to avoid index requirements
    query = query.limit(100);

    final snapshot = await query.get();

    var results = snapshot.docs.map((doc) {
      final data = _normalizeDriverData(doc.id, doc.data());
      return DriverOnboardingModel.fromJson(data);
    }).toList();

    // Filter by status in memory if provided
    if (status != null) {
      results = results.where((r) => r.status == status).toList();
    }

    // Sort by createdAt descending in memory
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return results.take(limit).toList();
  }

  Future<List<StoreOnboardingModel>> _fetchStoreRequests({
    OnboardingStatus? status,
    int limit = 20,
    String? lastId,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection(_storeRequestsCollection);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    query = query.orderBy('createdAt', descending: true);

    if (lastId != null) {
      final lastDoc = await _firestore
          .collection(_storeRequestsCollection)
          .doc(lastId)
          .get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = {...doc.data(), 'id': doc.id};
      return StoreOnboardingModel.fromJson(data);
    }).toList();
  }

  @override
  Future<dynamic> getRequestById(String id) async {
    // Try driver requests first
    var doc =
        await _firestore.collection(_driverRequestsCollection).doc(id).get();

    if (doc.exists && doc.data() != null) {
      final data = _normalizeDriverData(doc.id, doc.data()!);
      return DriverOnboardingModel.fromJson(data);
    }

    // Try store requests
    doc = await _firestore.collection(_storeRequestsCollection).doc(id).get();

    if (doc.exists && doc.data() != null) {
      final data = {...doc.data()!, 'id': doc.id};
      return StoreOnboardingModel.fromJson(data);
    }

    throw Exception('Request not found: $id');
  }

  @override
  Future<void> approveRequest(String id, {String? notes}) async {
    final updateData = {
      'status': OnboardingStatus.approved.name,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': 'admin', // TODO: Get actual admin ID
      if (notes != null) 'notes': notes,
    };

    // Try to update in driver requests
    final driverDoc =
        await _firestore.collection(_driverRequestsCollection).doc(id).get();

    if (driverDoc.exists) {
      await _firestore
          .collection(_driverRequestsCollection)
          .doc(id)
          .update(updateData);
      return;
    }

    // Try store requests
    await _firestore
        .collection(_storeRequestsCollection)
        .doc(id)
        .update(updateData);
  }

  @override
  Future<void> rejectRequest(String id, String reason) async {
    final updateData = {
      'status': OnboardingStatus.rejected.name,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': 'admin', // TODO: Get actual admin ID
      'rejectionReason': reason,
    };

    // Try to update in driver requests
    final driverDoc =
        await _firestore.collection(_driverRequestsCollection).doc(id).get();

    if (driverDoc.exists) {
      await _firestore
          .collection(_driverRequestsCollection)
          .doc(id)
          .update(updateData);
      return;
    }

    // Try store requests
    await _firestore
        .collection(_storeRequestsCollection)
        .doc(id)
        .update(updateData);
  }

  @override
  Future<void> markUnderReview(String id) async {
    final updateData = {
      'status': OnboardingStatus.underReview.name,
    };

    // Try to update in driver requests
    final driverDoc =
        await _firestore.collection(_driverRequestsCollection).doc(id).get();

    if (driverDoc.exists) {
      await _firestore
          .collection(_driverRequestsCollection)
          .doc(id)
          .update(updateData);
      return;
    }

    // Try store requests
    await _firestore
        .collection(_storeRequestsCollection)
        .doc(id)
        .update(updateData);
  }

  @override
  Future<OnboardingStats> getStats() async {
    // Get driver requests stats
    final driverSnapshot =
        await _firestore.collection(_driverRequestsCollection).get();

    // Get store requests stats
    final storeSnapshot =
        await _firestore.collection(_storeRequestsCollection).get();

    int pending = 0;
    int approved = 0;
    int rejected = 0;
    int pendingDrivers = 0;
    int pendingStores = 0;

    // Count driver requests
    for (final doc in driverSnapshot.docs) {
      final status = doc.data()['status'] as String?;
      switch (status) {
        case 'pending':
        case 'underReview':
          pending++;
          pendingDrivers++;
        case 'approved':
          approved++;
        case 'rejected':
          rejected++;
      }
    }

    // Count store requests
    for (final doc in storeSnapshot.docs) {
      final status = doc.data()['status'] as String?;
      switch (status) {
        case 'pending':
        case 'underReview':
          pending++;
          pendingStores++;
        case 'approved':
          approved++;
        case 'rejected':
          rejected++;
      }
    }

    return OnboardingStats(
      totalRequests: driverSnapshot.size + storeSnapshot.size,
      pendingRequests: pending,
      approvedRequests: approved,
      rejectedRequests: rejected,
      pendingDriverRequests: pendingDrivers,
      pendingStoreRequests: pendingStores,
    );
  }

  /// Normalizes driver data from Deliverzler's format.
  ///
  /// Deliverzler stores dates as millisecondsSinceEpoch (int),
  /// while our models expect DateTime or ISO8601 strings.
  Map<String, dynamic> _normalizeDriverData(
    String docId,
    Map<String, dynamic> data,
  ) {
    return {
      ...data,
      'id': docId,
      'type': 'driver',
      // Convert milliseconds to DateTime
      'createdAt': _parseTimestamp(data['createdAt']),
      'reviewedAt': _parseTimestamp(data['reviewedAt']),
      'licenseExpiryDate': _parseTimestamp(data['licenseExpiryDate']),
    };
  }

  /// Parses various timestamp formats to DateTime.
  ///
  /// Supports:
  /// - int (millisecondsSinceEpoch from Deliverzler)
  /// - Timestamp (Firestore)
  /// - String (ISO8601)
  /// - DateTime (passthrough)
  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is Timestamp) return value.toDate();

    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

    if (value is String) return DateTime.tryParse(value);

    return null;
  }
}
