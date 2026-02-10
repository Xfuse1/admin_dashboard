import '../entities/simulator_settings.dart';
import '../repositories/settings_repository.dart';

/// Use case to get simulator settings.
class GetSimulatorSettings {
  final SettingsRepository repository;

  GetSimulatorSettings(this.repository);

  Future<SimulatorSettings> call() async {
    return await repository.getSimulatorSettings();
  }
}

/// Use case to toggle simulator enabled/disabled.
class ToggleSimulator {
  final SettingsRepository repository;

  ToggleSimulator(this.repository);

  Future<void> call(bool enabled) async {
    return await repository.toggleSimulator(enabled);
  }
}

/// Use case to save all simulator settings.
class SaveSimulatorSettings {
  final SettingsRepository repository;

  SaveSimulatorSettings(this.repository);

  Future<void> call(SimulatorSettings settings) async {
    return await repository.saveSimulatorSettings(settings);
  }
}
