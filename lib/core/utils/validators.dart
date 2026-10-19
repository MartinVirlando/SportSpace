import '../constants/app_strings.dart';

/// Validasi form. Semua mengembalikan `null` kalau valid, atau pesan
/// kesalahan berbahasa Indonesia kalau tidak — bentuk yang langsung
/// dipahami `TextFormField.validator`.
class Validators {
  Validators._();

  static String? wajib(String? nilai, String namaField) {
    if (nilai == null || nilai.trim().isEmpty) {
      return AppStrings.errWajibDiisi(namaField);
    }
    return null;
  }

  static String? surel(String? nilai) {
    if (nilai == null || nilai.trim().isEmpty) return AppStrings.errSurelWajib;

    // Sengaja sederhana. Regex surel yang "lengkap" panjangnya ratusan
    // karakter dan tetap tidak sempurna — validasi sesungguhnya terjadi
    // saat Firebase Auth menolak surel yang tidak sah.
    final pola = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
    if (!pola.hasMatch(nilai.trim())) return AppStrings.errFormatSurel;
    return null;
  }

  static String? kataSandi(String? nilai) {
    if (nilai == null || nilai.isEmpty) return AppStrings.errKataSandiWajib;
    // Firebase Auth menolak kata sandi di bawah 6 karakter, jadi batasnya
    // disamakan supaya pesannya muncul sebelum permintaan jaringan.
    if (nilai.length < 6) return AppStrings.errKataSandiPendek;
    return null;
  }

  static String? konfirmasiKataSandi(String? nilai, String kataSandiAsli) {
    if (nilai != kataSandiAsli) return AppStrings.errKataSandiBeda;
    return null;
  }

  static String? nomorTelepon(String? nilai) {
    if (nilai == null || nilai.trim().isEmpty) return null; // opsional
    final bersih = nilai.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (!RegExp(r'^\d{8,15}$').hasMatch(bersih)) {
      return AppStrings.errNomorTelepon;
    }
    return null;
  }

  /// Jumlah pemain pada form Buat Aktivitas — PRD L-08: 2 sampai 30.
  static String? jumlahPemain(String? nilai) {
    if (nilai == null || nilai.trim().isEmpty) {
      return AppStrings.errJumlahPemainWajib;
    }
    final angka = int.tryParse(nilai.trim());
    if (angka == null) return AppStrings.errJumlahPemainAngka;
    if (angka < 2 || angka > 30) return AppStrings.errJumlahPemainRentang;
    return null;
  }

  /// Waktu aktivitas harus di masa depan — PRD L-08, diuji oleh BB-15.
  static String? waktuDiMasaDepan(DateTime? waktu) {
    if (waktu == null) return AppStrings.errWaktuWajib;
    if (!waktu.isAfter(DateTime.now())) {
      return AppStrings.errWaktuLampau;
    }
    return null;
  }

  /// Ulasan opsional, maksimal 500 karakter — PRD AB-09.
  static String? ulasan(String? nilai) {
    if (nilai == null || nilai.isEmpty) return null; // opsional
    if (nilai.length > 500) return AppStrings.errUlasanPanjang;
    return null;
  }

  /// Harga sewa pada form Tambah/Edit Lapangan — PRD L-15: wajib, angka
  /// bulat positif (rupiah, tanpa desimal — PRD Bagian 6.2).
  static String? harga(String? nilai) {
    if (nilai == null || nilai.trim().isEmpty) return AppStrings.errHargaWajib;
    final angka = int.tryParse(nilai.trim());
    if (angka == null) return AppStrings.errHargaAngka;
    if (angka <= 0) return AppStrings.errHargaNol;
    return null;
  }

  /// Latitude/longitude pada form Tambah/Edit Lapangan — PRD L-15.
  /// [min]/[max] beda untuk latitude (-90..90) dan longitude (-180..180).
  static String? koordinat(
    String? nilai, {
    required String namaField,
    required double min,
    required double max,
  }) {
    if (nilai == null || nilai.trim().isEmpty) {
      return AppStrings.errWajibDiisi(namaField);
    }
    final angka = double.tryParse(nilai.trim());
    if (angka == null) return AppStrings.errHarusAngka(namaField);
    if (angka < min || angka > max) {
      return AppStrings.errRentang(namaField, min, max);
    }
    return null;
  }

  /// URL foto pada form Tambah/Edit Lapangan — PRD L-15: opsional, kalau
  /// diisi harus URL http/https yang sah (foto lapangan tidak diunggah,
  /// hanya tautan eksternal — PRD Bagian 2.1, Firebase Storage dilarang).
  static String? urlOpsional(String? nilai) {
    if (nilai == null || nilai.trim().isEmpty) return null; // opsional
    final uri = Uri.tryParse(nilai.trim());
    if (uri == null || !uri.isAbsolute || !uri.scheme.startsWith('http')) {
      return AppStrings.errUrlFoto;
    }
    return null;
  }
}
