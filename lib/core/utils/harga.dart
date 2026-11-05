import '../../models/lapangan_model.dart';

/// Perhitungan harga booking — PRD AB-08 (sewa), AB-18 (diskon), AB-19
/// (produk tambahan), v1.5.
///
/// Semua fungsi di sini MURNI: tanpa Firestore dan tanpa state, hanya
/// masukan → keluaran, sehingga bisa diuji otomatis (`test/harga_test.dart`).
/// Sebelumnya logika sewa ada di `BookingViewModel`; dipindah ke sini supaya
/// satu sumber dipakai bersama oleh form reservasi dan (nanti) ubah jadwal.

/// Persen diskon yang diizinkan — PRD 6.2 (`diskonPersen`).
const int diskonPersenMaksimal = 90;

/// Harga [nilai] setelah dipotong [persen] — PRD AB-18, BB-71.
///
/// Dibulatkan ke rupiah terdekat dengan aritmetika bilangan bulat, BUKAN
/// `double`: `(nilai × (100 − persen) + 50) ~/ 100`. Pakai `double` rentan
/// kesalahan pembulatan (mis. 0.1 + 0.2) pada uang. [persen] di luar
/// 0–100 dijepit, jadi data rusak tidak menghasilkan harga negatif.
int hargaSetelahDiskon(int nilai, int persen) {
  final p = persen.clamp(0, 100);
  return (nilai * (100 - p) + 50) ~/ 100;
}

/// Sewa lapangan SEBELUM diskon untuk jam-jam [daftarJam] — PRD AB-08:
/// `harga × jumlah jam`, atau jumlah `hargaSlot` per jam bila lapangan punya
/// harga per periode.
///
/// Periode ditentukan dari jam masing-masing: pagi (< 12), siang (12–17),
/// malam (≥ 18) — pembagian sederhana yang cukup untuk data seed
/// (`SEED-DATA.md`), bukan aturan bisnis dari PRD.
int hitungSewaSebelumDiskon(LapanganModel lapangan, List<int> daftarJam) {
  final hargaSlot = lapangan.hargaSlot;
  if (hargaSlot == null) return lapangan.harga * daftarJam.length;

  return daftarJam.fold<int>(0, (total, jam) {
    final periode = jam < 12 ? 'pagi' : (jam < 18 ? 'siang' : 'malam');
    return total + (hargaSlot[periode] ?? lapangan.harga);
  });
}

/// Rincian estimasi harga satu booking, untuk kotak estimasi di L-10.
class RincianHarga {
  /// Sewa sebelum diskon.
  final int sewaAsli;

  /// Besar potongan dalam rupiah (`sewaAsli − sewaSetelahDiskon`).
  final int potongan;

  /// Sewa setelah diskon.
  final int sewaSetelahDiskon;

  /// Jumlah seluruh produk tambahan (AB-19) — TIDAK didiskon.
  final int totalProduk;

  /// `sewaSetelahDiskon + totalProduk` — nilai yang disimpan ke
  /// `booking.totalHarga`.
  final int total;

  const RincianHarga({
    required this.sewaAsli,
    required this.potongan,
    required this.sewaSetelahDiskon,
    required this.totalProduk,
    required this.total,
  });
}

/// Menghitung [RincianHarga] — PRD AB-18 dan AB-19.
///
/// Diskon (`lapangan.diskonPersen`) hanya mengenai SEWA, bukan produk
/// tambahan. [totalProduk] sudah dijumlahkan pemanggil (`Σ harga × jumlah`).
RincianHarga hitungRincianHarga({
  required LapanganModel lapangan,
  required List<int> daftarJam,
  int totalProduk = 0,
}) {
  final sewaAsli = hitungSewaSebelumDiskon(lapangan, daftarJam);
  final sewaSetelah = hargaSetelahDiskon(sewaAsli, lapangan.diskonPersen);

  return RincianHarga(
    sewaAsli: sewaAsli,
    potongan: sewaAsli - sewaSetelah,
    sewaSetelahDiskon: sewaSetelah,
    totalProduk: totalProduk,
    total: sewaSetelah + totalProduk,
  );
}
