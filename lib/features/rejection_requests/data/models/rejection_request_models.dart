import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/rejection_request_entities.dart';

/// Data model for rejection request
class RejectionRequestModel extends RejectionRequestEntity {
  const RejectionRequestModel({
    required super.requestId,
    required super.orderId,
    required super.driverId,
    required super.driverName,
    required super.reason,
    required super.adminDecision,
    super.adminComment,
    required super.requestedAt,
    super.decidedAt,
  });

  /// Create from Firestore document
  factory RejectionRequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return RejectionRequestModel(
      requestId: snapshot.id,
      orderId: data['orderId'] as String,
      driverId: data['driverId'] as String,
      driverName: data['driverName'] as String,
      reason: data['reason'] as String,
      adminDecision: data['adminDecision'] as String,
      adminComment: data['adminComment'] as String?,
      // Support both conventions (createdAt is used in deliverzler app)
      requestedAt: data.containsKey('createdAt') 
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['requestedAt'] as Timestamp).toDate(),
      decidedAt: data['decidedAt'] != null
          ? (data['decidedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'driverId': driverId,
      'driverName': driverName,
      'reason': reason,
      'adminDecision': adminDecision,
      'adminComment': adminComment,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'decidedAt': decidedAt != null ? Timestamp.fromDate(decidedAt!) : null,
    };
  }

  /// Create from entity
  factory RejectionRequestModel.fromEntity(RejectionRequestEntity entity) {
    return RejectionRequestModel(
      requestId: entity.requestId,
      orderId: entity.orderId,
      driverId: entity.driverId,
      driverName: entity.driverName,
      reason: entity.reason,
      adminDecision: entity.adminDecision,
      adminComment: entity.adminComment,
      requestedAt: entity.requestedAt,
      decidedAt: entity.decidedAt,
    );
  }
}
