import 'package:flutter/foundation.dart';

import '../../../models/lapangan_model.dart';
import '../../../repositories/lapangan_repository.dart';

/// Kondisi layar Detail Lapangan. Sama seperti Home, tiga kondisi
/// ditangani eksplisit — tidak boleh ada layar putih polos (CLAUDE.md).
enum KondisiDetail { memuat, berhasil, gagal }

/// ViewModel untuk halaman Detail Lapangan (L-06).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data diambil lewat
/// [LapanganRepository.ambilSatuLapangan].
///
/// Dibuat baru tiap kali layar dibuka (lewat ChangeNotifierProvider lokal
/// di `detail_lapangan_screen.dart`), bukan Provider global — beda dari
/// AuthViewModel yang memang perlu hidup sepanjang aplikasi.
class DetailLapanganViewModel extends ChangeNotifier {
  final LapanganRepository _repository;

  DetailLapanganViewModel({required LapanganRepository repository})
      : _repository = repository;

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
}
