import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/restore_session.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/favorites/data/datasources/favorites_local_data_source.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/domain/usecases/get_favorites.dart';
import 'features/favorites/domain/usecases/toggle_favorite.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/products/data/datasources/product_remote_data_source.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/domain/usecases/get_product.dart';
import 'features/products/domain/usecases/search_products.dart';
import 'features/products/presentation/bloc/product_list_bloc.dart';
import 'features/products/presentation/cubit/product_detail_cubit.dart';

final GetIt sl = GetIt.instance;

/// Wires every layer together. This is the only file that knows all the
/// concrete classes; everything else depends on interfaces.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<http.Client>(() => http.Client())
    // Auth
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: sl(), local: sl()),
    )
    ..registerLazySingleton(() => Login(sl()))
    ..registerLazySingleton(() => RestoreSession(sl()))
    ..registerLazySingleton(() => Logout(sl()))
    ..registerFactory(
      () => AuthCubit(login: sl(), restoreSession: sl(), logout: sl()),
    )
    // Products
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(sl()))
    ..registerLazySingleton(() => SearchProducts(sl()))
    ..registerLazySingleton(() => GetProduct(sl()))
    ..registerFactory(() => ProductListBloc(sl()))
    ..registerFactory(() => ProductDetailCubit(sl()))
    // Favorites
    ..registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetFavorites(sl()))
    ..registerLazySingleton(() => ToggleFavorite(sl()))
    ..registerFactory(
      () => FavoritesCubit(getFavorites: sl(), toggleFavorite: sl()),
    );
}
