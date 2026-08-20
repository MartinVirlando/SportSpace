import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/lapangan_model.dart';
import '../models/rating_model.dart';

/// Satu-satunya lapisan yang boleh menyentuh Firestore untuk data rating.
///
/// ATURAN LAPISAN (CLAUDE.md): View dan ViewModel TIDAK BOLEH
/// `import cloud_firestore`. Semua akses data lewat kelas ini.
class RatingRepository {
  final FirebaseFirestore _db;

  RatingRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Beri atau perbarui rating — PRD AB-05, AB-09, T-21, BB-21/22/23.
  ///
  /// ID dokumen rating sengaja `{userId}_{lapanganId}` (lihat RatingModel)
  /// supaya satu pengguna hanya punya satu rating per lapangan, dan
  /// mengirim ulang berarti memperbarui, bukan menambah dokumen baru.
  ///
  /// Transaction hanya `get()` pada dua `DocumentReference`
  /// (`rating/{id}` dan `lapangan/{lapanganId}`) — TIDAK ada Query di
  /// dalamnya, sesuai jebakan Firestore Transaction di CLAUDE.md.
  /// `ratingTotal`/`jumlahRating` didenormalisasi di dokumen lapangan
  /// supaya `ratingRata2` tidak pernah dihitung dari seluruh koleksi.
  Future<void> beriRating({
    required String lapanganId,
    required String userId,
    required String namaUser,
    required int nilaiRating,
    String? ulasanTeks,
  }) async {
    final ratingRef = _db.collection('rating').doc('${userId}_$lapanganId');
    final lapanganRef = _db.collection('lapangan').doc(lapanganId);

    try {
      await _db.runTransaction((transaction) async {
        final ratingSnap = await transaction.get(ratingRef);
        final lapanganSnap = await transaction.get(lapanganRef);

        if (!lapanganSnap.exists) {
          throw Exception('Lapangan tidak ditemukan.');
        }
        final lapangan = LapanganModel.fromFirestore(lapanganSnap);

        var ratingTotal = lapangan.ratingTotal;
        var jumlahRating = lapangan.jumlahRating;

        if (ratingSnap.exists) {
          // Pengguna memperbarui rating lama — cuma selisihnya yang
          // ditambahkan, jumlahRating tidak berubah (BB-22).
          final ratingLama = RatingModel.fromFirestore(ratingSnap);
          ratingTotal += nilaiRating - ratingLama.nilaiRating;
        } else {
          ratingTotal += nilaiRating;
          jumlahRating += 1;
        }

        final ratingRata2 = ratingTotal / jumlahRating;

        transaction.set(
          ratingRef,
          RatingModel(
            ratingId: ratingRef.id,
            userId: userId,
            namaUser: namaUser,
            lapanganId: lapanganId,
            nilaiRating: nilaiRating,
            ulasanTeks: ulasanTeks,
            tanggal: DateTime.now(),
          ).toFirestore(),
        );
        transaction.update(lapanganRef, {
          'ratingTotal': ratingTotal,
          'jumlahRating': jumlahRating,
          'ratingRata2': ratingRata2,
        });
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin memberi rating.');
      }
      throw Exception('Gagal mengirim rating. Coba lagi.');
    }
  }
}
