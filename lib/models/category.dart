/// Kategori transaksi (pemasukan atau pengeluaran).
class Category {
  final String id;
  final String nama;
  final String tipe; // 'income' | 'expense'
  final int? warna;

  const Category({
    required this.id,
    required this.nama,
    required this.tipe,
    this.warna,
  });

  bool get isIncome => tipe == 'income';

  factory Category.fromMap(Map<String, dynamic> m) => Category(
        id: m['id'] as String,
        nama: m['nama'] as String,
        tipe: m['tipe'] as String,
        warna: m['warna'] as int?,
      );
}
