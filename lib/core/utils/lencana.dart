import '../constants/app_strings.dart';

/// Satu lencana pencapaian di Profil (L-13) — PRD AB-14, v1.4 (T-58).
///
/// Lencana TIDAK disimpan di Firestore: ia diturunkan di klien dari tiga
/// angka statistik AB-12 oleh [hitungLencana]. Kelas ini hanya pembawa data
/// untuk tampilan.
class LencanaProfil {
  /// Emoji, mengikuti gaya ikon olahraga di `AppSports`.
  final String ikon;
  final String nama;

  /// Kalimat syarat, ditampilkan agar pengguna tahu apa yang harus dilakukan
  /// (terutama untuk lencana yang belum diraih).
  final String syarat;
  final bool diraih;

  const LencanaProfil({
    required this.ikon,
    required this.nama,
    required this.syarat,
    required this.diraih,
  });
}

/// Aturan lima lencana — PRD AB-14.
///
/// Fungsi murni: hanya tiga angka masuk, daftar lencana keluar. Tanpa
/// Firestore dan tanpa state, sehingga bisa diuji otomatis
/// (`test/lencana_test.dart`, BB-56 dan BB-57).
///
/// Angka masuk: [jumlahBooking] sama persis dengan kotak statistik AB-12
/// (semua status), begitu pula aktivitas yang dibuat maupun diikuti dan
/// daftar favorit. [jumlahBookingTerkonfirmasi] hanya booking yang benar-benar
/// diterima mitra (`DIKONFIRMASI` atau `SELESAI`) — dipakai Langganan Lapangan
/// supaya lencana tidak bisa diraih dengan memesan lalu membatalkan.
List<LencanaProfil> hitungLencana({
  required int jumlahBooking,
  required int jumlahBookingTerkonfirmasi,
  required int jumlahAktivitas,
  required int jumlahFavorit,
}) {
  return [
    LencanaProfil(
      ikon: '🎟️',
      nama: AppStrings.lencanaPemesanPertama,
      syarat: AppStrings.syaratPemesanPertama,
      diraih: jumlahBooking >= 1,
    ),
    LencanaProfil(
      ikon: '🏆',
      nama: AppStrings.lencanaLangganan,
      syarat: AppStrings.syaratLangganan,
      diraih: jumlahBookingTerkonfirmasi >= 5,
    ),
    LencanaProfil(
      ikon: '🤝',
      nama: AppStrings.lencanaRekanBermain,
      syarat: AppStrings.syaratRekanBermain,
      diraih: jumlahAktivitas >= 1,
    ),
    LencanaProfil(
      ikon: '🔥',
      nama: AppStrings.lencanaPenggerak,
      syarat: AppStrings.syaratPenggerak,
      diraih: jumlahAktivitas >= 5,
    ),
    LencanaProfil(
      ikon: '⭐',
      nama: AppStrings.lencanaKolektorFavorit,
      syarat: AppStrings.syaratKolektorFavorit,
      diraih: jumlahFavorit >= 3,
    ),
  ];
}
