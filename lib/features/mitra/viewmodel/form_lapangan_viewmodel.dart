import 'package:flutter/foundation.dart';

import '../../../models/lapangan_model.dart';
import '../../../repositories/lapangan_repository.dart';

/// ViewModel untuk form Tambah/Edit Lapangan (L-15).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data ditulis lewat
/// [LapanganRepository.tambahLapangan] / [LapanganRepository.perbaruiLapangan].
///
/// Dibuat lokal tiap kali layar ini dibuka (lewat ChangeNotifierProvider
/// di `form_lapangan_screen.dart`) — bukan Provider global, sama seperti
/// BuatAktivitasViewModel.
class FormLapanganViewModel extends ChangeNotifier {
  final LapanganRepository _repository;

  FormLapanganViewModel({required LapanganRepository repository})
      : _repository = repository;

  bool _sedangProses = false;
  bool get sedangProses => _sedangProses;

  String? _pesanError;
  String? get pesanError => _pesanError;

  /// Mengembalikan `true` kalau berhasil. Kalau `false`, baca
  /// [pesanError] untuk pesan yang siap ditampilkan.
  Future<bool> tambahLapangan({
    required String nama,
    required String alamat,
    required double latitude,
    required double longitude,
    required List<String> jenisOlahraga,
    required int harga,
    required String jamBuka,
    required String jamTutup,
    required List<String> fasilitas,
    required List<String> fotoURL,
    required String pemilikId,
  }) async {
    _sedangProses = true;
    _pesanError = null;
    notifyListeners();

    try {
      await _repository.tambahLapangan(
        nama: nama,
        alamat: alamat,
        latitude: latitude,
        longitude: longitude,
        jenisOlahraga: jenisOlahraga,
        harga: harga,
        jamBuka: jamBuka,
        jamTutup: jamTutup,
        fasilitas: fasilitas,
        fotoURL: fotoURL,
        pemilikId: pemilikId,
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

  /// Mengembalikan `true` kalau berhasil. [lapanganLama] dipakai untuk
  /// menyalin `lapanganId`/`pemilikId`/`isMitra`/`sumberData`/field
  /// rating apa adanya — form edit hanya mengubah field informasional.
  Future<bool> perbaruiLapangan(
    LapanganModel lapanganLama, {
    required String nama,
    required String alamat,
    required double latitude,
    required double longitude,
    required List<String> jenisOlahraga,
    required int harga,
    required String jamBuka,
    required String jamTutup,
    required List<String> fasilitas,
    required List<String> fotoURL,
  }) async {
    _sedangProses = true;
    _pesanError = null;
    notifyListeners();

    try {
      final lapanganBaru = LapanganModel(
        lapanganId: lapanganLama.lapanganId,
        nama: nama,
        alamat: alamat,
        latitude: latitude,
        longitude: longitude,
        jenisOlahraga: jenisOlahraga,
        harga: harga,
        jamBuka: jamBuka,
        jamTutup: jamTutup,
        fasilitas: fasilitas,
        fotoURL: fotoURL,
        isMitra: lapanganLama.isMitra,
        pemilikId: lapanganLama.pemilikId,
        sumberData: lapanganLama.sumberData,
        ratingTotal: lapanganLama.ratingTotal,
        jumlahRating: lapanganLama.jumlahRating,
        ratingRata2: lapanganLama.ratingRata2,
      );
      await _repository.perbaruiLapangan(lapanganBaru);
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
