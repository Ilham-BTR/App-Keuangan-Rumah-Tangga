import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/category.dart';
import '../../providers/providers.dart';
import '../../widgets/month_selector.dart';

/// Daftar anggaran per kategori pengeluaran + progress terpakai vs limit.
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final txAsync = ref.watch(transactionsProvider);

    return Column(
      children: [
        const SizedBox(height: 8),
        const MonthSelector(),
        Expanded(
          child: budgetsAsync.when(
            data: (budgets) {
              // Hitung pengeluaran terpakai per kategori dari transaksi bulan ini.
              final spent = <String, double>{};
              for (final t in (txAsync.value ?? [])) {
                if (!t.isIncome && t.categoryId != null) {
                  spent[t.categoryId!] = (spent[t.categoryId!] ?? 0) + t.amount;
                }
              }

              if (budgets.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Belum ada anggaran.\nTekan tombol + di kanan bawah untuk menambah.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: budgets.length,
                itemBuilder: (_, i) {
                  final b = budgets[i];
                  final used = spent[b.categoryId] ?? 0;
                  final ratio =
                      b.limitAmount == 0 ? 0.0 : (used / b.limitAmount);
                  final over = used > b.limitAmount;
                  final sisa = b.limitAmount - used;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(b.categoryNama ?? '-',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () async {
                                  await ref
                                      .read(budgetServiceProvider)
                                      .delete(b.id);
                                  ref.invalidate(budgetsProvider);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio.clamp(0.0, 1.0),
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade300,
                              color: over ? kExpenseColor : kIncomeColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${formatRupiah(used)} / ${formatRupiah(b.limitAmount)}'
                            '  •  ${over ? 'Lebih ${formatRupiah(-sisa)}' : 'Sisa ${formatRupiah(sisa)}'}',
                            style: TextStyle(
                                color: over ? kExpenseColor : Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Gagal memuat: $e')),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.add),
              label: const Text('Tambah / Ubah Anggaran'),
              onPressed: () => _showAddBudget(context, ref),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddBudget(BuildContext context, WidgetRef ref) async {
    final cats = (ref.read(categoriesProvider).value ?? [])
        .where((c) => c.tipe == 'expense')
        .toList();
    if (cats.isEmpty) return;

    String? categoryId = cats.first.id;
    final limitCtrl = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Anggaran Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: categoryId,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: cats
                    .map((Category c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.nama)))
                    .toList(),
                onChanged: (v) => setState(() => categoryId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: limitCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Batas (Rp)'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Simpan')),
          ],
        ),
      ),
    );

    if (saved == true && categoryId != null) {
      final limit = double.tryParse(
              limitCtrl.text.replaceAll('.', '').replaceAll(',', '.')) ??
          0;
      final month = ref.read(selectedMonthProvider);
      await ref.read(budgetServiceProvider).upsert(
            categoryId: categoryId!,
            bulan: monthKey(month),
            limitAmount: limit,
          );
      ref.invalidate(budgetsProvider);
    }
  }
}
