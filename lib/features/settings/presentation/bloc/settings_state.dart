import 'package:equatable/equatable.dart';

import '../../domain/entities/settings_entities.dart';

/// Base class for Settings states.
sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Loading state.
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Loaded state with settings data.
class SettingsLoaded extends SettingsState {
  final AppSettingsEntity settings;
  final int currentTab;

  const SettingsLoaded({
    required this.settings,
    this.currentTab = 0,
  });

  SettingsLoaded copyWith({
    AppSettingsEntity? settings,
    int? currentTab,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      currentTab: currentTab ?? this.currentTab,
    );
  }

  @override
  List<Object?> get props => [settings, currentTab];
}

/// Error state.
class SettingsError extends SettingsState {
  final String message;
  final SettingsState? previousState;

  const SettingsError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// Action in progress (saving settings).
class SettingsActionInProgress extends SettingsState {
  final String action;
  final SettingsLoaded previousState;

  const SettingsActionInProgress({
    required this.action,
    required this.previousState,
  });

  @override
  List<Object?> get props => [action, previousState];
}

/// Action completed successfully.
class SettingsActionSuccess extends SettingsState {
  final String message;
  final SettingsLoaded updatedState;

  const SettingsActionSuccess({
    required this.message,
    required this.updatedState,
  });

  @override
  List<Object?> get props => [message, updatedState];
}
