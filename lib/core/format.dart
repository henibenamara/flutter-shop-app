/// Formats a price for display with two decimals, for example \$9.50.
String formatPrice(double value) => '\$${value.toStringAsFixed(2)}';
