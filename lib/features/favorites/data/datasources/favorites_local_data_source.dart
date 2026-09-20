import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../products/data/models/product_model.dart';

abstract interface class FavoritesLocalDataSource {
  Future<List<ProductModel>> read();

  Future<void> write(List<ProductModel> products);
}

/// Keeps the whole product in storage, so favorites still show offline.
class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  FavoritesLocalDataSourceImpl(this._prefs);

  static const _key = 'favorites.products';

  final SharedPreferences _prefs;

  @override
  Future<List<ProductModel>> read() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }

  @override
  Future<void> write(List<ProductModel> products) async {
    final saved = await _prefs.setString(
      _key,
      jsonEncode(products.map((product) => product.toJson()).toList()),
    );
    if (!saved) throw const StorageException('Could not save your favorites.');
  }
}
