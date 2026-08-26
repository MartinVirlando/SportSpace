import 'package:flutter/foundation.dart';

import '../../../core/services/location_service.dart';
import '../../../core/utils/haversine.dart';
import '../../../models/lapangan_model.dart';
import '../../../repositories/lapangan_repository.dart';

/// Kondisi layar Peta. Sama seperti Home — setiap kondisi ditangani
/// eksplisit, tidak boleh ada layar putih polos (CLAUDE.md).
enum KondisiMap { memuat, berhasil, gagal, lokasiDitolak }

/// ViewModel untuk halaman Peta Lapangan (L-05).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data lewat
/// [LapanganRepository], posisi lewat [LocationService] — pola yang
/// sama persis dengan HomeViewModel, cuma tanpa filter/pencarian karena
/// PRD L-05 tidak menyebutkannya.
class MapViewModel extends ChangeNotifier {
  final LapanganRepository _repository;
  final LocationService _locationService;

  MapViewModel({
    required LapanganRepository repository,
    required LocationService locationService,
  })  : _repository = repository,
        _locationService = locationService;

  KondisiMap _kondisi = KondisiMap.memuat;
  KondisiMap get kondisi => _kondisi;

  String? _pesanError;
  String? get pesanError => _pesanError;

  List<LapanganModel> _lapangan = [];
  List<LapanganModel> get lapangan => _lapangan;

  double? _latPengguna;
  double? get latPengguna => _latPengguna;

  double? _lonPengguna;
  double? get lonPengguna => _lonPengguna;

  bool _pakaiLokasiDefault = false;
  bool get pakaiLokasiDefault => _pakaiLokasiDefault;

  /// Nomor urut permintaan [muatPeta] yang sedang berjalan — sama seperti
  /// `HomeViewModel._permintaanTerakhir`, mencegah panggilan yang tumpang
  /// tindih (mis. tombol "Coba Lagi" ditekan dua kali) saling menimpa
  /// state dengan hasil yang sudah usang.
  int _permintaanTerakhir = 0;

  /// Lapangan yang marker-nya baru ditekan — dipakai menampilkan kartu
  /// ringkas (BB-10). `null` berarti tidak ada kartu yang perlu tampil.
  LapanganModel? _lapanganTerpilih;
  LapanganModel? get lapanganTerpilih => _lapanganTerpilih;

  void pilihLapangan(LapanganModel? nilai) {
    _lapanganTerpilih = nilai;
    notifyListeners();
  }

  Future<void> muatPeta({double? latDefault, double? lonDefault}) async {
    final permintaanIni = ++_permintaanTerakhir;

    _kondisi = KondisiMap.memuat;
    _pesanError = null;
    notifyListeners();

    try {
      final hasilLokasi = await _locationService.ambilPosisi();
      if (permintaanIni != _permintaanTerakhir) return;

      double? lat;
      double? lon;

      if (hasilLokasi.status == StatusLokasi.berhasil && hasilLokasi.ada) {
        lat = hasilLokasi.latitude;
        lon = hasilLokasi.longitude;
        _pakaiLokasiDefault = false;
      } else if (latDefault != null && lonDefault != null) {
        lat = latDefault;
        lon = lonDefault;
        _pakaiLokasiDefault = true;
      } else {
        _kondisi = KondisiMap.lokasiDitolak;
        notifyListeners();
        return;
      }

      final daftar = await _repository.ambilSemuaLapangan();
      if (permintaanIni != _permintaanTerakhir) return;

      // Jarak dihitung supaya kartu ringkas (BB-10) bisa menampilkannya —
      // PRD L-05 tidak mensyaratkan urutan tertentu di peta, jadi tidak
      // diurutkan seperti Home (AB-02 murni soal L-04).
      final berjarak = daftar.map((l) {
        final jarak = hitungJarakHaversine(lat!, lon!, l.latitude, l.longitude);
        return l.salinDenganJarak(jarak);
      }).toList();

      _latPengguna = lat;
      _lonPengguna = lon;
      _lapangan = berjarak;
      _kondisi = KondisiMap.berhasil;
    } catch (e) {
      if (permintaanIni != _permintaanTerakhir) return;
      _pesanError = e.toString().replaceFirst('Exception: ', '');
      _kondisi = KondisiMap.gagal;
    }

    notifyListeners();
  }

  Future<void> bukaPengaturanLokasi() =>
      _locationService.bukaPengaturanLokasi();
}
