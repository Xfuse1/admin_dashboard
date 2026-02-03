import 'package:equatable/equatable.dart';

/// Products events
abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all products
class LoadProducts extends ProductsEvent {
  const LoadProducts();
}

/// Search products
class SearchProducts extends ProductsEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter by store
class FilterProductsByStore extends ProductsEvent {
  final String storeId;

  const FilterProductsByStore(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Filter by category
class FilterProductsByCategory extends ProductsEvent {
  final String category;

  const FilterProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Clear filters
class ClearProductsFilters extends ProductsEvent {
  const ClearProductsFilters();
}
