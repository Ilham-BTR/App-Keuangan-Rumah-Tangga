import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/formatters.dart';
import '../models/transaction.dart';

/// Membuat file CSV dari daftar transaksi lalu membagikannya.
class ExportService {
  Future<void> shareCsv(List<TxRecord> items, DateTime month) async {
    final rows = <List<dynamic>>[
      ['Tanggal', 'Tipe', 'Kategori', 'Jumlah', 'Catatan'],
      ...items.map((t) => [
            formatTanggal(t.tanggal),
            t.isIncome ? 'Pemasukan' : 'Pengeluaran',
            t.categoryNama ?? '-',
            t.amount.toStringAsFixed(0),
            t.catatan,
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final fileName = 'keuangan_${monthKey(month)}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Laporan Keuangan ${monthLabel(month)}',
      text: 'Laporan keuangan rumah tangga bulan ${monthLabel(month)}.',
    );
  }
}
