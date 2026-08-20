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

  /// ID aktivitas yang tombol "Gabung" kartunya sedang memproses —
  /// dipakai untuk menonaktifkan tombol itu saja, bukan seluruh layar,
  /// selagi menunggu Firestore.
  final Set<String> _sedangDiproses = {};
  bool sedangDiproses(String aktivitasId) =>
      _sedangDiproses.contains(aktivitasId);

  /// Kirim permintaan gabung langsung dari kartu (L-07) — PRD AB-06,
  /// BB-16. Mengembalikan `null` kalau berhasil, atau pesan kesalahan
  /// yang siap ditampilkan lewat `SnackBar` kalau gagal.
  ///
  /// Aturan tambahan AB-06 (pembuat tidak bisa gabung ke aktivitasnya
  /// sendiri, peserta tidak bisa kirim ulang) dicek di sini dari data
  /// [AktivitasBermainModel] yang sudah ada di kartu — tidak perlu baca
  /// subkoleksi `permintaan` sama sekali untuk dua aturan ini.
  Future<String?> kirimPermintaanGabung(
    AktivitasBermainModel aktivitas, {
    required String userId,
    required String namaUser,
  }) async {
    if (aktivitas.pembuatId == userId) {
      return 'Tidak bisa gabung ke aktivitas buatan sendiri.';
    }
    if (aktivitas.peserta.contains(userId)) {
      return 'Kamu sudah jadi peserta aktivitas ini.';
    }

    _sedangDiproses.add(aktivitas.aktivitasId);
    notifyListeners();

    try {
      await _repository.kirimPermintaanGabung(
        aktivitasId: aktivitas.aktivitasId,
        pembuatId: aktivitas.pembuatId,
        userId: userId,
        namaUser: namaUser,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _sedangDiproses.remove(aktivitas.aktivitasId);
      notifyListeners();
    }
  }
}
