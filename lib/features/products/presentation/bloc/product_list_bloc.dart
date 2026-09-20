import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/search_products.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

/// Drives the product list: first page, search, pull to refresh, paging.
///
/// Every event uses a concurrency rule that fits it. Loads and searches are
/// "restartable" (a newer one replaces an older one), and paging is
/// "droppable" (scroll fires many times, only one request should run).
class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc(
    this._searchProducts, {
    Duration searchDebounce = const Duration(milliseconds: 350),
  })  : _searchDebounce = searchDebounce,
        super(const ProductListState()) {
    on<ProductListStarted>(_onStarted, transformer: restartable());
    on<ProductListRefreshed>(_onRefreshed, transformer: restartable());
    on<ProductSearchChanged>(_onSearchChanged, transformer: restartable());
    on<ProductNextPageRequested>(_onNextPageRequested, transformer: droppable());
  }

  final SearchProducts _searchProducts;
  final Duration _searchDebounce;

  Future<void> _onStarted(
    ProductListStarted event,
    Emitter<ProductListState> emit,
  ) {
    return _loadFirstPage(emit, state.query);
  }

  Future<void> _onRefreshed(
    ProductListRefreshed event,
    Emitter<ProductListState> emit,
  ) {
    return _loadFirstPage(emit, state.query, keepItems: true);
  }

  Future<void> _onSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductListState> emit,
  ) async {
    final query = event.query.trim();
    // Wait for the user to stop typing. If another keystroke arrives, this
    // handler is cancelled and emit.isDone becomes true.
    await Future<void>.delayed(_searchDebounce);
    if (emit.isDone) return;
    if (query == state.query && state.status == ProductListStatus.success) return;
    await _loadFirstPage(emit, query);
  }

  Future<void> _loadFirstPage(
    Emitter<ProductListState> emit,
    String query, {
    bool keepItems = false,
  }) async {
    emit(
      state.copyWith(
        status: ProductListStatus.loading,
        query: query,
        products: keepItems ? state.products : const [],
        isLoadingMore: false,
      ),
    );
    final result = await _searchProducts(query: query, skip: 0);
    if (emit.isDone || state.query != query) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            status: ProductListStatus.success,
            products: value.products,
            hasMore: value.hasMore,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: ProductListStatus.failure,
            hasMore: false,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onNextPageRequested(
    ProductNextPageRequested event,
    Emitter<ProductListState> emit,
  ) async {
    if (state.status != ProductListStatus.success ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }
    final query = state.query;
    final skip = state.products.length;
    emit(state.copyWith(isLoadingMore: true));

    final result = await _searchProducts(query: query, skip: skip);
    // The list may have been replaced by a new search while we waited.
    if (state.query != query || state.products.length != skip) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            products: [...state.products, ...value.products],
            hasMore: value.hasMore,
            isLoadingMore: false,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
