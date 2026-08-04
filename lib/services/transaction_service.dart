import '../core/supabase_client.dart';
import '../models/transaction.dart';

/// Akses data transaksi. Difilter per bulan ('YYYY-MM').
class TransactionService {
  /// Ambil transaksi pada bulan tertentu (berdasarkan tanggal awal & akhir).
  Future<List<TxRecord>> fetchByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final rows = await supabase
        .from('transactions')
        .select('*, categories(nama)')
        .gte('tanggal', _dateOnly(start))
        .lt('tanggal', _dateOnly(end))
        .order('tanggal', ascending: false)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => TxRecord.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add({
    required String tipe,
    required double amount,
    required DateTime tanggal,
    String? categoryId,
    String catatan = '',
  }) async {
    final uid = supabase.auth.currentUser!.id;
    await supabase.from('transactions').insert({
      'user_id': uid,
      'tipe': tipe,
      'amount': amount,
      'tanggal': _dateOnly(tanggal),
      'category_id': categoryId,
      'catatan': catatan,
    });
  }

  Future<void> update({
    required String id,
    required String tipe,
    required double amount,
    required DateTime tanggal,
    String? categoryId,
    String catatan = '',
  }) async {
    await supabase.from('transactions').update({
      'tipe': tipe,
      'amount': amount,
      'tanggal': _dateOnly(tanggal),
      'category_id': categoryId,
      'catatan': catatan,
    }).eq('id', id);
  }

  Future<void> delete(String id) async {
    await supabase.from('transactions').delete().eq('id', id);
  }

  String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
