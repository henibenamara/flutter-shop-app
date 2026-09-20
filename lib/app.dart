import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'injection.dart';
import 'router.dart';

class ShopApp extends StatefulWidget {
  const ShopApp({super.key});

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  late final AuthCubit _auth = sl<AuthCubit>()..restore();
  late final FavoritesCubit _favorites = sl<FavoritesCubit>()..load();
  late final GoRouterRefreshStream _refresh = GoRouterRefreshStream(_auth.stream);
  late final GoRouter _router = createRouter(authCubit: _auth, refresh: _refresh);

  @override
  void dispose() {
    _router.dispose();
    _refresh.dispose();
    unawaited(_auth.close());
    unawaited(_favorites.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _auth),
        BlocProvider<FavoritesCubit>.value(value: _favorites),
      ],
      child: BlocListener<FavoritesCubit, FavoritesState>(
        listenWhen: (previous, current) {
          return current.errorMessage != null &&
              current.errorMessage != previous.errorMessage;
        },
        listener: (context, state) {
          _messengerKey.currentState
            ?..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        child: MaterialApp.router(
          title: 'Shop',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: _messengerKey,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          routerConfig: _router,
        ),
      ),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: brightness,
    ),
  );
}
