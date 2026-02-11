import 'package:equatable/equatable.dart';

/// Admin entity representing an admin user.
class AdminEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final String? createdBy;

  const AdminEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.createdAt,
    this.createdBy,
  });

  bool get isSuperAdmin => role == 'superAdmin';

  @override
  List<Object?> get props =>
      [id, name, email, role, isActive, createdAt, createdBy];
}
