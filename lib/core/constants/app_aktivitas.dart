/// Jenis aktivitas bermain — PRD 6.3 (`jenisAktivitas`), v1.4 (T-54).
///
/// Dua nilai saja:
/// - `main_bareng` — main santai bersama, tujuannya mencari rekan.
/// - `sparring`    — mencari lawan tanding.
///
/// Polanya sama dengan [AppSports]: nilai yang tersimpan di Firestore ada
/// di sini, begitu juga label bahasa Indonesia untuk tampilan.
class AppJenisAktivitas {
  AppJenisAktivitas._();

  /// Nilai yang tersimpan di Firestore pada field `jenisAktivitas`.
  static const String mainBareng = 'main_bareng';
  static const String sparring = 'sparring';

  /// Nilai semu untuk chip "Semua" — TIDAK pernah disimpan ke Firestore.
  static const String semua = '__semua__';

  /// Pilihan di form Buat Aktivitas (L-08) — tanpa "Semua".
  static const List<String> daftarPilihan = [mainBareng, sparring];

  /// Urutan chip filter di Cari Rekan (L-07).
  static const List<String> daftarFilter = [semua, mainBareng, sparring];

  static const Map<String, String> label = {
    semua: 'Semua',
    mainBareng: 'Main Bareng',
    sparring: 'Sparring',
  };

  static String labelDari(String kode) => label[kode] ?? kode;

  /// Nilai di Firestore harus salah satu dari [daftarPilihan].
  static bool valid(String kode) => daftarPilihan.contains(kode);
}
