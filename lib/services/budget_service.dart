import '../core/supabase_client.dart';
import '../models/budget.dart';

/// Akses data anggaran (budget) per kategori per bulan.
class BudgetService {
  Future<List<Budget>> fetchByMonth(String bulan) async {
    final rows = await supabase
        .from('budgets')
        .select('*, categories(nama)')
        .eq('bulan', bulan);
    return (rows as List)
        .map((e) => Budget.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Buat atau perbarui budget (satu baris per kategori+bulan).
  Future<void> upsert({
    required String categoryId,
    required String bulan,
    required double limitAmount,
  }) async {
    final uid = supabase.auth.currentUser!.id;
    await supabase.from('budgets').upsert({
      'user_id': uid,
      'category_id': categoryId,
      'bulan': bulan,
      'limit_amount': limitAmount,
    }, onConflict: 'user_id,category_id,bulan');
  }

  Future<void> delete(String id) async {
    await supabase.from('budgets').delete().eq('id', id);
  }
}
