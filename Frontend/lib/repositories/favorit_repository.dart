import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/favorit_model.dart';

/// Satu-satunya lapisan yang boleh menyentuh Firestore untuk favorit
/// lapangan — PRD Bagian 6.9, AB-10 (v1.1).
///
/// ATURAN LAPISAN (CLAUDE.md): View dan ViewModel TIDAK BOLEH
/// `import cloud_firestore`. Semua akses data lewat kelas ini.
///
/// ID dokumen subkoleksi `users/{userId}/favorit/{lapanganId}` = `lapanganId`
/// (bukan auto-ID) — pola yang sama dengan `permintaan` (PRD 6.4). Itu
/// sebabnya toggle di sini TIDAK butuh Firestore Transaction: "sudah
/// difavoritkan atau belum" cukup dibaca dari satu dokumen, dan `set`/
/// `delete` biasa pada ID deterministik sudah atomik — tidak mungkin dobel.
class FavoritRepository {
  final FirebaseFirestore _db;

  FavoritRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _koleksiFavorit(String userId) =>
      _db.collection('users').doc(userId).collection('favorit');

  /// Stream ID seluruh lapangan yang difavoritkan pengguna — dipakai untuk
  /// menentukan ikon ♡/♥ di L-04 dan L-06 (AB-10). Diambil sebagai Set
  /// (bukan List<FavoritModel>) karena yang dibutuhkan View hanya
  /// keanggotaan (`contains`), bukan detail dokumennya.
  Stream<Set<String>> streamIdFavorit(String userId) {
    return _koleksiFavorit(userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
        )
        .handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca favorit.');
      }
      throw Exception('Gagal memuat favorit. Coba lagi.');
    });
  }

  /// Stream daftar favorit lengkap — dipakai L-13 Profil (AB-12 lanjutan).
  Stream<List<FavoritModel>> streamDaftarFavorit(String userId) {
    return _koleksiFavorit(userId)
        .orderBy('dibuatPada', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FavoritModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca favorit.');
      }
      throw Exception('Gagal memuat favorit. Coba lagi.');
    });
  }

  /// Hitung jumlah favorit — PRD L-13, T-38, AB-12.
  Future<int> hitungFavorit(String userId) async {
    try {
      final hasil = await _koleksiFavorit(userId).count().get();
      return hasil.count ?? 0;
    } on FirebaseException {
      throw Exception('Gagal menghitung favorit.');
    }
  }

  /// Menekan ikon ♡/♥ — PRD AB-10. Dokumen dihapus kalau sudah ada
  /// (batal favorit), dibuat kalau belum ada (favoritkan).
  Future<void> toggleFavorit({
    required String userId,
    required String lapanganId,
    required String namaLapangan,
  }) async {
    try {
      final ref = _koleksiFavorit(userId).doc(lapanganId);
      final snap = await ref.get();

      if (snap.exists) {
        await ref.delete();
      } else {
        await ref.set(
          FavoritModel(
            lapanganId: lapanganId,
            namaLapangan: namaLapangan,
            dibuatPada: DateTime.now(),
          ).toFirestore(),
        );
      }
    } on FirebaseException {
      throw Exception('Gagal menyimpan favorit. Coba lagi.');
    }
  }
}
