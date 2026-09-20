import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/network/http_helpers.dart';
import '../../domain/entities/paged_products.dart';
import '../models/product_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<PagedProducts> search({
    required String query,
    required int skip,
    required int limit,
  });

  Future<ProductModel> getById(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._client);

  final http.Client _client;

  @override
  Future<PagedProducts> search({
    required String query,
    required int skip,
    required int limit,
  }) async {
    final uri = Uri.https(
      ApiConfig.host,
      query.isEmpty ? '/products' : '/products/search',
      {
        'limit': limit.toString(),
        'skip': skip.toString(),
        if (query.isNotEmpty) 'q': query,
      },
    );
    final response = await sendRequest(() => _client.get(uri));
    ensureSuccess(response);
    return parseOrThrow(() {
      final json = decodeObject(response);
      final products = (json['products'] as List<dynamic>)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return PagedProducts(
        products: products,
        total: json['total'] as int,
        skip: json['skip'] as int,
      );
    });
  }

  @override
  Future<ProductModel> getById(int id) async {
    final response = await sendRequest(
      () => _client.get(Uri.https(ApiConfig.host, '/products/$id')),
    );
    ensureSuccess(response);
    return parseOrThrow(() => ProductModel.fromJson(decodeObject(response)));
  }
}
