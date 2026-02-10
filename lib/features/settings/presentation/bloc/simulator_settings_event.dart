import 'package:equatable/equatable.dart';

import '../../domain/entities/simulator_settings.dart';

/// Events for SimulatorSettingsBloc.
sealed class SimulatorSettingsEvent extends Equatable {
  const SimulatorSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load simulator settings from repository.
final class LoadSimulatorSettings extends SimulatorSettingsEvent {
  const LoadSimulatorSettings();
}

/// Toggle simulator enabled/disabled.
final class ToggleSimulatorEvent extends SimulatorSettingsEvent {
  final bool enabled;

  const ToggleSimulatorEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Save all simulator settings.
final class SaveSimulatorSettingsEvent extends SimulatorSettingsEvent {
  final SimulatorSettings settings;

  const SaveSimulatorSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}
