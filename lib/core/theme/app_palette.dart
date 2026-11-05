import 'package:flutter/material.dart';

/// Warna yang BERUBAH mengikuti mode terang/gelap — PRD AB-24, v1.5.
///
/// Dipasang di `ThemeData.extensions` (lihat `app_theme.dart`) dan dibaca
/// lewat `context.warna`. Hanya warna yang memang harus berbeda di kedua
/// mode yang ada di sini. Warna yang sama di kedua mode (hijau merek, warna
/// pastel per olahraga) tetap konstanta di `AppColors`.
///
/// Nilai [terang] diambil dari Figma dan SAMA PERSIS dengan konstanta lama di
/// `AppColors` — jadi tampilan mode terang tidak berubah sama sekali.
///
/// **Konsep Flutter yang baru:** `ThemeExtension` adalah cara resmi
/// menambahkan warna/ukuran buatan sendiri ke `ThemeData`. Berbeda dari
/// konstanta `static const`, nilainya dipilih saat runtime berdasarkan tema
/// yang aktif, dan widget yang membacanya lewat `Theme.of(context)` otomatis
/// digambar ulang ketika tema berganti — tanpa kode tambahan.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Latar layar.
  final Color background;

  /// Latar kartu, header, dan lembar bawah.
  final Color surface;

  /// Latar kolom pencarian dan chip.
  final Color surfaceVariant;

  /// Teks utama: nama lapangan, judul, angka.
  final Color textPrimary;

  /// Teks sekunder: alamat, jarak, rating.
  final Color textSecondary;

  /// Ikon besar di dalam thumbnail kartu.
  final Color textTertiary;

  /// Latar area peta pada mockup (L-05) dan garis grid-nya.
  final Color mapBackground;
  final Color mapGrid;

  /// Bayangan kartu lapangan dan chip filter. Di mode gelap bayangan hampir
  /// tidak terlihat, jadi dikosongkan — pemisahnya cukup beda warna latar.
  final List<BoxShadow> shadowKartu;
  final List<BoxShadow> shadowChip;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.mapBackground,
    required this.mapGrid,
    required this.shadowKartu,
    required this.shadowChip,
  });

  /// Mode terang — nilai asli dari Figma.
  static const terang = AppPalette(
    background: Color(0xFFF8F8F8),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF2F2F2),
    textPrimary: Color(0xFF1C1C1C),
    textSecondary: Color(0xFF8C8C8C),
    textTertiary: Color(0xFF4D4D4D),
    mapBackground: Color(0xFFD8E9D8),
    mapGrid: Color(0x80B2D9B2),
    // 0 2px 8px rgba(0,0,0,0.08)
    shadowKartu: [
      BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 8),
    ],
    // 0 1px 4px rgba(0,0,0,0.06)
    shadowChip: [
      BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 4),
    ],
  );

  /// Mode gelap. Kontras teks terhadap latar sudah diperiksa: teks utama
  /// (#EDEDED) di atas permukaan (#1E1E1E) lebih dari 14:1, teks sekunder
  /// (#A3A3A3) sekitar 6:1 — di atas batas 4,5:1 untuk teks kecil (WCAG AA).
  static const gelap = AppPalette(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF2C2C2C),
    textPrimary: Color(0xFFEDEDED),
    textSecondary: Color(0xFFA3A3A3),
    textTertiary: Color(0xFFC7C7C7),
    mapBackground: Color(0xFF22301F),
    mapGrid: Color(0x80385238),
    shadowKartu: [],
    shadowChip: [],
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? mapBackground,
    Color? mapGrid,
    List<BoxShadow>? shadowKartu,
    List<BoxShadow>? shadowChip,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      mapBackground: mapBackground ?? this.mapBackground,
      mapGrid: mapGrid ?? this.mapGrid,
      shadowKartu: shadowKartu ?? this.shadowKartu,
      shadowChip: shadowChip ?? this.shadowChip,
    );
  }

  /// Dipanggil Flutter saat tema berganti dengan animasi (mis. terang →
  /// gelap): menghasilkan warna di antara dua palet.
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      mapBackground: Color.lerp(mapBackground, other.mapBackground, t)!,
      mapGrid: Color.lerp(mapGrid, other.mapGrid, t)!,
      shadowKartu: BoxShadow.lerpList(shadowKartu, other.shadowKartu, t)!,
      shadowChip: BoxShadow.lerpList(shadowChip, other.shadowChip, t)!,
    );
  }
}

/// Jalan pintas `context.warna.surface` dst.
///
/// Kalau tema tidak punya [AppPalette] (seharusnya tidak pernah, karena
/// `app_theme.dart` selalu memasangnya), jatuh balik ke mode terang —
/// aplikasi tetap tampil, bukan crash.
extension AppPaletteContext on BuildContext {
  AppPalette get warna => Theme.of(this).extension<AppPalette>() ?? AppPalette.terang;
}
