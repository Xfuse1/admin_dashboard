import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/driver_application_entity.dart';

class DriverApplicationsRepository {
  final FirebaseFirestore _firestore;

  DriverApplicationsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection names as constants for maintainability
  static const String _applicationsCollection = 'driver_requests';
  static const String _driversCollection = 'drivers';

  /// Get all driver applications stream
  Stream<List<DriverApplicationEntity>> getApplicationsStream() {
    return _firestore
        .collection(_applicationsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _applicationFromFirestore(doc))
            .toList());
  }

  /// Get applications by status
  Stream<List<DriverApplicationEntity>> getApplicationsByStatus(
      ApplicationStatus status) {
    return _firestore
        .collection(_applicationsCollection)
        .where('status', isEqualTo: status.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _applicationFromFirestore(doc))
            .toList());
  }

  /// Get single application
  Future<DriverApplicationEntity?> getApplication(String applicationId) async {
    final doc = await _firestore
        .collection(_applicationsCollection)
        .doc(applicationId)
        .get();
    if (!doc.exists) return null;
    return _applicationFromFirestore(doc);
  }

  /// Update application status
  /// Uses Firestore batch write for better performance when approving
  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus newStatus,
    required String reviewedBy,
    String? rejectionReason,
  }) async {
    final updateData = <String, dynamic>{
      'status': newStatus.value,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': reviewedBy,
    };

    if (rejectionReason != null && newStatus == ApplicationStatus.rejected) {
      updateData['rejectionReason'] = rejectionReason;
    }

    // Use batch write for atomic operations when approving
    if (newStatus == ApplicationStatus.approved) {
      final application = await getApplication(applicationId);
      if (application == null) return;

      final batch = _firestore.batch();

      // Update application status
      batch.update(
        _firestore.collection(_applicationsCollection).doc(applicationId),
        updateData,
      );

      // Create/update driver profile
      batch.set(
        _firestore.collection(_driversCollection).doc(application.userId),
        {
          'name': application.name,
          'email': application.email,
          'phone': application.phone,
          'vehicleType': application.vehicleType.value,
          'vehiclePlate': application.vehiclePlate,
          'photoUrl': application.photoUrl,
          'isActive': true,
          'isApproved': true,
          'isOnline': false,
          'rating': 0.0,
          'totalDeliveries': 0,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } else {
      // For non-approval status updates, single write is sufficient
      await _firestore
          .collection(_applicationsCollection)
          .doc(applicationId)
          .update(updateData);
    }
  }

  /// Convert Firestore document to entity
  DriverApplicationEntity _applicationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverApplicationEntity(
      id: doc.id,
      userId: data['userId'] ?? '',
      status: ApplicationStatus.fromString(data['status']),
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      idNumber: data['idNumber'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      licenseExpiryDate:
          _parseDateTime(data['licenseExpiryDate']) ?? DateTime.now(),
      vehicleType: VehicleType.fromString(data['vehicleType']),
      vehiclePlate: data['vehiclePlate'] ?? '',
      photoUrl: data['photoUrl'],
      idDocumentUrl: data['idDocumentUrl'],
      licenseUrl: data['licenseUrl'],
      vehicleRegistrationUrl: data['vehicleRegistrationUrl'],
      vehicleInsuranceUrl: data['vehicleInsuranceUrl'],
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      reviewedAt: _parseDateTime(data['reviewedAt']),
      reviewedBy: data['reviewedBy'],
      rejectionReason: data['rejectionReason'],
      notes: data['notes'],
    );
  }

  /// Parse DateTime from Firestore data (handles both Timestamp and int)
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
