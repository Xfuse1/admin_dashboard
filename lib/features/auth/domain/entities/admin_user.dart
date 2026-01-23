import 'package:equatable/equatable.dart';

/// Admin user entity.
class AdminUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        role,
        createdAt,
        lastLoginAt,
      ];

  AdminUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
