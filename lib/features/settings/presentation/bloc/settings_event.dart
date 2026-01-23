import 'package:equatable/equatable.dart';

import '../../domain/entities/settings_entities.dart';

/// Base class for Settings events.
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load app settings.
class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Update general settings.
class UpdateGeneralSettingsEvent extends SettingsEvent {
  final GeneralSettings settings;

  const UpdateGeneralSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Update delivery settings.
class UpdateDeliverySettingsEvent extends SettingsEvent {
  final DeliverySettings settings;

  const UpdateDeliverySettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Update commission settings.
class UpdateCommissionSettingsEvent extends SettingsEvent {
  final CommissionSettings settings;

  const UpdateCommissionSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Update notification settings.
class UpdateNotificationSettingsEvent extends SettingsEvent {
  final NotificationSettings settings;

  const UpdateNotificationSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Add delivery zone.
class AddDeliveryZoneEvent extends SettingsEvent {
  final DeliveryZone zone;

  const AddDeliveryZoneEvent(this.zone);

  @override
  List<Object?> get props => [zone];
}

/// Update delivery zone.
class UpdateDeliveryZoneEvent extends SettingsEvent {
  final DeliveryZone zone;

  const UpdateDeliveryZoneEvent(this.zone);

  @override
  List<Object?> get props => [zone];
}

/// Delete delivery zone.
class DeleteDeliveryZoneEvent extends SettingsEvent {
  final String zoneId;

  const DeleteDeliveryZoneEvent(this.zoneId);

  @override
  List<Object?> get props => [zoneId];
}

/// Switch settings tab.
class SwitchSettingsTab extends SettingsEvent {
  final int tabIndex;

  const SwitchSettingsTab(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

/// Clear error state.
class ClearSettingsError extends SettingsEvent {
  const ClearSettingsError();
}
