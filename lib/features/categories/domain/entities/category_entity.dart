import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'subcategory_entity.dart';

/// Category entity representing a main category (e.g. الملابس).
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SubcategoryEntity> subcategories;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.subcategories = const [],
  });

  /// Creates a [CategoryEntity] from a Firestore document map.
  factory CategoryEntity.fromMap(String id, Map<String, dynamic> map) {
    return CategoryEntity(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
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
  CategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SubcategoryEntity>? subcategories,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subcategories: subcategories ?? this.subcategories,
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
      [id, name, description, createdAt, updatedAt, subcategories];
}
