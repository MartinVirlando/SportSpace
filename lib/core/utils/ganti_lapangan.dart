import '../../models/lapangan_model.dart';

/// Mengganti satu lapangan di [daftar] dengan versi terbarunya [baru] —
/// dipakai Home supaya kartu ikut berubah setelah pengguna memberi rating di
/// Detail Lapangan, tanpa memuat ulang seluruh daftar.
///
/// - Lapangan dicocokkan lewat `lapanganId`. Kalau tidak ada di [daftar]
///   (mis. daftar sedang dimuat ulang), hasilnya salinan [daftar] tanpa
///   perubahan.
/// - `jarakKm` DIPERTAHANKAN dari lapangan lama: dokumen baru dari Firestore
///   tidak membawa jarak (jarak dihitung di klien lewat Haversine, AB-02),
///   dan tanpa ini kartu kehilangan jaraknya serta urutan terdekat bergeser.
/// - Urutan elemen tidak berubah; hanya isi satu posisi yang diganti.
///
/// Mengembalikan daftar BARU; [daftar] asli tidak diubah.
List<LapanganModel> gantiLapanganDalamDaftar(
  List<LapanganModel> daftar,
  LapanganModel baru,
) {
  return [
    for (final lapangan in daftar)
      if (lapangan.lapanganId == baru.lapanganId)
        (lapangan.jarakKm == null
            ? baru
            : baru.salinDenganJarak(lapangan.jarakKm!))
      else
        lapangan,
  ];
}
