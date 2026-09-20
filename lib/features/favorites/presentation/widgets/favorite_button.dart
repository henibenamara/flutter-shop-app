import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/domain/entities/product.dart';
import '../cubit/favorites_cubit.dart';

/// A heart that saves or removes [product]. Rebuilds only when this product's
/// favorite status changes, not on every change to the list.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({required this.product, this.filled = false, super.key});

  final Product product;

  /// Draws a light backdrop, for use on top of a product photo.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (previous, current) {
        return previous.contains(product.id) != current.contains(product.id);
      },
      builder: (context, state) {
        final isFavorite = state.contains(product.id);
        return IconButton(
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          color: isFavorite || filled ? Colors.red : null,
          style: filled ? IconButton.styleFrom(backgroundColor: Colors.white70) : null,
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: () => context.read<FavoritesCubit>().toggle(product),
        );
      },
    );
  }
}
