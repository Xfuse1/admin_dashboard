import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Subcategory entity representing a sub-division within a category.
class SubcategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String parentCategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubcategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.parentCategoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [SubcategoryEntity] from a Firestore document map.
  factory SubcategoryEntity.fromMap(
    String id,
    Map<String, dynamic> map, {
    required String parentCategoryId,
  }) {
    return SubcategoryEntity(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      parentCategoryId: parentCategoryId,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  /// Converts to a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a copy with optional overrides.
  SubcategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? parentCategoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubcategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  @override
  List<Object?> get props =>
      [id, name, description, parentCategoryId, createdAt, updatedAt];
}

/// Temporary input model for subcategories in forms (before saving to Firestore).
class SubcategoryInput {
  final String name;
  final String description;

  const SubcategoryInput({
    required this.name,
    required this.description,
  });
}
