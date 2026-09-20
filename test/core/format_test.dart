import 'package:flutter_shop_app/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats a price with two decimals', () {
    expect(formatPrice(9.5), '\$9.50');
    expect(formatPrice(100), '\$100.00');
  });
}
