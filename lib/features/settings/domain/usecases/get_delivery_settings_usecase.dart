
import '../entities/delivery_settings.dart';
import '../repositories/settings_repository.dart';

class GetDeliverySettingsUseCase {
  final SettingsRepository repository;

  GetDeliverySettingsUseCase(this.repository);

  Future<DeliverySettings> call() async {
    return await repository.getDeliverySettings();
  }
}
