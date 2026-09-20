/// Formats a price for display, e.g. 9.99 becomes \$${'9.99'}.
String formatPrice(double value) => '\$${value.toStringAsFixed(2)}';
