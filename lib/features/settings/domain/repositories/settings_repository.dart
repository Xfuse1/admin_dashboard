import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/settings_entities.dart';

/// Repository for settings operations.
abstract class SettingsRepository {
  /// Get current app settings.
  Future<Either<Failure, AppSettingsEntity>> getSettings();

  /// Update general settings.
  Future<Either<Failure, void>> updateGeneralSettings(GeneralSettings settings);

  /// Update delivery settings.
  Future<Either<Failure, void>> updateDeliverySettings(
      DeliverySettings settings);

  /// Update commission settings.
  Future<Either<Failure, void>> updateCommissionSettings(
      CommissionSettings settings);

  /// Update notification settings.
  Future<Either<Failure, void>> updateNotificationSettings(
      NotificationSettings settings);

  /// Add delivery zone.
  Future<Either<Failure, DeliveryZone>> addDeliveryZone(DeliveryZone zone);

  /// Update delivery zone.
  Future<Either<Failure, void>> updateDeliveryZone(DeliveryZone zone);

  /// Delete delivery zone.
  Future<Either<Failure, void>> deleteDeliveryZone(String zoneId);
}
