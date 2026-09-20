import '../result.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Runs [body] and converts any [AppException] it throws into an [Err].
///
/// This is the single place where data-layer exceptions become domain failures.
Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Ok<T>(await body());
  } on AppException catch (e) {
    return Err<T>(_toFailure(e));
  }
}

Failure _toFailure(AppException e) => switch (e) {
      AuthException() => AuthFailure(e.message),
      NetworkException() => NetworkFailure(e.message),
      ServerException() => ServerFailure(e.message),
      StorageException() => StorageFailure(e.message),
    };
