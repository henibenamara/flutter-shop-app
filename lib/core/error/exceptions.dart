/// Errors thrown inside the data layer.
///
/// Repositories catch these and turn them into [Failure]s, so nothing above
/// the data layer ever sees an exception.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The server rejected the credentials.
final class AuthException extends AppException {
  const AuthException(super.message);
}

/// The request never reached the server (offline, DNS, timeout).
final class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// The server answered, but not with what we expected.
final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});

  final int? statusCode;
}

/// Reading or writing local storage failed.
final class StorageException extends AppException {
  const StorageException(super.message);
}
