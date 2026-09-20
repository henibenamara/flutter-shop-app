import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../domain/entities/product.dart';

/// The discounted price, with the original struck through when there is one.
class PriceText extends StatelessWidget {
  const PriceText({required this.product, this.large = false, super.key});

  final Product product;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = (large ? theme.textTheme.headlineSmall : theme.textTheme.titleMedium)
        ?.copyWith(fontWeight: FontWeight.w700);
    if (!product.hasDiscount) {
      return Text(formatPrice(product.price), style: style);
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(formatPrice(product.discountedPrice), style: style),
        Text(
          formatPrice(product.price),
          style: theme.textTheme.bodySmall?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
