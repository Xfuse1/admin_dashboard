import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/onboarding_entities.dart';
import '../../domain/usecases/onboarding_usecases.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// BLoC for managing onboarding requests.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingRequests _getRequests;
  final ApproveOnboardingRequest _approveRequest;
  final RejectOnboardingRequest _rejectRequest;
  final MarkRequestUnderReview _markUnderReview;
  final GetOnboardingStats _getStats;

  static const int _pageSize = 20;

  OnboardingBloc({
    required GetOnboardingRequests getRequests,
    required ApproveOnboardingRequest approveRequest,
    required RejectOnboardingRequest rejectRequest,
    required MarkRequestUnderReview markUnderReview,
    required GetOnboardingStats getStats,
  })  : _getRequests = getRequests,
        _approveRequest = approveRequest,
        _rejectRequest = rejectRequest,
        _markUnderReview = markUnderReview,
        _getStats = getStats,
        super(const OnboardingInitial()) {
    on<LoadOnboardingRequests>(_onLoadRequests);
    on<LoadMoreRequests>(_onLoadMore);
    on<LoadOnboardingStats>(_onLoadStats);
    on<FilterByType>(_onFilterByType);
    on<FilterByStatus>(_onFilterByStatus);
    on<SelectRequest>(_onSelectRequest);
    on<ApproveRequestEvent>(_onApproveRequest);
    on<RejectRequestEvent>(_onRejectRequest);
    on<MarkUnderReviewEvent>(_onMarkUnderReview);
    on<ClearOnboardingError>(_onClearError);
  }

  Future<void> _onLoadRequests(
    LoadOnboardingRequests event,
    Emitter<OnboardingState> emit,
  ) async {
    final currentState = state;
    OnboardingLoaded loadedState;

    if (currentState is OnboardingLoaded) {
      loadedState = currentState;
    } else {
      emit(const OnboardingLoading());
      loadedState = const OnboardingLoaded();
    }

    final result = await _getRequests(
      type: event.type,
      status: event.status,
      limit: _pageSize,
    );

    result.fold(
      (failure) =>
          emit(OnboardingError(failure.message, previousState: loadedState)),
      (requests) => emit(loadedState.copyWith(
        requests: requests,
        hasMore: requests.length >= _pageSize,
        filterType: event.type,
        clearFilterType: event.type == null,
        filterStatus: event.status,
        clearFilterStatus: event.status == null,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreRequests event,
    Emitter<OnboardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final lastId =
        currentState.requests.isNotEmpty ? currentState.requests.last.id : null;

    final result = await _getRequests(
      type: currentState.filterType,
      status: currentState.filterStatus,
      limit: _pageSize,
      lastId: lastId,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newRequests) {
        final allRequests = [...currentState.requests, ...newRequests];
        emit(currentState.copyWith(
          requests: allRequests,
          hasMore: newRequests.length >= _pageSize,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onLoadStats(
    LoadOnboardingStats event,
    Emitter<OnboardingState> emit,
  ) async {
    final currentState = state;
    OnboardingLoaded loadedState;

    if (currentState is OnboardingLoaded) {
      loadedState = currentState;
    } else {
      loadedState = const OnboardingLoaded();
    }

    final result = await _getStats();

    result.fold(
      (failure) => null, // Silently fail for stats
      (stats) => emit(loadedState.copyWith(stats: stats)),
    );
  }

  void _onFilterByType(
    FilterByType event,
    Emitter<OnboardingState> emit,
  ) {
    final currentState = state;
    if (currentState is OnboardingLoaded) {
      add(LoadOnboardingRequests(
        type: event.type,
        status: currentState.filterStatus,
      ));
    }
  }

  void _onFilterByStatus(
    FilterByStatus event,
    Emitter<OnboardingState> emit,
  ) {
    final currentState = state;
    if (currentState is OnboardingLoaded) {
      add(LoadOnboardingRequests(
        type: currentState.filterType,
        status: event.status,
      ));
    }
  }

  void _onSelectRequest(
    SelectRequest event,
    Emitter<OnboardingState> emit,
  ) {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;

    if (event.request == null) {
      emit(currentState.copyWith(clearSelectedRequest: true));
    } else {
      emit(currentState.copyWith(selectedRequest: event.request));
    }
  }

  Future<void> _onApproveRequest(
    ApproveRequestEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;

    emit(OnboardingActionInProgress(
      requestId: event.requestId,
      action: 'الموافقة على الطلب',
      previousState: currentState,
    ));

    final result = await _approveRequest(event.requestId, notes: event.notes);

    result.fold(
      (failure) =>
          emit(OnboardingError(failure.message, previousState: currentState)),
      (_) {
        final updatedRequests = currentState.requests.map((r) {
          if (r.id == event.requestId) {
            return _updateRequestStatus(r, OnboardingStatus.approved);
          }
          return r;
        }).toList();

        emit(OnboardingActionSuccess(
          message: 'تم قبول الطلب بنجاح',
          updatedState: currentState.copyWith(
            requests: updatedRequests,
            clearSelectedRequest: true,
          ),
        ));
      },
    );
  }

  Future<void> _onRejectRequest(
    RejectRequestEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;

    emit(OnboardingActionInProgress(
      requestId: event.requestId,
      action: 'رفض الطلب',
      previousState: currentState,
    ));

    final result = await _rejectRequest(event.requestId, event.reason);

    result.fold(
      (failure) =>
          emit(OnboardingError(failure.message, previousState: currentState)),
      (_) {
        final updatedRequests = currentState.requests.map((r) {
          if (r.id == event.requestId) {
            return _updateRequestStatus(r, OnboardingStatus.rejected);
          }
          return r;
        }).toList();

        emit(OnboardingActionSuccess(
          message: 'تم رفض الطلب',
          updatedState: currentState.copyWith(
            requests: updatedRequests,
            clearSelectedRequest: true,
          ),
        ));
      },
    );
  }

  Future<void> _onMarkUnderReview(
    MarkUnderReviewEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OnboardingLoaded) return;

    emit(OnboardingActionInProgress(
      requestId: event.requestId,
      action: 'تحديث حالة الطلب',
      previousState: currentState,
    ));

    final result = await _markUnderReview(event.requestId);

    result.fold(
      (failure) =>
          emit(OnboardingError(failure.message, previousState: currentState)),
      (_) {
        final updatedRequests = currentState.requests.map((r) {
          if (r.id == event.requestId) {
            return _updateRequestStatus(r, OnboardingStatus.underReview);
          }
          return r;
        }).toList();

        emit(OnboardingActionSuccess(
          message: 'تم تحديث حالة الطلب',
          updatedState: currentState.copyWith(requests: updatedRequests),
        ));
      },
    );
  }

  void _onClearError(
    ClearOnboardingError event,
    Emitter<OnboardingState> emit,
  ) {
    final currentState = state;
    if (currentState is OnboardingError && currentState.previousState != null) {
      emit(currentState.previousState!);
    }
  }

  OnboardingRequestEntity _updateRequestStatus(
    OnboardingRequestEntity request,
    OnboardingStatus newStatus,
  ) {
    if (request is StoreOnboardingEntity) {
      return StoreOnboardingEntity(
        id: request.id,
        status: newStatus,
        name: request.name,
        email: request.email,
        phone: request.phone,
        createdAt: request.createdAt,
        reviewedAt: DateTime.now(),
        reviewedBy: 'admin',
        storeName: request.storeName,
        storeType: request.storeType,
        address: request.address,
        ownerName: request.ownerName,
        ownerIdNumber: request.ownerIdNumber,
        commercialRegister: request.commercialRegister,
        logoUrl: request.logoUrl,
        commercialRegisterUrl: request.commercialRegisterUrl,
        ownerIdUrl: request.ownerIdUrl,
        categories: request.categories,
      );
    } else if (request is DriverOnboardingEntity) {
      return DriverOnboardingEntity(
        id: request.id,
        status: newStatus,
        name: request.name,
        email: request.email,
        phone: request.phone,
        createdAt: request.createdAt,
        reviewedAt: DateTime.now(),
        reviewedBy: 'admin',
        idNumber: request.idNumber,
        licenseNumber: request.licenseNumber,
        licenseExpiryDate: request.licenseExpiryDate,
        vehicleType: request.vehicleType,
        vehiclePlate: request.vehiclePlate,
        photoUrl: request.photoUrl,
        idDocumentUrl: request.idDocumentUrl,
        licenseUrl: request.licenseUrl,
        vehicleRegistrationUrl: request.vehicleRegistrationUrl,
        vehicleInsuranceUrl: request.vehicleInsuranceUrl,
      );
    }
    return request;
  }
}
