// ignore_for_file: unnecessary_overrides

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../../domain/entities/vendor_entity.dart';
import '../../domain/usecases/vendors_usecases.dart';
import 'vendors_event.dart';
import 'vendors_state.dart';

/// BLoC for managing vendors.
class VendorsBloc extends Bloc<VendorsEvent, VendorsState> {
  final GetVendors getVendors;
  final GetVendor getVendor;
  final UpdateVendor updateVendor;
  final DeleteVendor deleteVendor;
  final ToggleVendorStatus toggleVendorStatus;
  final GetVendorStats getVendorStats;
  final WatchVendors watchVendors;
  final UpdateVendorRating updateVendorRating;
  final GetVendorProducts getVendorProducts;
  final ToggleFeaturedStatus toggleFeaturedStatus;
  final VerifyVendor verifyVendor;

  VendorsBloc({
    required this.getVendors,
    required this.getVendor,
    required this.updateVendor,
    required this.deleteVendor,
    required this.toggleVendorStatus,
    required this.getVendorStats,
    required this.watchVendors,
    required this.updateVendorRating,
    required this.getVendorProducts,
    required this.toggleFeaturedStatus,
    required this.verifyVendor,
  }) : super(const VendorsInitial()) {
    on<LoadVendors>(_onLoadVendors);
    on<LoadVendorProductsEvent>(_onLoadVendorProducts);
    on<LoadMoreVendors>(_onLoadMoreVendors);
    on<SearchVendors>(_onSearchVendors);
    on<FilterByStatus>(_onFilterByStatus);
    on<FilterByCategory>(_onFilterByCategory);
    on<SelectVendor>(_onSelectVendor);
    on<ClearSelectedVendor>(_onClearSelectedVendor);
    on<UpdateVendorEvent>(_onUpdateVendor);
    on<DeleteVendorEvent>(_onDeleteVendor);
    on<ToggleVendorStatusEvent>(_onToggleVendorStatus);
    on<ToggleFeaturedStatusEvent>(_onToggleFeaturedStatus);
    on<VerifyVendorEvent>(_onVerifyVendor);
    on<WatchVendorsEvent>(_onWatchVendors, transformer: restartable());
    on<RefreshVendors>(_onRefreshVendors);
  }

  @override
  Future<void> close() {
    return super.close();
  }

  Future<void> _onLoadVendors(
    LoadVendors event,
    Emitter<VendorsState> emit,
  ) async {
    emit(const VendorsLoading());

    final results = await Future.wait([
      getVendors(
        status: event.status,
        category: event.category,
        searchQuery: event.searchQuery,
        limit: 20,
      ),
      getVendorStats(),
    ]);

    final vendorsResult = results[0];
    final statsResult = results[1];

    vendorsResult.fold(
      (failure) => emit(VendorsError(failure.message)),
      (vendors) {
        final stats = statsResult.fold(
          (failure) => null,
          (stats) => stats as Map<String, dynamic>,
        );

        emit(VendorsLoaded(
          vendors: vendors as List<VendorEntity>,
          stats: stats,
          currentStatusFilter: event.status,
          currentCategoryFilter: event.category,
          searchQuery: event.searchQuery,
          hasMore: vendors.length >= 20,
        ));
      },
    );
  }

  Future<void> _onLoadMoreVendors(
    LoadMoreVendors event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorsLoaded ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final lastVendorId =
        currentState.vendors.isNotEmpty ? currentState.vendors.last.id : null;

    final result = await getVendors(
      status: currentState.currentStatusFilter,
      category: currentState.currentCategoryFilter,
      searchQuery: currentState.searchQuery,
      limit: 20,
      lastDocumentId: lastVendorId,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newVendors) {
        emit(currentState.copyWith(
          vendors: [...currentState.vendors, ...newVendors],
          hasMore: newVendors.length >= 20,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onSearchVendors(
    SearchVendors event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is VendorsLoaded) {
      add(LoadVendors(
        status: currentState.currentStatusFilter,
        category: currentState.currentCategoryFilter,
        searchQuery: event.query.isNotEmpty ? event.query : null,
      ));
    }
  }

  Future<void> _onFilterByStatus(
    FilterByStatus event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is VendorsLoaded) {
      // Load with new filter, then restart watch for real-time updates
      add(LoadVendors(
        status: event.status,
        category: currentState.currentCategoryFilter,
        searchQuery: currentState.searchQuery,
      ));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is VendorsLoaded) {
      // Load with new filter, then restart watch for real-time updates
      add(LoadVendors(
        status: currentState.currentStatusFilter,
        category: event.category,
        searchQuery: currentState.searchQuery,
      ));
    }
  }

  Future<void> _onSelectVendor(
    SelectVendor event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorsLoaded) return;

    final result = await getVendor(event.vendorId);

    result.fold(
      (failure) => emit(VendorsError(failure.message)),
      (vendor) {
        emit(currentState.copyWith(selectedVendor: vendor));
        add(LoadVendorProductsEvent(vendor.id));
      },
    );
  }

  void _onClearSelectedVendor(
    ClearSelectedVendor event,
    Emitter<VendorsState> emit,
  ) {
    final currentState = state;
    if (currentState is VendorsLoaded) {
      emit(currentState.copyWith(clearSelectedVendor: true));
    }
  }

  Future<void> _onUpdateVendor(
    UpdateVendorEvent event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorsLoaded) return;

    final result = await updateVendor(event.vendor);

    result.fold(
      (failure) => emit(VendorsError(failure.message)),
      (vendor) {
        final updatedVendors = currentState.vendors
            .map((v) => v.id == vendor.id ? vendor : v)
            .toList();
        final updatedState = currentState.copyWith(
          vendors: updatedVendors,
          selectedVendor:
              currentState.selectedVendor?.id == vendor.id ? vendor : null,
        );
        emit(VendorsActionSuccess(
          successMessage: 'تم تحديث المتجر بنجاح',
          previousState: updatedState,
        ));
        emit(updatedState);
      },
    );
  }

