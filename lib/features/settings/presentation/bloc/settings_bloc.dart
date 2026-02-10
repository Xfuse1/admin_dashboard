import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_delivery_settings_usecase.dart';
import '../../domain/usecases/update_delivery_price_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC for managing Settings feature.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetDeliverySettingsUseCase _getDeliverySettingsUseCase;
  final UpdateDeliveryPriceUseCase _updateDeliveryPriceUseCase;
  final SettingsRepository _repository;

  SettingsBloc({
    required GetDeliverySettingsUseCase getDeliverySettingsUseCase,
    required UpdateDeliveryPriceUseCase updateDeliveryPriceUseCase,
    required SettingsRepository repository,
  })  : _getDeliverySettingsUseCase = getDeliverySettingsUseCase,
        _updateDeliveryPriceUseCase = updateDeliveryPriceUseCase,
        _repository = repository,
        super(const SettingsInitial()) {
    on<LoadDeliveryPrice>(_onLoadDeliveryPrice);
    on<UpdateDeliveryPrice>(_onUpdateDeliveryPrice);
    on<LoadDriverCommission>(_onLoadDriverCommission);
    on<UpdateDriverCommission>(_onUpdateDriverCommission);
    on<LoadAllDriverCommissions>(_onLoadAllDriverCommissions);
    on<UpdateAllDriverCommissions>(_onUpdateAllDriverCommissions);
  }

  Future<void> _onLoadDeliveryPrice(
    LoadDeliveryPrice event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await _getDeliverySettingsUseCase();
      emit(DeliverySettingsLoaded(settings.deliveryPrice));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateDeliveryPrice(
    UpdateDeliveryPrice event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      await _updateDeliveryPriceUseCase(event.price);
      emit(const SettingsSuccess('تم تحديث سعر التوصيل بنجاح'));
      // Refresh the data
      final settings = await _getDeliverySettingsUseCase();
      emit(DeliverySettingsLoaded(settings.deliveryPrice));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onLoadDriverCommission(
    LoadDriverCommission event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final rate = await _repository.getDriverCommission();
      emit(DriverCommissionLoaded(rate));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateDriverCommission(
    UpdateDriverCommission event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      await _repository.updateDriverCommission(event.rate);
      emit(const SettingsSuccess('تم تحديث عمولة السائق بنجاح'));
      // Refresh the data
      final updatedRate = await _repository.getDriverCommission();
      emit(DriverCommissionLoaded(updatedRate));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onLoadAllDriverCommissions(
    LoadAllDriverCommissions event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final commissions = await _repository.getAllDriverCommissions();
      emit(AllDriverCommissionsLoaded(
        rate1Order: commissions['rate'] ?? 10.0,
        rate2Orders: commissions['rate2Orders'] ?? 10.0,
        rate3Orders: commissions['rate3Orders'] ?? 10.0,
        rate4Orders: commissions['rate4Orders'] ?? 10.0,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateAllDriverCommissions(
    UpdateAllDriverCommissions event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      await _repository.updateAllDriverCommissions(
        rate1Order: event.rate1Order,
        rate2Orders: event.rate2Orders,
        rate3Orders: event.rate3Orders,
        rate4Orders: event.rate4Orders,
      );
      emit(const SettingsSuccess('تم تحديث العمولات بنجاح'));
      // Refresh the data
      add(const LoadAllDriverCommissions());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
