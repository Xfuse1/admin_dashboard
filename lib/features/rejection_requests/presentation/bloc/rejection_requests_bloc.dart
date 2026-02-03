import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/rejection_requests_usecases.dart';
import 'rejection_requests_event.dart';
import 'rejection_requests_state.dart';

/// Rejection requests BLoC
class RejectionRequestsBloc
    extends Bloc<RejectionRequestsEvent, RejectionRequestsState> {
  final GetRejectionRequests _getRejectionRequests;
  final WatchRejectionRequests _watchRejectionRequests;
  final ApproveExcuse _approveExcuse;
  final RejectExcuse _rejectExcuse;
  final GetRejectionStats _getRejectionStats;
  final GetPendingRequestsCount _getPendingRequestsCount;

  StreamSubscription? _rejectionRequestsSubscription;

  RejectionRequestsBloc({
    required GetRejectionRequests getRejectionRequests,
    required WatchRejectionRequests watchRejectionRequests,
    required ApproveExcuse approveExcuse,
    required RejectExcuse rejectExcuse,
    required GetRejectionStats getRejectionStats,
    required GetPendingRequestsCount getPendingRequestsCount,
  })  : _getRejectionRequests = getRejectionRequests,
        _watchRejectionRequests = watchRejectionRequests,
        _approveExcuse = approveExcuse,
        _rejectExcuse = rejectExcuse,
        _getRejectionStats = getRejectionStats,
        _getPendingRequestsCount = getPendingRequestsCount,
        super(const RejectionRequestsInitial()) {
    on<LoadRejectionRequests>(_onLoadRejectionRequests);
    on<WatchRejectionRequestsEvent>(_onWatchRejectionRequests);
    on<FilterRejectionsByStatus>(_onFilterByStatus);
    on<SelectRejectionRequest>(_onSelectRequest);
    on<ClearSelectedRejectionRequest>(_onClearSelectedRequest);
    on<ApproveExcuseEvent>(_onApproveExcuse);
    on<RejectExcuseEvent>(_onRejectExcuse);
    on<LoadRejectionStats>(_onLoadStats);
    on<LoadPendingRequestsCount>(_onLoadPendingCount);
  }

  Future<void> _onLoadRejectionRequests(
    LoadRejectionRequests event,
    Emitter<RejectionRequestsState> emit,
  ) async {
    emit(const RejectionRequestsLoading());

    final result = await _getRejectionRequests(
      adminDecision: event.adminDecision,
      driverId: event.driverId,
    );

    await result.fold<Future<void>>(
      (Failure failure) async =>
          emit(RejectionRequestsError(message: failure.message)),
      (requests) async {
        // Also load pending count
        final countResult = await _getPendingRequestsCount();
        final pendingCount = countResult.fold(
          (failure) => 0,
          (count) => count,
        );

        emit(RejectionRequestsLoaded(
          requests: requests,
          currentFilter: event.adminDecision,
          pendingCount: pendingCount,
        ));
      },
    );
  }

  Future<void> _onWatchRejectionRequests(
    WatchRejectionRequestsEvent event,
    Emitter<RejectionRequestsState> emit,
  ) async {
    emit(const RejectionRequestsLoading());

    await _rejectionRequestsSubscription?.cancel();

    _rejectionRequestsSubscription = _watchRejectionRequests(
      adminDecision: event.adminDecision,
    ).listen((result) async {
      result.fold<void>(
        (Failure failure) =>
            add(const LoadRejectionRequests(adminDecision: 'pending')),
        (requests) async {
          if (emit.isDone) return;

          // Also get pending count
          final countResult = await _getPendingRequestsCount();
          final pendingCount = countResult.fold(
            (failure) => 0,
            (count) => count,
          );

          if (emit.isDone) return;

          if (state is RejectionRequestsLoaded) {
            final currentState = state as RejectionRequestsLoaded;
            emit(currentState.copyWith(
              requests: requests,
              pendingCount: pendingCount,
            ));
          } else {
            emit(RejectionRequestsLoaded(
              requests: requests,
              currentFilter: event.adminDecision,
              pendingCount: pendingCount,
            ));
          }
        },
      );
    });
  }

  Future<void> _onFilterByStatus(
    FilterRejectionsByStatus event,
    Emitter<RejectionRequestsState> emit,
  ) async {
    if (state is RejectionRequestsLoaded) {
      emit(const RejectionRequestsLoading());
    }

    final result = await _getRejectionRequests(
      adminDecision: event.adminDecision,
    );

    result.fold<void>(
      (Failure failure) =>
          emit(RejectionRequestsError(message: failure.message)),
      (requests) {
        if (state is RejectionRequestsLoaded) {
          final currentState = state as RejectionRequestsLoaded;
          emit(currentState.copyWith(
            requests: requests,
            currentFilter: event.adminDecision,
            clearSelectedRequest: true,
          ));
        } else {
          emit(RejectionRequestsLoaded(
            requests: requests,
            currentFilter: event.adminDecision,
          ));
        }
      },
    );
  }

  void _onSelectRequest(
    SelectRejectionRequest event,
    Emitter<RejectionRequestsState> emit,
  ) {
    if (state is RejectionRequestsLoaded) {
      final currentState = state as RejectionRequestsLoaded;
      emit(currentState.copyWith(selectedRequest: event.request));
    }
  }

  void _onClearSelectedRequest(
    ClearSelectedRejectionRequest event,
    Emitter<RejectionRequestsState> emit,
  ) {
    if (state is RejectionRequestsLoaded) {
      final currentState = state as RejectionRequestsLoaded;
      emit(currentState.copyWith(clearSelectedRequest: true));
    }
  }

  Future<void> _onApproveExcuse(
    ApproveExcuseEvent event,
    Emitter<RejectionRequestsState> emit,
  ) async {
    if (state is! RejectionRequestsLoaded) return;

    final currentState = state as RejectionRequestsLoaded;
    emit(const RejectionRequestsOperationInProgress('Approving excuse...'));

    final result = await _approveExcuse(
      requestId: event.requestId,
      adminComment: event.adminComment,
    );

    result.fold<void>(
      (Failure failure) =>
          emit(RejectionRequestsError(message: failure.message)),
      (_) {
        emit(RejectionRequestsOperationSuccess(
          message: 'Excuse approved successfully',
          previousState: currentState,
        ));
        // Reload requests
        add(const LoadRejectionRequests(adminDecision: 'pending'));
      },
    );
  }

  Future<void> _onRejectExcuse(
    RejectExcuseEvent event,
    Emitter<RejectionRequestsState> emit,
  ) async {
    if (state is! RejectionRequestsLoaded) return;

    final currentState = state as RejectionRequestsLoaded;
    emit(const RejectionRequestsOperationInProgress('Rejecting excuse...'));

    final result = await _rejectExcuse(
      requestId: event.requestId,
      adminComment: event.adminComment,
    );

    result.fold<void>(
      (Failure failure) =>
          emit(RejectionRequestsError(message: failure.message)),
      (_) {
        emit(RejectionRequestsOperationSuccess(
          message: 'Excuse rejected successfully',
          previousState: currentState,
        ));
        // Reload requests
        add(const LoadRejectionRequests(adminDecision: 'pending'));
      },
    );
  }

  Future<void> _onLoadStats(
    LoadRejectionStats event,
    Emitter<RejectionRequestsState> emit,
  ) async {
    final result = await _getRejectionStats(
      driverId: event.driverId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold<void>(
      (Failure failure) =>
          emit(RejectionRequestsError(message: failure.message)),
      (stats) {
        if (state is RejectionRequestsLoaded) {
          final currentState = state as RejectionRequestsLoaded;
          emit(currentState.copyWith(stats: stats));
        } else {
          emit(RejectionRequestsLoaded(
            requests: const [],
            stats: stats,
          ));
        }
      },
    );
  }

  Future<void> _onLoadPendingCount(
    LoadPendingRequestsCount event,
    Emitter<RejectionRequestsState> emit,
  ) async {
    final result = await _getPendingRequestsCount();

    result.fold(
      (failure) {}, // Silently fail
      (count) {
        if (state is RejectionRequestsLoaded) {
          final currentState = state as RejectionRequestsLoaded;
          emit(currentState.copyWith(pendingCount: count));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _rejectionRequestsSubscription?.cancel();
    return super.close();
  }
}
