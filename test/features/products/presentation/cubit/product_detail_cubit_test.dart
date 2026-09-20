import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/core/result.dart';
import 'package:flutter_shop_app/features/products/domain/entities/product.dart';
import 'package:flutter_shop_app/features/products/domain/usecases/get_product.dart';
import 'package:flutter_shop_app/features/products/presentation/cubit/product_detail_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures.dart';

class MockGetProduct extends Mock implements GetProduct {}

void main() {
  late MockGetProduct getProduct;
  final product = buildProduct(1);

  setUp(() => getProduct = MockGetProduct());

  blocTest<ProductDetailCubit, ProductDetailState>(
    'loads the product',
    setUp: () {
      when(() => getProduct(1)).thenAnswer((_) async => Ok(product));
    },
    build: () => ProductDetailCubit(getProduct),
    act: (cubit) => cubit.load(1),
    expect: () => [
      ProductDetailState(status: ProductDetailStatus.success, product: product),
    ],
  );

  blocTest<ProductDetailCubit, ProductDetailState>(
    'reports a failure',
    setUp: () {
      when(() => getProduct(1)).thenAnswer(
        (_) async => const Err<Product>(ServerFailure('Not found')),
      );
    },
    build: () => ProductDetailCubit(getProduct),
    act: (cubit) => cubit.load(1),
    expect: () => [
      const ProductDetailState(
        status: ProductDetailStatus.failure,
        errorMessage: 'Not found',
      ),
    ],
  );

  blocTest<ProductDetailCubit, ProductDetailState>(
    'retry loads the same product again',
    setUp: () {
      var calls = 0;
      when(() => getProduct(1)).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? const Err<Product>(ServerFailure('boom'))
            : Ok<Product>(product);
      });
    },
    build: () => ProductDetailCubit(getProduct),
    act: (cubit) async {
      await cubit.load(1);
      await cubit.retry();
    },
    expect: () => [
      const ProductDetailState(
        status: ProductDetailStatus.failure,
        errorMessage: 'boom',
      ),
      const ProductDetailState(),
      ProductDetailState(status: ProductDetailStatus.success, product: product),
    ],
  );
}
