import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/restore_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required Login login,
    required RestoreSession restoreSession,
    required Logout logout,
  })  : _login = login,
        _restoreSession = restoreSession,
        _logout = logout,
        super(const AuthState());

  final Login _login;
  final RestoreSession _restoreSession;
  final Logout _logout;

  /// Called once at start-up to pick up a session saved on the device.
  Future<void> restore() async {
    final result = await _restoreSession();
    switch (result) {
      case Ok(:final value):
        emit(
          value == null
              ? const AuthState(status: AuthStatus.unauthenticated)
              : AuthState(status: AuthStatus.authenticated, session: value),
        );
      case Err():
        emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login({required String username, required String password}) async {
    emit(const AuthState(status: AuthStatus.unauthenticated, isSubmitting: true));
    final result = await _login(username: username, password: password);
    switch (result) {
      case Ok(:final value):
        emit(AuthState(status: AuthStatus.authenticated, session: value));
      case Err(:final failure):
        emit(
          AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> logout() async {
    await _logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
