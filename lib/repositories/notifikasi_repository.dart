import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notifikasi_model.dart';

/// Satu-satunya lapisan yang boleh menyentuh Firestore untuk data
/// notifikasi in-app — pengganti Firebase Cloud Messaging yang dilarang
/// (PRD Bagian 2.1). Notifikasi dibuat langsung oleh repository lain
/// (mis. `AktivitasRepository.kirimPermintaanGabung`) saat menulis
/// dokumen pemicunya; kelas ini hanya untuk MEMBACA dan menandai dibaca.
///
/// ATURAN LAPISAN (CLAUDE.md): View dan ViewModel TIDAK BOLEH
/// `import cloud_firestore`. Semua akses data lewat kelas ini.
class NotifikasiRepository {
  final FirebaseFirestore _db;

  NotifikasiRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Stream notifikasi milik satu pengguna, terbaru dulu — PRD L-12.
  ///
  /// Index #11 — (untukUserId ASC, dibuatPada DESC). Batas 50 mengikuti
  /// `FIRESTORE-INDEXES.md`. Badge jumlah belum dibaca SENGAJA tidak
  /// dihitung lewat query kedua di sini — dihitung di View dari daftar
  /// yang sama (lihat catatan "Yang TIDAK butuh index" di dokumen itu).
  Stream<List<NotifikasiModel>> streamNotifikasi(String userId) {
    return _db
        .collection('notifikasi')
        .where('untukUserId', isEqualTo: userId)
        .orderBy('dibuatPada', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotifikasiModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca notifikasi.');
      }
      throw Exception('Gagal memuat notifikasi. Coba lagi.');
    });
  }

  /// Menandai satu notifikasi sudah dibaca — dipanggil saat item ditekan
  /// (PRD L-12).
  Future<void> tandaiSudahDibaca(String notifikasiId) async {
    try {
      await _db.collection('notifikasi').doc(notifikasiId).update({
        'sudahDibaca': true,
      });
    } on FirebaseException {
      throw Exception('Gagal menandai notifikasi. Coba lagi.');
    }
  }
}
