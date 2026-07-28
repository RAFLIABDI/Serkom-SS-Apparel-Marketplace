import 'package:intl/intl.dart';

// Helper untuk memformat angka menjadi format mata uang Rupiah (Rp)
class CurrencyFormatter {
  // Konfigurasi format: locale Indonesia, simbol Rp, tanpa desimal
  static final NumberFormat _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Mengubah angka menjadi string Rupiah, contoh: 89000 -> "Rp 89.000"
  static String format(double amount) {
    return _idr.format(amount);
  }
}
