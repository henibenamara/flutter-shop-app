import '../../../../core/error/guard.dart';
import '../../../../core/result.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Result<Session>> login({
    required String username,
    required String password,
  }) {
    return guard<Session>(() async {
      final session = await _remote.login(username: username, password: password);
      await _local.saveSession(session);
      return session;
    });
  }

  @override
  Future<Result<Session?>> restoreSession() {
    return guard<Session?>(() => _local.readSession());
  }

  @override
  Future<Result<void>> logout() {
    return guard<void>(() => _local.clearSession());
  }
}
