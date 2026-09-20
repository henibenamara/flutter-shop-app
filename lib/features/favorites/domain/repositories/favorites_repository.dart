import '../../../../core/result.dart';
import '../../../products/domain/entities/product.dart';

abstract interface class FavoritesRepository {
  Future<Result<List<Product>>> getFavorites();

  /// Adds [product] when it is not a favorite yet and removes it otherwise.
  /// Returns the updated list, newest first.
  Future<Result<List<Product>>> toggle(Product product);
}
