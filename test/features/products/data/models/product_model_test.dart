import 'package:flutter_shop_app/features/products/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures.dart';

void main() {
  test('parses a full DummyJSON product', () {
    final product = ProductModel.fromJson(productJson(3));

    expect(product.id, 3);
    expect(product.title, 'Product 3');
    expect(product.price, 100.0);
    expect(product.discountPercentage, 10.5);
    expect(product.brand, 'Brand');
    expect(product.images, ['https://example.com/3.webp']);
  });

  test('copes with a product that has no brand, rating or images', () {
    final product = ProductModel.fromJson(const {'id': 2, 'title': 'Bare', 'price': 5});

    expect(product.brand, isNull);
    expect(product.rating, 0);
    expect(product.stock, 0);
    expect(product.images, isEmpty);
    expect(product.description, isEmpty);
  });

  test('survives a round trip through JSON', () {
    final product = ProductModel.fromEntity(buildProduct(4));

    expect(ProductModel.fromJson(product.toJson()), product);
  });

  test('discountedPrice applies the discount', () {
    expect(buildProduct(1).discountedPrice, closeTo(90, 0.001));
  });
}
