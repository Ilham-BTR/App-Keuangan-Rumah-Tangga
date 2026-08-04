import '../core/supabase_client.dart';
import '../models/category.dart';

/// Akses data kategori.
class CategoryService {
  Future<List<Category>> fetchAll() async {
    final rows = await supabase
        .from('categories')
        .select()
        .order('tipe')
        .order('nama');
    return (rows as List)
        .map((e) => Category.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add({required String nama, required String tipe}) async {
    final uid = supabase.auth.currentUser!.id;
    await supabase.from('categories').insert({
      'user_id': uid,
      'nama': nama,
      'tipe': tipe,
    });
  }

  Future<void> delete(String id) async {
    await supabase.from('categories').delete().eq('id', id);
  }
}
