import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product.dart';

enum ProductDetailStatus { loading, success, failure }

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.loading,
    this.product,
    this.errorMessage,
  });

  final ProductDetailStatus status;
  final Product? product;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, product, errorMessage];
}

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(this._getProduct) : super(const ProductDetailState());

  final GetProduct _getProduct;
  int? _productId;

  Future<void> load(int productId) async {
    _productId = productId;
    emit(const ProductDetailState());
    final result = await _getProduct(productId);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        emit(ProductDetailState(status: ProductDetailStatus.success, product: value));
      case Err(:final failure):
        emit(
          ProductDetailState(
            status: ProductDetailStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> retry() {
    final id = _productId;
    return id == null ? Future<void>.value() : load(id);
  }
}
