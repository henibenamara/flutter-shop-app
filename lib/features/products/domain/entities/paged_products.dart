import 'package:equatable/equatable.dart';

import 'product.dart';

/// One page of a product listing.
class PagedProducts extends Equatable {
  const PagedProducts({
    required this.products,
    required this.total,
    required this.skip,
  });

  final List<Product> products;

  /// How many products match in total, across all pages.
  final int total;

  /// How many products come before this page.
  final int skip;

  bool get hasMore => skip + products.length < total;

  @override
  List<Object?> get props => [products, total, skip];
}
