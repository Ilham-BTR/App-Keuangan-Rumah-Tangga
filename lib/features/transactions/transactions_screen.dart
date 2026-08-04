import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/transaction.dart';
import '../../providers/providers.dart';
import '../../widgets/month_selector.dart';
import 'transaction_form.dart';

/// Daftar transaksi bulan terpilih + tombol ekspor CSV.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, TxRecord tx) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionForm(existing: tx),
    );
    if (changed == true) invalidateData(ref);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, TxRecord tx) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(transactionServiceProvider).delete(tx.id);
      invalidateData(ref);
    }
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final items = ref.read(transactionsProvider).value ?? [];
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada transaksi untuk diekspor.')));
      return;
    }
    final month = ref.read(selectedMonthProvider);
    try {
      await ref.read(exportServiceProvider).shareCsv(items, month);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal ekspor: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: MonthSelector()),
            IconButton(
              tooltip: 'Ekspor CSV',
              icon: const Icon(Icons.ios_share),
              onPressed: () => _export(context, ref),
            ),
            const SizedBox(width: 4),
          ],
        ),
        Expanded(
          child: txAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                    child: Text('Belum ada transaksi bulan ini.'));
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(transactionsProvider),
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final tx = items[i];
                    final color = tx.isIncome ? kIncomeColor : kExpenseColor;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.15),
                        child: Icon(
                            tx.isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: color),
                      ),
                      title: Text(tx.categoryNama ?? 'Tanpa kategori'),
                      subtitle: Text(
                        [formatTanggal(tx.tanggal), if (tx.catatan.isNotEmpty) tx.catatan]
                            .join(' • '),
                      ),
                      trailing: Text(
                        '${tx.isIncome ? '+' : '-'}${formatRupiah(tx.amount)}',
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _edit(context, ref, tx),
                      onLongPress: () => _delete(context, ref, tx),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Gagal memuat: $e')),
          ),
        ),
      ],
    );
  }
}
