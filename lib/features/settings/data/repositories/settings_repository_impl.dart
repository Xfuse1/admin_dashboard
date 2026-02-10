import '../../domain/entities/delivery_settings.dart';
import '../../domain/entities/simulator_settings.dart';
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

  @override
  Future<double> getDriverCommission() async {
    return await dataSource.getDriverCommission();
  }

  @override
  Future<void> updateDriverCommission(double rate) async {
    await dataSource.updateDriverCommission(rate);
  }

  @override
  Future<Map<String, double>> getAllDriverCommissions() async {
    return await dataSource.getAllDriverCommissions();
  }

  @override
  Future<void> updateAllDriverCommissions({
    required double rate1Order,
    required double rate2Orders,
    required double rate3Orders,
    required double rate4Orders,
  }) async {
    await dataSource.updateAllDriverCommissions(
      rate1Order: rate1Order,
      rate2Orders: rate2Orders,
      rate3Orders: rate3Orders,
      rate4Orders: rate4Orders,
    );
  }

  @override
  Future<SimulatorSettings> getSimulatorSettings() async {
    return await dataSource.getSimulatorSettings();
  }

  @override
  Future<void> toggleSimulator(bool enabled) async {
    await dataSource.toggleSimulator(enabled);
  }

  @override
  Future<void> saveSimulatorSettings(SimulatorSettings settings) async {
    await dataSource.saveSimulatorSettings(settings);
  }
}
