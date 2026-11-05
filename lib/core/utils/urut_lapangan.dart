import '../../models/lapangan_model.dart';

/// Pilihan urutan daftar lapangan di Home — PRD AB-16, v1.5 (T-57).
///
/// [terdekat] adalah BAWAAN dan persis AB-02 (murni jarak). Dua lainnya
/// hanya terjadi kalau pengguna sendiri memilihnya, dan kembali ke
/// [terdekat] lewat tombol Reset.
///
/// Sengaja TIDAK ada urutan harga: filter harga dibatalkan (T-49) dan harga
/// lapangan non-mitra hanya estimasi, jadi mengurutkannya menyesatkan.
enum UrutanLapangan { terdekat, rating, populer }

/// Mengurutkan [daftar] menurut [urutan] — PRD AB-16, BB-62, BB-63.
///
/// Mengembalikan daftar BARU; [daftar] asli tidak diubah.
///
/// - [UrutanLapangan.terdekat]: urutan masukan dipertahankan. HomeViewModel
///   sudah mengurutkannya menurut jarak (AB-02) sebelum sampai di sini.
/// - [UrutanLapangan.rating]: `ratingRata2` menurun. Lapangan yang belum
///   punya ulasan (`jumlahRating == 0`) SELALU di akhir — kalau tidak,
///   rating 0.0 mereka akan tampak sama buruknya dengan rating 1.
/// - [UrutanLapangan.populer]: `jumlahRating` menurun, lalu `ratingRata2`
///   menurun.
///
/// Pada kedua urutan di atas, hasil seri diurutkan menurut jarak menaik.
/// `jarakKm` bisa `null` (posisi belum diketahui) — dianggap paling jauh.
List<LapanganModel> urutkanLapangan(
  List<LapanganModel> daftar,
  UrutanLapangan urutan,
) {
  final hasil = List<LapanganModel>.of(daftar);
  if (urutan == UrutanLapangan.terdekat) return hasil;

  int bandingJarak(LapanganModel a, LapanganModel b) =>
      (a.jarakKm ?? double.infinity).compareTo(b.jarakKm ?? double.infinity);

  hasil.sort((a, b) {
    if (urutan == UrutanLapangan.rating) {
      final aAdaUlasan = a.jumlahRating > 0;
      final bAdaUlasan = b.jumlahRating > 0;
      // Yang tidak punya ulasan ke belakang.
      if (aAdaUlasan != bAdaUlasan) return aAdaUlasan ? -1 : 1;
      final byRating = b.ratingRata2.compareTo(a.ratingRata2);
      return byRating != 0 ? byRating : bandingJarak(a, b);
    }

    // populer
    final byJumlah = b.jumlahRating.compareTo(a.jumlahRating);
    if (byJumlah != 0) return byJumlah;
    final byRating = b.ratingRata2.compareTo(a.ratingRata2);
    return byRating != 0 ? byRating : bandingJarak(a, b);
  });

  return hasil;
}

/// Menyisakan lapangan yang punya SEMUA fasilitas di [dipilih] — PRD AB-16,
/// BB-65. [dipilih] kosong berarti tanpa penyaringan.
List<LapanganModel> saringFasilitas(
  List<LapanganModel> daftar,
  Set<String> dipilih,
) {
  if (dipilih.isEmpty) return daftar;
  return daftar
      .where((l) => dipilih.every((f) => l.fasilitas.contains(f)))
      .toList();
}
