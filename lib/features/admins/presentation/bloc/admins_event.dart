import 'package:equatable/equatable.dart';

/// Admins events using sealed class.
sealed class AdminsEvent extends Equatable {
  const AdminsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all admins.
final class LoadAdmins extends AdminsEvent {
  const LoadAdmins();
}

/// Add a new admin.
final class AddAdminRequested extends AdminsEvent {
  final String name;
  final String email;
  final String password;

  const AddAdminRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Delete an admin.
final class DeleteAdminRequested extends AdminsEvent {
  final String adminId;

  const DeleteAdminRequested(this.adminId);

  @override
  List<Object?> get props => [adminId];
}
