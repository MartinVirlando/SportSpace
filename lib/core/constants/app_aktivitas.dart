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

/// Tingkat kemampuan yang dicari — PRD 6.3 (`tingkatKemampuan`), v1.4
/// (T-55). Dipilih manual oleh pembuat aktivitas; tidak ada penilaian
/// otomatis. Aktivitas lama (sebelum v1.4) tidak punya tingkat (`null`).
class AppTingkat {
  AppTingkat._();

  /// Nilai yang tersimpan di Firestore pada field `tingkatKemampuan`.
  static const String pemula = 'pemula';
  static const String menengah = 'menengah';
  static const String mahir = 'mahir';

  /// Nilai semu untuk chip "Semua tingkat" — TIDAK pernah disimpan.
  static const String semua = '__semua__';

  /// Pilihan di form Buat Aktivitas (L-08) — tanpa "Semua".
  static const List<String> daftarPilihan = [pemula, menengah, mahir];

  /// Urutan chip filter di Cari Rekan (L-07).
  static const List<String> daftarFilter = [semua, pemula, menengah, mahir];

  static const Map<String, String> label = {
    semua: 'Semua tingkat',
    pemula: 'Pemula',
    menengah: 'Menengah',
    mahir: 'Mahir',
  };

  static String labelDari(String kode) => label[kode] ?? kode;

  /// Nilai di Firestore harus salah satu dari [daftarPilihan].
  static bool valid(String kode) => daftarPilihan.contains(kode);
}

/// Batas biaya per orang — PRD 6.3 (`biayaPerOrang`), v1.4 (T-56).
///
/// Biaya hanyalah INFORMASI (dibayar di lokasi), bukan pembayaran lewat
/// aplikasi — payment gateway dilarang (PRD §2.1). Dicek di View (validator),
/// dan diulang di `AktivitasRepository` sebagai pengaman kedua.
class AppBiaya {
  AppBiaya._();

  /// 0 berarti gratis.
  static const int minimal = 0;
  static const int maksimal = 1000000;

  static bool valid(int nilai) => nilai >= minimal && nilai <= maksimal;
}

/// Visibilitas aktivitas — PRD 6.3 (`visibilitas`), v1.5 (T-64), AB-21.
///
/// - `publik` — tampil di daftar Cari Rekan (bawaan, dan nilai untuk dokumen
///   lama yang belum punya field ini).
/// - `privat` — TIDAK tampil di daftar; hanya bisa dibuka lewat `kodeAkses`.
///
/// Privat hanya MENYEMBUNYIKAN dari daftar, bukan dilindungi Security Rules
/// (rules `aktivitasBermain` mengizinkan `read` untuk semua pengguna login).
/// Keterbatasan ini dicatat di PRD AB-21 dan Bab 5.
class AppVisibilitas {
  AppVisibilitas._();

  static const String publik = 'publik';
  static const String privat = 'privat';

  /// Pilihan di form Buat Aktivitas (L-08).
  static const List<String> daftarPilihan = [publik, privat];

  static const Map<String, String> label = {
    publik: 'Publik',
    privat: 'Privat',
  };

  static String labelDari(String kode) => label[kode] ?? kode;

  static bool valid(String kode) => daftarPilihan.contains(kode);
}
