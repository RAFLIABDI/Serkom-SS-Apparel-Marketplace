import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _idr.format(amount);
  }
}
