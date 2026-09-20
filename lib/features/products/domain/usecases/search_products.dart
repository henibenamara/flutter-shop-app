import '../../../../core/result.dart';
import '../entities/paged_products.dart';
import '../repositories/product_repository.dart';

class SearchProducts {
  const SearchProducts(this._repository);

  final ProductRepository _repository;

  Future<Result<PagedProducts>> call({
    required String query,
    required int skip,
  }) {
    return _repository.searchProducts(query: query, skip: skip);
  }
}
