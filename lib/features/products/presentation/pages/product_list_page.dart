import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../bloc/product_list_bloc.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  /// Ask for the next page when the user is close to the end of the list.
  /// The bloc ignores the request when a page is already loading.
  void _onScroll() {
    if (_scroll.hasClients && _scroll.position.extentAfter < 400) {
      context.read<ProductListBloc>().add(const ProductNextPageRequested());
    }
  }

  void _onSearchCleared() {
    _search.clear();
    context.read<ProductListBloc>().add(const ProductSearchChanged(''));
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<ProductListBloc>()..add(const ProductListRefreshed());
    await bloc.stream.firstWhere(
      (state) => state.status != ProductListStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.push('/favorites'),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products',
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _search,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear),
                      onPressed: _onSearchCleared,
                    );
                  },
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
              ),
              onChanged: (value) {
                context.read<ProductListBloc>().add(ProductSearchChanged(value));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductListBloc, ProductListState>(
              builder: _buildBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductListState state) {
    if (state.products.isEmpty) {
      switch (state.status) {
        case ProductListStatus.initial:
        case ProductListStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case ProductListStatus.failure:
          return _ErrorView(
            message: state.errorMessage ?? 'Something went wrong.',
            onRetry: () {
              context.read<ProductListBloc>().add(const ProductListStarted());
            },
          );
        case ProductListStatus.success:
          return Center(
            child: Text(
              state.query.isEmpty
                  ? 'No products yet.'
                  : 'No products match "${state.query}".',
            ),
          );
      }
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.66,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: state.products[index]);
              },
            ),
          ),
          SliverToBoxAdapter(child: _ListFooter(state: state)),
        ],
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final ProductListState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.status == ProductListStatus.failure) {
      return _retryButton(
        'Could not refresh. Tap to retry.',
        () => context.read<ProductListBloc>().add(const ProductListRefreshed()),
      );
    }
    if (state.errorMessage != null) {
      return _retryButton(
        'Could not load more. Tap to retry.',
        () => context.read<ProductListBloc>().add(const ProductNextPageRequested()),
      );
    }
    return const SizedBox(height: 16);
  }

  Widget _retryButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.refresh),
          label: Text(label),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
