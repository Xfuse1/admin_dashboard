import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/vendor_entity.dart';

/// Base class for vendors states.
abstract class VendorsState extends Equatable {
  const VendorsState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class VendorsInitial extends VendorsState {
  const VendorsInitial();
}

/// Loading state.
class VendorsLoading extends VendorsState {
  const VendorsLoading();
}

/// Vendors loaded successfully.
class VendorsLoaded extends VendorsState {
  final List<VendorEntity> vendors;
  final VendorEntity? selectedVendor;
  final Map<String, dynamic>? stats;
  final VendorStatus? currentStatusFilter;
  final VendorCategory? currentCategoryFilter;
  final String? searchQuery;
  final bool hasMore;
  final bool isLoadingMore;
  final List<ProductEntity>? vendorProducts;
  final bool isProductsLoading;

  const VendorsLoaded({
    required this.vendors,
    this.selectedVendor,
    this.stats,
    this.currentStatusFilter,
    this.currentCategoryFilter,
    this.searchQuery,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.vendorProducts,
    this.isProductsLoading = false,
  });

  @override
  List<Object?> get props => [
        vendors,
        selectedVendor,
        stats,
        currentStatusFilter,
        currentCategoryFilter,
        searchQuery,
        hasMore,
        isLoadingMore,
        vendorProducts,
        isProductsLoading,
      ];

  VendorsLoaded copyWith({
    List<VendorEntity>? vendors,
    VendorEntity? selectedVendor,
    Map<String, dynamic>? stats,
    VendorStatus? currentStatusFilter,
    VendorCategory? currentCategoryFilter,
    String? searchQuery,
    bool? hasMore,
    bool? isLoadingMore,
    List<ProductEntity>? vendorProducts,
    bool? isProductsLoading,
    bool clearSelectedVendor = false,
    bool clearStatusFilter = false,
    bool clearCategoryFilter = false,
    bool clearSearchQuery = false,
  }) {
    return VendorsLoaded(
      vendors: vendors ?? this.vendors,
      selectedVendor:
          clearSelectedVendor ? null : (selectedVendor ?? this.selectedVendor),
      stats: stats ?? this.stats,
      currentStatusFilter: clearStatusFilter
          ? null
          : (currentStatusFilter ?? this.currentStatusFilter),
      currentCategoryFilter: clearCategoryFilter
          ? null
          : (currentCategoryFilter ?? this.currentCategoryFilter),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      vendorProducts: vendorProducts ?? this.vendorProducts,
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
    );
  }
}

/// Error state.
class VendorsError extends VendorsState {
  final String message;

  const VendorsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Action success state (for toasts).
class VendorsActionSuccess extends VendorsState {
  final String successMessage;
  final VendorsLoaded previousState;

  const VendorsActionSuccess({
    required this.successMessage,
    required this.previousState,
  });

  @override
  List<Object?> get props => [successMessage, previousState];
}
