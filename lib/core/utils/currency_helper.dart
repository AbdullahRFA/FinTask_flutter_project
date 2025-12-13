import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(double amount) {
    // Uses the "bn_BD" locale for Bangladesh formatting
    // If you want English numbers with Taka symbol, we custom build it.
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '৳',
      decimalDigits: 0, // No decimal points for cleaner look (e.g. ৳500)
    );
    return formatter.format(amount);
  }
}