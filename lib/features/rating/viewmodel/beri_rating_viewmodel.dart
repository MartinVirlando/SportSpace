import 'package:flutter/foundation.dart';

import '../../../repositories/rating_repository.dart';

/// ViewModel untuk form/modal Beri Rating (L-11).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data ditulis lewat
/// [RatingRepository.beriRating] (AB-05).
///
/// Dibuat lokal tiap kali modal ini dibuka (lewat ChangeNotifierProvider
/// di `beri_rating_sheet.dart`) — sama seperti BuatAktivitasViewModel,
/// bukan Provider global.
class BeriRatingViewModel extends ChangeNotifier {
  final RatingRepository _repository;

  BeriRatingViewModel({required RatingRepository repository})
      : _repository = repository;

  bool _sedangProses = false;
  bool get sedangProses => _sedangProses;

  String? _pesanError;
  String? get pesanError => _pesanError;

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
