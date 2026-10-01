import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/forum_post_model.dart';
import '../models/forum_komentar_model.dart';

class ForumRepository {
  final FirebaseFirestore _db;

  ForumRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Stream semua post forum, terbaru dulu.

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

  ///  post baru di forum.
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
