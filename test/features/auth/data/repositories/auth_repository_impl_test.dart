import 'package:flutter_shop_app/core/error/exceptions.dart';
import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/core/result.dart';
import 'package:flutter_shop_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_shop_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_shop_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_shop_app/features/auth/domain/entities/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

class MockLocal extends Mock implements AuthLocalDataSource {}

void main() {
  late MockRemote remote;
  late MockLocal local;
  late AuthRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(testSessionModel));

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    repository = AuthRepositoryImpl(remote: remote, local: local);
  });

  group('login', () {
    test('saves the session and returns it', () async {
      when(() => remote.login(username: 'emilys', password: 'pw'))
          .thenAnswer((_) async => testSessionModel);
      when(() => local.saveSession(any())).thenAnswer((_) async {});

      final result = await repository.login(username: 'emilys', password: 'pw');

      expect(result, isA<Ok<Session>>().having((ok) => ok.value, 'value', testSession));
      verify(() => local.saveSession(testSessionModel)).called(1);
    });

    test('maps a rejected login to an AuthFailure and saves nothing', () async {
      when(() => remote.login(username: 'emilys', password: 'bad'))
          .thenAnswer((_) async => throw const AuthException('Invalid credentials'));

      final result = await repository.login(username: 'emilys', password: 'bad');

      expect(
        result,
        isA<Err<Session>>().having(
          (err) => err.failure,
          'failure',
          const AuthFailure('Invalid credentials'),
        ),
      );
      verifyNever(() => local.saveSession(any()));
    });

    test('maps a storage error to a StorageFailure', () async {
      when(() => remote.login(username: 'emilys', password: 'pw'))
          .thenAnswer((_) async => testSessionModel);
      when(() => local.saveSession(any()))
          .thenAnswer((_) async => throw const StorageException('disk full'));

      final result = await repository.login(username: 'emilys', password: 'pw');

      expect(
        result,
        isA<Err<Session>>().having(
          (err) => err.failure,
          'failure',
          const StorageFailure('disk full'),
        ),
      );
    });
  });

  group('restoreSession', () {
    test('returns the stored session', () async {
      when(() => local.readSession()).thenAnswer((_) async => testSessionModel);

      final result = await repository.restoreSession();

      expect(result, isA<Ok<Session?>>().having((ok) => ok.value, 'value', testSession));
    });

    test('returns null when nobody is signed in', () async {
      when(() => local.readSession()).thenAnswer((_) async => null);

      final result = await repository.restoreSession();

      expect(result, isA<Ok<Session?>>().having((ok) => ok.value, 'value', isNull));
    });
  });

  test('logout clears the stored session', () async {
    when(() => local.clearSession()).thenAnswer((_) async {});

    final result = await repository.logout();

    expect(result, isA<Ok<void>>());
    verify(() => local.clearSession()).called(1);
  });
}