  Future<void> _onDeleteVendor(
    DeleteVendorEvent event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorsLoaded) return;

    final result = await deleteVendor(event.vendorId);

    result.fold(
      (failure) => emit(VendorsError(failure.message)),
      (_) {
        final updatedVendors =
            currentState.vendors.where((v) => v.id != event.vendorId).toList();
        final updatedState = currentState.copyWith(
          vendors: updatedVendors,
          clearSelectedVendor:
              currentState.selectedVendor?.id == event.vendorId,
        );
        emit(VendorsActionSuccess(
          successMessage: 'تم حذف المتجر بنجاح',
          previousState: updatedState,
        ));
        emit(updatedState);
      },
    );
  }

  Future<void> _onToggleVendorStatus(
    ToggleVendorStatusEvent event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorsLoaded) return;

    final result = await toggleVendorStatus(event.vendorId, event.status);

    result.fold(
      (failure) => emit(VendorsError(failure.message)),
      (vendor) {
        final updatedVendors = currentState.vendors
            .map((v) => v.id == vendor.id ? vendor : v)
            .toList();
        final updatedState = currentState.copyWith(
          vendors: updatedVendors,
          selectedVendor:
              currentState.selectedVendor?.id == vendor.id ? vendor : null,
        );
        emit(VendorsActionSuccess(
          successMessage: 'تم تحديث حالة المتجر',
          previousState: updatedState,
        ));
        emit(updatedState);
      },
    );
  }

  Future<void> _onToggleFeaturedStatus(
    ToggleFeaturedStatusEvent event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorsLoaded) return;

    final result = await toggleFeaturedStatus(event.vendorId, event.isFeatured);

    result.fold(
      (failure) => emit(VendorsError(failure.message)),
      (vendor) {
        final updatedVendors = currentState.vendors
            .map((v) => v.id == vendor.id ? vendor : v)
            .toList();
        final message = event.isFeatured
            ? 'تم إضافة المتجر للمميزين'
            : 'تم إزالة المتجر من المميزين';
        final updatedState = currentState.copyWith(
          vendors: updatedVendors,
          selectedVendor:
              currentState.selectedVendor?.id == vendor.id ? vendor : null,
        );
        emit(VendorsActionSuccess(
          successMessage: message,
          previousState: updatedState,
        ));
        emit(updatedState);
      },
    );
  }

  Future<void> _onVerifyVendor(
    VerifyVendorEvent event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorsLoaded) return;

    final result = await verifyVendor(event.vendorId);

    result.fold(
      (failure) => emit(VendorsError(failure.message)),
      (vendor) {
        final updatedVendors = currentState.vendors
            .map((v) => v.id == vendor.id ? vendor : v)
            .toList();
        final updatedState = currentState.copyWith(
          vendors: updatedVendors,
          selectedVendor:
              currentState.selectedVendor?.id == vendor.id ? vendor : null,
        );
        emit(VendorsActionSuccess(
          successMessage: 'تم التحقق من المتجر بنجاح',
          previousState: updatedState,
        ));
        emit(updatedState);
      },
    );
  }

  Future<void> _onWatchVendors(
    WatchVendorsEvent event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;

    // Load stats once if not loaded yet
    Map<String, dynamic>? stats;
    if (currentState is! VendorsLoaded || currentState.stats == null) {
      final statsResult = await getVendorStats();
      statsResult.fold(
        (failure) => stats = null,
        (s) => stats = s,
      );
    } else {
      stats = currentState.stats;
    }

    return emit.forEach(
      watchVendors(
        status: event.status,
        category: event.category,
      ),
      onData: (result) {
        return result.fold(
          (failure) {
            // On error, return current state or initial state
            final state = this.state;
            if (state is VendorsLoaded) {
              return state;
            }
            return const VendorsInitial();
          },
          (vendors) {
            final state = this.state;

            if (state is VendorsLoaded) {
              return state.copyWith(
                vendors: vendors,
                currentStatusFilter: event.status,
                currentCategoryFilter: event.category,
                clearStatusFilter: event.status == null,
                clearCategoryFilter: event.category == null,
              );
            } else {
              return VendorsLoaded(
                vendors: vendors,
                stats: stats,
                currentStatusFilter: event.status,
                currentCategoryFilter: event.category,
                hasMore: vendors.length >= 20,
              );
            }
          },
        );
      },
      onError: (error, stackTrace) {
        final state = this.state;
        if (state is VendorsLoaded) {
          return state;
        }
        return VendorsError(error.toString());
      },
    );
  }

  Future<void> _onRefreshVendors(
    RefreshVendors event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is VendorsLoaded) {
      add(LoadVendors(
        status: currentState.currentStatusFilter,
        category: currentState.currentCategoryFilter,
        searchQuery: currentState.searchQuery,
      ));
    } else {
      add(const LoadVendors());
    }
  }

  Future<void> _onLoadVendorProducts(
    LoadVendorProductsEvent event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorsLoaded) return;

    emit(currentState.copyWith(isProductsLoading: true));

    final result = await getVendorProducts(event.vendorId);

    result.fold(
      (failure) => emit(currentState.copyWith(
        isProductsLoading: false,
        // Optional: show error toast or something.
        // For now just stop loading.
      )),
      (products) {
        emit(currentState.copyWith(
          vendorProducts: products,
          isProductsLoading: false,
        ));
      },
    );
  }
}
