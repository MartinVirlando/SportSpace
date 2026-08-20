import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_sports.dart';
import '../models/aktivitas_bermain_model.dart';

/// Satu-satunya lapisan yang boleh menyentuh Firestore untuk data
/// aktivitas bermain.
///
/// ATURAN LAPISAN (CLAUDE.md): View dan ViewModel TIDAK BOLEH
/// `import cloud_firestore`. Semua akses data lewat kelas ini.
///
/// Daftar aktivitas (L-07) dipakai lewat `Stream`, bukan `Future` —
/// beda dari LapanganRepository. Alasannya (CLAUDE.md aturan 6): daftar
/// yang perlu langsung hidup pakai StreamBuilder. Aktivitas yang baru
/// dibuat orang lain, atau yang baru penuh (BB-20: "hilang dari
/// daftar"), harus muncul/hilang tanpa pengguna menarik untuk
/// menyegarkan — beda dari Home (AB-02) yang sengaja sekali ambil lalu
/// dihitung Haversine di klien.
class AktivitasRepository {
  final FirebaseFirestore _db;

  AktivitasRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Stream aktivitas berstatus TERBUKA dan waktunya belum lewat — PRD
  /// L-07. [olahraga] null atau `AppSports.semua` berarti tanpa
  /// penyaringan cabang olahraga.
  ///
  /// Query ini persis mengikuti `FIRESTORE-INDEXES.md` index #2 (tanpa
  /// filter olahraga) dan #3 (dengan filter olahraga) — jangan diubah
  /// tanpa memperbarui index-nya juga.
  Stream<List<AktivitasBermainModel>> streamAktivitasTerbuka({
    String? olahraga,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection('aktivitasBermain')
        .where('status', isEqualTo: 'TERBUKA')
        // Pertidaksamaan (isGreaterThan) mewajibkan orderBy pertama
        // memakai field yang sama — lihat jebakan di FIRESTORE-INDEXES.md.
        .where('waktu', isGreaterThan: Timestamp.now());

    if (olahraga != null && olahraga != AppSports.semua) {
      query = query.where('jenisOlahraga', isEqualTo: olahraga);
    }

    return query.orderBy('waktu').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AktivitasBermainModel.fromFirestore(doc))
          .toList();
    }).handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca data aktivitas.');
      }
      throw Exception('Gagal memuat daftar aktivitas. Coba lagi.');
    });
  }

  /// Membuat aktivitas baru — PRD L-08, dipakai T-18.
  ///
  /// `jumlahPemainSaatIni` awal 1 dan `peserta` awal berisi [pembuatId]
  /// sendiri (PRD 6.3 — pembuat otomatis ikut bermain).
  Future<AktivitasBermainModel> buatAktivitas({
    required String jenisOlahraga,
    required int jumlahPemainDibutuhkan,
    required DateTime waktu,
    required String lapanganId,
    required String namaLapangan,
    required String pembuatId,
    required String namaPembuat,
    String? catatan,
  }) async {
    try {
      final ref = _db.collection('aktivitasBermain').doc();
      final aktivitas = AktivitasBermainModel(
        aktivitasId: ref.id,
        jenisOlahraga: jenisOlahraga,
        jumlahPemainDibutuhkan: jumlahPemainDibutuhkan,
        jumlahPemainSaatIni: 1,
        waktu: waktu,
        lapanganId: lapanganId,
        namaLapangan: namaLapangan,
        pembuatId: pembuatId,
        namaPembuat: namaPembuat,
        status: 'TERBUKA',
        peserta: [pembuatId],
        catatan: catatan,
        dibuatPada: DateTime.now(),
      );

      await ref.set(aktivitas.toFirestore());
      return aktivitas;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin membuat aktivitas.');
      }
      throw Exception('Gagal membuat aktivitas. Coba lagi.');
    }
  }
}
