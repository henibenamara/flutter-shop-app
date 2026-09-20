import 'dart:convert';

import 'package:flutter_shop_app/core/error/exceptions.dart';
import 'package:flutter_shop_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../../../fixtures.dart';

http.Response _json(Object body, [int status = 200]) {
  return http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  group('search', () {
    test('lists products with paging parameters when the query is empty', () async {
      late Uri requested;
      final client = MockClient((request) async {
        requested = request.url;
        return _json({
          'products': [productJson(1), productJson(2)],
          'total': 50,
          'skip': 20,
          'limit': 20,
        });
      });

      final page = await ProductRemoteDataSourceImpl(client)
          .search(query: '', skip: 20, limit: 20);

      expect(requested.path, '/products');
      expect(requested.queryParameters, {'limit': '20', 'skip': '20'});
      expect(page.products.map((p) => p.id), [1, 2]);
      expect(page.total, 50);
      expect(page.hasMore, isTrue);
    });

    test('uses the search endpoint when there is a query', () async {
      late Uri requested;
      final client = MockClient((request) async {
        requested = request.url;
        return _json({'products': <Object>[], 'total': 0, 'skip': 0, 'limit': 20});
      });

      final page = await ProductRemoteDataSourceImpl(client)
          .search(query: 'phone', skip: 0, limit: 20);

      expect(requested.path, '/products/search');
      expect(requested.queryParameters['q'], 'phone');
      expect(page.products, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('rejects a payload without a product list', () async {
      final client = MockClient((_) async => _json({'total': 1}));

      await expectLater(
        ProductRemoteDataSourceImpl(client).search(query: '', skip: 0, limit: 20),
        throwsA(isA<ServerException>()),
      );
    });

    test('maps a transport failure to NetworkException', () async {
      final client = MockClient((_) async => throw http.ClientException('offline'));

      await expectLater(
        ProductRemoteDataSourceImpl(client).search(query: '', skip: 0, limit: 20),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('getById', () {
    test('fetches one product', () async {
      late Uri requested;
      final client = MockClient((request) async {
        requested = request.url;
        return _json(productJson(7));
      });

      final product = await ProductRemoteDataSourceImpl(client).getById(7);

      expect(requested.path, '/products/7');
      expect(product.id, 7);
    });

    test('turns a 404 into a ServerException with the status code', () async {
      final client = MockClient(
        (_) async => _json({'message': "Product with id '9' not found"}, 404),
      );

      await expectLater(
        ProductRemoteDataSourceImpl(client).getById(9),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.message, 'message', contains('not found')),
        ),
      );
    });
  });
}
