import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_shop_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';

class MockFavoritesCubit extends MockCubit<FavoritesState>
    implements FavoritesCubit {}

void main() {
  late MockFavoritesCubit cubit;
  final product = buildProduct(1);

  setUpAll(() => registerFallbackValue(product));

  setUp(() {
    cubit = MockFavoritesCubit();
    when(() => cubit.toggle(any())).thenAnswer((_) async {});
  });

  Future<void> pumpButton(WidgetTester tester, FavoritesState state) {
    whenListen(cubit, const Stream<FavoritesState>.empty(), initialState: state);
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<FavoritesCubit>.value(
            value: cubit,
            child: FavoriteButton(product: product),
          ),
        ),
      ),
    );
  }

  testWidgets('shows an outline heart for a product that is not saved',
      (tester) async {
    await pumpButton(tester, const FavoritesState());

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
  });

  testWidgets('shows a filled heart for a saved product', (tester) async {
    await pumpButton(tester, FavoritesState(items: [product]));

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('toggles the product when tapped', (tester) async {
    await pumpButton(tester, const FavoritesState());

    await tester.tap(find.byType(IconButton));

    verify(() => cubit.toggle(product)).called(1);
  });
}
