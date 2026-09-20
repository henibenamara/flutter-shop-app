import '../../../../core/error/guard.dart';
import '../../../../core/result.dart';
import '../../domain/entities/paged_products.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<Result<PagedProducts>> searchProducts({
    required String query,
    required int skip,
  }) {
    return guard<PagedProducts>(
      () => _remote.search(query: query, skip: skip, limit: productsPageSize),
    );
  }

  @override
  Future<Result<Product>> getProduct(int id) {
    return guard<Product>(() => _remote.getById(id));
  }
}
