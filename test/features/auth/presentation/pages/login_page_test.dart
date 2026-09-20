import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_shop_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_shop_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit cubit;

  setUp(() {
    cubit = MockAuthCubit();
    when(
      () => cubit.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> pumpPage(
    WidgetTester tester, [
    AuthState state = const AuthState(status: AuthStatus.unauthenticated),
  ]) {
    whenListen(cubit, const Stream<AuthState>.empty(), initialState: state);
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthCubit>.value(value: cubit, child: const LoginPage()),
      ),
    );
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('asks for both fields and does not sign in when they are empty',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Required'), findsNWidgets(2));
    verifyNever(
      () => cubit.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('signs in with what was typed', (tester) async {
    await pumpPage(tester);

    await tester.enterText(field('Username'), 'emilys');
    await tester.enterText(field('Password'), 'emilyspass');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    verify(() => cubit.login(username: 'emilys', password: 'emilyspass')).called(1);
  });

  testWidgets('the demo account button fills in the username', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Use the demo account'));
    await tester.pump();

    expect(find.text('emilys'), findsOneWidget);
  });

  testWidgets('shows why the last attempt failed', (tester) async {
    await pumpPage(
      tester,
      const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Invalid credentials',
      ),
    );

    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('disables the button and shows progress while signing in',
      (tester) async {
    await pumpPage(
      tester,
      const AuthState(status: AuthStatus.unauthenticated, isSubmitting: true),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
