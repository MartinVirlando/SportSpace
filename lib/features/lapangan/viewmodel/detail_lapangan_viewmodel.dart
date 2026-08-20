import 'package:flutter/foundation.dart';

import '../../../models/lapangan_model.dart';
import '../../../models/rating_model.dart';
import '../../../repositories/lapangan_repository.dart';
import '../../../repositories/rating_repository.dart';

/// Kondisi layar Detail Lapangan. Sama seperti Home, tiga kondisi
/// ditangani eksplisit — tidak boleh ada layar putih polos (CLAUDE.md).
enum KondisiDetail { memuat, berhasil, gagal }

/// ViewModel untuk halaman Detail Lapangan (L-06).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data diambil lewat
/// [LapanganRepository.ambilSatuLapangan] dan [RatingRepository.streamUlasan].
///
/// Dibuat baru tiap kali layar dibuka (lewat ChangeNotifierProvider lokal
/// di `detail_lapangan_screen.dart`), bukan Provider global — beda dari
/// AuthViewModel yang memang perlu hidup sepanjang aplikasi.
///
/// [streamUlasan] dipaparkan sebagai `Stream` lewat method, dibaca View
/// lewat `StreamBuilder` (CLAUDE.md aturan 6, T-22) — daftar ulasan perlu
/// langsung hidup, ulasan baru harus muncul tanpa menyegarkan layar.
class DetailLapanganViewModel extends ChangeNotifier {
  final LapanganRepository _repository;
  final RatingRepository _ratingRepository;

  DetailLapanganViewModel({
    required LapanganRepository repository,
    required RatingRepository ratingRepository,
  })  : _repository = repository,
        _ratingRepository = ratingRepository;

  KondisiDetail _kondisi = KondisiDetail.memuat;
  KondisiDetail get kondisi => _kondisi;

  LapanganModel? _lapangan;
  LapanganModel? get lapangan => _lapangan;

  String? _pesanError;
  String? get pesanError => _pesanError;

  Future<void> muatDetail(String lapanganId) async {
    _kondisi = KondisiDetail.memuat;
    _pesanError = null;
    notifyListeners();

    try {
      _lapangan = await _repository.ambilSatuLapangan(lapanganId);
      _kondisi = KondisiDetail.berhasil;
    } catch (e) {
      _pesanError = e.toString().replaceFirst('Exception: ', '');
      _kondisi = KondisiDetail.gagal;
    }

    notifyListeners();
  }

  Stream<List<RatingModel>> streamUlasan(String lapanganId) =>
      _ratingRepository.streamUlasan(lapanganId);
}
