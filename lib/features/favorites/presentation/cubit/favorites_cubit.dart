import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/toggle_favorite.dart';

class FavoritesState extends Equatable {
  const FavoritesState({this.items = const [], this.errorMessage});

  final List<Product> items;
  final String? errorMessage;

  bool contains(int productId) => items.any((product) => product.id == productId);

  @override
  List<Object?> get props => [items, errorMessage];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required GetFavorites getFavorites,
    required ToggleFavorite toggleFavorite,
  })  : _getFavorites = getFavorites,
        _toggleFavorite = toggleFavorite,
        super(const FavoritesState());

  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;

  Future<void> load() async => _emitResult(await _getFavorites());

  Future<void> toggle(Product product) async {
    _emitResult(await _toggleFavorite(product));
  }

  void _emitResult(Result<List<Product>> result) {
    switch (result) {
      case Ok(:final value):
        emit(FavoritesState(items: value));
      case Err(:final failure):
        emit(FavoritesState(items: state.items, errorMessage: failure.message));
    }
  }
}
