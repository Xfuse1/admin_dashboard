import 'package:equatable/equatable.dart';

import '../../domain/entities/simulator_settings.dart';

/// States for SimulatorSettingsBloc.
sealed class SimulatorSettingsState extends Equatable {
  const SimulatorSettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
final class SimulatorSettingsInitial extends SimulatorSettingsState {
  const SimulatorSettingsInitial();
}

/// Loading state.
final class SimulatorSettingsLoading extends SimulatorSettingsState {
  const SimulatorSettingsLoading();
}

/// Settings loaded successfully.
final class SimulatorSettingsLoaded extends SimulatorSettingsState {
  final SimulatorSettings settings;

  const SimulatorSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Action in progress (saving/toggling) — keeps current settings visible.
final class SimulatorSettingsActionInProgress extends SimulatorSettingsState {
  final SimulatorSettings settings;

  const SimulatorSettingsActionInProgress(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Error state.
final class SimulatorSettingsError extends SimulatorSettingsState {
  final String message;
  final SimulatorSettings? settings;

  const SimulatorSettingsError(this.message, {this.settings});

  @override
  List<Object?> get props => [message, settings];
}
