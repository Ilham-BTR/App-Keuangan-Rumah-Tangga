/// Satu transaksi pemasukan atau pengeluaran.
class TxRecord {
  final String id;
  final String? categoryId;
  final String? categoryNama;
  final String tipe; // 'income' | 'expense'
  final double amount;
  final DateTime tanggal;
  final String catatan;

  const TxRecord({
    required this.id,
    required this.categoryId,
    required this.categoryNama,
    required this.tipe,
    required this.amount,
    required this.tanggal,
    required this.catatan,
  });

  bool get isIncome => tipe == 'income';

  factory TxRecord.fromMap(Map<String, dynamic> m) {
    final cat = m['categories'] as Map<String, dynamic>?;
    return TxRecord(
      id: m['id'] as String,
      categoryId: m['category_id'] as String?,
      categoryNama: cat?['nama'] as String?,
      tipe: m['tipe'] as String,
      amount: (m['amount'] as num).toDouble(),
      tanggal: DateTime.parse(m['tanggal'] as String),
      catatan: (m['catatan'] as String?) ?? '',
    );
  }
}
