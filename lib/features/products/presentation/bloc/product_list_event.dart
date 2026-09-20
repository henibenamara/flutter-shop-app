part of 'product_list_bloc.dart';

sealed class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

/// Load the first page for the current query.
final class ProductListStarted extends ProductListEvent {
  const ProductListStarted();
}

/// Pull to refresh: reload the first page but keep what is on screen.
final class ProductListRefreshed extends ProductListEvent {
  const ProductListRefreshed();
}

final class ProductSearchChanged extends ProductListEvent {
  const ProductSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class ProductNextPageRequested extends ProductListEvent {
  const ProductNextPageRequested();
}
