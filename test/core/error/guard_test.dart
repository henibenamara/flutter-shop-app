import 'package:flutter_shop_app/core/error/exceptions.dart';
import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/core/error/guard.dart';
import 'package:flutter_shop_app/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wraps a returned value in Ok', () async {
    final result = await guard<int>(() async => 42);

    expect(result, isA<Ok<int>>().having((ok) => ok.value, 'value', 42));
  });

  const cases = <(AppException, Failure)>[
    (AuthException('a'), AuthFailure('a')),
    (NetworkException('n'), NetworkFailure('n')),
    (ServerException('s', statusCode: 500), ServerFailure('s')),
    (StorageException('d'), StorageFailure('d')),
  ];

  for (final (exception, expected) in cases) {
    test('maps ${exception.runtimeType} to ${expected.runtimeType}', () async {
      final result = await guard<int>(() async => throw exception);

      expect(
        result,
        isA<Err<int>>().having((err) => err.failure, 'failure', expected),
      );
    });
  }

  test('lets unexpected errors through instead of hiding a bug', () {
    expect(
      guard<int>(() async => throw StateError('bug')),
      throwsStateError,
    );
  });
}
