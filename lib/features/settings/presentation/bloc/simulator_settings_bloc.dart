import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/simulator_settings.dart';
import '../../domain/usecases/simulator_usecases.dart';
import 'simulator_settings_event.dart';
import 'simulator_settings_state.dart';

/// Bloc that manages simulator settings.
class SimulatorSettingsBloc
    extends Bloc<SimulatorSettingsEvent, SimulatorSettingsState> {
  final GetSimulatorSettings _getSimulatorSettings;
  final ToggleSimulator _toggleSimulator;
  final SaveSimulatorSettings _saveSimulatorSettings;

  SimulatorSettingsBloc({
    required GetSimulatorSettings getSimulatorSettings,
    required ToggleSimulator toggleSimulator,
    required SaveSimulatorSettings saveSimulatorSettings,
  })  : _getSimulatorSettings = getSimulatorSettings,
        _toggleSimulator = toggleSimulator,
        _saveSimulatorSettings = saveSimulatorSettings,
        super(const SimulatorSettingsInitial()) {
    on<LoadSimulatorSettings>(_onLoad);
    on<ToggleSimulatorEvent>(_onToggle);
    on<SaveSimulatorSettingsEvent>(_onSave);
  }

  Future<void> _onLoad(
    LoadSimulatorSettings event,
    Emitter<SimulatorSettingsState> emit,
  ) async {
    emit(const SimulatorSettingsLoading());
    try {
      final settings = await _getSimulatorSettings();
      emit(SimulatorSettingsLoaded(settings));
    } catch (e) {
      emit(SimulatorSettingsError('فشل تحميل البيانات: $e'));
    }
  }

  Future<void> _onToggle(
    ToggleSimulatorEvent event,
    Emitter<SimulatorSettingsState> emit,
  ) async {
    final currentSettings = _currentSettings;
    if (currentSettings == null) return;

    emit(SimulatorSettingsActionInProgress(currentSettings));
    try {
      await _toggleSimulator(event.enabled);
      final updated = currentSettings.copyWith(enabled: event.enabled);
      emit(SimulatorSettingsLoaded(updated));
    } catch (e) {
      emit(SimulatorSettingsError(
        'فشل حفظ الإعدادات: $e',
        settings: currentSettings,
      ));
    }
  }

  Future<void> _onSave(
    SaveSimulatorSettingsEvent event,
    Emitter<SimulatorSettingsState> emit,
  ) async {
    final currentSettings = _currentSettings;
    emit(SimulatorSettingsActionInProgress(currentSettings ?? event.settings));
    try {
      await _saveSimulatorSettings(event.settings);
      emit(SimulatorSettingsLoaded(event.settings));
    } catch (e) {
      emit(SimulatorSettingsError(
        'فشل حفظ الإعدادات: $e',
        settings: currentSettings,
      ));
    }
  }

  /// Helper to extract current settings from state.
  SimulatorSettings? get _currentSettings {
    final s = state;
    if (s is SimulatorSettingsLoaded) return s.settings;
    if (s is SimulatorSettingsActionInProgress) return s.settings;
    if (s is SimulatorSettingsError) return s.settings;
    return null;
  }
}
