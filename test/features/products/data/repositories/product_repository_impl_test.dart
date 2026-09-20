import 'package:flutter_shop_app/core/error/exceptions.dart';
import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/core/result.dart';
import 'package:flutter_shop_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_shop_app/features/products/data/models/product_model.dart';
import 'package:flutter_shop_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_shop_app/features/products/domain/entities/paged_products.dart';
import 'package:flutter_shop_app/features/products/domain/entities/product.dart';
import 'package:flutter_shop_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';

class MockRemote extends Mock implements ProductRemoteDataSource {}

void main() {
  late MockRemote remote;
  late ProductRepositoryImpl repository;

  setUp(() {
    remote = MockRemote();
    repository = ProductRepositoryImpl(remote);
  });

  test('searchProducts asks for one page at a time', () async {
    final page = PagedProducts(products: [buildProduct(1)], total: 1, skip: 0);
    when(
      () => remote.search(query: 'a', skip: 40, limit: productsPageSize),
    ).thenAnswer((_) async => page);

    final result = await repository.searchProducts(query: 'a', skip: 40);

    expect(result, isA<Ok<PagedProducts>>().having((ok) => ok.value, 'value', page));
  });

  test('searchProducts maps a network error to a NetworkFailure', () async {
    when(
      () => remote.search(
        query: any(named: 'query'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => throw const NetworkException('offline'));

    final result = await repository.searchProducts(query: '', skip: 0);

    expect(
      result,
      isA<Err<PagedProducts>>().having(
        (err) => err.failure,
        'failure',
        const NetworkFailure('offline'),
      ),
    );
  });

  test('getProduct returns the product', () async {
    final model = ProductModel.fromEntity(buildProduct(5));
    when(() => remote.getById(5)).thenAnswer((_) async => model);

    final result = await repository.getProduct(5);

    expect(result, isA<Ok<Product>>().having((ok) => ok.value, 'value', model));
  });

  test('getProduct maps a 404 to a ServerFailure', () async {
    when(() => remote.getById(9)).thenAnswer(
      (_) async => throw const ServerException('Not found', statusCode: 404),
    );

    final result = await repository.getProduct(9);

    expect(
      result,
      isA<Err<Product>>().having(
        (err) => err.failure,
        'failure',
        const ServerFailure('Not found'),
      ),
    );
  });
}
