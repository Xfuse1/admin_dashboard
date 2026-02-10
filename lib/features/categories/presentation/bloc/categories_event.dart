import 'package:equatable/equatable.dart';

import '../../domain/entities/subcategory_entity.dart';

/// Categories events
abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

/// Load all categories with subcategories
class LoadCategories extends CategoriesEvent {
  const LoadCategories();
}

/// Refresh categories (force re-fetch, bypass cache)
class RefreshCategories extends CategoriesEvent {
  const RefreshCategories();
}

/// Search categories locally
class SearchCategories extends CategoriesEvent {
  final String query;

  const SearchCategories(this.query);

  @override
  List<Object?> get props => [query];
}

/// Select a category to view its subcategories
class SelectCategory extends CategoriesEvent {
  final String? categoryId;

  const SelectCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Add a new category with subcategories (batch write)
class AddCategoryEvent extends CategoriesEvent {
  final String name;
  final String description;
  final List<SubcategoryInput> subcategories;

  const AddCategoryEvent({
    required this.name,
    required this.description,
    required this.subcategories,
  });

  @override
  List<Object?> get props => [name, description, subcategories];
}

/// Update an existing category
class UpdateCategoryEvent extends CategoriesEvent {
  final String categoryId;
  final String name;
  final String description;

  const UpdateCategoryEvent({
    required this.categoryId,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [categoryId, name, description];
}

/// Delete a category and all its subcategories
class DeleteCategoryEvent extends CategoriesEvent {
  final String categoryId;

  const DeleteCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Add a subcategory to an existing category
class AddSubcategoryEvent extends CategoriesEvent {
  final String categoryId;
  final String name;
  final String description;

  const AddSubcategoryEvent({
    required this.categoryId,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [categoryId, name, description];
}

/// Update an existing subcategory
class UpdateSubcategoryEvent extends CategoriesEvent {
  final String categoryId;
  final String subcategoryId;
  final String name;
  final String description;

  const UpdateSubcategoryEvent({
    required this.categoryId,
    required this.subcategoryId,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [categoryId, subcategoryId, name, description];
}

/// Delete a subcategory
class DeleteSubcategoryEvent extends CategoriesEvent {
  final String categoryId;
  final String subcategoryId;

  const DeleteSubcategoryEvent({
    required this.categoryId,
    required this.subcategoryId,
  });

  @override
  List<Object?> get props => [categoryId, subcategoryId];
}
