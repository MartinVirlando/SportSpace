import 'package:flutter/foundation.dart';

import '../../../models/aktivitas_bermain_model.dart';
import '../../../models/permintaan_gabung_model.dart';
import '../../../repositories/aktivitas_repository.dart';

/// ViewModel untuk halaman Detail Aktivitas (L-09).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data lewat
/// [AktivitasRepository].
///
/// Dibuat lokal tiap kali layar ini dibuka (lewat ChangeNotifierProvider
/// di `detail_aktivitas_screen.dart`), BUKAN memakai AktivitasViewModel
/// milik tab Teman — alasan yang sama seperti BuatAktivitasViewModel:
/// `Navigator.push` tidak mewarisi Provider yang disuntik lokal di dalam
/// `IndexedStack` milik ShellNavigasi.
///
/// Dua daftar (detail aktivitas, daftar permintaan) dipaparkan sebagai
/// `Stream` lewat getter, dibaca View lewat `StreamBuilder` (CLAUDE.md
/// aturan 6) — keduanya perlu langsung hidup: `jumlahPemainSaatIni`
/// berubah begitu permintaan diterima (T-20), dan daftar permintaan baru
/// harus muncul tanpa pengguna menarik untuk menyegarkan.
class DetailAktivitasViewModel extends ChangeNotifier {
  final AktivitasRepository _repository;
  final String aktivitasId;

  DetailAktivitasViewModel({
    required AktivitasRepository repository,
    required this.aktivitasId,
  }) : _repository = repository;

  Stream<AktivitasBermainModel> get streamAktivitas =>
      _repository.streamDetailAktivitas(aktivitasId);

  Stream<List<PermintaanGabungModel>> get streamPermintaan =>
      _repository.streamPermintaan(aktivitasId);

  bool _sedangProses = false;
  bool get sedangProses => _sedangProses;

  String? _pesanError;
  String? get pesanError => _pesanError;

  /// Kirim permintaan gabung dari tombol "Gabung" di L-09 — PRD AB-06,
  /// BB-16. Mengembalikan `true` kalau berhasil.
  ///
  /// Pengecekan aturan tambahan (bukan pembuat, belum jadi peserta)
  /// dilakukan di View lewat data [aktivitas] yang sedang ditonton lewat
  /// [streamAktivitas] — sama seperti AktivitasViewModel, cukup dari data
  /// yang sudah ada tanpa baca subkoleksi.
  Future<bool> kirimPermintaanGabung(
    AktivitasBermainModel aktivitas, {
    required String userId,
    required String namaUser,
  }) async {
    _sedangProses = true;
    _pesanError = null;
    notifyListeners();

    try {
      await _repository.kirimPermintaanGabung(
        aktivitasId: aktivitas.aktivitasId,
        pembuatId: aktivitas.pembuatId,
        userId: userId,
        namaUser: namaUser,
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
