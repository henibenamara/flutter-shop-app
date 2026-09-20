import '../../../../core/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProduct {
  const GetProduct(this._repository);

  final ProductRepository _repository;

  Future<Result<Product>> call(int id) => _repository.getProduct(id);
}
