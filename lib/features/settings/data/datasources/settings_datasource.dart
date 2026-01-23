import '../../domain/entities/settings_entities.dart';

/// Abstract data source for settings operations.
abstract class SettingsDataSource {
  /// Get current app settings.
  Future<dynamic> getSettings();

  /// Update general settings.
  Future<void> updateGeneralSettings(GeneralSettings settings);

  /// Update delivery settings.
  Future<void> updateDeliverySettings(DeliverySettings settings);

  /// Update commission settings.
  Future<void> updateCommissionSettings(CommissionSettings settings);

  /// Update notification settings.
  Future<void> updateNotificationSettings(NotificationSettings settings);

  /// Add delivery zone.
  Future<DeliveryZone> addDeliveryZone(DeliveryZone zone);

  /// Update delivery zone.
  Future<void> updateDeliveryZone(DeliveryZone zone);

  /// Delete delivery zone.
  Future<void> deleteDeliveryZone(String zoneId);
}
