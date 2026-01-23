import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_datasource.dart';

/// Implementation of SettingsRepository.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource _dataSource;

  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, AppSettingsEntity>> getSettings() async {
    try {
      final settings = await _dataSource.getSettings();
      return Right(settings as AppSettingsEntity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateGeneralSettings(
      GeneralSettings settings) async {
    try {
      await _dataSource.updateGeneralSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDeliverySettings(
      DeliverySettings settings) async {
    try {
      await _dataSource.updateDeliverySettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCommissionSettings(
      CommissionSettings settings) async {
    try {
      await _dataSource.updateCommissionSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings(
      NotificationSettings settings) async {
    try {
      await _dataSource.updateNotificationSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryZone>> addDeliveryZone(
      DeliveryZone zone) async {
    try {
      final newZone = await _dataSource.addDeliveryZone(zone);
      return Right(newZone);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDeliveryZone(DeliveryZone zone) async {
    try {
      await _dataSource.updateDeliveryZone(zone);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeliveryZone(String zoneId) async {
    try {
      await _dataSource.deleteDeliveryZone(zoneId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
