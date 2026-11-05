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
    // Pengaman berlapis (PRD AB-09) — sudah dicek di UI (`beri_rating_sheet.dart`),
    // tapi diulang di sini juga supaya pemanggil lain di masa depan tidak
    // bisa mencemari `ratingRata2` dengan nilai di luar 1-5 kalau lupa
    // memvalidasi di lapisan atas.
    if (nilaiRating < 1 || nilaiRating > 5) {
      throw Exception('Nilai rating harus 1-5.');
    }
    if (ulasanTeks != null && ulasanTeks.length > 500) {
      throw Exception('Ulasan maksimal 500 karakter.');
    }

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
        final sekarang = DateTime.now();

        if (ratingSnap.exists) {
          // PERBARUI, jangan `set` seluruh dokumen: `set` akan menghapus
          // `balasanMitra`/`balasanPada` yang mungkin sudah ditulis mitra
          // (v1.5, T-66), dan Security Rules melarang pengguna menyentuh
          // field balasan. Hanya empat field milik pengguna yang ditulis.
          transaction.update(ratingRef, {
            'namaUser': namaUser,
            'nilaiRating': nilaiRating,
            'ulasanTeks': ulasanTeks,
            'tanggal': Timestamp.fromDate(sekarang),
          });
        } else {
          transaction.set(
            ratingRef,
            RatingModel(
              ratingId: ratingRef.id,
              userId: userId,
              namaUser: namaUser,
              lapanganId: lapanganId,
              nilaiRating: nilaiRating,
              ulasanTeks: ulasanTeks,
              tanggal: sekarang,
            ).toFirestore(),
          );
        }
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

  /// Batas panjang balasan mitra. Angka yang sama diulang di
  /// `Validators.balasan` dan di Security Rules `rating` (PRD §9).
  static const batasPanjangBalasan = 500;

  /// Mitra pemilik lapangan membalas (atau mengganti balasan) satu ulasan —
  /// PRD AB-22, v1.5 (T-66), BB-86/88.
  ///
  /// Satu `update` pada dokumen `rating/{ratingId}` yang hanya menyentuh
  /// `balasanMitra` dan `balasanPada`. Siapa yang boleh dicek Security
  /// Rules (mitra pemilik lapangan itu), bukan di sini: tombolnya hanya
  /// digambar untuk pemilik, tapi rules tetap penjaga sebenarnya.
  ///
  /// Tidak menyentuh `ratingTotal`/`jumlahRating`/`ratingRata2` — balasan
  /// tidak memengaruhi angka rating, jadi tidak perlu transaction.
  Future<void> balasUlasan({
    required String ratingId,
    required String teks,
  }) async {
    final bersih = teks.trim();
    if (bersih.isEmpty) {
      throw Exception('Balasan wajib diisi.');
    }
    if (bersih.length > batasPanjangBalasan) {
      throw Exception('Balasan maksimal $batasPanjangBalasan karakter.');
    }

    try {
      await _db.collection('rating').doc(ratingId).update({
        'balasanMitra': bersih,
        'balasanPada': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Hanya pemilik lapangan yang bisa membalas ulasan.');
      }
      if (e.code == 'not-found') {
        throw Exception('Ulasan tidak ditemukan.');
      }
      throw Exception('Gagal mengirim balasan. Coba lagi.');
    }
  }

  /// Ambil rating milik [userId] untuk satu lapangan, atau `null` kalau
  /// belum pernah menilai — dipakai lembar Beri Rating (L-11) supaya
  /// pengguna yang sudah pernah menilai melihat nilai lamanya dan tahu bahwa
  /// mengirim ulang akan MENGGANTI, bukan menambah (PRD AB-05, AB-09).
  ///
  /// Hanya `get()` pada satu dokumen dengan ID deterministik
  /// `{userId}_{lapanganId}` — bukan query, jadi tidak butuh index baru.
  Future<RatingModel?> ambilRatingSaya({
    required String userId,
    required String lapanganId,
  }) async {
    try {
      final snap =
          await _db.collection('rating').doc('${userId}_$lapanganId').get();
      if (!snap.exists) return null;
      return RatingModel.fromFirestore(snap);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca ulasanmu.');
      }
      throw Exception('Gagal memuat ulasanmu sebelumnya. Coba lagi.');
    }
  }

  /// Stream daftar ulasan satu lapangan, terbaru dulu — PRD L-06, T-22.
  ///
  /// Index #6 — (lapanganId ASC, tanggal DESC). Batas 20 mengikuti
  /// `FIRESTORE-INDEXES.md`. Rata-rata rating TIDAK dihitung dari stream
  /// ini — itu tetap pakai `ratingTotal`/`jumlahRating` yang
  /// didenormalisasi di dokumen lapangan (AB-05).
  Stream<List<RatingModel>> streamUlasan(String lapanganId) {
    return _db
        .collection('rating')
        .where('lapanganId', isEqualTo: lapanganId)
        .orderBy('tanggal', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RatingModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca ulasan.');
      }
      throw Exception('Gagal memuat ulasan. Coba lagi.');
    });
  }
}
