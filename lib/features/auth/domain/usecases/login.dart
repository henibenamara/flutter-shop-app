import '../../../../core/error/failures.dart';
import '../../../../core/result.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class Login {
  const Login(this._repository);

  final AuthRepository _repository;

  /// Blank credentials are rejected here, so the rule holds for any UI or API.
  Future<Result<Session>> call({
    required String username,
    required String password,
  }) {
    final name = username.trim();
    if (name.isEmpty || password.isEmpty) {
      return Future.value(
        const Err<Session>(ValidationFailure('Enter your username and password.')),
      );
    }
    return _repository.login(username: name, password: password);
  }
}
