import '../entities/delivery_settings.dart';

abstract class SettingsRepository {
  Future<DeliverySettings> getDeliverySettings();
  Future<void> updateDeliveryPrice(double price);
  Future<double> getDriverCommission();
  Future<void> updateDriverCommission(double rate);
}
