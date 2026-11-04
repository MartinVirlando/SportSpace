import 'package:flutter/foundation.dart';

import '../../../models/forum_komentar_model.dart';
import '../../../repositories/forum_repository.dart';

/// ViewModel untuk layar Detail Post forum.
///
/// ATURAN LAPISAN (CLAUDE.md): TIDAK `import cloud_firestore`.
///
/// Dibuat lokal tiap kali layar detail dibuka (butuh `postId`), BUKAN
/// Provider global — sama seperti pola `ProfilViewModel` (dibuat per
/// instance lewat ChangeNotifierProvider di View-nya, bukan didaftarkan
/// sekali di main.dart).
class DetailPostViewModel extends ChangeNotifier {
  final ForumRepository _repository;
  final String postId;

  DetailPostViewModel({
    required ForumRepository repository,
    required this.postId,
  })  : _repository = repository,
        streamKomentar = repository.streamKomentar(postId);

  /// Stream komentar post ini, dibuat sekali di konstruktor (bukan
  /// getter) — pola sama seperti `streamRiwayatBooking` di
  /// `ProfilViewModel`, supaya tidak membuat listener Firestore baru
  /// setiap kali `streamKomentar` dibaca ulang oleh `StreamBuilder`.
  final Stream<List<ForumKomentarModel>> streamKomentar;

  // ---------- State kirim komentar ----------

  bool _sedangMengirim = false;
  bool get sedangMengirim => _sedangMengirim;

  /// Kirim komentar baru ke post ini. Mengembalikan `null` kalau
  /// berhasil, atau pesan kesalahan kalau gagal — pola sama seperti
  /// `BuatPostViewModel.kirimPost`.
  Future<String?> kirimKomentar({
    required String userId,
    required String namaUser,
    required String teks,
  }) async {
    _sedangMengirim = true;
    notifyListeners();

    try {
      await _repository.tambahKomentar(
        postId: postId,
        userId: userId,
        namaUser: namaUser,
        teks: teks,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _sedangMengirim = false;
      notifyListeners();
    }
  }

  // ---------- State hapus post ----------

  bool _sedangMenghapus = false;
  bool get sedangMenghapus => _sedangMenghapus;

  /// Hapus post ini beserta komentarnya. `null` = berhasil, selain itu
  /// pesan kesalahan.
  Future<String?> hapusPost() async {
    _sedangMenghapus = true;
    notifyListeners();

    try {
      await _repository.hapusPost(postId);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _sedangMenghapus = false;
      notifyListeners();
    }
  }
}