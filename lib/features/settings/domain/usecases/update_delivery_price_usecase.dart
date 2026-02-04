import '../repositories/settings_repository.dart';

class UpdateDeliveryPriceUseCase {
  final SettingsRepository repository;

  UpdateDeliveryPriceUseCase(this.repository);

  Future<void> call(double price) async {
    return await repository.updateDeliveryPrice(price);
  }
}
