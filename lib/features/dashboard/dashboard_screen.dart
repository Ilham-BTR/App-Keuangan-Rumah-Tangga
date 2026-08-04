import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/transaction.dart';
import '../../providers/providers.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/summary_card.dart';

/// Ringkasan bulanan: total pemasukan, pengeluaran, saldo, dan grafik pie
/// pengeluaran per kategori.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // Palet warna untuk irisan pie.
  static const _palette = [
    Color(0xFF1976D2),
    Color(0xFFC62828),
    Color(0xFF2E7D32),
    Color(0xFFF9A825),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFFEF6C00),
    Color(0xFF5D4037),
    Color(0xFFAD1457),
    Color(0xFF546E7A),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(transactionsProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MonthSelector(),
          const SizedBox(height: 8),
          txAsync.when(
            data: (items) => _content(context, items),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text('Gagal memuat: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, List<TxRecord> items) {
    double income = 0, expense = 0;
    final byCategory = <String, double>{};
    for (final t in items) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
        final key = t.categoryNama ?? 'Lainnya';
        byCategory[key] = (byCategory[key] ?? 0) + t.amount;
      }
    }
    final saldo = income - expense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
                child: SummaryCard(
                    label: 'Pemasukan',
                    amount: income,
                    color: kIncomeColor,
                    icon: Icons.arrow_downward)),
            const SizedBox(width: 12),
            Expanded(
                child: SummaryCard(
                    label: 'Pengeluaran',
                    amount: expense,
                    color: kExpenseColor,
                    icon: Icons.arrow_upward)),
          ],
        ),
        const SizedBox(height: 12),
        SummaryCard(
          label: 'Saldo',
          amount: saldo,
          color: saldo >= 0 ? kIncomeColor : kExpenseColor,
          icon: Icons.account_balance_wallet,
        ),
        const SizedBox(height: 24),
        Text('Pengeluaran per Kategori',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (byCategory.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('Belum ada pengeluaran bulan ini.')),
          )
        else
          _pie(byCategory, expense),
      ],
    );
  }

  Widget _pie(Map<String, double> byCategory, double total) {
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    color: _palette[i % _palette.length],
                    title:
                        '${(entries[i].value / total * 100).toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...[
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                          color: _palette[i % _palette.length],
                          shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entries[i].key)),
                  Text(formatRupiah(entries[i].value),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
