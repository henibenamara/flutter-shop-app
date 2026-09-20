import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/core/result.dart';
import 'package:flutter_shop_app/features/products/domain/entities/paged_products.dart';
import 'package:flutter_shop_app/features/products/domain/usecases/search_products.dart';
import 'package:flutter_shop_app/features/products/presentation/bloc/product_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';

class MockSearchProducts extends Mock implements SearchProducts {}

PagedProducts _page(List<int> ids, {required int total, int skip = 0}) {
  return PagedProducts(
    products: ids.map(buildProduct).toList(),
    total: total,
    skip: skip,
  );
}

void main() {
  late MockSearchProducts search;
  final firstPage = _page([1, 2], total: 3);

  setUp(() => search = MockSearchProducts());

  ProductListBloc buildBloc() {
    return ProductListBloc(search, searchDebounce: Duration.zero);
  }

  group('ProductListStarted', () {
    blocTest<ProductListBloc, ProductListState>(
      'loads the first page',
      setUp: () {
        when(() => search(query: '', skip: 0)).thenAnswer((_) async => Ok(firstPage));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ProductListStarted()),
      expect: () => [
        const ProductListState(status: ProductListStatus.loading),
        ProductListState(
          status: ProductListStatus.success,
          products: firstPage.products,
          hasMore: true,
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'reports a failure when the first page cannot be loaded',
      setUp: () {
        when(() => search(query: '', skip: 0)).thenAnswer(
          (_) async => const Err<PagedProducts>(ServerFailure('boom')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ProductListStarted()),
      expect: () => [
        const ProductListState(status: ProductListStatus.loading),
        const ProductListState(
          status: ProductListStatus.failure,
          errorMessage: 'boom',
        ),
      ],
    );
  });

  group('ProductSearchChanged', () {
    blocTest<ProductListBloc, ProductListState>(
      'replaces the list with the results for the trimmed query',
      setUp: () {
        when(() => search(query: 'phone', skip: 0))
            .thenAnswer((_) async => Ok(_page([9], total: 1)));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const ProductSearchChanged('  phone ')),
      expect: () => [
        const ProductListState(status: ProductListStatus.loading, query: 'phone'),
        ProductListState(
          status: ProductListStatus.success,
          query: 'phone',
          products: [buildProduct(9)],
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'only searches for the last query when the user keeps typing',
      setUp: () {
        when(() => search(query: 'phone', skip: 0))
            .thenAnswer((_) async => Ok(_page([9], total: 1)));
      },
      build: buildBloc,
      act: (bloc) {
        bloc
          ..add(const ProductSearchChanged('p'))
          ..add(const ProductSearchChanged('ph'))
          ..add(const ProductSearchChanged('phone'));
      },
      expect: () => [
        const ProductListState(status: ProductListStatus.loading, query: 'phone'),
        ProductListState(
          status: ProductListStatus.success,
          query: 'phone',
          products: [buildProduct(9)],
        ),
      ],
      verify: (_) {
        verifyNever(() => search(query: 'p', skip: 0));
        verifyNever(() => search(query: 'ph', skip: 0));
      },
    );
  });

  group('ProductNextPageRequested', () {
    blocTest<ProductListBloc, ProductListState>(
      'appends the next page',
      setUp: () {
        when(() => search(query: '', skip: 2))
            .thenAnswer((_) async => Ok(_page([3], total: 3, skip: 2)));
      },
      build: buildBloc,
      seed: () => ProductListState(
        status: ProductListStatus.success,
        products: firstPage.products,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(const ProductNextPageRequested()),
      expect: () => [
        ProductListState(
          status: ProductListStatus.success,
          products: firstPage.products,
          hasMore: true,
          isLoadingMore: true,
        ),
        ProductListState(
          status: ProductListStatus.success,
          products: [...firstPage.products, buildProduct(3)],
        ),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'does nothing when there are no more pages',
      build: buildBloc,
      seed: () => ProductListState(
        status: ProductListStatus.success,
        products: firstPage.products,
      ),
      act: (bloc) => bloc.add(const ProductNextPageRequested()),
      expect: () => <ProductListState>[],
      verify: (_) {
        verifyNever(
          () => search(query: any(named: 'query'), skip: any(named: 'skip')),
        );
      },
    );

    blocTest<ProductListBloc, ProductListState>(
      'keeps the list and reports the error when the next page fails',
      setUp: () {
        when(() => search(query: '', skip: 2)).thenAnswer(
          (_) async => const Err<PagedProducts>(NetworkFailure('offline')),
        );
      },
      build: buildBloc,
      seed: () => ProductListState(
        status: ProductListStatus.success,
        products: firstPage.products,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(const ProductNextPageRequested()),
      expect: () => [
        ProductListState(
          status: ProductListStatus.success,
          products: firstPage.products,
          hasMore: true,
          isLoadingMore: true,
        ),
        ProductListState(
          status: ProductListStatus.success,
          products: firstPage.products,
          hasMore: true,
          errorMessage: 'offline',
        ),
      ],
    );
  });

  blocTest<ProductListBloc, ProductListState>(
    'ProductListRefreshed keeps the list on screen while reloading',
    setUp: () {
      when(() => search(query: '', skip: 0))
          .thenAnswer((_) async => Ok(_page([7], total: 1)));
    },
    build: buildBloc,
    seed: () => ProductListState(
      status: ProductListStatus.success,
      products: firstPage.products,
      hasMore: true,
    ),
    act: (bloc) => bloc.add(const ProductListRefreshed()),
    expect: () => [
      ProductListState(
        status: ProductListStatus.loading,
        products: firstPage.products,
        hasMore: true,
      ),
      ProductListState(
        status: ProductListStatus.success,
        products: [buildProduct(7)],
      ),
    ],
  );
}
