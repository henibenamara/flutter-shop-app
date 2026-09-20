import 'package:flutter_shop_app/core/error/exceptions.dart';
import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/core/result.dart';
import 'package:flutter_shop_app/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:flutter_shop_app/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:flutter_shop_app/features/products/data/models/product_model.dart';
import 'package:flutter_shop_app/features/products/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures.dart';

/// Keeps favorites in memory so the repository can be tested on its own.
class InMemoryFavorites implements FavoritesLocalDataSource {
  List<ProductModel> stored = [];
  bool failWrites = false;

  @override
  Future<List<ProductModel>> read() async => stored;

  @override
  Future<void> write(List<ProductModel> products) async {
    if (failWrites) throw const StorageException('disk full');
    stored = products;
  }
}

List<int> _ids(Result<List<Product>> result) {
  return (result as Ok<List<Product>>).value.map((p) => p.id).toList();
}

void main() {
  late InMemoryFavorites local;
  late FavoritesRepositoryImpl repository;

  setUp(() {
    local = InMemoryFavorites();
    repository = FavoritesRepositoryImpl(local);
  });

  test('starts empty', () async {
    expect(_ids(await repository.getFavorites()), isEmpty);
  });

  test('toggle adds a product to the front', () async {
    await repository.toggle(buildProduct(1));
    final result = await repository.toggle(buildProduct(2));

    expect(_ids(result), [2, 1]);
  });

  test('toggle removes a product that is already a favorite', () async {
    await repository.toggle(buildProduct(1));
    await repository.toggle(buildProduct(2));

    final result = await repository.toggle(buildProduct(1));

    expect(_ids(result), [2]);
    expect(_ids(await repository.getFavorites()), [2]);
  });

  test('maps a write error to a StorageFailure', () async {
    local.failWrites = true;

    final result = await repository.toggle(buildProduct(1));

    expect(
      result,
      isA<Err<List<Product>>>().having(
        (err) => err.failure,
        'failure',
        const StorageFailure('disk full'),
      ),
    );
  });

  group('FavoritesLocalDataSourceImpl', () {
    Future<FavoritesLocalDataSourceImpl> dataSource([
      Map<String, Object> stored = const {},
    ]) async {
      SharedPreferences.setMockInitialValues(stored);
      return FavoritesLocalDataSourceImpl(await SharedPreferences.getInstance());
    }

    test('keeps whole products so they work offline', () async {
      final source = await dataSource();
      final product = ProductModel.fromEntity(buildProduct(3));

      await source.write([product]);

      expect(await source.read(), [product]);
    });

    test('returns an empty list when the stored value is corrupted', () async {
      final source = await dataSource({'favorites.products': 'nope'});

      expect(await source.read(), isEmpty);
    });
  });
}
