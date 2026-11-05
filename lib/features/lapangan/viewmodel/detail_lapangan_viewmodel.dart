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

  /// Dipanggil sekali setiap kali pengguna berhasil mengirim rating dari
  /// layar ini. Pembukanya (mis. Home) memakainya untuk ikut menyegarkan
  /// kartu lapangan yang sama; `null` untuk pembuka yang tidak perlu.
  final VoidCallback? _onRatingBerubah;

  DetailLapanganViewModel({
    required LapanganRepository repository,
    required RatingRepository ratingRepository,
    VoidCallback? onRatingBerubah,
  })  : _repository = repository,
        _ratingRepository = ratingRepository,
        _onRatingBerubah = onRatingBerubah;

  KondisiDetail _kondisi = KondisiDetail.memuat;
  KondisiDetail get kondisi => _kondisi;

  LapanganModel? _lapangan;
  LapanganModel? get lapangan => _lapangan;

  String? _pesanError;
  String? get pesanError => _pesanError;

  // Disimpan supaya tombol "Coba Lagi" (kondisi gagal) bisa memuat ulang
  // lapanganId yang benar — sebelumnya View mengandalkan `vm.lapangan?.id`,
  // yang masih null persis saat kondisi gagal terjadi di percobaan pertama.
  String? _lapanganIdTerakhir;

  Future<void> muatDetail(String lapanganId) async {
    _lapanganIdTerakhir = lapanganId;
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

  Future<void> muatUlang() async {
    if (_lapanganIdTerakhir != null) {
      await muatDetail(_lapanganIdTerakhir!);
    }
  }

  /// Dipanggil View setelah rating berhasil dikirim: memuat ulang detail ini
  /// (supaya `ratingRata2` baru tampil) dan memberi tahu pembuka layar.
  Future<void> catatRatingBerubah(String lapanganId) async {
    _onRatingBerubah?.call();
    await muatDetail(lapanganId);
  }

  Stream<List<RatingModel>> streamUlasan(String lapanganId) =>
      _ratingRepository.streamUlasan(lapanganId);
}
