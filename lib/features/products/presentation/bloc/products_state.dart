import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';

/// Products states
abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

/// Loading state
class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

/// Loaded state
class ProductsLoaded extends ProductsState {
  final List<ProductEntity> products;
  final String? searchQuery;
  final String? filterStore;
  final String? filterCategory;

  const ProductsLoaded({
    required this.products,
    this.searchQuery,
    this.filterStore,
    this.filterCategory,
  });

  @override
  List<Object?> get props =>
      [products, searchQuery, filterStore, filterCategory];

  ProductsLoaded copyWith({
    List<ProductEntity>? products,
    String? searchQuery,
    String? filterStore,
    String? filterCategory,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStore: filterStore ?? this.filterStore,
      filterCategory: filterCategory ?? this.filterCategory,
    );
  }
}

/// Error state
class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
