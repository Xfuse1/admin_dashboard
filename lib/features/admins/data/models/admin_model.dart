import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin_entity.dart';

/// Data model for Admin with Firestore serialization.
class AdminModel extends AdminEntity {
  const AdminModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.isActive,
    super.createdAt,
    super.createdBy,
  });

  /// Create from Firestore document data.
  factory AdminModel.fromFirestore(String id, Map<String, dynamic> data) {
    return AdminModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'admin',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'] as String?,
    );
  }

  /// Convert to Firestore document data.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}
