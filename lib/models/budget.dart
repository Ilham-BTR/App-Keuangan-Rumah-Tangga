/// Anggaran (budget) untuk sebuah kategori pengeluaran pada satu bulan.
class Budget {
  final String id;
  final String categoryId;
  final String? categoryNama;
  final String bulan; // 'YYYY-MM'
  final double limitAmount;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.categoryNama,
    required this.bulan,
    required this.limitAmount,
  });

  factory Budget.fromMap(Map<String, dynamic> m) {
    final cat = m['categories'] as Map<String, dynamic>?;
    return Budget(
      id: m['id'] as String,
      categoryId: m['category_id'] as String,
      categoryNama: cat?['nama'] as String?,
      bulan: m['bulan'] as String,
      limitAmount: (m['limit_amount'] as num).toDouble(),
    );
  }
}
