import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/subcategory_entity.dart';

/// Firebase datasource for categories with in-memory caching.
///
/// Uses [collectionGroup] to fetch all subcategories in a single query,
/// avoiding N+1 problem. Uses [WriteBatch] for atomic multi-document writes.
class CategoriesFirebaseDatasource {
  final FirebaseFirestore _firestore;

  CategoriesFirebaseDatasource(this._firestore);

  // ============================================
  // 🗃️ CACHE
  // ============================================

  static const _cacheDuration = Duration(minutes: 5);
  List<CategoryEntity>? _cachedCategories;
  DateTime? _lastFetchTime;

  bool get _isCacheValid =>
      _cachedCategories != null &&
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < _cacheDuration;

  void invalidateCache() {
    _cachedCategories = null;
    _lastFetchTime = null;
  }

  // ============================================
  // 📖 READ OPERATIONS
  // ============================================

  /// Fetches all categories with their subcategories using only 2 Firestore queries.
  ///
  /// 1. Query all documents from `categories` collection.
  /// 2. Query all documents using `collectionGroup('subcategories')`.
  /// 3. Group subcategories by parent category ID in memory.
  ///
  /// This avoids the N+1 problem entirely.
  Future<List<CategoryEntity>> getCategories(
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid) {
      return _cachedCategories!;
    }

    try {
      // Two parallel queries instead of N+1
      final results = await Future.wait([
        _firestore
            .collection('categories')
            .orderBy('created_at', descending: true)
            .get(),
        _firestore.collectionGroup('subcategories').get(),
      ]);

      final categoriesSnapshot = results[0];
      final subcategoriesSnapshot = results[1];

      // Group subcategories by parent category ID
      final subcategoriesMap = <String, List<SubcategoryEntity>>{};
      for (final doc in subcategoriesSnapshot.docs) {
        // Get parent category ID from the document reference path:
        // categories/{categoryId}/subcategories/{subId}
        final parentCategoryId = doc.reference.parent.parent!.id;
        final subcategory = SubcategoryEntity.fromMap(
          doc.id,
          doc.data(),
          parentCategoryId: parentCategoryId,
        );
        subcategoriesMap
            .putIfAbsent(parentCategoryId, () => [])
            .add(subcategory);
      }

      // Build category entities with their subcategories
      final categories = categoriesSnapshot.docs.map((doc) {
        final category = CategoryEntity.fromMap(doc.id, doc.data());
        final subs = subcategoriesMap[doc.id] ?? [];
        return category.copyWith(subcategories: subs);
      }).toList();

      // Update cache
      _cachedCategories = categories;
      _lastFetchTime = DateTime.now();

      return categories;
    } catch (e) {
      // Return stale cache on error if available
      if (_cachedCategories != null) return _cachedCategories!;
      throw Exception('فشل في جلب الأقسام: $e');
    }
  }

  // ============================================
  // ✏️ CATEGORY CRUD
  // ============================================

  /// Adds a new category with its subcategories in a single atomic batch write.
  Future<CategoryEntity> addCategory({
    required String name,
    required String description,
    required List<SubcategoryInput> subcategories,
  }) async {
    try {
      final batch = _firestore.batch();
      final now = FieldValue.serverTimestamp();

      // 1. Create category document
      final categoryRef = _firestore.collection('categories').doc();
      batch.set(categoryRef, {
        'name': name,
        'description': description,
        'created_at': now,
        'updated_at': now,
      });

      // 2. Create all subcategory documents in the subcollection
      final subcategoryEntities = <SubcategoryEntity>[];
      for (final sub in subcategories) {
        final subRef = categoryRef.collection('subcategories').doc();
        batch.set(subRef, {
          'name': sub.name,
          'description': sub.description,
          'created_at': now,
          'updated_at': now,
        });
        subcategoryEntities.add(SubcategoryEntity(
          id: subRef.id,
          name: sub.name,
          description: sub.description,
          parentCategoryId: categoryRef.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      // 3. Commit all writes atomically
      await batch.commit();

      invalidateCache();

      return CategoryEntity(
        id: categoryRef.id,
        name: name,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subcategories: subcategoryEntities,
      );
    } catch (e) {
      throw Exception('فشل في إضافة القسم: $e');
    }
  }

  /// Updates an existing category's name and description.
  Future<void> updateCategory({
    required String categoryId,
    required String name,
    required String description,
  }) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'name': name,
        'description': description,
        'updated_at': FieldValue.serverTimestamp(),
      });
      invalidateCache();
    } catch (e) {
      throw Exception('فشل في تعديل القسم: $e');
    }
  }

  /// Deletes a category and all its subcategories using batch delete.
  Future<void> deleteCategory(String categoryId) async {
    try {
      final batch = _firestore.batch();

      // 1. Get all subcategories to delete them
      final subcategoriesSnapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('subcategories')
          .get();

      for (final doc in subcategoriesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 2. Delete the category document itself
      batch.delete(_firestore.collection('categories').doc(categoryId));

      // 3. Commit all deletes atomically
      await batch.commit();

      invalidateCache();
    } catch (e) {
      throw Exception('فشل في حذف القسم: $e');
    }
  }

  // ============================================
  // ✏️ SUBCATEGORY CRUD
  // ============================================

  /// Adds a subcategory to an existing category.
  Future<SubcategoryEntity> addSubcategory({
    required String categoryId,
    required String name,
    required String description,
  }) async {
    try {
      final ref = _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('subcategories')
          .doc();

      await ref.set({
        'name': name,
        'description': description,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      invalidateCache();

      return SubcategoryEntity(
        id: ref.id,
        name: name,
        description: description,
        parentCategoryId: categoryId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('فشل في إضافة القسم الفرعي: $e');
    }
  }

  /// Updates a subcategory's name and description.
  Future<void> updateSubcategory({
    required String categoryId,
    required String subcategoryId,
    required String name,
    required String description,
  }) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('subcategories')
          .doc(subcategoryId)
          .update({
        'name': name,
        'description': description,
        'updated_at': FieldValue.serverTimestamp(),
      });
      invalidateCache();
    } catch (e) {
      throw Exception('فشل في تعديل القسم الفرعي: $e');
    }
  }

  /// Deletes a subcategory.
  Future<void> deleteSubcategory({
    required String categoryId,
    required String subcategoryId,
  }) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('subcategories')
          .doc(subcategoryId)
          .delete();
      invalidateCache();
    } catch (e) {
      throw Exception('فشل في حذف القسم الفرعي: $e');
    }
  }
}
