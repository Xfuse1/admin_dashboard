import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_delivery_settings_usecase.dart';
import '../../domain/usecases/update_delivery_price_usecase.dart';
import '../../domain/repositories/settings_repository.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetDeliverySettingsUseCase getDeliverySettingsUseCase;
  final UpdateDeliveryPriceUseCase updateDeliveryPriceUseCase;
  final SettingsRepository repository;

  SettingsCubit({
    required this.getDeliverySettingsUseCase,
    required this.updateDeliveryPriceUseCase,
    required this.repository,
  }) : super(SettingsInitial());

  Future<void> getDeliveryPrice() async {
    emit(SettingsLoading());
    try {
      final settings = await getDeliverySettingsUseCase();
      emit(DeliverySettingsLoaded(settings.deliveryPrice));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> updateDeliveryPrice(double price) async {
    emit(SettingsLoading());
    try {
      await updateDeliveryPriceUseCase(price);
      emit(const SettingsSuccess('تم تحديث سعر التوصيل بنجاح'));
      // Refresh the data
      final settings = await getDeliverySettingsUseCase();
      emit(DeliverySettingsLoaded(settings.deliveryPrice));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> getDriverCommission() async {
    emit(SettingsLoading());
    try {
      final rate = await repository.getDriverCommission();
      emit(DriverCommissionLoaded(rate));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> updateDriverCommission(double rate) async {
    emit(SettingsLoading());
    try {
      await repository.updateDriverCommission(rate);
      emit(const SettingsSuccess('تم تحديث عمولة السائق بنجاح'));
      // Refresh the data
      final updatedRate = await repository.getDriverCommission();
      emit(DriverCommissionLoaded(updatedRate));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> getAllDriverCommissions() async {
    emit(SettingsLoading());
    try {
      final commissions = await repository.getAllDriverCommissions();
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

  Future<void> updateAllDriverCommissions({
    required double rate1Order,
    required double rate2Orders,
    required double rate3Orders,
    required double rate4Orders,
  }) async {
    emit(SettingsLoading());
    try {
      await repository.updateAllDriverCommissions(
        rate1Order: rate1Order,
        rate2Orders: rate2Orders,
        rate3Orders: rate3Orders,
        rate4Orders: rate4Orders,
      );
      emit(const SettingsSuccess('تم تحديث العمولات بنجاح'));
      // Refresh the data
      await getAllDriverCommissions();
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
