import 'package:flutter/foundation.dart';

import '../../../repositories/rating_repository.dart';

/// ViewModel untuk bottom sheet Balas Ulasan (mitra, AB-22, v1.5 T-66).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data ditulis lewat
/// [RatingRepository.balasUlasan].
///
/// Dibuat lokal tiap kali sheet dibuka (lewat ChangeNotifierProvider di
/// `balas_ulasan_sheet.dart`), sama seperti [BeriRatingViewModel] — bukan
/// Provider global.
class BalasUlasanViewModel extends ChangeNotifier {
  final RatingRepository _repository;

  BalasUlasanViewModel({required RatingRepository repository})
      : _repository = repository;

  bool _sedangProses = false;
  bool get sedangProses => _sedangProses;

  String? _pesanError;
  String? get pesanError => _pesanError;

  /// Mengembalikan `true` kalau berhasil. Kalau `false`, baca [pesanError]
  /// untuk pesan berbahasa Indonesia yang siap ditampilkan.
  Future<bool> kirim({required String ratingId, required String teks}) async {
    _sedangProses = true;
    _pesanError = null;
    notifyListeners();

    try {
      await _repository.balasUlasan(ratingId: ratingId, teks: teks);
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
