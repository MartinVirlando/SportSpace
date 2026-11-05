/// Pilihan mode tampilan pengguna — PRD AB-24, v1.5.
///
/// Sengaja enum buatan sendiri, bukan `ThemeMode` milik Flutter: ViewModel
/// dan Repository tidak perlu mengimpor library Material, dan nilai yang
/// disimpan ke HP ([kode]) tetap stabil walau nama enum Flutter berubah.
/// Perubahan ke `ThemeMode` dilakukan di satu tempat saja (`app_theme.dart`).
enum ModeTema {
  /// Selalu terang. BAWAAN: tampilan yang sama dengan Figma dan tangkapan
  /// layar di skripsi.
  terang('terang'),

  /// Selalu gelap.
  gelap('gelap'),

  /// Mengikuti pengaturan tema HP.
  sistem('sistem');

  /// Teks yang disimpan di `shared_preferences`.
  final String kode;

  const ModeTema(this.kode);

  /// Membaca kembali dari teks yang disimpan. Nilai kosong atau tidak
  /// dikenal (data rusak, atau berasal dari versi aplikasi lain) jatuh ke
  /// bawaan [terang], bukan galat.
  static ModeTema dariKode(String? kode) {
    for (final mode in values) {
      if (mode.kode == kode) return mode;
    }
    return terang;
  }
}
