import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_user.dart';

/// Auth state types using sealed class.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before checking auth.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during auth operations.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state with user data.
final class AuthAuthenticated extends AuthState {
  final AdminUser user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Auth error state.
final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
