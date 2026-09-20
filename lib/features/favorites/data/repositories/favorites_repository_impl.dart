import '../../../../core/error/guard.dart';
import '../../../../core/result.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._local);

  final FavoritesLocalDataSource _local;

  @override
  Future<Result<List<Product>>> getFavorites() {
    return guard<List<Product>>(() => _local.read());
  }

  @override
  Future<Result<List<Product>>> toggle(Product product) {
    return guard<List<Product>>(() async {
      final current = await _local.read();
      final isFavorite = current.any((item) => item.id == product.id);
      final updated = isFavorite
          ? current.where((item) => item.id != product.id).toList()
          : [ProductModel.fromEntity(product), ...current];
      await _local.write(updated);
      return updated;
    });
  }
}
