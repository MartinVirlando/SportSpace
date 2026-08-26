import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../models/user_model.dart';
import '../../../repositories/auth_repository.dart';

/// Status sesi login. `memuat` cuma sebentar di awal, sebelum
/// `authStateChanges` mengirim nilai pertamanya.
enum StatusAuth { memuat, sudahMasuk, belumMasuk }

/// ViewModel untuk status autentikasi.
///
/// ATURAN LAPISAN: kelas ini TIDAK `import cloud_firestore` (dan sengaja
/// juga tidak import apa pun dari `firebase_auth` — lihat komentar
/// `perubahanStatusLogin` di AuthRepository).
///
/// Berbeda dari HomeViewModel yang dibuat baru tiap layar, AuthViewModel
/// ini dipasang SEKALI di `main.dart` lewat Provider dan dipakai lintas
/// layar (CLAUDE.md aturan 6: Provider hanya untuk state lintas layar —
/// status autentikasi dan posisi GPS). ViewModel ini juga yang
/// berlangganan `authStateChanges`, supaya begitu pengguna login/logout
/// di layar mana pun, seluruh aplikasi (header Home, nanti shell
/// navigasi di T-08) langsung tahu tanpa perlu di-refresh manual.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<String?>? _langganan;

  AuthViewModel({required AuthRepository repository})
      : _repository = repository {
    _langganan = _repository.perubahanStatusLogin.listen(_saatStatusBerubah);
  }

  StatusAuth _status = StatusAuth.memuat;
  StatusAuth get status => _status;

  UserModel? _user;
  UserModel? get user => _user;

  /// True selagi permintaan login/daftar sedang berjalan — dipakai View
  /// untuk menonaktifkan tombol submit dan menampilkan indikator.
  bool _sedangProses = false;
  bool get sedangProses => _sedangProses;

  String? _pesanError;
  String? get pesanError => _pesanError;

  Future<void> _saatStatusBerubah(String? uid) async {
    if (uid == null) {
      _user = null;
      _status = StatusAuth.belumMasuk;
      notifyListeners();
      return;
    }

    try {
      _user = await _repository.ambilUser(uid);
      _status = StatusAuth.sudahMasuk;
    } catch (_) {
      // Akun Auth ada tapi dokumen users gagal diambil (lihat catatan
      // di AuthRepository.daftar soal akun "yatim") — anggap belum
      // masuk daripada menampilkan layar rusak.
      _user = null;
      _status = StatusAuth.belumMasuk;
    }
    notifyListeners();
  }

  /// Mengembalikan `true` kalau berhasil. Kalau `false`, baca
  /// [pesanError] untuk pesan yang siap ditampilkan (BB-04).
  ///
  /// [_user] diisi LANGSUNG dari hasil `_repository.login()` di sini —
  /// BUKAN menunggu `_saatStatusBerubah` yang dipicu `authStateChanges`.
  /// Alasan: `login_screen.dart` langsung `pushAndRemoveUntil` ke
  /// `ShellNavigasi` begitu method ini mengembalikan `true`, dan
  /// `ShellNavigasi` langsung membangun SEMUA tab lewat `IndexedStack`
  /// (termasuk Home/Profil yang membaca `user!`/`user` lewat
  /// `context.read`, bukan `watch`). Kalau `_user` masih null saat itu
  /// (fetch Firestore di `_saatStatusBerubah` — request TERPISAH dari
  /// yang di dalam `_repository.login()` — belum selesai), tab Profil
  /// akan macet permanen di spinner: `context.read` tidak memicu rebuild
  /// susulan, dan `const HomeScreen()`/`const ProfilScreen()` di
  /// `ShellNavigasi` membuat Flutter melewati rebuild saat pindah tab.
  /// Mengisi `_user` di sini menghilangkan celah itu — `authStateChanges`
  /// tetap jalan untuk kasus lain (sesi lama saat app dibuka via Splash,
  /// dan logout), memanggil ulang `_saatStatusBerubah` sesudahnya tidak
  /// berbahaya karena hasilnya sama.
  Future<bool> masuk(String surel, String kataSandi) async {
    _sedangProses = true;
    _pesanError = null;
    notifyListeners();

    try {
      _user = await _repository.login(surel, kataSandi);
      _status = StatusAuth.sudahMasuk;
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

  /// Mengembalikan `true` kalau berhasil. Kalau `false`, baca
  /// [pesanError] untuk pesan yang siap ditampilkan (BB-02).
  ///
  /// Sama seperti [masuk]: `_user` diisi langsung dari hasil
  /// `_repository.daftar()`, tidak menunggu `authStateChanges` — lihat
  /// komentar lengkap di [masuk].
  Future<bool> daftar({
    required String nama,
    required String surel,
    required String kataSandi,
    required String nomorTelepon,
    required String role,
  }) async {
    _sedangProses = true;
    _pesanError = null;
    notifyListeners();

    try {
      _user = await _repository.daftar(
        nama: nama,
        surel: surel,
        kataSandi: kataSandi,
        nomorTelepon: nomorTelepon,
        role: role,
      );
      _status = StatusAuth.sudahMasuk;
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

  /// Ubah Olahraga Favorit — PRD L-13, T-37. Mengembalikan `true` kalau
  /// berhasil; kalau `false`, baca [pesanError].
  Future<bool> ubahOlahragaFavorit(List<String> olahragaFavorit) async {
    final userSaatIni = _user;
    if (userSaatIni == null) return false;

    try {
      await _repository.perbaruiOlahragaFavorit(
        userSaatIni.userId,
        olahragaFavorit,
      );
      // Salin lokal langsung, tanpa ambilUser() ulang — AuthViewModel
      // sudah tahu isinya, jadi tidak perlu baca balik dari Firestore.
      _user = userSaatIni.salinDengan(olahragaFavorit: olahragaFavorit);
      notifyListeners();
      return true;
    } catch (e) {
      _pesanError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Ubah Lokasi Default — PRD L-13, T-37 (cadangan AB-03 saat GPS
  /// ditolak). Mengembalikan `true` kalau berhasil; kalau `false`, baca
  /// [pesanError].
  Future<bool> ubahLokasiDefault(Map<String, dynamic> lokasiDefault) async {
    final userSaatIni = _user;
    if (userSaatIni == null) return false;

    try {
      await _repository.perbaruiLokasiDefault(userSaatIni.userId, lokasiDefault);
      _user = userSaatIni.salinDengan(lokasiDefault: lokasiDefault);
      notifyListeners();
      return true;
    } catch (e) {
      _pesanError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> keluar() => _repository.keluar();

  @override
  void dispose() {
    _langganan?.cancel();
    super.dispose();
  }
}
