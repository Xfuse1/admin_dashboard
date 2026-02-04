import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_delivery_settings_usecase.dart';
import '../../domain/usecases/update_delivery_price_usecase.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetDeliverySettingsUseCase getDeliverySettingsUseCase;
  final UpdateDeliveryPriceUseCase updateDeliveryPriceUseCase;

  SettingsCubit({
    required this.getDeliverySettingsUseCase,
    required this.updateDeliveryPriceUseCase,
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
}
