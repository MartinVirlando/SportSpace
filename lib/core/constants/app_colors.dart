// lib/core/constants/app_colors.dart
//
// Seluruh nilai di file ini diambil langsung dari Figma
// "App Skripsi - Sport Field Finder", frame "2 - Home" (node 1:16).
// Bukan hasil kira-kira — jadi kode dan lampiran desain di skripsi konsisten.
//
// Catatan: file Figma belum memakai Figma Variables, jadi warnanya masih
// hardcoded di tiap layer. Konsekuensinya, kalau nanti ada warna yang diubah
// di Figma, file ini TIDAK ikut berubah sendiri — harus diperbarui manual.
//
// v1.5 (mode gelap, PRD AB-24): warna yang BERBEDA di mode terang dan gelap
// (latar, permukaan, teks) pindah ke `AppPalette` dan dibaca lewat
// `context.warna.surface` dst. Yang tinggal di sini hanya warna yang SAMA di
// kedua mode.

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

// Supaya semua berkas yang sudah mengimpor app_colors.dart otomatis punya
// `context.warna` tanpa menambah impor satu per satu.
export '../theme/app_palette.dart' show AppPalette, AppPaletteContext;

class AppColors {
  AppColors._(); // kelas ini hanya wadah konstanta, tidak untuk di-instance

  // ---------- Warna utama ----------
  /// Hijau merek. Dipakai untuk chip aktif, harga, tab aktif, tombol utama.
  /// Sama di mode terang dan gelap.
  static const Color primary = Color(0xFF1FA54E);

  // ---------- Warna per cabang olahraga ----------
  // Dipakai sebagai latar thumbnail kartu lapangan saat fotoURL kosong.
  // Di Figma baru futsal dan badminton yang punya warna; dua sisanya
  // diturunkan dengan tingkat kecerahan yang sama supaya satu keluarga.
  // Pastel terang dengan ikon gelap di atasnya, jadi tetap terbaca di mode
  // gelap dan tidak perlu versi tersendiri.
  static const Color futsal = Color(0xFFB2E5B2);
  static const Color badminton = Color(0xFFB2D9FF);
  static const Color padel =
      Color(0xFFE5E5B2); // turunan — konfirmasi ke desainer
  static const Color miniSoccer =
      Color(0xFFB2E5D9); // turunan — konfirmasi ke desainer
}

/// Ukuran dan jarak yang berulang di seluruh desain.
/// Ditaruh di sini supaya tidak ada angka ajaib bertebaran di widget.
class AppSizes {
  AppSizes._();

  /// Margin kiri-kanan seluruh konten layar.
  static const double marginLayar = 20;

  static const double radiusKartu = 12;
  static const double radiusChip = 20;
  static const double radiusPencarian = 22;

  static const double tinggiPencarian = 44;
  static const double tinggiHeader = 100;
  static const double tinggiBottomNav = 60;

  /// Kartu lapangan di Figma: 168 × 140 (tata letak horizontal).
  static const double lebarKartuLapangan = 168;
  static const double tinggiKartuLapangan = 140;
  static const double tinggiThumbnailKartu = 72;
}

/// Gaya teks. Figma memakai Inter — tambahkan google_fonts atau
/// bundel font-nya ke pubspec, atau ganti ke font bawaan kalau tidak mau
/// menambah dependency di luar PRD Bagian 4 (perlu izin dulu).
///
/// v1.5 (mode gelap): gaya yang warnanya berubah per mode kini FUNGSI yang
/// menerima `context` — `AppTextStyles.judulSeksi(context)`. Dulu `static
/// const`; konstanta tidak bisa memilih warna menurut tema yang aktif.
/// Ukuran dan ketebalan huruf tidak berubah. Gaya yang tidak punya warna
/// bergantung-mode ([harga], [chip], [labelNav]) tetap konstanta.
class AppTextStyles {
  AppTextStyles._();

  /// "Hai, Kevin 👋" — 18 / SemiBold
  static TextStyle sambutan(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: context.warna.textPrimary,
      );

  /// "📍 Jakarta Selatan" — 12 / Regular
  static TextStyle lokasi(BuildContext context) => TextStyle(
        fontSize: 12,
        color: context.warna.textSecondary,
      );

  /// "Lapangan Terdekat" — 15 / SemiBold
  static TextStyle judulSeksi(BuildContext context) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: context.warna.textPrimary,
      );

  /// Nama lapangan di kartu — 12 / SemiBold
  static TextStyle namaLapangan(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: context.warna.textPrimary,
      );

  /// "⭐ 4.8 · 0.8 km" — 10 / Regular
  static TextStyle metaLapangan(BuildContext context) => TextStyle(
        fontSize: 10,
        color: context.warna.textSecondary,
      );

  /// "Rp 120k/jam" — 11 / SemiBold, warna primary
  static const TextStyle harga = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  /// Label chip filter — 12
  static const TextStyle chip = TextStyle(fontSize: 12);

  /// Label bottom navigation — 9
  static const TextStyle labelNav = TextStyle(fontSize: 9);
}
