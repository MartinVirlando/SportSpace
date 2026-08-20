import 'package:flutter/foundation.dart';

import '../../../core/constants/app_sports.dart';
import '../../../models/aktivitas_bermain_model.dart';
import '../../../repositories/aktivitas_repository.dart';

/// ViewModel untuk tab Teman / Cari Rekan (L-07).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data lewat
/// [AktivitasRepository].
///
/// Beda dari HomeViewModel: kelas ini TIDAK menyimpan daftar aktivitas
/// sebagai state sendiri. Ia cuma menyediakan getter [streamAktivitas]
/// yang dibaca View lewat `StreamBuilder` (CLAUDE.md aturan 6) — daftar
/// ini perlu langsung hidup (aktivitas baru muncul, yang penuh hilang
/// sendiri, BB-20), beda dari Home yang sengaja sekali ambil.
class AktivitasViewModel extends ChangeNotifier {
  final AktivitasRepository _repository;

  AktivitasViewModel({required AktivitasRepository repository})
      : _repository = repository;

  String _filterOlahraga = AppSports.semua;
  String get filterOlahraga => _filterOlahraga;

  /// Getter baru dipanggil ulang tiap `build()` View — sengaja begitu,
  /// karena `StreamBuilder` akan berlangganan ulang otomatis setiap kali
  /// diberi objek Stream yang berbeda (terjadi saat filter berubah).
  Stream<List<AktivitasBermainModel>> get streamAktivitas =>
      _repository.streamAktivitasTerbuka(olahraga: _filterOlahraga);

  void ubahFilterOlahraga(String kode) {
    if (_filterOlahraga == kode) return;
    _filterOlahraga = kode;
    notifyListeners();
  }
}
