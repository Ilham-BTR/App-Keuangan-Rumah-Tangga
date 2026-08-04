import 'package:flutter/material.dart';

/// Tema aplikasi. Hijau = pemasukan, merah = pengeluaran.
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
  scaffoldBackgroundColor: const Color(0xFFF6F7F9),
  appBarTheme: const AppBarTheme(centerTitle: true),
);

const Color kIncomeColor = Color(0xFF2E7D32); // hijau
const Color kExpenseColor = Color(0xFFC62828); // merah
