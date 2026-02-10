import 'package:equatable/equatable.dart';

import '../../domain/entities/category_entity.dart';

/// Categories states
abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

/// Loading state
class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

/// Loaded state with all categories and optional filters
class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;
  final List<CategoryEntity> filteredCategories;
  final CategoryEntity? selectedCategory;
  final String? searchQuery;

  const CategoriesLoaded({
    required this.categories,
    required this.filteredCategories,
    this.selectedCategory,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        categories,
        filteredCategories,
        selectedCategory,
        searchQuery,
      ];

  CategoriesLoaded copyWith({
    List<CategoryEntity>? categories,
    List<CategoryEntity>? filteredCategories,
    CategoryEntity? selectedCategory,
    String? searchQuery,
    bool clearSelectedCategory = false,
  }) {
    return CategoriesLoaded(
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Error state
class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Action success state (for toast then restore previous state)
class CategoriesActionSuccess extends CategoriesState {
  final String message;
  final CategoriesState previousState;

  const CategoriesActionSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}
