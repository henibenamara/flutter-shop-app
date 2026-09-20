import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shop_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_shop_app/features/products/presentation/cubit/product_detail_cubit.dart';
import 'package:flutter_shop_app/features/products/presentation/pages/product_detail_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';

class MockDetailCubit extends MockCubit<ProductDetailState>
    implements ProductDetailCubit {}

class MockFavoritesCubit extends MockCubit<FavoritesState>
    implements FavoritesCubit {}

void main() {
  late MockDetailCubit detail;
  late MockFavoritesCubit favorites;

  setUp(() {
    detail = MockDetailCubit();
    favorites = MockFavoritesCubit();
    whenListen(
      favorites,
      const Stream<FavoritesState>.empty(),
      initialState: const FavoritesState(),
    );
  });

  Future<void> pumpPage(WidgetTester tester, ProductDetailState state) {
    whenListen(detail, const Stream<ProductDetailState>.empty(), initialState: state);
    return tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProductDetailCubit>.value(value: detail),
            BlocProvider<FavoritesCubit>.value(value: favorites),
          ],
          child: const ProductDetailPage(),
        ),
      ),
    );
  }

  testWidgets('shows a spinner while loading', (tester) async {
    await pumpPage(tester, const ProductDetailState());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the product with its discounted and original price',
      (tester) async {
    await pumpPage(
      tester,
      ProductDetailState(
        status: ProductDetailStatus.success,
        product: buildProduct(1),
      ),
    );

    expect(find.text('Description of product 1.'), findsOneWidget);
    expect(find.text('\$90.00'), findsOneWidget);
    expect(find.text('\$100.00'), findsOneWidget);
    expect(find.text('5 in stock'), findsOneWidget);
    expect(find.byTooltip('Add to favorites'), findsOneWidget);
  });

  testWidgets('shows the error and lets the user retry', (tester) async {
    when(() => detail.retry()).thenAnswer((_) async {});
    await pumpPage(
      tester,
      const ProductDetailState(
        status: ProductDetailStatus.failure,
        errorMessage: 'Product not found.',
      ),
    );

    expect(find.text('Product not found.'), findsOneWidget);

    await tester.tap(find.text('Try again'));

    verify(() => detail.retry()).called(1);
  });
}
