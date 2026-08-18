import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Batas waktu tiap permintaan ke Firebase. Tanpa ini, koneksi yang
/// menggantung (bukan gagal, cuma tidak pernah selesai — mis. emulator
/// tanpa akses internet) membuat tombol submit loading selamanya, karena
/// tidak ada Exception yang bisa ditangkap `catch`.
const _batasWaktu = Duration(seconds: 15);

/// Satu-satunya lapisan yang boleh menyentuh Firebase Authentication dan
/// koleksi `users` untuk urusan login/daftar.
///
/// ATURAN LAPISAN (CLAUDE.md): View dan ViewModel TIDAK BOLEH
/// `import cloud_firestore`. Semua akses data lewat kelas ini.
///
/// Repository melempar `Exception` dengan pesan berbahasa Indonesia yang
/// sudah siap ditampilkan ke pengguna. ViewModel menangkapnya dan
/// menyimpannya ke `pesanError`.
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  /// Dipakai AuthViewModel untuk tahu kapan pengguna masuk/keluar, dari
  /// mana saja (bukan cuma lewat metode di kelas ini — mis. sesi yang
  /// sudah tersimpan sejak sebelumnya). Sengaja hanya mengirim `uid`
  /// (bukan objek `User` dari firebase_auth) supaya lapisan ViewModel ke
  /// atas tidak perlu tahu tipe apa pun dari Firebase.
  Stream<String?> get perubahanStatusLogin =>
      _auth.authStateChanges().map((user) => user?.uid);

  /// Login — PRD L-02. BB-03/BB-04.
  Future<UserModel> login(String surel, String kataSandi) async {
    try {
      final kredensial = await _auth
          .signInWithEmailAndPassword(email: surel.trim(), password: kataSandi)
          .timeout(_batasWaktu);
      return await ambilUser(kredensial.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_pesanKesalahanLogin(e.code));
    } on FirebaseException {
      throw Exception('Tidak ada koneksi internet. Coba lagi.');
    } on TimeoutException {
      throw Exception('Tidak ada koneksi internet. Coba lagi.');
    }
  }

  /// Daftar — PRD L-03. BB-01/BB-02.
  ///
  /// Membuat akun Auth DAN dokumen `users` sekaligus, dengan
  /// `olahragaFavorit: []` dan `lokasiDefault: null` sesuai PRD.
  Future<UserModel> daftar({
    required String nama,
    required String surel,
    required String kataSandi,
    required String nomorTelepon,
    required String role,
  }) async {
    try {
      final kredensial = await _auth
          .createUserWithEmailAndPassword(
            email: surel.trim(),
            password: kataSandi,
          )
          .timeout(_batasWaktu);

      final user = UserModel(
        userId: kredensial.user!.uid,
        nama: nama.trim(),
        surel: surel.trim(),
        nomorTelepon: nomorTelepon.trim(),
        role: role,
        tanggalDaftar: DateTime.now(),
        olahragaFavorit: const [],
        lokasiDefault: null,
      );

      // Tidak ada Cloud Functions (dilarang PRD Bagian 2.1), jadi dokumen
      // users dibuat langsung di sini setelah akun Auth berhasil. Kalau
      // langkah ini gagal (mis. jaringan putus di tengah), akun Auth
      // sudah terlanjur ada tanpa dokumen users — risiko yang diterima
      // untuk skala skripsi, dicatat sebagai keterbatasan di Bab 5.
      await _db
          .collection('users')
          .doc(user.userId)
          .set(user.toFirestore())
          .timeout(_batasWaktu);

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_pesanKesalahanDaftar(e.code));
    } on FirebaseException {
      throw Exception('Tidak ada koneksi internet. Coba lagi.');
    } on TimeoutException {
      throw Exception('Tidak ada koneksi internet. Coba lagi.');
    }
  }

  /// Mengambil dokumen `users/{uid}` — dipakai setelah login, dan oleh
  /// AuthViewModel setiap kali status login berubah.
  Future<UserModel> ambilUser(String uid) async {
    try {
      final doc =
          await _db.collection('users').doc(uid).get().timeout(_batasWaktu);
      if (!doc.exists) {
        throw Exception('Data pengguna tidak ditemukan.');
      }
      return UserModel.fromFirestore(doc);
    } on FirebaseException {
      throw Exception('Gagal memuat data pengguna. Coba lagi.');
    } on TimeoutException {
      throw Exception('Tidak ada koneksi internet. Coba lagi.');
    }
  }

  Future<void> keluar() => _auth.signOut();

  String _pesanKesalahanLogin(String kode) {
    switch (kode) {
      // Firebase Auth versi baru menyatukan user-not-found/wrong-password
      // jadi invalid-credential (supaya tidak bocor mana yang salah:
      // surel atau kata sandi) — ketiganya sengaja diberi pesan yang sama.
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Surel atau kata sandi salah.';
      case 'invalid-email':
        return 'Format surel tidak valid.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Gagal masuk. Coba lagi.';
    }
  }

  String _pesanKesalahanDaftar(String kode) {
    switch (kode) {
      case 'email-already-in-use':
        return 'Surel ini sudah terdaftar.';
      case 'invalid-email':
        return 'Format surel tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah.';
      default:
        return 'Gagal mendaftar. Coba lagi.';
    }
  }
}
