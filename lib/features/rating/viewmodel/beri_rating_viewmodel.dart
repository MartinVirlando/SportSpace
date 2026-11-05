import 'package:flutter/foundation.dart';

import '../../../models/rating_model.dart';
import '../../../repositories/rating_repository.dart';

/// Kondisi pemuatan ulasan lama pengguna di lembar Beri Rating. Tiga kondisi
/// ditangani eksplisit — tidak boleh ada lembar kosong tanpa penjelasan
/// (CLAUDE.md).
enum KondisiRatingLama { memuat, siap, gagal }

/// ViewModel untuk form/modal Beri Rating (L-11).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data ditulis lewat
/// [RatingRepository.beriRating] (AB-05) dan dibaca lewat
/// [RatingRepository.ambilRatingSaya].
///
/// Dibuat lokal tiap kali modal ini dibuka (lewat ChangeNotifierProvider
/// di `beri_rating_sheet.dart`) — sama seperti BuatAktivitasViewModel,
/// bukan Provider global.
///
/// Rating itu SATU per pengguna per lapangan dan boleh diperbarui (PRD
/// AB-05, AB-09). Karena mengirim ulang berarti MENGGANTI nilai lama, lembar
/// ini lebih dulu memuat rating lama lewat [muatRatingLama]: View mengisi
/// bintang dan teksnya dengan nilai itu dan memberi tahu pengguna bahwa
/// ulasannya akan diganti — supaya tidak menimpa tanpa sadar.
class BeriRatingViewModel extends ChangeNotifier {
  final RatingRepository _repository;

  BeriRatingViewModel({required RatingRepository repository})
      : _repository = repository;

  bool _sedangProses = false;
  bool get sedangProses => _sedangProses;

  String? _pesanError;
  String? get pesanError => _pesanError;

  KondisiRatingLama _kondisiRatingLama = KondisiRatingLama.memuat;
  KondisiRatingLama get kondisiRatingLama => _kondisiRatingLama;

  /// Rating lama pengguna untuk lapangan ini. `null` berarti BELUM pernah
  /// menilai (atau belum selesai dimuat — periksa [kondisiRatingLama]).
  RatingModel? _ratingLama;
  RatingModel? get ratingLama => _ratingLama;

  /// Memuat rating lama pengguna. Aman dipanggil lagi untuk "Coba Lagi".
  /// Kalau gagal, kondisi menjadi [KondisiRatingLama.gagal] dan pesannya
  /// ada di [pesanError] — form TIDAK dibuka dalam keadaan kosong, karena
  /// itulah yang membuat pengguna menimpa ulasan lamanya tanpa tahu.
  Future<void> muatRatingLama({
    required String userId,
    required String lapanganId,
  }) async {
    _kondisiRatingLama = KondisiRatingLama.memuat;
    _pesanError = null;
    notifyListeners();

    try {
      _ratingLama = await _repository.ambilRatingSaya(
        userId: userId,
        lapanganId: lapanganId,
      );
      _kondisiRatingLama = KondisiRatingLama.siap;
    } catch (e) {
      _pesanError = e.toString().replaceFirst('Exception: ', '');
      _kondisiRatingLama = KondisiRatingLama.gagal;
    }

    notifyListeners();
  }

  /// Mengembalikan `true` kalau berhasil. Kalau `false`, baca
  /// [pesanError] untuk pesan yang siap ditampilkan.
  Future<bool> kirim({
    required String lapanganId,
    required String userId,
    required String namaUser,
    required int nilaiRating,
    String? ulasanTeks,
  }) async {
    _sedangProses = true;
    _pesanError = null;
    notifyListeners();

    try {
      await _repository.beriRating(
        lapanganId: lapanganId,
        userId: userId,
        namaUser: namaUser,
        nilaiRating: nilaiRating,
        ulasanTeks: ulasanTeks,
      );
      _sedangProses = false;
      notifyListeners();
      return true;
    } catch (e) {
      _pesanError = e.toString().replaceFirst('Exception: ', '');
      _sedangProses = false;
      notifyListeners();
      return false;
    }
  }
}
