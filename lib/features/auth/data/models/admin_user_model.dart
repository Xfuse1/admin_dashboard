import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_user.dart';

/// Admin user data model.
class AdminUserModel extends AdminUser {
  const AdminUserModel({
    required super.id,
    required super.email,
    required super.name,
    super.photoUrl,
    required super.role,
    required super.createdAt,
    super.lastLoginAt,
  });

  /// Creates model from JSON map.
  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      } else if (value is DateTime) {
        return value;
      }
      return DateTime.now(); // Fallback
    }

    return AdminUserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? 'Admin').toString(),
      photoUrl: json['photoUrl']?.toString(),
      role: (json['role'] ?? 'admin').toString(),
      createdAt: parseDate(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null ? parseDate(json['lastLoginAt']) : null,
    );
  }

  /// Converts model to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  /// Creates model from entity.
  factory AdminUserModel.fromEntity(AdminUser entity) {
    return AdminUserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      photoUrl: entity.photoUrl,
      role: entity.role,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }
}
