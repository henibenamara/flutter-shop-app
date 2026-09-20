import '../../../../core/result.dart';
import '../entities/paged_products.dart';
import '../entities/product.dart';

/// How many products one page holds.
const int productsPageSize = 20;

abstract interface class ProductRepository {
  /// Lists products, or searches them when [query] is not empty.
  Future<Result<PagedProducts>> searchProducts({
    required String query,
    required int skip,
  });

  Future<Result<Product>> getProduct(int id);
}
