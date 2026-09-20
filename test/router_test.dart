import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_shop_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_shop_app/router.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group('authRedirect', () {
    test('keeps an unknown status on the splash page', () {
      expect(authRedirect(AuthStatus.unknown, '/splash'), isNull);
      expect(authRedirect(AuthStatus.unknown, '/products'), '/splash');
    });

    test('sends signed-out users to the login page', () {
      expect(authRedirect(AuthStatus.unauthenticated, '/login'), isNull);
      expect(authRedirect(AuthStatus.unauthenticated, '/products'), '/login');
      expect(authRedirect(AuthStatus.unauthenticated, '/products/3'), '/login');
      expect(authRedirect(AuthStatus.unauthenticated, '/favorites'), '/login');
    });

    test('moves signed-in users off the entry pages', () {
      expect(authRedirect(AuthStatus.authenticated, '/login'), '/products');
      expect(authRedirect(AuthStatus.authenticated, '/splash'), '/products');
      expect(authRedirect(AuthStatus.authenticated, '/favorites'), isNull);
      expect(authRedirect(AuthStatus.authenticated, '/products/3'), isNull);
    });
  });

  testWidgets('a signed-out user lands on the login page', (tester) async {
    final auth = MockAuthCubit();
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: const AuthState(status: AuthStatus.unauthenticated),
    );
    final refresh = ChangeNotifier();
    final router = createRouter(authCubit: auth, refresh: refresh);

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    refresh.dispose();
  });
}
