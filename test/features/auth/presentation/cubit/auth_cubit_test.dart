import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/core/result.dart';
import 'package:flutter_shop_app/features/auth/domain/entities/session.dart';
import 'package:flutter_shop_app/features/auth/domain/usecases/login.dart';
import 'package:flutter_shop_app/features/auth/domain/usecases/logout.dart';
import 'package:flutter_shop_app/features/auth/domain/usecases/restore_session.dart';
import 'package:flutter_shop_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_shop_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';

class MockLogin extends Mock implements Login {}

class MockRestoreSession extends Mock implements RestoreSession {}

class MockLogout extends Mock implements Logout {}

void main() {
  late MockLogin login;
  late MockRestoreSession restoreSession;
  late MockLogout logout;

  setUp(() {
    login = MockLogin();
    restoreSession = MockRestoreSession();
    logout = MockLogout();
  });

  AuthCubit buildCubit() {
    return AuthCubit(login: login, restoreSession: restoreSession, logout: logout);
  }

  test('starts with an unknown status', () {
    expect(buildCubit().state.status, AuthStatus.unknown);
  });

  group('restore', () {
    blocTest<AuthCubit, AuthState>(
      'is authenticated when a session was saved',
      setUp: () {
        when(() => restoreSession()).thenAnswer((_) async => const Ok<Session?>(testSession));
      },
      build: buildCubit,
      act: (cubit) => cubit.restore(),
      expect: () => [
        const AuthState(status: AuthStatus.authenticated, session: testSession),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'is unauthenticated when nothing was saved',
      setUp: () {
        when(() => restoreSession()).thenAnswer((_) async => const Ok<Session?>(null));
      },
      build: buildCubit,
      act: (cubit) => cubit.restore(),
      expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    );

    blocTest<AuthCubit, AuthState>(
      'is unauthenticated when reading the session fails',
      setUp: () {
        when(() => restoreSession()).thenAnswer(
          (_) async => const Err<Session?>(StorageFailure('unreadable')),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.restore(),
      expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
    );
  });

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'shows progress, then authenticates',
      setUp: () {
        when(() => login(username: 'emilys', password: 'pw'))
            .thenAnswer((_) async => const Ok<Session>(testSession));
      },
      build: buildCubit,
      act: (cubit) => cubit.login(username: 'emilys', password: 'pw'),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated, isSubmitting: true),
        const AuthState(status: AuthStatus.authenticated, session: testSession),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'shows the failure message when the login is rejected',
      setUp: () {
        when(() => login(username: 'emilys', password: 'bad')).thenAnswer(
          (_) async => const Err<Session>(AuthFailure('Invalid credentials')),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.login(username: 'emilys', password: 'bad'),
      expect: () => [
        const AuthState(status: AuthStatus.unauthenticated, isSubmitting: true),
        const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Invalid credentials',
        ),
      ],
    );
  });

  blocTest<AuthCubit, AuthState>(
    'logout ends the session',
    setUp: () {
      when(() => logout()).thenAnswer((_) async => const Ok<void>(null));
    },
    build: buildCubit,
    seed: () => const AuthState(status: AuthStatus.authenticated, session: testSession),
    act: (cubit) => cubit.logout(),
    expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
  );
}
