import 'package:intl/intl.dart';

/// Format angka menjadi Rupiah, contoh: 15000 -> "Rp15.000".
final NumberFormat _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);

String formatRupiah(num value) => _rupiah.format(value);

/// Format tanggal singkat, contoh: "04 Agu 2026".
String formatTanggal(DateTime d) => DateFormat('dd MMM yyyy', 'id_ID').format(d);

/// Kunci bulan 'YYYY-MM' dari sebuah DateTime.
String monthKey(DateTime d) => DateFormat('yyyy-MM').format(d);

/// Label bulan ramah, contoh: "Agustus 2026".
String monthLabel(DateTime d) => DateFormat('MMMM yyyy', 'id_ID').format(d);
