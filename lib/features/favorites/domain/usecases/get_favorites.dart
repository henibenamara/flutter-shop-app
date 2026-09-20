import '../../../../core/result.dart';
import '../../../products/domain/entities/product.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  const GetFavorites(this._repository);

  final FavoritesRepository _repository;

  Future<Result<List<Product>>> call() => _repository.getFavorites();
}
