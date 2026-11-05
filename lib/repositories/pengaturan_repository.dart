import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/mode_tema.dart';

/// Pengaturan aplikasi yang disimpan DI HP (bukan di Firestore) — v1.5.
///
/// Dipakai untuk pilihan yang memang milik perangkat: pengingat jadwal
/// (T-67) dan mode tampilan terang/gelap (AB-24). Disimpan lewat `shared_preferences`
/// (berkas kecil kunci-nilai milik aplikasi), jadi tetap ada setelah
/// aplikasi ditutup dan tidak butuh jaringan. Seperti Repository lain,
/// ViewModel tidak menyentuh penyimpanan secara langsung.
class PengaturanRepository {
  static const _kunciPengingat = 'pengingat_jadwal_aktif';
  static const _kunciModeTema = 'mode_tema';

  final SharedPreferences _prefs;

  PengaturanRepository(this._prefs);

  /// Membuka penyimpanan. Dipanggil sekali di `main()`.
  static Future<PengaturanRepository> buka() async =>
      PengaturanRepository(await SharedPreferences.getInstance());

  /// Pengingat jadwal (T-67). BAWAAN menyala: fitur ini hanya berguna kalau
  /// aktif, dan pengguna bisa mematikannya di Profil.
  bool get pengingatAktif => _prefs.getBool(_kunciPengingat) ?? true;

  Future<void> simpanPengingatAktif(bool nilai) =>
      _prefs.setBool(_kunciPengingat, nilai);

  /// Mode tampilan (terang / gelap / ikuti HP) — PRD AB-24. BAWAAN terang:
  /// tampilan yang sama dengan Figma dan tangkapan layar di skripsi. Nilai
  /// yang tidak dikenal dibaca sebagai bawaan (lihat [ModeTema.dariKode]).
  ModeTema get modeTema => ModeTema.dariKode(_prefs.getString(_kunciModeTema));

  Future<void> simpanModeTema(ModeTema mode) =>
      _prefs.setString(_kunciModeTema, mode.kode);
}
