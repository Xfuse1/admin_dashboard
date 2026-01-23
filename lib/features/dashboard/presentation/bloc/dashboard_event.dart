import 'package:equatable/equatable.dart';

/// Dashboard event types using sealed class.
sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard data event.
final class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

/// Refresh dashboard data event.
final class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}
