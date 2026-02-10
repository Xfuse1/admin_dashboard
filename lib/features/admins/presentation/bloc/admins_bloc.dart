import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/admin_entity.dart';
import '../../domain/usecases/admins_usecases.dart';
import 'admins_event.dart';
import 'admins_state.dart';

/// BLoC for managing Admins feature.
class AdminsBloc extends Bloc<AdminsEvent, AdminsState> {
  final GetAdmins _getAdmins;
  final AddAdmin _addAdmin;
  final DeleteAdmin _deleteAdmin;

  List<AdminEntity> _currentAdmins = [];

  AdminsBloc({
    required GetAdmins getAdmins,
    required AddAdmin addAdmin,
    required DeleteAdmin deleteAdmin,
  })  : _getAdmins = getAdmins,
        _addAdmin = addAdmin,
        _deleteAdmin = deleteAdmin,
        super(const AdminsInitial()) {
    on<LoadAdmins>(_onLoadAdmins);
    on<AddAdminRequested>(_onAddAdmin);
    on<DeleteAdminRequested>(_onDeleteAdmin);
  }

  Future<void> _onLoadAdmins(
    LoadAdmins event,
    Emitter<AdminsState> emit,
  ) async {
    emit(const AdminsLoading());

    final result = await _getAdmins();

    result.fold(
      (failure) => emit(AdminsError(failure.message)),
      (admins) {
        _currentAdmins = admins;
        emit(AdminsLoaded(admins));
      },
    );
  }

  Future<void> _onAddAdmin(
    AddAdminRequested event,
    Emitter<AdminsState> emit,
  ) async {
    emit(AdminActionInProgress(_currentAdmins));

    final result = await _addAdmin(
      name: event.name,
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AdminsError(failure.message)),
      (admin) {
        _currentAdmins = [admin, ..._currentAdmins];
        emit(AdminActionSuccess(
          message: 'تم إضافة المسؤول بنجاح',
          admins: _currentAdmins,
        ));
      },
    );
  }

  Future<void> _onDeleteAdmin(
    DeleteAdminRequested event,
    Emitter<AdminsState> emit,
  ) async {
    emit(AdminActionInProgress(_currentAdmins));

    final result = await _deleteAdmin(event.adminId);

    result.fold(
      (failure) => emit(AdminsError(failure.message)),
      (_) {
        _currentAdmins =
            _currentAdmins.where((a) => a.id != event.adminId).toList();
        emit(AdminActionSuccess(
          message: 'تم حذف المسؤول بنجاح',
          admins: _currentAdmins,
        ));
      },
    );
  }
}
