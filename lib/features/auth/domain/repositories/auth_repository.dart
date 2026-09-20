import '../../../../core/result.dart';
import '../entities/session.dart';

abstract interface class AuthRepository {
  Future<Result<Session>> login({
    required String username,
    required String password,
  });

  /// The stored session, or null when nobody is signed in.
  Future<Result<Session?>> restoreSession();

  Future<Result<void>> logout();
}
