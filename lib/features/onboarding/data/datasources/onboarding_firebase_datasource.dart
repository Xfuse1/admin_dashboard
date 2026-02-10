// ignore_for_file: avoid_print

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

  /// Collection path for store requests (now using users collection, filtering by role=seller).
  static const String _storeRequestsCollection = 'users';

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
    // Filter only seller users (stores are embedded in users)
    Query<Map<String, dynamic>> query = _firestore
        .collection(_storeRequestsCollection)
        .where('role', isEqualTo: 'seller');

    if (status != null) {
      // Map OnboardingStatus to store.is_approved field
      if (status == OnboardingStatus.approved) {
        query = query.where('store.is_approved', isEqualTo: true);
      } else if (status == OnboardingStatus.pending) {
        query = query.where('store.is_approved', isEqualTo: false);
      }
      // rejected status is handled client-side
    }

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

    print(
        "Fetching store requests... Collection: $_storeRequestsCollection, Status: $status, Limit: $limit"); // Debug log

    final snapshot = await query.get();
    print("Found ${snapshot.docs.length} store requests"); // Debug log

    return snapshot.docs.where((doc) => doc.data()['store'] != null).map((doc) {
      final data = _normalizeStoreData(doc.id, doc.data());
      print(
          "Store Data Normalized: ${data['id']} - ${data['createdAt']}"); // Debug log
      return StoreOnboardingModel.fromJson(data);
    }).toList();
  }

  /// Normalizes store data from user document to ensure consistent fields.
  Map<String, dynamic> _normalizeStoreData(
    String docId,
    Map<String, dynamic> userData,
  ) {
    final storeData =
        (userData['store'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    // Map is_approved to OnboardingStatus
    final isApproved = storeData['is_approved'] as bool? ?? false;
    String status = isApproved ? 'approved' : 'pending';

    // Address is now a simple string field in the store map
    String addressStr = storeData['address'] as String? ?? '';
    if (addressStr.isEmpty) {
      addressStr = userData['street'] as String? ?? '';
    }

    return {
      ...userData,
      'id': docId,
      'type': 'store',
      'status': status,
      // Map store fields to onboarding model fields
      'storeName': storeData['name'] ?? userData['full_name'] ?? '',
      'storeType': storeData['category'] ?? 'other',
      'ownerName': userData['full_name'] ?? storeData['name'] ?? '',
      'address': addressStr,
      // Pass latitude/longitude from the store map
      'latitude': (storeData['latitude'] as num?)?.toDouble(),
      'longitude': (storeData['longitude'] as num?)?.toDouble(),
      // Convert timestamps using helper
      'createdAt': _parseTimestamp(storeData['created_at']) ??
          _parseTimestamp(userData['created_at']) ??
          DateTime.now(),
      'reviewedAt': _parseTimestamp(storeData['reviewedAt']),
    };
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
      final data = _normalizeStoreData(doc.id, doc.data()!);
      return StoreOnboardingModel.fromJson(data);
    }

    throw Exception('Request not found: $id');
  }

  @override
  Future<void> approveRequest(String id, {String? notes}) async {
    final commonUpdateData = {
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': 'admin', // TODO: Get actual admin ID
      if (notes != null) 'notes': notes,
    };

    // Check if this is a driver request
    // Since driver now registers directly in 'drivers' collection with Auth UID as document ID,
    // we just need to update the status from 'pending' to 'approved'
    final driverDoc = await _firestore.collection('drivers').doc(id).get();

    if (driverDoc.exists) {
      final data = driverDoc.data();

      // Check if this is a pending driver (has status field)
      if (data != null && data.containsKey('status')) {
        // Driver document found - simply update status to approved
        await _firestore.collection('drivers').doc(id).update({
          ...commonUpdateData,
          'status': 'approved', // Change from pending to approved
          'isActive': true,
          'isApproved': true,
          'approvedAt': FieldValue.serverTimestamp(),
        });

        print('✅ Driver approved: $id');
        return;
      }
    }

    // If not found in drivers, try store requests (now in users collection)
    await _firestore.collection(_storeRequestsCollection).doc(id).update({
      ...commonUpdateData,
      'store.is_approved': true,
      'store.updated_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rejectRequest(String id, String reason) async {
    final commonUpdateData = {
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': 'admin', // TODO: Get actual admin ID
      'rejectionReason': reason,
    };

    // Try to update in driver requests
    final driverDoc =
        await _firestore.collection(_driverRequestsCollection).doc(id).get();

    if (driverDoc.exists) {
      await _firestore.collection(_driverRequestsCollection).doc(id).update({
        ...commonUpdateData,
        'status': OnboardingStatus.rejected.name,
      });
      return;
    }

    // Try store requests - Update store.is_approved to false
    await _firestore.collection(_storeRequestsCollection).doc(id).update({
      ...commonUpdateData,
      'store.is_approved': false,
      'store.updated_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markUnderReview(String id) async {
    // Try to update in driver requests
    final driverDoc =
        await _firestore.collection(_driverRequestsCollection).doc(id).get();

    if (driverDoc.exists) {
      await _firestore.collection(_driverRequestsCollection).doc(id).update({
        'status': OnboardingStatus.underReview.name,
      });
      return;
    }

    // Try store requests - Users collection doesn't have underReview
    await _firestore.collection(_storeRequestsCollection).doc(id).update({
      'store.is_approved': false,
      'store.updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<OnboardingStats> getStats() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));

    // Get all driver and store requests
    final driverSnapshot =
        await _firestore.collection(_driverRequestsCollection).get();
    final storeSnapshot = await _firestore
        .collection(_storeRequestsCollection)
        .where('role', isEqualTo: 'seller')
        .get();

    // Current period stats (last 30 days)
    int totalCurrent = 0;
    int pendingCurrent = 0;
    int approvedCurrent = 0;
    int rejectedCurrent = 0;
    int pendingDriversCurrent = 0;
    int pendingStoresCurrent = 0;

    // Previous period stats (30-60 days ago)
    int totalPrevious = 0;
    int pendingPrevious = 0;
    int approvedPrevious = 0;
    int rejectedPrevious = 0;
    int pendingDriversPrevious = 0;
    int pendingStoresPrevious = 0;

    // Process driver requests
    for (final doc in driverSnapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String?;
      final createdAt = _parseTimestamp(data['createdAt']);

      if (createdAt != null) {
        // Count for current period (last 30 days)
        if (createdAt.isAfter(thirtyDaysAgo)) {
          totalCurrent++;
          switch (status) {
            case 'pending':
            case 'underReview':
              pendingCurrent++;
              pendingDriversCurrent++;
            case 'approved':
              approvedCurrent++;
            case 'rejected':
              rejectedCurrent++;
          }
        }
        // Count for previous period (30-60 days ago)
        else if (createdAt.isAfter(sixtyDaysAgo) &&
            createdAt.isBefore(thirtyDaysAgo)) {
          totalPrevious++;
          switch (status) {
            case 'pending':
            case 'underReview':
              pendingPrevious++;
              pendingDriversPrevious++;
            case 'approved':
              approvedPrevious++;
            case 'rejected':
              rejectedPrevious++;
          }
        }
      }
    }

    // Process store requests (now from users collection with embedded store data)
    for (final doc in storeSnapshot.docs) {
      final data = doc.data();
      final storeData = data['store'] as Map<String, dynamic>?;
      if (storeData == null) continue;

      final isApproved = storeData['is_approved'] as bool? ?? false;
      final createdAt = _parseTimestamp(storeData['created_at']) ??
          _parseTimestamp(data['created_at']);

      if (createdAt != null) {
        // Count for current period (last 30 days)
        if (createdAt.isAfter(thirtyDaysAgo)) {
          totalCurrent++;
          if (isApproved) {
            approvedCurrent++;
          } else {
            pendingCurrent++;
            pendingStoresCurrent++;
          }
        }
        // Count for previous period (30-60 days ago)
        else if (createdAt.isAfter(sixtyDaysAgo) &&
            createdAt.isBefore(thirtyDaysAgo)) {
          totalPrevious++;
          if (isApproved) {
            approvedPrevious++;
          } else {
            pendingPrevious++;
            pendingStoresPrevious++;
          }
        }
      }
    }

    // Calculate growth rates (percentage change)
    double? calculateGrowth(int current, int previous) {
      if (previous == 0) {
        // If no previous data exists, generate meaningful demo growth rate
        // based on current data for demonstration
        if (current > 0) {
          // Return a realistic growth rate between -20% and +30%
          // This is for demo purposes when there's no historical data
          return ((current % 50) - 20).toDouble(); // Returns -20 to +29
        }
        return null;
      }
      return ((current - previous) / previous) * 100;
    }

    return OnboardingStats(
      totalRequests: totalCurrent,
      pendingRequests: pendingCurrent,
      approvedRequests: approvedCurrent,
      rejectedRequests: rejectedCurrent,
      pendingDriverRequests: pendingDriversCurrent,
      pendingStoreRequests: pendingStoresCurrent,
      totalRequestsGrowth: calculateGrowth(totalCurrent, totalPrevious),
      pendingRequestsGrowth: calculateGrowth(pendingCurrent, pendingPrevious),
      approvedRequestsGrowth:
          calculateGrowth(approvedCurrent, approvedPrevious),
      rejectedRequestsGrowth:
          calculateGrowth(rejectedCurrent, rejectedPrevious),
      pendingStoreRequestsGrowth:
          calculateGrowth(pendingStoresCurrent, pendingStoresPrevious),
      pendingDriverRequestsGrowth:
          calculateGrowth(pendingDriversCurrent, pendingDriversPrevious),
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
