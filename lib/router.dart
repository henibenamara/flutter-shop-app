import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/favorites/presentation/pages/favorites_page.dart';
import 'features/products/presentation/bloc/product_list_bloc.dart';
import 'features/products/presentation/cubit/product_detail_cubit.dart';
import 'features/products/presentation/pages/product_detail_page.dart';
import 'features/products/presentation/pages/product_list_page.dart';
import 'injection.dart';

const splashPath = '/splash';
const loginPath = '/login';
const productsPath = '/products';
const favoritesPath = '/favorites';

/// Where each auth status is allowed to be. Returns null to stay where you are.
///
/// Kept as a plain function so the rules can be unit tested without a router.
String? authRedirect(AuthStatus status, String location) {
  switch (status) {
    case AuthStatus.unknown:
      return location == splashPath ? null : splashPath;
    case AuthStatus.unauthenticated:
      return location == loginPath ? null : loginPath;
    case AuthStatus.authenticated:
      final onEntryPage = location == loginPath || location == splashPath;
      return onEntryPage ? productsPath : null;
  }
}

/// Tells the router to re-run its redirects whenever [stream] emits.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

GoRouter createRouter({
  required AuthCubit authCubit,
  required Listenable refresh,
}) {
  return GoRouter(
    initialLocation: splashPath,
    refreshListenable: refresh,
    redirect: (context, state) {
      return authRedirect(authCubit.state.status, state.matchedLocation);
    },
    routes: [
      GoRoute(path: splashPath, builder: (context, state) => const SplashPage()),
      GoRoute(path: loginPath, builder: (context, state) => const LoginPage()),
      GoRoute(
        path: productsPath,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => sl<ProductListBloc>()..add(const ProductListStarted()),
            child: const ProductListPage(),
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) return const _NotFoundPage();
              return BlocProvider(
                create: (_) => sl<ProductDetailCubit>()..load(id),
                child: const ProductDetailPage(),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: favoritesPath,
        builder: (context, state) => const FavoritesPage(),
      ),
    ],
  );
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Product not found')),
    );
  }
}
