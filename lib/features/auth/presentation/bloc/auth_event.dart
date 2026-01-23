import 'package:equatable/equatable.dart';

/// Auth event types using sealed class.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check auth status event.
final class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

/// Login event.
final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Logout event.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
