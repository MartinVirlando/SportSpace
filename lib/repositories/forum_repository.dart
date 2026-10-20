import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/forum_post_model.dart';
import '../models/forum_komentar_model.dart';

/// Satu-satunya lapisan yang boleh menyentuh Firestore untuk data forum.
///
/// ATURAN LAPISAN (CLAUDE.md): View dan ViewModel TIDAK BOLEH
/// `import cloud_firestore`. Semua akses data lewat kelas ini.
class ForumRepository {
  final FirebaseFirestore _db;

  ForumRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Stream semua post forum, terbaru dulu.
  ///
  /// Limit 20 mengikuti pola di `RatingRepository.streamUlasan`
  /// (hindari menarik seluruh koleksi sekaligus).
  Stream<List<ForumPostModel>> streamPosts() {
    return _db
        .collection('forum_posts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ForumPostModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca forum.');
      }
      throw Exception('Gagal memuat forum. Coba lagi.');
    });
  }

  /// Buat post baru di forum.
  Future<void> buatPost({
    required String userId,
    required String namaUser,
    required String teks,
    String? gambarBase64,
  }) async {
    if (teks.trim().isEmpty && gambarBase64 == null) {
      throw Exception('Post tidak boleh kosong.');
    }

    try {
      await _db.collection('forum_posts').add({
        'userId': userId,
        'namaUser': namaUser,
        'teks': teks,
        'gambarBase64': gambarBase64,
        'jumlahKomentar': 0,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin membuat post.');
      }
      throw Exception('Gagal membuat post. Coba lagi.');
    }
  }

  /// Edit teks dan gambar sebuah post, lalu catat waktu editnya.
  ///
  /// Hanya tiga field yang disentuh: `teks`, `gambarBase64`, `dieditPada`.
  /// `userId`, `createdAt`, dan `jumlahKomentar` sengaja tidak diubah.
  /// Menghapus gambar = kirim `gambarBase64: null`.
  Future<void> editPost({
    required String postId,
    required String teks,
    String? gambarBase64,
  }) async {
    if (teks.trim().isEmpty && gambarBase64 == null) {
      throw Exception('Post tidak boleh kosong.');
    }

    try {
      await _db.collection('forum_posts').doc(postId).update({
        'teks': teks,
        'gambarBase64': gambarBase64,
        'dieditPada': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin mengedit post ini.');
      }
      if (e.code == 'not-found') {
        throw Exception('Post sudah tidak ada.');
      }
      throw Exception('Gagal menyimpan perubahan. Coba lagi.');
    }
  }

  /// Hapus sebuah post BESERTA semua komentarnya.
  ///
  /// Firestore tidak menghapus subkoleksi otomatis saat dokumen induk
  /// dihapus, jadi komentar dihapus dulu, baru postnya. Urutan ini
  /// penting: post dihapus TERAKHIR supaya aturan keamanan masih bisa
  /// memeriksa siapa pemilik post saat komentar dihapus.
  Future<void> hapusPost(String postId) async {
    final postRef = _db.collection('forum_posts').doc(postId);

    try {
      final komentarSnap = await postRef.collection('komentar').get();
      final daftarDoc = komentarSnap.docs;

      // WriteBatch maksimal 500 operasi, jadi dipecah per 400.
      const batasBatch = 400;
      for (var i = 0; i < daftarDoc.length; i += batasBatch) {
        final batch = _db.batch();
        for (final doc in daftarDoc.skip(i).take(batasBatch)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      await postRef.delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin menghapus post ini.');
      }
      throw Exception('Gagal menghapus post. Coba lagi.');
    }
  }

  /// Stream semua komentar dari satu post, terlama dulu (urutan chat).
  Stream<List<ForumKomentarModel>> streamKomentar(String postId) {
    return _db
        .collection('forum_posts')
        .doc(postId)
        .collection('komentar')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ForumKomentarModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca komentar.');
      }
      throw Exception('Gagal memuat komentar. Coba lagi.');
    });
  }

  /// Tambah komentar ke satu post, dan naikkan `jumlahKomentar` di post
  /// itu bersamaan lewat WriteBatch (dua tulisan, satu kali kirim,
  /// supaya jumlahnya tidak pernah tertinggal di belakang).
  Future<void> tambahKomentar({
    required String postId,
    required String userId,
    required String namaUser,
    required String teks,
  }) async {
    if (teks.trim().isEmpty) {
      throw Exception('Komentar tidak boleh kosong.');
    }

    final postRef = _db.collection('forum_posts').doc(postId);
    final komentarRef = postRef.collection('komentar').doc();

    try {
      final batch = _db.batch();
      batch.set(komentarRef, {
        'userId': userId,
        'namaUser': namaUser,
        'teks': teks,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      batch.update(postRef, {
        'jumlahKomentar': FieldValue.increment(1),
      });
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin mengirim komentar.');
      }
      throw Exception('Gagal mengirim komentar. Coba lagi.');
    }
  }
}
