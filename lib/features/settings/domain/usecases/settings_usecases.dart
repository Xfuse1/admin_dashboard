import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/settings_entities.dart';
import '../repositories/settings_repository.dart';

/// Get app settings use case.
class GetSettings {
  final SettingsRepository _repository;

  GetSettings(this._repository);

  Future<Either<Failure, AppSettingsEntity>> call() {
    return _repository.getSettings();
  }
}

/// Update general settings use case.
class UpdateGeneralSettings {
  final SettingsRepository _repository;

  UpdateGeneralSettings(this._repository);

  Future<Either<Failure, void>> call(GeneralSettings settings) {
    return _repository.updateGeneralSettings(settings);
  }
}

/// Update delivery settings use case.
class UpdateDeliverySettings {
  final SettingsRepository _repository;

  UpdateDeliverySettings(this._repository);

  Future<Either<Failure, void>> call(DeliverySettings settings) {
    return _repository.updateDeliverySettings(settings);
  }
}

/// Update commission settings use case.
class UpdateCommissionSettings {
  final SettingsRepository _repository;

  UpdateCommissionSettings(this._repository);

  Future<Either<Failure, void>> call(CommissionSettings settings) {
    return _repository.updateCommissionSettings(settings);
  }
}

/// Update notification settings use case.
class UpdateNotificationSettings {
  final SettingsRepository _repository;

  UpdateNotificationSettings(this._repository);

  Future<Either<Failure, void>> call(NotificationSettings settings) {
    return _repository.updateNotificationSettings(settings);
  }
}

/// Add delivery zone use case.
class AddDeliveryZone {
  final SettingsRepository _repository;

  AddDeliveryZone(this._repository);

  Future<Either<Failure, DeliveryZone>> call(DeliveryZone zone) {
    return _repository.addDeliveryZone(zone);
  }
}

/// Update delivery zone use case.
class UpdateDeliveryZone {
  final SettingsRepository _repository;

  UpdateDeliveryZone(this._repository);

  Future<Either<Failure, void>> call(DeliveryZone zone) {
    return _repository.updateDeliveryZone(zone);
  }
}

/// Delete delivery zone use case.
class DeleteDeliveryZone {
  final SettingsRepository _repository;

  DeleteDeliveryZone(this._repository);

  Future<Either<Failure, void>> call(String zoneId) {
    return _repository.deleteDeliveryZone(zoneId);
  }
}
