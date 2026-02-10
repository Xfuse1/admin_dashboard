import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import 'products_event.dart';
import 'products_state.dart';

/// Debounce duration for search
const _debounceDuration = Duration(milliseconds: 400);

/// Products BLoC
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository _repository;

  /// Keep a local copy of all products to filter without re-fetching
  List<ProductEntity> _allProducts = [];

  ProductsBloc(this._repository) : super(const ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(
      _onSearchProducts,
      transformer: restartable(),
    );
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
      _allProducts = products;
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    final query = event.query.trim();

    // Debounce: wait before processing
    await Future<void>.delayed(_debounceDuration);

    // If query is empty, show all products without re-fetching
    if (query.isEmpty) {
      if (_allProducts.isNotEmpty) {
        emit(ProductsLoaded(products: _allProducts));
      } else {
        add(const LoadProducts());
      }
      return;
    }

    // Filter locally if we already have products (much faster)
    if (_allProducts.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      final filtered = _allProducts
          .where((product) =>
              product.name.toLowerCase().contains(lowerQuery) ||
              product.storeName.toLowerCase().contains(lowerQuery) ||
              product.category.toLowerCase().contains(lowerQuery))
          .toList();

      emit(ProductsLoaded(
        products: filtered,
        searchQuery: query,
      ));
      return;
    }

    // Fallback: fetch from repo if no local data
    emit(const ProductsLoading());
    try {
      final products = await _repository.searchProducts(query);
      emit(ProductsLoaded(
        products: products,
        searchQuery: query,
      ));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onFilterByStore(
    FilterProductsByStore event,
    Emitter<ProductsState> emit,
  ) async {
    // Filter locally if available
    if (_allProducts.isNotEmpty) {
      final filtered =
          _allProducts.where((p) => p.storeId == event.storeId).toList();
      emit(ProductsLoaded(
        products: filtered,
        filterStore: event.storeId,
      ));
      return;
    }

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
    // Filter locally if available
    if (_allProducts.isNotEmpty) {
      final filtered =
          _allProducts.where((p) => p.category == event.category).toList();
      emit(ProductsLoaded(
        products: filtered,
        filterCategory: event.category,
      ));
      return;
    }

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
    // Use local data if available
    if (_allProducts.isNotEmpty) {
      emit(ProductsLoaded(products: _allProducts));
      return;
    }

    emit(const ProductsLoading());
    try {
      final products = await _repository.getProducts();
      _allProducts = products;
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
