import '../../../../core/result.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class RestoreSession {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  Future<Result<Session?>> call() => _repository.restoreSession();
}
