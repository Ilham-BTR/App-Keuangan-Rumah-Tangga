import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/budget_service.dart';
import '../services/category_service.dart';
import '../services/export_service.dart';
import '../services/transaction_service.dart';

// ---------- Services ----------
final authServiceProvider = Provider((_) => AuthService());
final categoryServiceProvider = Provider((_) => CategoryService());
final transactionServiceProvider = Provider((_) => TransactionService());
final budgetServiceProvider = Provider((_) => BudgetService());
final exportServiceProvider = Provider((_) => ExportService());

// ---------- Auth state ----------
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ---------- Bulan aktif (dipakai dashboard, transaksi, budget) ----------
class SelectedMonth extends StateNotifier<DateTime> {
  SelectedMonth() : super(_firstOfCurrentMonth());

  static DateTime _firstOfCurrentMonth() {
    // Tanggal 1 bulan berjalan (tanpa Date.now di test — di app ini aman).
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void previous() => state = DateTime(state.year, state.month - 1, 1);
  void next() => state = DateTime(state.year, state.month + 1, 1);
}

final selectedMonthProvider =
    StateNotifierProvider<SelectedMonth, DateTime>((_) => SelectedMonth());

// ---------- Data providers (auto-refresh saat bulan berubah) ----------
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(categoryServiceProvider).fetchAll();
});

final transactionsProvider = FutureProvider<List<TxRecord>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(transactionServiceProvider).fetchByMonth(month);
});

final budgetsProvider = FutureProvider<List<Budget>>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final key = '${month.year.toString().padLeft(4, '0')}-'
      '${month.month.toString().padLeft(2, '0')}';
  return ref.watch(budgetServiceProvider).fetchByMonth(key);
});

/// Refresh semua data terkait transaksi (dipanggil setelah tambah/edit/hapus).
void invalidateData(WidgetRef ref) {
  ref.invalidate(transactionsProvider);
  ref.invalidate(budgetsProvider);
}
