import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/pengingat_service.dart';
import '../../../core/theme/mode_tema.dart';
import '../../../core/utils/pengingat_jadwal.dart';
import '../../../models/booking_model.dart';
import '../../../repositories/pengaturan_repository.dart';

/// ViewModel pengaturan aplikasi (Profil) — v1.5. Mengurus pengingat jadwal
/// booking (T-67, PRD AB-23) dan mode tampilan terang/gelap (PRD AB-24).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Pilihan disimpan lewat
/// [PengaturanRepository] (di HP), notifikasi dijadwalkan lewat
/// [PengingatService]; daftar booking yang diingatkan DIKIRIM ke sini oleh
/// `ProfilViewModel` (lewat [sinkronkanPengingat]) — ViewModel ini tidak
/// membaca Firestore sendiri, jadi tidak ada langganan tambahan.
///
/// Dipasang sebagai Provider GLOBAL di `main.dart` (CLAUDE.md aturan 6:
/// state lintas layar): pilihannya dibaca layar Profil, sedangkan daftar
/// booking-nya datang dari ViewModel lain.
class PengaturanViewModel extends ChangeNotifier {
  final PengaturanRepository _repository;
  final PengingatService _pengingat;

  PengaturanViewModel({
    required PengaturanRepository repository,
    required PengingatService pengingat,
  })  : _repository = repository,
        _pengingat = pengingat,
        _pengingatAktif = repository.pengingatAktif,
        _modeTema = repository.modeTema;

  // ---------- Mode tampilan (AB-24) ----------

  ModeTema _modeTema;

  /// Pilihan mode tampilan. Dibaca `main.dart` untuk `MaterialApp.themeMode`
  /// — begitu berubah, seluruh aplikasi berganti tema.
  ModeTema get modeTema => _modeTema;

  /// Mengganti mode tampilan: tampil dulu, simpan kemudian. Kalau
  /// penyimpanan gagal, pilihan tetap berlaku sampai aplikasi ditutup dan
  /// pengguna diberi tahu (bukan dibatalkan diam-diam).
  Future<void> ubahModeTema(ModeTema mode) async {
    if (mode == _modeTema) return;
    _modeTema = mode;
    _pesanErrorTema = null;
    notifyListeners();

    try {
      await _repository.simpanModeTema(mode);
    } catch (_) {
      _pesanErrorTema = AppStrings.errGagalSimpanModeTema;
      notifyListeners();
    }
  }

  String? _pesanErrorTema;

  /// Galat penyimpanan mode tampilan; terpisah dari [pesanError] milik
  /// pengingat supaya keduanya tidak saling menghapus.
  String? get pesanErrorTema => _pesanErrorTema;

  // ---------- Pengingat jadwal (T-67) ----------

  bool _pengingatAktif;

  /// Pilihan pengguna: apakah pengingat jadwal menyala.
  bool get pengingatAktif => _pengingatAktif;

  bool _izinNotifikasi = true;

  /// Apakah Android mengizinkan notifikasi. Kalau `false` padahal
  /// [pengingatAktif], View menampilkan petunjuk — pengingat tidak akan
  /// muncul sampai pengguna mengizinkannya di pengaturan HP.
  bool get izinNotifikasi => _izinNotifikasi;

  String? _pesanError;
  String? get pesanError => _pesanError;

  /// Booking terakhir yang dikirim `ProfilViewModel`. Disimpan supaya saat
  /// pengguna menyalakan ulang pengingat, daftarnya bisa langsung dihitung
  /// tanpa menunggu booking berubah.
  List<BookingModel> _bookingTerakhir = const [];

  /// Dialog izin cukup diminta SEKALI otomatis per sesi aplikasi. Tanpa ini,
  /// pengguna yang menolak akan disodori dialog lagi setiap kali daftar
  /// booking berubah. Menyalakan saklar secara sengaja tetap selalu meminta.
  bool _sudahMemintaIzin = false;

  /// Rantai pekerjaan: penerapan pengingat dijalankan satu per satu, supaya
  /// penyalaan saklar dan kiriman booking baru yang datang bersamaan tidak
  /// saling menimpa di tengah jalan.
  Future<void> _antrean = Future<void>.value();

  /// Memeriksa status izin saat aplikasi dibuka. Dipanggil sekali di
  /// `main()`.
  Future<void> muat() async {
    _izinNotifikasi = await _pengingat.izinDiberikan();
    notifyListeners();
  }

  /// Saklar "Pengingat jadwal" di Profil.
  Future<void> ubahPengingat(bool nilai) async {
    _pengingatAktif = nilai;
    _pesanError = null;
    notifyListeners();

    try {
      await _repository.simpanPengingatAktif(nilai);
    } catch (_) {
      _pesanError = AppStrings.errGagalAturPengingat;
      notifyListeners();
      return;
    }

    await _terapkanBerurutan(sengajaMenyalakan: nilai);
  }

  /// Dipanggil `ProfilViewModel` setiap daftar booking pengguna berubah
  /// (dikonfirmasi mitra, dibatalkan, dijadwal ulang, dst.).
  Future<void> sinkronkanPengingat(List<BookingModel> daftar) {
    _bookingTerakhir = daftar;
    return _terapkanBerurutan();
  }

  /// Dipanggil saat keluar akun: semua pengingat yang belum muncul dibatalkan
  /// supaya pengguna berikutnya di HP yang sama tidak menerima pengingat
  /// milik orang lain. Pilihan saklar tetap tersimpan (milik perangkat).
  Future<void> batalkanPengingat() async {
    _bookingTerakhir = const [];
    try {
      await _pengingat.batalkanSemua();
    } catch (_) {
      _pesanError = AppStrings.errGagalAturPengingat;
      notifyListeners();
    }
  }

  Future<void> _terapkanBerurutan({bool sengajaMenyalakan = false}) {
    _antrean = _antrean.then((_) => _terapkan(sengajaMenyalakan));
    return _antrean;
  }

  Future<void> _terapkan(bool sengajaMenyalakan) async {
    try {
      if (!_pengingatAktif) {
        await _pengingat.batalkanSemua();
        _pesanError = null;
        notifyListeners();
        return;
      }

      final rencana = rencanakanPengingat(_bookingTerakhir, DateTime.now());

      var izin = await _pengingat.izinDiberikan();
      final perluMeminta =
          !izin && (sengajaMenyalakan || (!_sudahMemintaIzin && rencana.isNotEmpty));
      if (perluMeminta) {
        _sudahMemintaIzin = true;
        izin = await _pengingat.mintaIzin();
      }
      _izinNotifikasi = izin;

      if (izin) {
        await _pengingat.jadwalkan(rencana);
      }
      _pesanError = null;
    } catch (_) {
      // Pesan galat sudah siap tampil (CLAUDE.md "Menangani kesalahan");
      // detail teknis plugin tidak berguna bagi pengguna.
      _pesanError = AppStrings.errGagalAturPengingat;
    }
    notifyListeners();
  }
}
