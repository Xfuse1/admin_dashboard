import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/categories_firebase_datasource.dart';
import '../../domain/entities/category_entity.dart';
import 'categories_event.dart';
import 'categories_state.dart';

/// Categories BLoC — manages categories and subcategories state.
///
/// Uses simplified pattern (DataSource → BLoC) without UseCases or Either.
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesFirebaseDatasource _datasource;

  /// Local copy of all categories for filtering without re-fetching
  List<CategoryEntity> _allCategories = [];

  CategoriesBloc(this._datasource) : super(const CategoriesInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<RefreshCategories>(_onRefreshCategories);
    on<SearchCategories>(_onSearchCategories);
    on<SelectCategory>(_onSelectCategory);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<AddSubcategoryEvent>(_onAddSubcategory);
    on<UpdateSubcategoryEvent>(_onUpdateSubcategory);
    on<DeleteSubcategoryEvent>(_onDeleteSubcategory);
  }

  // ============================================
  // 📖 LOAD & SEARCH
  // ============================================

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());
    try {
      final categories = await _datasource.getCategories();
      _allCategories = categories;
      emit(CategoriesLoaded(
        categories: categories,
        filteredCategories: categories,
      ));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> _onRefreshCategories(
    RefreshCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(const CategoriesLoading());
    try {
      final categories = await _datasource.getCategories(forceRefresh: true);
      _allCategories = categories;
      emit(CategoriesLoaded(
        categories: categories,
        filteredCategories: categories,
      ));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  Future<void> _onSearchCategories(
    SearchCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    final query = event.query.trim().toLowerCase();

    if (query.isEmpty) {
      emit(CategoriesLoaded(
        categories: _allCategories,
        filteredCategories: _allCategories,
      ));
      return;
    }

    final filtered = _allCategories.where((category) {
      final nameMatch = category.name.toLowerCase().contains(query);
      final descMatch = category.description.toLowerCase().contains(query);
      final subMatch = category.subcategories.any(
        (sub) =>
            sub.name.toLowerCase().contains(query) ||
            sub.description.toLowerCase().contains(query),
      );
      return nameMatch || descMatch || subMatch;
    }).toList();

    emit(CategoriesLoaded(
      categories: _allCategories,
      filteredCategories: filtered,
      searchQuery: event.query,
    ));
  }

  Future<void> _onSelectCategory(
    SelectCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    final currentState = state;
    if (currentState is CategoriesLoaded) {
      if (event.categoryId == null) {
        emit(currentState.copyWith(clearSelectedCategory: true));
        return;
      }
      final selected = _allCategories.firstWhere(
        (c) => c.id == event.categoryId,
        orElse: () => _allCategories.first,
      );
      emit(currentState.copyWith(selectedCategory: selected));
    }
  }

  // ============================================
  // ✏️ CATEGORY CRUD
  // ============================================

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    final currentState = state;
    try {
      final newCategory = await _datasource.addCategory(
        name: event.name,
        description: event.description,
        subcategories: event.subcategories,
      );

      // Prepend to local list
      _allCategories = [newCategory, ..._allCategories];

      final loadedState = CategoriesLoaded(
        categories: _allCategories,
        filteredCategories: _allCategories,
      );

      emit(CategoriesActionSuccess(
        message: 'تم إضافة القسم بنجاح',
        previousState: loadedState,
      ));
      emit(loadedState);
    } catch (e) {
      emit(CategoriesError('فشل في إضافة القسم: $e'));
      if (currentState is CategoriesLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    final currentState = state;
    try {
      await _datasource.updateCategory(
        categoryId: event.categoryId,
        name: event.name,
        description: event.description,
      );

      // Update local list
      _allCategories = _allCategories.map((c) {
        if (c.id == event.categoryId) {
          return c.copyWith(
            name: event.name,
            description: event.description,
            updatedAt: DateTime.now(),
          );
        }
        return c;
      }).toList();

      final selectedId = currentState is CategoriesLoaded
          ? currentState.selectedCategory?.id
          : null;
      final selectedCategory = selectedId != null
          ? _allCategories.firstWhere((c) => c.id == selectedId)
          : null;

      final loadedState = CategoriesLoaded(
        categories: _allCategories,
        filteredCategories: _allCategories,
        selectedCategory: selectedCategory,
      );

      emit(CategoriesActionSuccess(
        message: 'تم تعديل القسم بنجاح',
        previousState: loadedState,
      ));
      emit(loadedState);
    } catch (e) {
      emit(CategoriesError('فشل في تعديل القسم: $e'));
      if (currentState is CategoriesLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    final currentState = state;
    try {
      await _datasource.deleteCategory(event.categoryId);

      // Remove from local list
      _allCategories =
          _allCategories.where((c) => c.id != event.categoryId).toList();

      final loadedState = CategoriesLoaded(
        categories: _allCategories,
        filteredCategories: _allCategories,
      );

      emit(CategoriesActionSuccess(
        message: 'تم حذف القسم بنجاح',
        previousState: loadedState,
      ));
      emit(loadedState);
    } catch (e) {
      emit(CategoriesError('فشل في حذف القسم: $e'));
      if (currentState is CategoriesLoaded) {
        emit(currentState);
      }
    }
  }

  // ============================================
  // ✏️ SUBCATEGORY CRUD
  // ============================================

  Future<void> _onAddSubcategory(
    AddSubcategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    final currentState = state;
    try {
      final newSub = await _datasource.addSubcategory(
        categoryId: event.categoryId,
        name: event.name,
        description: event.description,
      );

      // Update local list
      _allCategories = _allCategories.map((c) {
        if (c.id == event.categoryId) {
          return c.copyWith(subcategories: [...c.subcategories, newSub]);
        }
        return c;
      }).toList();

      final selectedCategory = _allCategories.firstWhere(
        (c) => c.id == event.categoryId,
      );

      final loadedState = CategoriesLoaded(
        categories: _allCategories,
        filteredCategories: _allCategories,
        selectedCategory: selectedCategory,
      );

      emit(CategoriesActionSuccess(
        message: 'تم إضافة القسم الفرعي بنجاح',
        previousState: loadedState,
      ));
      emit(loadedState);
    } catch (e) {
      emit(CategoriesError('فشل في إضافة القسم الفرعي: $e'));
      if (currentState is CategoriesLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateSubcategory(
    UpdateSubcategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    final currentState = state;
    try {
      await _datasource.updateSubcategory(
        categoryId: event.categoryId,
        subcategoryId: event.subcategoryId,
        name: event.name,
        description: event.description,
      );

      // Update local list
      _allCategories = _allCategories.map((c) {
        if (c.id == event.categoryId) {
          final updatedSubs = c.subcategories.map((s) {
            if (s.id == event.subcategoryId) {
              return s.copyWith(
                name: event.name,
                description: event.description,
                updatedAt: DateTime.now(),
              );
            }
            return s;
          }).toList();
          return c.copyWith(subcategories: updatedSubs);
        }
        return c;
      }).toList();

      final selectedCategory = _allCategories.firstWhere(
        (c) => c.id == event.categoryId,
      );

      final loadedState = CategoriesLoaded(
        categories: _allCategories,
        filteredCategories: _allCategories,
        selectedCategory: selectedCategory,
      );

      emit(CategoriesActionSuccess(
        message: 'تم تعديل القسم الفرعي بنجاح',
        previousState: loadedState,
      ));
      emit(loadedState);
    } catch (e) {
      emit(CategoriesError('فشل في تعديل القسم الفرعي: $e'));
      if (currentState is CategoriesLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteSubcategory(
    DeleteSubcategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    final currentState = state;
    try {
      await _datasource.deleteSubcategory(
        categoryId: event.categoryId,
        subcategoryId: event.subcategoryId,
      );

      // Update local list
      _allCategories = _allCategories.map((c) {
        if (c.id == event.categoryId) {
          final updatedSubs = c.subcategories
              .where((s) => s.id != event.subcategoryId)
              .toList();
          return c.copyWith(subcategories: updatedSubs);
        }
        return c;
      }).toList();

      final selectedCategory = _allCategories.firstWhere(
        (c) => c.id == event.categoryId,
      );

      final loadedState = CategoriesLoaded(
        categories: _allCategories,
        filteredCategories: _allCategories,
        selectedCategory: selectedCategory,
      );

      emit(CategoriesActionSuccess(
        message: 'تم حذف القسم الفرعي بنجاح',
        previousState: loadedState,
      ));
      emit(loadedState);
    } catch (e) {
      emit(CategoriesError('فشل في حذف القسم الفرعي: $e'));
      if (currentState is CategoriesLoaded) {
        emit(currentState);
      }
    }
  }
}
