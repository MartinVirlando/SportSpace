import 'package:flutter/foundation.dart';

import '../../../core/constants/app_sports.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/haversine.dart';
import '../../../models/lapangan_model.dart';
import '../../../repositories/lapangan_repository.dart';

/// Kondisi layar Home. Setiap layar wajib menangani memuat, kosong,
/// dan kesalahan — tidak boleh ada layar putih polos (CLAUDE.md).
enum KondisiHome { memuat, berhasil, kosong, gagal, lokasiDitolak }

/// ViewModel untuk halaman Home (L-04).
///
/// ATURAN LAPISAN: kelas ini TIDAK `import cloud_firestore`. Data diambil
/// lewat [LapanganRepository]. Di sinilah letak seluruh logika tampilan:
/// hitung jarak, urutkan, saring.
///
/// Catatan soal `ChangeNotifier` vs `StreamBuilder`: CLAUDE.md menyarankan
/// StreamBuilder untuk daftar dari Firestore. Home memakai ChangeNotifier
/// karena AB-02 butuh sekali ambil lalu hitung Haversine — dengan stream,
/// perhitungan itu akan diulang setiap kali ada snapshot baru, padahal
/// posisi pengguna tidak berubah. Untuk daftar yang memang perlu langsung
/// hidup (notifikasi, permintaan gabung), pakai StreamBuilder.
class HomeViewModel extends ChangeNotifier {
  final LapanganRepository _repository;
  final LocationService _locationService;

  HomeViewModel({
    required LapanganRepository repository,
    required LocationService locationService,
  })  : _repository = repository,
        _locationService = locationService;

  // ---------- State ----------

  KondisiHome _kondisi = KondisiHome.memuat;
  KondisiHome get kondisi => _kondisi;

  String? _pesanError;
  String? get pesanError => _pesanError;

  /// Seluruh lapangan, sudah berjarak dan terurut. Tidak diekspos ke View —
  /// View selalu membaca [lapanganTampil] yang sudah tersaring.
  List<LapanganModel> _semuaLapangan = [];

  String _filterOlahraga = AppSports.semua;
  String get filterOlahraga => _filterOlahraga;

  String _kataKunci = '';
  String get kataKunci => _kataKunci;

  bool _pakaiLokasiDefault = false;

  /// True kalau jarak dihitung dari lokasi default, bukan GPS (AB-03).
  /// View memakai ini untuk memunculkan spanduk pemberitahuan.
  bool get pakaiLokasiDefault => _pakaiLokasiDefault;

  /// Nomor urut permintaan [muatLapangan] yang sedang berjalan — dipakai
  /// supaya panggilan yang tumpang tindih tidak saling menimpa state.
  /// Tanpa ini: kalau pengguna menekan "Coba Lagi" atau menarik-refresh
  /// dua kali sebelum permintaan pertama selesai (mis. GPS lambat), hasil
  /// panggilan PERTAMA yang baru selesai belakangan bisa menimpa hasil
  /// panggilan KEDUA yang sebenarnya lebih baru dan sudah lebih dulu
  /// tampil ke pengguna.
  int _permintaanTerakhir = 0;

  /// Daftar yang benar-benar ditampilkan: hasil penyaringan olahraga
  /// dan kata kunci. Urutan jaraknya tetap terjaga karena penyaringan
  /// tidak mengubah urutan.
  List<LapanganModel> get lapanganTampil {
    return _semuaLapangan.where((lapangan) {
      // Saring olahraga. `jenisOlahraga` bertipe List, jadi pakai contains —
      // satu lapangan bisa punya lebih dari satu cabang.
      final cocokOlahraga = _filterOlahraga == AppSports.semua ||
          lapangan.jenisOlahraga.contains(_filterOlahraga);

      // Saring kata kunci: cocokkan ke nama ATAU alamat (PRD L-04).
      final kunci = _kataKunci.trim().toLowerCase();
      final cocokKunci = kunci.isEmpty ||
          lapangan.nama.toLowerCase().contains(kunci) ||
          lapangan.alamat.toLowerCase().contains(kunci);

      return cocokOlahraga && cocokKunci;
    }).toList();
  }

  // ---------- Aksi ----------

  /// Dipanggil sekali saat layar dibuka, dan lagi saat pengguna menarik
  /// untuk menyegarkan.
  ///
  /// [latDefault] / [lonDefault] diisi dari `users.lokasiDefault` bila ada.
  /// Kalau GPS ditolak dan nilai ini tersedia, daftar tetap tampil (AB-03).
  Future<void> muatLapangan({double? latDefault, double? lonDefault}) async {
    final permintaanIni = ++_permintaanTerakhir;

    _kondisi = KondisiHome.memuat;
    _pesanError = null;
    notifyListeners();

    try {
      // 1. Ambil posisi pengguna.
      final hasilLokasi = await _locationService.ambilPosisi();
      // Ada panggilan `muatLapangan` lain yang lebih baru dimulai selagi
      // kita menunggu di atas — biarkan panggilan itu yang menentukan
      // state akhir, jangan menimpanya dengan hasil yang sudah usang.
      if (permintaanIni != _permintaanTerakhir) return;

      double? lat;
      double? lon;

      if (hasilLokasi.status == StatusLokasi.berhasil && hasilLokasi.ada) {
        lat = hasilLokasi.latitude;
        lon = hasilLokasi.longitude;
        _pakaiLokasiDefault = false;
      } else if (latDefault != null && lonDefault != null) {
        // GPS ditolak/mati, tapi pengguna punya lokasi default.
        lat = latDefault;
        lon = lonDefault;
        _pakaiLokasiDefault = true;
      } else {
        // Tidak ada GPS dan tidak ada cadangan — layar khusus AB-03.
        _kondisi = KondisiHome.lokasiDitolak;
        notifyListeners();
        return;
      }

      // 2. Ambil seluruh lapangan dari Firestore.
      final daftar = await _repository.ambilSemuaLapangan();
      if (permintaanIni != _permintaanTerakhir) return;

      // 3. Hitung Haversine untuk tiap lapangan, lalu urutkan menaik.
      //    Ini inti AB-02 — pengurutan MURNI jarak. Rating hanya
      //    ditampilkan sebagai informasi, bukan faktor pengurutan.
      final berjarak = daftar.map((lapangan) {
        final jarak = hitungJarakHaversine(
          lat!,
          lon!,
          lapangan.latitude,
          lapangan.longitude,
        );
        return lapangan.salinDenganJarak(jarak);
      }).toList();

      berjarak.sort((a, b) => a.jarakKm!.compareTo(b.jarakKm!));

      _semuaLapangan = berjarak;
      _kondisi = berjarak.isEmpty ? KondisiHome.kosong : KondisiHome.berhasil;
    } catch (e) {
      if (permintaanIni != _permintaanTerakhir) return;
      // Repository sudah melempar pesan berbahasa Indonesia yang siap
      // tampil. `toString()` pada Exception menghasilkan "Exception: pesan",
      // jadi awalannya dibuang.
      _pesanError = e.toString().replaceFirst('Exception: ', '');
      _kondisi = KondisiHome.gagal;
    }

    notifyListeners();
  }

  void ubahFilterOlahraga(String kode) {
    if (_filterOlahraga == kode) return;
    _filterOlahraga = kode;
    // Tidak perlu ambil ulang dari Firestore — penyaringan di klien.
    notifyListeners();
  }

  void ubahKataKunci(String kunci) {
    _kataKunci = kunci;
    notifyListeners();
  }

  Future<void> bukaPengaturanLokasi() =>
      _locationService.bukaPengaturanLokasi();
}
