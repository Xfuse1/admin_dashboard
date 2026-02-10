// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/rejection_request_entities.dart';
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

        // Load stats
        final statsResult = await _getRejectionStats(
          driverId: event.driverId,
          startDate: null,
          endDate: null,
        );

        final stats = statsResult.fold(
          (failure) => null,
          (stats) => stats,
        );

        emit(RejectionRequestsLoaded(
          requests: requests,
          currentFilter: event.adminDecision,
          pendingCount: pendingCount,
          stats: stats,
        ));
      },
    );
  }

  Future<void> _onWatchRejectionRequests(
    WatchRejectionRequestsEvent event,
    Emitter<RejectionRequestsState> emit,
  ) async {
    
    // Guard: If we're already watching the same status, skip
    if (state is RejectionRequestsLoading) {
      return;
    }

    emit(const RejectionRequestsLoading());

    // Cancel previous subscription
    await _rejectionRequestsSubscription?.cancel();

    // Use emit.onEach to keep the handler alive
    await emit.onEach<dynamic>(
      _watchRejectionRequests(adminDecision: event.adminDecision)
          .asyncMap((result) async {
        return await result.fold<Future<RejectionRequestsState>>(
          (Failure failure) async {
            return RejectionRequestsError(message: failure.message);
          },
          (List<RejectionRequestEntity> requests) async {
         
            final countResult = await _getPendingRequestsCount();

            final pendingCount = countResult.fold(
              (failure) {
                print('[BLoC] Failed to get pending count: ${failure.message}');
                return 0;
              },
              (count) {
                
                return count;
              },
            );

            final statsResult = await _getRejectionStats(
              driverId: null,
              startDate: null,
              endDate: null,
            );

            final stats = statsResult.fold(
              (failure) {
                print('[BLoC] Failed to get stats: ${failure.message}');
                return null;
              },
              (stats) {
                
                return stats;
              },
            );

            
            final currentSelectedRequest = state is RejectionRequestsLoaded
                ? (state as RejectionRequestsLoaded).selectedRequest
                : null;

           
            return RejectionRequestsLoaded(
              requests: requests,
              currentFilter: event.adminDecision,
              pendingCount: pendingCount,
              stats: stats,
              selectedRequest: currentSelectedRequest,
            );
          },
        );
      }),
      onData: (newState) {
        if (newState is RejectionRequestsState) {
          emit(newState);
        }
      },
      onError: (error, stackTrace) {
        print('[BLoC] Stream error: $error');
        emit(RejectionRequestsError(
            message: 'حدث خطأ في تحميل البيانات: $error'));
      },
    );
  }

  /// معالجة بيانات طلبات الرفض مع الـ async operations
  // ignore: unused_element
  Future<void> _handleRejectionRequestsData({
    required List<RejectionRequestEntity> requests,
    required String? adminDecision,
    required Emitter<RejectionRequestsState> emit,
  }) async {
    

    // Get pending count
    final countResult = await _getPendingRequestsCount();
    

    final pendingCount = countResult.fold(
      (failure) {
        return 0;
      },
      (count) {
        return count;
      },
    );

    // Get stats
    final statsResult = await _getRejectionStats(
      driverId: null,
      startDate: null,
      endDate: null,
    );

    final stats = statsResult.fold(
      (failure) {
        print('⚠️ [BLoC] Failed to get stats: ${failure.message}');
        return null;
      },
      (stats) {
        return stats;
      },
    );

    
    // Preserve selected request if filtering same status
    final currentSelectedRequest = state is RejectionRequestsLoaded
        ? (state as RejectionRequestsLoaded).selectedRequest
        : null;

    if (state is RejectionRequestsLoaded) {
      final currentState = state as RejectionRequestsLoaded;
      if (!emit.isDone) {
        emit(currentState.copyWith(
          requests: requests,
          pendingCount: pendingCount,
          stats: stats,
        ));
      }
    } else {
      if (!emit.isDone) {
        emit(RejectionRequestsLoaded(
          requests: requests,
          currentFilter: adminDecision,
          pendingCount: pendingCount,
          stats: stats,
          selectedRequest: currentSelectedRequest,
        ));
      }
    }

    
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

    await result.fold<Future<void>>(
      (Failure failure) async =>
          emit(RejectionRequestsError(message: failure.message)),
      (requests) async {
        // Load pending count
        final countResult = await _getPendingRequestsCount();
        final pendingCount = countResult.fold(
          (failure) => 0,
          (count) => count,
        );

        // Load stats
        final statsResult = await _getRejectionStats(
          driverId: null,
          startDate: null,
          endDate: null,
        );

        final stats = statsResult.fold(
          (failure) => null,
          (stats) => stats,
        );

        if (state is RejectionRequestsLoaded) {
          final currentState = state as RejectionRequestsLoaded;
          emit(currentState.copyWith(
            requests: requests,
            currentFilter: event.adminDecision,
            pendingCount: pendingCount,
            stats: stats,
            clearSelectedRequest: true,
          ));
        } else {
          emit(RejectionRequestsLoaded(
            requests: requests,
            currentFilter: event.adminDecision,
            pendingCount: pendingCount,
            stats: stats,
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

    // Show loading indicator briefly
    emit(const RejectionRequestsOperationInProgress(
        'جاري الموافقة على الاعتذار...'));

    final result = await _approveExcuse(
      requestId: event.requestId,
      adminComment: event.adminComment,
    );

    result.fold<void>(
      (Failure failure) {
        emit(RejectionRequestsError(message: failure.message));
        // Restore previous state after error
        Future.delayed(const Duration(seconds: 2), () {
          emit(currentState);
        });
      },
      (_) {
        emit(RejectionRequestsOperationSuccess(
          message: 'تم قبول الاعتذار بنجاح',
          previousState: currentState,
        ));

        // Trigger reload via watch event to get live updates
        add(WatchRejectionRequestsEvent(
          adminDecision: currentState.currentFilter,
        ));
      },
    );
  }

  Future<void> _onRejectExcuse(
    RejectExcuseEvent event,
    Emitter<RejectionRequestsState> emit,
  ) async {
    if (state is! RejectionRequestsLoaded) return;

    final currentState = state as RejectionRequestsLoaded;

    // Show loading indicator briefly
    emit(const RejectionRequestsOperationInProgress('جاري رفض الاعتذار...'));

    final result = await _rejectExcuse(
      requestId: event.requestId,
      adminComment: event.adminComment,
    );

    result.fold<void>(
      (Failure failure) {
        emit(RejectionRequestsError(message: failure.message));
        // Restore previous state after error
        Future.delayed(const Duration(seconds: 2), () {
          emit(currentState);
        });
      },
      (_) {
        emit(RejectionRequestsOperationSuccess(
          message: 'تم رفض الاعتذار بنجاح',
          previousState: currentState,
        ));

        // Trigger reload via watch event to get live updates
        add(WatchRejectionRequestsEvent(
          adminDecision: currentState.currentFilter,
        ));
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
      (Failure failure) {
        // Don't emit error for stats loading failure
        print('⚠️ Failed to load stats: ${failure.message}');
      },
      (stats) {
        if (state is RejectionRequestsLoaded) {
          final currentState = state as RejectionRequestsLoaded;
          emit(currentState.copyWith(stats: stats));
        } else {
          emit(RejectionRequestsLoaded(
            requests: const [],
            stats: stats,
            pendingCount: 0,
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
      (failure) {
        print('⚠️ Failed to load pending count: ${failure.message}');
      },
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
