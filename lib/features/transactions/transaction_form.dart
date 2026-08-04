import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/providers.dart';

/// Form tambah/edit transaksi, ditampilkan sebagai bottom sheet.
/// Jika [existing] null → mode tambah, jika ada → mode edit.
class TransactionForm extends ConsumerStatefulWidget {
  final TxRecord? existing;
  const TransactionForm({super.key, this.existing});

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _catatan;
  late String _tipe;
  String? _categoryId;
  late DateTime _tanggal;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amount = TextEditingController(
        text: e != null ? e.amount.toStringAsFixed(0) : '');
    _catatan = TextEditingController(text: e?.catatan ?? '');
    _tipe = e?.tipe ?? 'expense';
    _categoryId = e?.categoryId;
    _tanggal = e?.tanggal ?? DateTime.now();
  }

  @override
  void dispose() {
    _amount.dispose();
    _catatan.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final service = ref.read(transactionServiceProvider);
    final amount = double.parse(_amount.text.replaceAll('.', '').replaceAll(',', '.'));
    try {
      if (widget.existing == null) {
        await service.add(
          tipe: _tipe,
          amount: amount,
          tanggal: _tanggal,
          categoryId: _categoryId,
          catatan: _catatan.text.trim(),
        );
      } else {
        await service.update(
          id: widget.existing!.id,
          tipe: _tipe,
          amount: amount,
          tanggal: _tanggal,
          categoryId: _categoryId,
          catatan: _catatan.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.existing == null ? 'Tambah Transaksi' : 'Edit Transaksi',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                  ButtonSegment(value: 'income', label: Text('Pemasukan')),
                ],
                selected: {_tipe},
                onSelectionChanged: (s) => setState(() {
                  _tipe = s.first;
                  _categoryId = null; // reset kategori karena tipe berubah
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Jumlah (Rp)', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Isi jumlah';
                  final n = double.tryParse(
                      v.replaceAll('.', '').replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Jumlah tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (cats) {
                  final filtered =
                      cats.where((c) => c.tipe == _tipe).toList();
                  final valid = filtered.any((c) => c.id == _categoryId);
                  return DropdownButtonFormField<String>(
                    value: valid ? _categoryId : null,
                    decoration: const InputDecoration(
                        labelText: 'Kategori', border: OutlineInputBorder()),
                    items: filtered
                        .map((Category c) => DropdownMenuItem(
                            value: c.id, child: Text(c.nama)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                    validator: (v) => v == null ? 'Pilih kategori' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Gagal memuat kategori: $e'),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: 'Tanggal', border: OutlineInputBorder()),
                  child: Text(formatTanggal(_tanggal)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _catatan,
                decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
