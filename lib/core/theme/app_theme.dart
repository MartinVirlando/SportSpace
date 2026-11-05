import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'mode_tema.dart';

/// Pembuat `ThemeData` terang dan gelap — PRD AB-24, v1.5.
///
/// Mode TERANG sengaja dibiarkan persis seperti sebelumnya
/// (`ColorScheme.fromSeed` dengan hijau merek, latar dari Figma), supaya
/// tampilan di skripsi tidak berubah. Mode GELAP memakai skema yang sama
/// dengan kecerahan gelap, lalu permukaan Material (dialog, bilah navigasi,
/// lembar bawah) diganti abu netral supaya serasi dengan kartu buatan sendiri
/// yang warnanya datang dari [AppPalette]. Tanpa itu, `fromSeed` menghasilkan
/// permukaan gelap bernuansa hijau yang berbeda dari kartu.
class AppTheme {
  AppTheme._();

  // Dibuat SEKALI lalu dipakai ulang: `MaterialApp` dibangun ulang tiap
  // pengaturan berubah, dan membuat `ThemeData` baru setiap kali membuat Flutter
  // menganggap tema berganti dan menggambar ulang seluruh pohon widget.
  static final ThemeData _terang = _bangunTerang();
  static final ThemeData _gelap = _bangunGelap();

  static ThemeData terang() => _terang;
  static ThemeData gelap() => _gelap;

  static ThemeData _bangunTerang() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppPalette.terang.background,
      extensions: const [AppPalette.terang],
    );
  }

  static ThemeData _bangunGelap() {
    const palet = AppPalette.gelap;
    final skema = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      surface: palet.surface,
      onSurface: palet.textPrimary,
      onSurfaceVariant: palet.textSecondary,
      surfaceContainerLowest: palet.background,
      surfaceContainerLow: palet.surface,
      surfaceContainer: const Color(0xFF242424),
      surfaceContainerHigh: const Color(0xFF2A2A2A),
      surfaceContainerHighest: palet.surfaceVariant,
      outline: const Color(0xFF8A8A8A),
      outlineVariant: const Color(0xFF3A3A3A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: skema,
      scaffoldBackgroundColor: palet.background,
      // Material 3 menaungi AppBar dengan warna tema (hijau) saat isi layar
      // tergulung di bawahnya. Di mode terang tipis dan sudah begitu sejak
      // awal, jadi dibiarkan; di mode gelap hasilnya abu kehijauan yang tidak
      // serasi dengan kartu abu netral, jadi tint-nya dimatikan.
      appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
      extensions: const [palet],
    );
  }

  /// Pilihan pengguna → `ThemeMode` Flutter. Satu-satunya tempat konversi ini.
  static ThemeMode themeModeDari(ModeTema mode) => switch (mode) {
        ModeTema.terang => ThemeMode.light,
        ModeTema.gelap => ThemeMode.dark,
        ModeTema.sistem => ThemeMode.system,
      };
}
