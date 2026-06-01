import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  comfort,
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData comfort() {
    // Escuro "conforto ocular": preto levemente levantado + dourado/âmbar.
    const bg = Color(0xFF0B0B0B);
    const gold = Color(0xFFFFC107);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.dark,
      ).copyWith(
        primary: gold,
      ),
      useMaterial3: true,
    );
  }
}

