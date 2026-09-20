import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.category,
    required this.thumbnail,
    required this.images,
    this.brand,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String category;
  final String thumbnail;
  final List<String> images;
  final String? brand;

  /// The price after the discount, which is what the shopper pays.
  double get discountedPrice => price * (1 - discountPercentage / 100);

  bool get hasDiscount => discountPercentage >= 1;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        discountPercentage,
        rating,
        stock,
        category,
        thumbnail,
        images,
        brand,
      ];
}
