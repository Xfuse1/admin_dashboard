import '../entities/delivery_settings.dart';
import '../entities/simulator_settings.dart';

abstract class SettingsRepository {
  Future<DeliverySettings> getDeliverySettings();
  Future<void> updateDeliveryPrice(double price);
  Future<double> getDriverCommission();
  Future<void> updateDriverCommission(double rate);
  Future<Map<String, double>> getAllDriverCommissions();
  Future<void> updateAllDriverCommissions({
    required double rate1Order,
    required double rate2Orders,
    required double rate3Orders,
    required double rate4Orders,
  });
  Future<SimulatorSettings> getSimulatorSettings();
  Future<void> toggleSimulator(bool enabled);
  Future<void> saveSimulatorSettings(SimulatorSettings settings);
}
