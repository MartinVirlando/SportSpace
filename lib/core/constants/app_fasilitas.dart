/// Fasilitas lapangan yang bisa dipilih — PRD 6.2 (`fasilitas`), v1.5.
///
/// Satu sumber untuk dua pemakai: form mitra (L-15, mengisi `fasilitas`)
/// dan filter Home (L-04, T-57, menyaring berdasarkan `fasilitas`). Kosakata
/// yang sama dipakai `SEED-DATA.md`/`seed_lapangan.dart`, bukan daftar baku
/// dari PRD. Disimpan huruf kecil persis seperti di Firestore.
class AppFasilitas {
  AppFasilitas._();

  static const List<String> daftar = [
    'parkir',
    'toilet',
    'kantin',
    'ruang ganti',
    'mushola',
    'shower',
  ];
}
