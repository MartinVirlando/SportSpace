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
  /// Aturan tambahan AB-06 (pembuat tidak bisa gabung ke aktivitasnya
  /// sendiri, peserta tidak bisa kirim ulang) dicek ULANG di sini dari
  /// data [aktivitas] — sama seperti `AktivitasViewModel`, dan bukan
  /// cuma diandalkan dari View yang menyembunyikan tombol "Gabung".
  /// Sebelumnya cek ini tidak ada di sini sama sekali (hanya di
  /// AktivitasViewModel milik tab Teman), jadi entry point ini jadi celah
  /// kalau nanti ada cara lain memanggilnya di luar tombol yang sudah
  /// disembunyikan View saat ini.
  Future<bool> kirimPermintaanGabung(
    AktivitasBermainModel aktivitas, {
    required String userId,
    required String namaUser,
  }) async {
    if (aktivitas.pembuatId == userId) {
      _pesanError = 'Tidak bisa gabung ke aktivitas buatan sendiri.';
      notifyListeners();
      return false;
    }
    if (aktivitas.peserta.contains(userId)) {
      _pesanError = 'Kamu sudah jadi peserta aktivitas ini.';
      notifyListeners();
      return false;
    }

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

  /// Terima permintaan gabung dari daftar "Permintaan Masuk" — PRD AB-06,
  /// T-20, BB-17/BB-18. Mengembalikan `true` kalau berhasil.
  ///
  /// Tidak memakai [sedangProses]/[pesanError] bersama seperti
  /// [kirimPermintaanGabung]: baris permintaan bisa lebih dari satu, jadi
  /// status proses & error per-baris ditangani View lewat nilai balik dan
  /// parameter lokal, supaya menekan Terima di satu baris tidak mengunci
  /// tombol baris lain.
  Future<String?> terimaPermintaan({
    required String userId,
    required String namaUser,
  }) async {
    try {
      await _repository.terimaPermintaan(
        aktivitasId: aktivitasId,
        userId: userId,
        namaUser: namaUser,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Tolak permintaan gabung — PRD AB-06, T-20, BB-19. Mengembalikan
  /// `null` kalau berhasil, atau pesan kesalahan kalau gagal.
  Future<String?> tolakPermintaan({
    required String userId,
    required String namaUser,
    required String namaLapangan,
  }) async {
    try {
      await _repository.tolakPermintaan(
        aktivitasId: aktivitasId,
        userId: userId,
        namaUser: namaUser,
        namaLapangan: namaLapangan,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
