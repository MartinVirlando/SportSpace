// lib/core/constants/app_colors.dart
//
// Seluruh nilai di file ini diambil langsung dari Figma
// "App Skripsi - Sport Field Finder", frame "2 - Home" (node 1:16).
// Bukan hasil kira-kira — jadi kode dan lampiran desain di skripsi konsisten.
//
// Catatan: file Figma belum memakai Figma Variables, jadi warnanya masih
// hardcoded di tiap layer. Konsekuensinya, kalau nanti ada warna yang diubah
// di Figma, file ini TIDAK ikut berubah sendiri — harus diperbarui manual.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // kelas ini hanya wadah konstanta, tidak untuk di-instance

  // ---------- Warna utama ----------
  /// Hijau merek. Dipakai untuk chip aktif, harga, tab aktif, tombol utama.
  static const Color primary = Color(0xFF1FA54E);

  // ---------- Latar ----------
  /// Latar layar. Sedikit abu supaya kartu putih terlihat "naik".
  static const Color background = Color(0xFFF8F8F8);

  /// Latar kartu, header, dan bottom navigation.
  static const Color surface = Color(0xFFFFFFFF);

  /// Latar kolom pencarian.
  static const Color surfaceVariant = Color(0xFFF2F2F2);

  // ---------- Teks ----------
  /// Teks utama: nama lapangan, judul, angka.
  static const Color textPrimary = Color(0xFF1C1C1C);

  /// Teks sekunder: alamat, jarak, rating, label tab non-aktif.
  static const Color textSecondary = Color(0xFF8C8C8C);

  /// Ikon besar di dalam thumbnail kartu.
  static const Color textTertiary = Color(0xFF4D4D4D);

  // ---------- Peta (L-05) ----------
  /// Latar area peta pada mockup.
  static const Color mapBackground = Color(0xFFD8E9D8);

  /// Garis grid peta. Di desain: #B2D9B2 dengan opasitas 50%.
  static const Color mapGrid = Color(0x80B2D9B2);

  // ---------- Warna per cabang olahraga ----------
  // Dipakai sebagai latar thumbnail kartu lapangan saat fotoURL kosong.
  // Di Figma baru futsal dan badminton yang punya warna; dua sisanya
  // diturunkan dengan tingkat kecerahan yang sama supaya satu keluarga.
  static const Color futsal = Color(0xFFB2E5B2);
  static const Color badminton = Color(0xFFB2D9FF);
  static const Color padel =
      Color(0xFFE5E5B2); // turunan — konfirmasi ke desainer
  static const Color miniSoccer =
      Color(0xFFB2E5D9); // turunan — konfirmasi ke desainer

  // ---------- Bayangan ----------
  /// Bayangan kartu lapangan: 0 2px 8px rgba(0,0,0,0.08)
  static const List<BoxShadow> shadowKartu = [
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 8),
  ];

  /// Bayangan chip filter non-aktif: 0 1px 4px rgba(0,0,0,0.06)
  static const List<BoxShadow> shadowChip = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 4),
  ];
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
class AppTextStyles {
  AppTextStyles._();

  /// "Hai, Kevin 👋" — 18 / SemiBold
  static const TextStyle sambutan = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// "📍 Jakarta Selatan" — 12 / Regular
  static const TextStyle lokasi = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  /// "Lapangan Terdekat" — 15 / SemiBold
  static const TextStyle judulSeksi = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Nama lapangan di kartu — 12 / SemiBold
  static const TextStyle namaLapangan = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// "⭐ 4.8 · 0.8 km" — 10 / Regular
  static const TextStyle metaLapangan = TextStyle(
    fontSize: 10,
    color: AppColors.textSecondary,
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
