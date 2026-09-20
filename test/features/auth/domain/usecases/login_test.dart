import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/core/result.dart';
import 'package:flutter_shop_app/features/auth/domain/entities/session.dart';
import 'package:flutter_shop_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_shop_app/features/auth/domain/usecases/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late Login login;

  setUp(() {
    repository = MockAuthRepository();
    login = Login(repository);
  });

  test('rejects a blank username without calling the repository', () async {
    final result = await login(username: '   ', password: 'secret');

    expect(
      result,
      isA<Err<Session>>().having(
        (err) => err.failure,
        'failure',
        isA<ValidationFailure>(),
      ),
    );
    verifyZeroInteractions(repository);
  });

  test('rejects an empty password without calling the repository', () async {
    final result = await login(username: 'emilys', password: '');

    expect(result, isA<Err<Session>>());
    verifyZeroInteractions(repository);
  });

  test('trims the username and delegates to the repository', () async {
    when(() => repository.login(username: 'emilys', password: 'pw'))
        .thenAnswer((_) async => const Ok(testSession));

    final result = await login(username: '  emilys ', password: 'pw');

    expect(result, isA<Ok<Session>>().having((ok) => ok.value, 'value', testSession));
    verify(() => repository.login(username: 'emilys', password: 'pw')).called(1);
  });
}
