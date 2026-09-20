import 'package:flutter/material.dart';

/// A network image that shows a placeholder while loading and when it fails.
class ProductImage extends StatelessWidget {
  const ProductImage({required this.url, this.fit = BoxFit.cover, super.key});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _Placeholder();
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const _Placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}
