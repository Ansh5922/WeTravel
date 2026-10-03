class CurrencyFormatter {
  static String formatINR(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}
