part of 'product_list_bloc.dart';

enum ProductListStatus { initial, loading, success, failure }

final class ProductListState extends Equatable {
  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.query = '',
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final ProductListStatus status;
  final List<Product> products;
  final String query;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  /// The error message is not carried over: each copy starts without one.
  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    String? query,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        query,
        hasMore,
        isLoadingMore,
        errorMessage,
      ];
}
