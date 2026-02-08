import '../models/delivery_settings_model.dart';

abstract class SettingsDataSource {
  Future<DeliverySettingsModel> getDeliverySettings();
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
}
