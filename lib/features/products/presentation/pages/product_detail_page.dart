import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_detail_cubit.dart';
import '../widgets/price_text.dart';
import '../widgets/product_image.dart';

/// Shows one product. Expects a [ProductDetailCubit] above it in the tree.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        final product = state.product;
        return Scaffold(
          appBar: AppBar(
            title: Text(product?.title ?? 'Product'),
            actions: [if (product != null) FavoriteButton(product: product)],
          ),
          body: switch (state.status) {
            ProductDetailStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
            ProductDetailStatus.failure => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'Something went wrong.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () => context.read<ProductDetailCubit>().retry(),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            ProductDetailStatus.success when product != null => _Content(product: product),
            ProductDetailStatus.success => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = product.images.isEmpty ? [product.thumbnail] : product.images;
    final subtitle = [if (product.brand != null) product.brand!, product.category];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          children: [
            SizedBox(
              height: 320,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return ProductImage(url: images[index], fit: BoxFit.contain);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    subtitle.join(' · '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PriceText(product: product, large: true),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(product.rating.toStringAsFixed(1)),
                      const SizedBox(width: 16),
                      Text(
                        product.stock > 0 ? '${product.stock} in stock' : 'Out of stock',
                        style: product.stock > 0
                            ? null
                            : TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(product.description, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
