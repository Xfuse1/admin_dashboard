import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_entity.dart';

/// Admins states using sealed class.
sealed class AdminsState extends Equatable {
  const AdminsState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class AdminsInitial extends AdminsState {
  const AdminsInitial();
}

/// Loading admins list.
final class AdminsLoading extends AdminsState {
  const AdminsLoading();
}

/// Admins loaded successfully.
final class AdminsLoaded extends AdminsState {
  final List<AdminEntity> admins;

  const AdminsLoaded(this.admins);

  @override
  List<Object?> get props => [admins];
}

/// Admin action in progress (add/delete).
final class AdminActionInProgress extends AdminsState {
  final List<AdminEntity> admins;

  const AdminActionInProgress(this.admins);

  @override
  List<Object?> get props => [admins];
}

/// Admin action success.
final class AdminActionSuccess extends AdminsState {
  final String message;
  final List<AdminEntity> admins;

  const AdminActionSuccess({
    required this.message,
    required this.admins,
  });

  @override
  List<Object?> get props => [message, admins];
}

/// Error state.
final class AdminsError extends AdminsState {
  final String message;

  const AdminsError(this.message);

  @override
  List<Object?> get props => [message];
}
