import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/core/result.dart';
import 'package:flutter_shop_app/features/favorites/domain/usecases/get_favorites.dart';
import 'package:flutter_shop_app/features/favorites/domain/usecases/toggle_favorite.dart';
import 'package:flutter_shop_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_shop_app/features/products/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';

class MockGetFavorites extends Mock implements GetFavorites {}

class MockToggleFavorite extends Mock implements ToggleFavorite {}

void main() {
  late MockGetFavorites getFavorites;
  late MockToggleFavorite toggleFavorite;
  final product = buildProduct(1);

  setUpAll(() => registerFallbackValue(product));

  setUp(() {
    getFavorites = MockGetFavorites();
    toggleFavorite = MockToggleFavorite();
  });

  FavoritesCubit buildCubit() {
    return FavoritesCubit(getFavorites: getFavorites, toggleFavorite: toggleFavorite);
  }

  test('contains tells whether a product is a favorite', () {
    final state = FavoritesState(items: [product]);

    expect(state.contains(1), isTrue);
    expect(state.contains(2), isFalse);
  });

  blocTest<FavoritesCubit, FavoritesState>(
    'load emits the saved favorites',
    setUp: () {
      when(() => getFavorites()).thenAnswer((_) async => Ok([product]));
    },
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [FavoritesState(items: [product])],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'toggle emits the updated list',
    setUp: () {
      when(() => toggleFavorite(any())).thenAnswer((_) async => Ok([product]));
    },
    build: buildCubit,
    act: (cubit) => cubit.toggle(product),
    expect: () => [FavoritesState(items: [product])],
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'toggle keeps the list and reports the error when saving fails',
    setUp: () {
      when(() => toggleFavorite(any())).thenAnswer(
        (_) async => const Err<List<Product>>(StorageFailure('disk full')),
      );
    },
    build: buildCubit,
    seed: () => FavoritesState(items: [product]),
    act: (cubit) => cubit.toggle(buildProduct(2)),
    expect: () => [
      FavoritesState(items: [product], errorMessage: 'disk full'),
    ],
  );
}
