import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/settings_entities.dart';
import '../../domain/usecases/settings_usecases.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC for managing app settings.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings _getSettings;
  final UpdateGeneralSettings _updateGeneralSettings;
  final UpdateDeliverySettings _updateDeliverySettings;
  final UpdateCommissionSettings _updateCommissionSettings;
  final UpdateNotificationSettings _updateNotificationSettings;
  final AddDeliveryZone _addDeliveryZone;
  final UpdateDeliveryZone _updateDeliveryZone;
  final DeleteDeliveryZone _deleteDeliveryZone;

  SettingsBloc({
    required GetSettings getSettings,
    required UpdateGeneralSettings updateGeneralSettings,
    required UpdateDeliverySettings updateDeliverySettings,
    required UpdateCommissionSettings updateCommissionSettings,
    required UpdateNotificationSettings updateNotificationSettings,
    required AddDeliveryZone addDeliveryZone,
    required UpdateDeliveryZone updateDeliveryZone,
    required DeleteDeliveryZone deleteDeliveryZone,
  })  : _getSettings = getSettings,
        _updateGeneralSettings = updateGeneralSettings,
        _updateDeliverySettings = updateDeliverySettings,
        _updateCommissionSettings = updateCommissionSettings,
        _updateNotificationSettings = updateNotificationSettings,
        _addDeliveryZone = addDeliveryZone,
        _updateDeliveryZone = updateDeliveryZone,
        _deleteDeliveryZone = deleteDeliveryZone,
        super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateGeneralSettingsEvent>(_onUpdateGeneralSettings);
    on<UpdateDeliverySettingsEvent>(_onUpdateDeliverySettings);
    on<UpdateCommissionSettingsEvent>(_onUpdateCommissionSettings);
    on<UpdateNotificationSettingsEvent>(_onUpdateNotificationSettings);
    on<AddDeliveryZoneEvent>(_onAddDeliveryZone);
    on<UpdateDeliveryZoneEvent>(_onUpdateDeliveryZone);
    on<DeleteDeliveryZoneEvent>(_onDeleteDeliveryZone);
    on<SwitchSettingsTab>(_onSwitchTab);
    on<ClearSettingsError>(_onClearError);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final result = await _getSettings();

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsLoaded(settings: settings)),
    );
  }

  Future<void> _onUpdateGeneralSettings(
    UpdateGeneralSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(SettingsActionInProgress(
      action: 'حفظ الإعدادات العامة',
      previousState: currentState,
    ));

    final result = await _updateGeneralSettings(event.settings);

    result.fold(
      (failure) =>
          emit(SettingsError(failure.message, previousState: currentState)),
      (_) {
        final updatedSettings = AppSettingsEntity(
          id: currentState.settings.id,
          general: event.settings,
          delivery: currentState.settings.delivery,
          commission: currentState.settings.commission,
          notifications: currentState.settings.notifications,
          updatedAt: DateTime.now(),
        );

        emit(SettingsActionSuccess(
          message: 'تم حفظ الإعدادات العامة',
          updatedState: currentState.copyWith(settings: updatedSettings),
        ));
      },
    );
  }

  Future<void> _onUpdateDeliverySettings(
    UpdateDeliverySettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(SettingsActionInProgress(
      action: 'حفظ إعدادات التوصيل',
      previousState: currentState,
    ));

    final result = await _updateDeliverySettings(event.settings);

    result.fold(
      (failure) =>
          emit(SettingsError(failure.message, previousState: currentState)),
      (_) {
        final updatedSettings = AppSettingsEntity(
          id: currentState.settings.id,
          general: currentState.settings.general,
          delivery: event.settings,
          commission: currentState.settings.commission,
          notifications: currentState.settings.notifications,
          updatedAt: DateTime.now(),
        );

        emit(SettingsActionSuccess(
          message: 'تم حفظ إعدادات التوصيل',
          updatedState: currentState.copyWith(settings: updatedSettings),
        ));
      },
    );
  }

  Future<void> _onUpdateCommissionSettings(
    UpdateCommissionSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(SettingsActionInProgress(
      action: 'حفظ إعدادات العمولات',
      previousState: currentState,
    ));

    final result = await _updateCommissionSettings(event.settings);

    result.fold(
      (failure) =>
          emit(SettingsError(failure.message, previousState: currentState)),
      (_) {
        final updatedSettings = AppSettingsEntity(
          id: currentState.settings.id,
          general: currentState.settings.general,
          delivery: currentState.settings.delivery,
          commission: event.settings,
          notifications: currentState.settings.notifications,
          updatedAt: DateTime.now(),
        );

        emit(SettingsActionSuccess(
          message: 'تم حفظ إعدادات العمولات',
          updatedState: currentState.copyWith(settings: updatedSettings),
        ));
      },
    );
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(SettingsActionInProgress(
      action: 'حفظ إعدادات الإشعارات',
      previousState: currentState,
    ));

    final result = await _updateNotificationSettings(event.settings);

    result.fold(
      (failure) =>
          emit(SettingsError(failure.message, previousState: currentState)),
      (_) {
        final updatedSettings = AppSettingsEntity(
          id: currentState.settings.id,
          general: currentState.settings.general,
          delivery: currentState.settings.delivery,
          commission: currentState.settings.commission,
          notifications: event.settings,
          updatedAt: DateTime.now(),
        );

        emit(SettingsActionSuccess(
          message: 'تم حفظ إعدادات الإشعارات',
          updatedState: currentState.copyWith(settings: updatedSettings),
        ));
      },
    );
  }

  Future<void> _onAddDeliveryZone(
    AddDeliveryZoneEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(SettingsActionInProgress(
      action: 'إضافة منطقة توصيل',
      previousState: currentState,
    ));

    final result = await _addDeliveryZone(event.zone);

    result.fold(
      (failure) =>
          emit(SettingsError(failure.message, previousState: currentState)),
      (newZone) {
        final currentDelivery = currentState.settings.delivery;
        final updatedDelivery = DeliverySettings(
          baseDeliveryFee: currentDelivery.baseDeliveryFee,
          feePerKilometer: currentDelivery.feePerKilometer,
          minimumOrderAmount: currentDelivery.minimumOrderAmount,
          freeDeliveryThreshold: currentDelivery.freeDeliveryThreshold,
          maxDeliveryRadius: currentDelivery.maxDeliveryRadius,
          estimatedDeliveryTime: currentDelivery.estimatedDeliveryTime,
          zones: [...currentDelivery.zones, newZone],
        );

        final updatedSettings = AppSettingsEntity(
          id: currentState.settings.id,
          general: currentState.settings.general,
          delivery: updatedDelivery,
          commission: currentState.settings.commission,
          notifications: currentState.settings.notifications,
          updatedAt: DateTime.now(),
        );

        emit(SettingsActionSuccess(
          message: 'تمت إضافة منطقة التوصيل',
          updatedState: currentState.copyWith(settings: updatedSettings),
        ));
      },
    );
  }

  Future<void> _onUpdateDeliveryZone(
    UpdateDeliveryZoneEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(SettingsActionInProgress(
      action: 'تحديث منطقة التوصيل',
      previousState: currentState,
    ));

    final result = await _updateDeliveryZone(event.zone);

    result.fold(
      (failure) =>
          emit(SettingsError(failure.message, previousState: currentState)),
      (_) {
        final currentDelivery = currentState.settings.delivery;
        final updatedZones = currentDelivery.zones.map((z) {
          return z.id == event.zone.id ? event.zone : z;
        }).toList();

        final updatedDelivery = DeliverySettings(
          baseDeliveryFee: currentDelivery.baseDeliveryFee,
          feePerKilometer: currentDelivery.feePerKilometer,
          minimumOrderAmount: currentDelivery.minimumOrderAmount,
          freeDeliveryThreshold: currentDelivery.freeDeliveryThreshold,
          maxDeliveryRadius: currentDelivery.maxDeliveryRadius,
          estimatedDeliveryTime: currentDelivery.estimatedDeliveryTime,
          zones: updatedZones,
        );

        final updatedSettings = AppSettingsEntity(
          id: currentState.settings.id,
          general: currentState.settings.general,
          delivery: updatedDelivery,
          commission: currentState.settings.commission,
          notifications: currentState.settings.notifications,
          updatedAt: DateTime.now(),
        );

        emit(SettingsActionSuccess(
          message: 'تم تحديث منطقة التوصيل',
          updatedState: currentState.copyWith(settings: updatedSettings),
        ));
      },
    );
  }

  Future<void> _onDeleteDeliveryZone(
    DeleteDeliveryZoneEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(SettingsActionInProgress(
      action: 'حذف منطقة التوصيل',
      previousState: currentState,
    ));

    final result = await _deleteDeliveryZone(event.zoneId);

    result.fold(
      (failure) =>
          emit(SettingsError(failure.message, previousState: currentState)),
      (_) {
        final currentDelivery = currentState.settings.delivery;
        final updatedZones =
            currentDelivery.zones.where((z) => z.id != event.zoneId).toList();

        final updatedDelivery = DeliverySettings(
          baseDeliveryFee: currentDelivery.baseDeliveryFee,
          feePerKilometer: currentDelivery.feePerKilometer,
          minimumOrderAmount: currentDelivery.minimumOrderAmount,
          freeDeliveryThreshold: currentDelivery.freeDeliveryThreshold,
          maxDeliveryRadius: currentDelivery.maxDeliveryRadius,
          estimatedDeliveryTime: currentDelivery.estimatedDeliveryTime,
          zones: updatedZones,
        );

        final updatedSettings = AppSettingsEntity(
          id: currentState.settings.id,
          general: currentState.settings.general,
          delivery: updatedDelivery,
          commission: currentState.settings.commission,
          notifications: currentState.settings.notifications,
          updatedAt: DateTime.now(),
        );

        emit(SettingsActionSuccess(
          message: 'تم حذف منطقة التوصيل',
          updatedState: currentState.copyWith(settings: updatedSettings),
        ));
      },
    );
  }

  void _onSwitchTab(
    SwitchSettingsTab event,
    Emitter<SettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is! SettingsLoaded) return;

    emit(currentState.copyWith(currentTab: event.tabIndex));
  }

  void _onClearError(
    ClearSettingsError event,
    Emitter<SettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SettingsError && currentState.previousState != null) {
      emit(currentState.previousState!);
    }
  }
}
