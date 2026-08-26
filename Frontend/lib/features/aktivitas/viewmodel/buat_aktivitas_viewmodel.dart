import 'package:flutter/foundation.dart';

import '../../../models/lapangan_model.dart';
import '../../../repositories/aktivitas_repository.dart';
import '../../../repositories/lapangan_repository.dart';

/// Kondisi daftar lapangan untuk dropdown "Pilih Lapangan" — bukan
/// kondisi keseluruhan layar, karena form tetap bisa dilihat (cuma
/// dropdown-nya yang menunggu/gagal) sementara field lain sudah bisa diisi.
enum KondisiDaftarLapangan { memuat, berhasil, gagal }

/// ViewModel untuk form Buat Aktivitas (L-08).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Dua repository
/// dipakai: [LapanganRepository] untuk isi dropdown "Pilih Lapangan",
/// [AktivitasRepository] untuk menyimpan aktivitas baru.
///
/// Dibuat lokal tiap kali layar ini dibuka (lewat ChangeNotifierProvider
/// di `buat_aktivitas_screen.dart`) — BUKAN Provider global, dan BUKAN
/// pakai AktivitasViewModel milik tab Teman, karena layar ini dibuka
/// lewat `Navigator.push` yang tidak mewarisi Provider yang disuntik
/// lokal di dalam `IndexedStack` milik ShellNavigasi (lihat catatan
/// yang sama di DetailLapanganViewModel).
class BuatAktivitasViewModel extends ChangeNotifier {
  final AktivitasRepository _aktivitasRepository;
  final LapanganRepository _lapanganRepository;

  BuatAktivitasViewModel({
    required AktivitasRepository aktivitasRepository,
    required LapanganRepository lapanganRepository,
  })  : _aktivitasRepository = aktivitasRepository,
        _lapanganRepository = lapanganRepository;

  KondisiDaftarLapangan _kondisiLapangan = KondisiDaftarLapangan.memuat;
  KondisiDaftarLapangan get kondisiLapangan => _kondisiLapangan;

  List<LapanganModel> _daftarLapangan = [];
  List<LapanganModel> get daftarLapangan => _daftarLapangan;

  bool _sedangProses = false;
  bool get sedangProses => _sedangProses;

  String? _pesanError;
  String? get pesanError => _pesanError;

  Future<void> muatDaftarLapangan() async {
    _kondisiLapangan = KondisiDaftarLapangan.memuat;
    notifyListeners();

    try {
      _daftarLapangan = await _lapanganRepository.ambilSemuaLapangan();
      _kondisiLapangan = KondisiDaftarLapangan.berhasil;
    } catch (_) {
      _kondisiLapangan = KondisiDaftarLapangan.gagal;
    }

    notifyListeners();
  }

  /// Mengembalikan `true` kalau berhasil. Kalau `false`, baca
  /// [pesanError] untuk pesan yang siap ditampilkan.
  Future<bool> buatAktivitas({
    required String jenisOlahraga,
    required int jumlahPemainDibutuhkan,
    required DateTime waktu,
    required String lapanganId,
    required String namaLapangan,
    required String pembuatId,
    required String namaPembuat,
    String? catatan,
  }) async {
    _sedangProses = true;
    _pesanError = null;
    notifyListeners();

    try {
      await _aktivitasRepository.buatAktivitas(
        jenisOlahraga: jenisOlahraga,
        jumlahPemainDibutuhkan: jumlahPemainDibutuhkan,
        waktu: waktu,
        lapanganId: lapanganId,
        namaLapangan: namaLapangan,
        pembuatId: pembuatId,
        namaPembuat: namaPembuat,
        catatan: catatan,
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
