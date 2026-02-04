import '../models/delivery_settings_model.dart';

abstract class SettingsDataSource {
  Future<DeliverySettingsModel> getDeliverySettings();
  Future<void> updateDeliveryPrice(double price);
}
