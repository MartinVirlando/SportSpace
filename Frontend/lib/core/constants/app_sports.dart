/// Empat cabang olahraga yang didukung — PRD Bagian 1.
/// Persis empat, tidak lebih. Jangan tambah tanpa merevisi PRD.
class AppSports {
  AppSports._();

  /// Nilai yang tersimpan di Firestore pada field `jenisOlahraga`.
  static const String futsal = 'futsal';
  static const String miniSoccer = 'mini_soccer';
  static const String badminton = 'badminton';
  static const String padel = 'padel';

  /// Nilai semu untuk chip "Semua" — TIDAK pernah disimpan ke Firestore.
  static const String semua = '__semua__';

  /// Urutan chip filter di Home (L-04) dan Cari Rekan (L-07).
  static const List<String> daftarFilter = [
    semua,
    futsal,
    miniSoccer,
    badminton,
    padel,
  ];

  /// Label yang dilihat pengguna. Semua teks antarmuka wajib bahasa
  /// Indonesia (PRD Bagian 2.3), jadi label tinggal ambil dari sini.
  static const Map<String, String> label = {
    semua: 'Semua',
    futsal: 'Futsal',
    miniSoccer: 'Mini Soccer',
    badminton: 'Badminton',
    padel: 'Padel',
  };

  /// Ikon emoji mengikuti prototipe Figma.
  static const Map<String, String> ikon = {
    semua: '🏟️',
    futsal: '⚽',
    miniSoccer: '⚽',
    badminton: '🏸',
    padel: '🎾',
  };

  static String labelDari(String kode) => label[kode] ?? kode;
  static String ikonDari(String kode) => ikon[kode] ?? '🏟️';
}
