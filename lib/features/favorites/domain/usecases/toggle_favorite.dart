import '../../../../core/result.dart';
import '../../../products/domain/entities/product.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavorite {
  const ToggleFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<Result<List<Product>>> call(Product product) {
    return _repository.toggle(product);
  }
}
