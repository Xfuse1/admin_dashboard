import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/vendor_entity.dart';
import '../../domain/usecases/vendors_usecases.dart';
import 'vendors_event.dart';
import 'vendors_state.dart';

/// BLoC for managing vendors.
class VendorsBloc extends Bloc<VendorsEvent, VendorsState> {
  final GetVendors getVendors;
  final GetVendor getVendor;
  final AddVendor addVendor;
  final UpdateVendor updateVendor;
  final DeleteVendor deleteVendor;
  final ToggleVendorStatus toggleVendorStatus;
  final GetVendorStats getVendorStats;
  final WatchVendors watchVendors;
  final UpdateVendorRating updateVendorRating;

  StreamSubscription<dynamic>? _vendorsSubscription;

  VendorsBloc({
    required this.getVendors,
    required this.getVendor,
    required this.addVendor,
    required this.updateVendor,
    required this.deleteVendor,
    required this.toggleVendorStatus,
    required this.getVendorStats,
    required this.watchVendors,
    required this.updateVendorRating,
  }) : super(const VendorsInitial()) {
    on<LoadVendors>(_onLoadVendors);
    on<LoadMoreVendors>(_onLoadMoreVendors);
    on<SearchVendors>(_onSearchVendors);
    on<FilterByStatus>(_onFilterByStatus);
    on<FilterByCategory>(_onFilterByCategory);
    on<SelectVendor>(_onSelectVendor);
    on<ClearSelectedVendor>(_onClearSelectedVendor);
    on<AddVendorEvent>(_onAddVendor);
    on<UpdateVendorEvent>(_onUpdateVendor);
    on<DeleteVendorEvent>(_onDeleteVendor);
    on<ToggleVendorStatusEvent>(_onToggleVendorStatus);
    on<ToggleFeaturedStatusEvent>(_onToggleFeaturedStatus);
    on<VerifyVendorEvent>(_onVerifyVendor);
    on<WatchVendorsEvent>(_onWatchVendors);
    on<RefreshVendors>(_onRefreshVendors);
  }

  @override
  Future<void> close() {
    _vendorsSubscription?.cancel();
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
      (vendor) => emit(currentState.copyWith(selectedVendor: vendor)),
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

  Future<void> _onAddVendor(
    AddVendorEvent event,
    Emitter<VendorsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorsLoaded) return;

    final result = await addVendor(event.vendor);

    result.fold(
      (failure) => emit(VendorsError(failure.message)),
      (vendor) {
        final updatedVendors = [vendor, ...currentState.vendors];
        final updatedState = currentState.copyWith(vendors: updatedVendors);
        emit(VendorsActionSuccess(
          successMessage: 'تمت إضافة المتجر بنجاح',
          previousState: updatedState,
        ));
        emit(updatedState);
      },
    );
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

    // This would need a use case for toggleFeaturedStatus
    // For now, we'll update the vendor directly
    final vendorToUpdate =
        currentState.vendors.firstWhere((v) => v.id == event.vendorId);
    final updatedVendor = vendorToUpdate.copyWith(isFeatured: event.isFeatured);

    final result = await updateVendor(updatedVendor);

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

    // This would need a use case for verifyVendor
    // For now, we'll update the vendor directly
    final vendorToUpdate =
        currentState.vendors.firstWhere((v) => v.id == event.vendorId);
    final updatedVendor = vendorToUpdate.copyWith(isVerified: true);

    final result = await updateVendor(updatedVendor);

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

  void _onWatchVendors(
    WatchVendorsEvent event,
    Emitter<VendorsState> emit,
  ) {
    _vendorsSubscription?.cancel();
    _vendorsSubscription = watchVendors(
      status: event.status,
      category: event.category,
    ).listen((result) {
      result.fold(
        (failure) => add(const LoadVendors()),
        (vendors) {
          final currentState = state;
          if (currentState is VendorsLoaded) {
            emit(currentState.copyWith(vendors: vendors));
          }
        },
      );
    });
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
}
