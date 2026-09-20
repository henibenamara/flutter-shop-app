import 'error/failures.dart';

/// The outcome of an operation that can fail in an expected way.
///
/// Use cases and repositories return this instead of throwing, so callers have
/// to handle both outcomes.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
