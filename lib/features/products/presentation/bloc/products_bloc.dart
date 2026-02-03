import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/products_repository.dart';
import 'products_event.dart';
import 'products_state.dart';

/// Products BLoC
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository _repository;

  ProductsBloc(this._repository) : super(const ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByStore>(_onFilterByStore);
    on<FilterProductsByCategory>(_onFilterByCategory);
    on<ClearProductsFilters>(_onClearFilters);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      final products = await _repository.getProducts();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      final products = await _repository.searchProducts(event.query);
      emit(ProductsLoaded(
        products: products,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onFilterByStore(
    FilterProductsByStore event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      final products = await _repository.getProductsByStore(event.storeId);
      emit(ProductsLoaded(
        products: products,
        filterStore: event.storeId,
      ));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(
    FilterProductsByCategory event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      final products = await _repository.getProductsByCategory(event.category);
      emit(ProductsLoaded(
        products: products,
        filterCategory: event.category,
      ));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onClearFilters(
    ClearProductsFilters event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      final products = await _repository.getProducts();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
