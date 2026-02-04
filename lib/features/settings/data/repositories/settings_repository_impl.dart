import '../../domain/entities/delivery_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource dataSource;

  SettingsRepositoryImpl(this.dataSource);

  @override
  Future<DeliverySettings> getDeliverySettings() async {
    return await dataSource.getDeliverySettings();
  }

  @override
  Future<void> updateDeliveryPrice(double price) async {
    await dataSource.updateDeliveryPrice(price);
  }
}
