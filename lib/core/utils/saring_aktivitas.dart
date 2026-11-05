import '../../models/aktivitas_bermain_model.dart';
import '../constants/app_aktivitas.dart';

/// Menyaring daftar aktivitas di sisi klien — PRD L-07, v1.4.
///
/// Filter jenis aktivitas (T-54) dan tingkat kemampuan (T-55) sengaja
/// dijalankan di sini, BUKAN di query Firestore: menaruhnya di query berarti
/// index baru untuk tiap kombinasi filter (lihat `FIRESTORE-INDEXES.md`).
/// Daftar aktivitas terbuka kecil, jadi menyaring di klien murah dan lebih
/// mudah dijelaskan.
///
/// Fungsi murni: tanpa Firestore, tanpa state, hanya masukan → keluaran,
/// sehingga bisa diuji otomatis (`test/saring_aktivitas_test.dart`).
///
/// [jenis] dan [tingkat] bernilai `semua` berarti tanpa penyaringan.
/// Aktivitas lama yang belum punya `tingkatKemampuan` (`null`) hanya lolos
/// kalau [tingkat] == [AppTingkat.semua].
List<AktivitasBermainModel> saringAktivitas(
  List<AktivitasBermainModel> daftar, {
  String jenis = AppJenisAktivitas.semua,
  String tingkat = AppTingkat.semua,
}) {
  return daftar.where((a) {
    final cocokJenis =
        jenis == AppJenisAktivitas.semua || a.jenisAktivitas == jenis;
    final cocokTingkat =
        tingkat == AppTingkat.semua || a.tingkatKemampuan == tingkat;
    return cocokJenis && cocokTingkat;
  }).toList();
}
