import '../../models/produk_tambahan_model.dart';
import '../constants/app_strings.dart';

/// Aturan produk tambahan — PRD AB-19, v1.5 (T-60). Fungsi dan batas di sini
/// MURNI (tanpa Firestore dan tanpa state), diuji di
/// `test/produk_tambahan_test.dart`.
///
/// Produk hanya INFORMASI dan perhitungan estimasi: dibayar di lokasi, tanpa
/// payment gateway (PRD §2.1).
class BatasProduk {
  BatasProduk._();

  /// Banyak produk yang boleh didaftarkan satu lapangan.
  static const int jumlahProdukMaksimal = 5;

  static const int namaMaksimal = 30;

  static const int hargaMinimal = 1;
  static const int hargaMaksimal = 1000000;

  /// Jumlah per item yang boleh dipilih pengguna dalam satu booking.
  static const int jumlahPerItemMaksimal = 10;
}

/// Total seluruh produk yang dipesan: `Σ harga × jumlah` — AB-19, BB-74.
/// Produk TIDAK ikut didiskon (AB-18).
int hitungTotalProduk(List<ProdukPesananModel> produk) {
  return produk.fold<int>(0, (total, p) => total + p.harga * p.jumlah);
}

/// Ringkasan satu baris untuk ditampilkan di Riwayat Pemesanan dan Booking
/// Masuk mitra, mis. `Sewa Bola ×2 · Rompi ×1` — BB-74. Kosong kalau tidak
/// ada produk (pemanggil menyembunyikan barisnya).
String ringkasProduk(List<ProdukPesananModel> produk) {
  return produk.map((p) => '${p.nama} ×${p.jumlah}').join(' · ');
}

/// Memeriksa daftar produk milik lapangan sebelum disimpan — AB-19, BB-73.
/// Mengembalikan pesan kesalahan berbahasa Indonesia, atau `null` kalau
/// semuanya valid. Dipakai sebagai pengaman kedua di `LapanganRepository`
/// (form sudah memeriksa tiap kolom lewat `Validators`).
String? periksaDaftarProduk(List<ProdukTambahanModel> daftar) {
  if (daftar.length > BatasProduk.jumlahProdukMaksimal) {
    return AppStrings.errProdukTerlalubanyak;
  }
  for (final p in daftar) {
    final namaRapi = p.nama.trim();
    if (namaRapi.isEmpty || namaRapi.length > BatasProduk.namaMaksimal) {
      return AppStrings.errNamaProdukRentang;
    }
    if (p.harga < BatasProduk.hargaMinimal ||
        p.harga > BatasProduk.hargaMaksimal) {
      return AppStrings.errHargaProdukRentang;
    }
  }
  return null;
}

/// Memeriksa produk yang dipilih pengguna pada satu booking — pengaman kedua
/// di `BookingRepository`. `null` kalau valid.
String? periksaPesananProduk(List<ProdukPesananModel> daftar) {
  for (final p in daftar) {
    if (p.nama.trim().isEmpty ||
        p.harga < BatasProduk.hargaMinimal ||
        p.jumlah < 1 ||
        p.jumlah > BatasProduk.jumlahPerItemMaksimal) {
      return AppStrings.errProdukPesananTidakValid;
    }
  }
  return null;
}

