import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_shop_app/features/products/presentation/bloc/product_list_bloc.dart';
import 'package:flutter_shop_app/features/products/presentation/pages/product_list_page.dart';
import 'package:flutter_shop_app/features/products/presentation/widgets/product_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';

class MockProductListBloc extends MockBloc<ProductListEvent, ProductListState>
    implements ProductListBloc {}

class MockFavoritesCubit extends MockCubit<FavoritesState>
    implements FavoritesCubit {}

void main() {
  late MockProductListBloc bloc;
  late MockFavoritesCubit favorites;

  setUp(() {
    bloc = MockProductListBloc();
    favorites = MockFavoritesCubit();
    whenListen(
      favorites,
      const Stream<FavoritesState>.empty(),
      initialState: const FavoritesState(),
    );
  });

  Future<void> pumpPage(WidgetTester tester, ProductListState state) {
    whenListen(bloc, const Stream<ProductListState>.empty(), initialState: state);
    return tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProductListBloc>.value(value: bloc),
            BlocProvider<FavoritesCubit>.value(value: favorites),
          ],
          child: const ProductListPage(),
        ),
      ),
    );
  }

  testWidgets('shows a spinner while the first page loads', (tester) async {
    await pumpPage(tester, const ProductListState(status: ProductListStatus.loading));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a card for each product', (tester) async {
    await pumpPage(
      tester,
      ProductListState(
        status: ProductListStatus.success,
        products: [buildProduct(1), buildProduct(2), buildProduct(3)],
      ),
    );

    expect(find.byType(ProductCard), findsNWidgets(3));
    expect(find.text('Product 2'), findsOneWidget);
  });

  testWidgets('says so when a search has no results', (tester) async {
    await pumpPage(
      tester,
      const ProductListState(status: ProductListStatus.success, query: 'zzz'),
    );

    expect(find.text('No products match "zzz".'), findsOneWidget);
  });

  testWidgets('offers a retry when the first page fails', (tester) async {
    await pumpPage(
      tester,
      const ProductListState(
        status: ProductListStatus.failure,
        errorMessage: 'Could not reach the server.',
      ),
    );

    expect(find.text('Could not reach the server.'), findsOneWidget);

    await tester.tap(find.text('Try again'));

    verify(() => bloc.add(const ProductListStarted())).called(1);
  });

  testWidgets('sends what the user types to the bloc', (tester) async {
    await pumpPage(tester, const ProductListState(status: ProductListStatus.loading));

    await tester.enterText(find.byType(TextField), 'phone');

    verify(() => bloc.add(const ProductSearchChanged('phone'))).called(1);
  });

  testWidgets('shows a spinner under the list while the next page loads',
      (tester) async {
    await pumpPage(
      tester,
      ProductListState(
        status: ProductListStatus.success,
        products: [buildProduct(1)],
        hasMore: true,
        isLoadingMore: true,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('lets the user retry when the next page fails', (tester) async {
    await pumpPage(
      tester,
      ProductListState(
        status: ProductListStatus.success,
        products: [buildProduct(1)],
        hasMore: true,
        errorMessage: 'offline',
      ),
    );

    await tester.tap(find.text('Could not load more. Tap to retry.'));

    verify(() => bloc.add(const ProductNextPageRequested())).called(1);
  });
}
