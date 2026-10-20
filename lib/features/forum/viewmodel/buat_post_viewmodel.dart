import 'package:flutter/foundation.dart';

import '../../../repositories/forum_repository.dart';


/// ATURAN LAPISAN (CLAUDE.md): TIDAK `import cloud_firestore`, dan juga
/// TIDAK `import image_picker` — sama seperti `ubah_profil_sheet.dart`,
/// urusan pilih galeri & konversi Base64 ada di View (butuh `BuildContext`
/// untuk SnackBar). ViewModel ini hanya terima Base64 yang sudah jadi.
class BuatPostViewModel extends ChangeNotifier {
  final ForumRepository _repository;

  BuatPostViewModel({required ForumRepository repository})
      : _repository = repository;

  // ---------- State ----------

  bool _sedangMengirim = false;
  bool get sedangMengirim => _sedangMengirim;

  // ---------- Aksi ----------

  /// Kirim post baru. Mengembalikan `null` kalau berhasil, atau pesan
  /// kesalahan (siap tampil, tanpa awalan "Exception:") kalau gagal —
  Future<String?> kirimPost({
    required String userId,
    required String namaUser,
    required String teks,
    String? gambarBase64,
  }) async {
    _sedangMengirim = true;
    notifyListeners();

    try {
      await _repository.buatPost(
        userId: userId,
        namaUser: namaUser,
        teks: teks,
        gambarBase64: gambarBase64,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _sedangMengirim = false;
      notifyListeners();
    }
  }

  /// Simpan perubahan pada post yang sudah ada. Pola return sama dengan
  /// [kirimPost]: `null` = berhasil, selain itu pesan kesalahan.
  Future<String?> simpanEdit({
    required String postId,
    required String teks,
    String? gambarBase64,
  }) async {
    _sedangMengirim = true;
    notifyListeners();

    try {
      await _repository.editPost(
        postId: postId,
        teks: teks,
        gambarBase64: gambarBase64,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _sedangMengirim = false;
      notifyListeners();
    }
  }
}