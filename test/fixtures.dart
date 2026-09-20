import 'package:flutter_shop_app/features/auth/data/models/session_model.dart';
import 'package:flutter_shop_app/features/auth/domain/entities/session.dart';
import 'package:flutter_shop_app/features/auth/domain/entities/user.dart';
import 'package:flutter_shop_app/features/products/domain/entities/product.dart';

const testUser = User(
  id: 1,
  username: 'emilys',
  firstName: 'Emily',
  lastName: 'Johnson',
  email: 'emily@example.com',
);

const testSession = Session(user: testUser, accessToken: 'token-123');

const testSessionModel = SessionModel(user: testUser, accessToken: 'token-123');

/// The JSON DummyJSON returns from POST /auth/login.
const loginResponse = {
  'id': 1,
  'username': 'emilys',
  'firstName': 'Emily',
  'lastName': 'Johnson',
  'email': 'emily@example.com',
  'image': 'https://example.com/emily.png',
  'accessToken': 'token-123',
};

Product buildProduct(int id, {String? title}) {
  return Product(
    id: id,
    title: title ?? 'Product $id',
    description: 'Description of product $id.',
    price: 100,
    discountPercentage: 10,
    rating: 4.5,
    stock: 5,
    category: 'beauty',
    brand: 'Brand',
    thumbnail: 'https://example.com/$id.webp',
    images: ['https://example.com/$id.webp'],
  );
}

/// The JSON DummyJSON returns for one product.
Map<String, dynamic> productJson(int id) {
  return {
    'id': id,
    'title': 'Product $id',
    'description': 'Description of product $id.',
    'price': 100,
    'discountPercentage': 10.5,
    'rating': 4.5,
    'stock': 5,
    'category': 'beauty',
    'brand': 'Brand',
    'thumbnail': 'https://example.com/$id.webp',
    'images': ['https://example.com/$id.webp'],
  };
}
