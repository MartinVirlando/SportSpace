import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_sports.dart';
import '../models/aktivitas_bermain_model.dart';
import '../models/notifikasi_model.dart';
import '../models/permintaan_gabung_model.dart';

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

  /// Stream aktivitas yang dibuat MAUPUN diikuti pengguna — PRD L-13,
  /// T-27.
  ///
  /// Cukup satu query `peserta arrayContains uid`, bukan dua query
  /// terpisah untuk "dibuat" dan "diikuti": pembuat aktivitas selalu ikut
  /// masuk ke `peserta` sejak [buatAktivitas] (PRD 6.3), jadi query ini
  /// otomatis mencakup keduanya — sesuai catatan di
  /// `FIRESTORE-INDEXES.md` index #5.
  ///
  /// Index #5 — (peserta CONTAINS, waktu DESC).
  Stream<List<AktivitasBermainModel>> streamAktivitasSaya(String userId) {
    return _db
        .collection('aktivitasBermain')
        .where('peserta', arrayContains: userId)
        .orderBy('waktu', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AktivitasBermainModel.fromFirestore(doc))
          .toList();
    }).handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca aktivitas kamu.');
      }
      throw Exception('Gagal memuat aktivitas kamu. Coba lagi.');
    });
  }

  /// Hitung jumlah aktivitas yang dibuat/diikuti pengguna — PRD L-13,
  /// T-38, AB-12. Query sama dengan [streamAktivitasSaya], jadi ikut
  /// index #5 — tapi lewat `count()`, bukan `.snapshots()`, karena
  /// statistik profil sekali ambil (CLAUDE.md aturan 6), bukan daftar
  /// yang perlu tetap hidup.
  Future<int> hitungAktivitasSaya(String userId) async {
    try {
      final hasil = await _db
          .collection('aktivitasBermain')
          .where('peserta', arrayContains: userId)
          .count()
          .get();
      return hasil.count ?? 0;
    } on FirebaseException {
      throw Exception('Gagal menghitung aktivitas.');
    }
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
    // Pengaman berlapis — sudah dicek di UI (`buat_aktivitas_screen.dart`
    // lewat `Validators.jumlahPemain`/`Validators.waktuDiMasaDepan`), tapi
    // diulang di sini juga supaya pemanggil lain di masa depan tidak bisa
    // membuat aktivitas dengan target pemain di luar rentang atau jadwal
    // yang sudah lewat kalau lupa memvalidasi di lapisan atas.
    if (jumlahPemainDibutuhkan < 2 || jumlahPemainDibutuhkan > 30) {
      throw Exception('Jumlah pemain dibutuhkan harus 2-30.');
    }
    if (!waktu.isAfter(DateTime.now())) {
      throw Exception('Waktu aktivitas harus di masa depan.');
    }

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

  /// Stream satu aktivitas — dipakai Detail Aktivitas (L-09) supaya
  /// `jumlahPemainSaatIni`/`status` ikut hidup begitu ada permintaan yang
  /// diterima (T-20), tanpa pengguna menarik untuk menyegarkan.
  Stream<AktivitasBermainModel> streamDetailAktivitas(String aktivitasId) {
    return _db
        .collection('aktivitasBermain')
        .doc(aktivitasId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception('Aktivitas tidak ditemukan.');
      }
      return AktivitasBermainModel.fromFirestore(doc);
    }).handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca aktivitas ini.');
      }
      throw Exception('Gagal memuat detail aktivitas. Coba lagi.');
    });
  }

  /// Stream SELURUH subkoleksi `permintaan`, tanpa filter/orderBy — sesuai
  /// `FIRESTORE-INDEXES.md` ("Subkoleksi permintaan di L-09: ambil seluruh
  /// subkoleksi, tanpa filter"), jadi tidak butuh composite index apa pun.
  ///
  /// Dipakai untuk DUA hal sekaligus di L-09, supaya tidak ada listener
  /// dobel: (1) nama peserta yang sudah `DITERIMA` digabung dengan
  /// [AktivitasBermainModel.namaPembuat] untuk daftar peserta, dan (2)
  /// daftar permintaan berstatus `MENUNGGU` untuk pembuat (Terima/Tolak,
  /// tombolnya baru berfungsi di T-20).
  Stream<List<PermintaanGabungModel>> streamPermintaan(String aktivitasId) {
    return _db
        .collection('aktivitasBermain')
        .doc(aktivitasId)
        .collection('permintaan')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PermintaanGabungModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca permintaan gabung.');
      }
      throw Exception('Gagal memuat permintaan gabung. Coba lagi.');
    });
  }

  /// Kirim permintaan gabung — PRD AB-06, BB-16.
  ///
  /// ID dokumen permintaan sengaja = [userId] (lihat PermintaanGabungModel)
  /// supaya satu pengguna tidak bisa mengirim permintaan ganda — mengirim
  /// ulang cukup menimpa dokumen MENUNGGU yang sama, aman tanpa Query.
  ///
  /// Bukan transaction: tidak ada penghitung bersama yang dibaca-lalu-
  /// ditulis di sini (beda dari [terimaPermintaan] nanti di T-20). Dua
  /// tulisan (permintaan + notifikasi) cukup digabung lewat `WriteBatch`
  /// supaya tetap atomik.
  Future<void> kirimPermintaanGabung({
    required String aktivitasId,
    required String pembuatId,
    required String userId,
    required String namaUser,
  }) async {
    try {
      final permintaanRef = _db
          .collection('aktivitasBermain')
          .doc(aktivitasId)
          .collection('permintaan')
          .doc(userId);
      final notifRef = _db.collection('notifikasi').doc();

      final permintaan = PermintaanGabungModel(
        userId: userId,
        namaUser: namaUser,
        status: 'MENUNGGU',
        dibuatPada: DateTime.now(),
      );
      final notifikasi = NotifikasiModel(
        notifikasiId: notifRef.id,
        untukUserId: pembuatId,
        tipe: 'PERMINTAAN_GABUNG',
        judul: 'Permintaan gabung baru',
        pesan: '$namaUser ingin bergabung ke aktivitasmu.',
        refId: aktivitasId,
        dibuatPada: DateTime.now(),
      );

      final batch = _db.batch();
      batch.set(permintaanRef, permintaan.toFirestore());
      batch.set(notifRef, notifikasi.toFirestore());
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin mengirim permintaan gabung.');
      }
      throw Exception('Gagal mengirim permintaan gabung. Coba lagi.');
    }
  }

  /// Terima permintaan gabung — PRD AB-06, T-20, BB-17/BB-18.
  ///
  /// Transaction (bukan batch seperti [tolakPermintaan]) karena
  /// `jumlahPemainSaatIni` dibaca lalu ditulis balik: dua permintaan
  /// berbeda diterima hampir bersamaan tidak boleh sama-sama lolos kalau
  /// slot yang tersisa cuma satu (BB-18). `transaction.get()` di sini
  /// pada `DocumentReference` `aktivitasBermain/{id}`, bukan Query —
  /// lihat jebakan Firestore Transaction di CLAUDE.md.
  Future<void> terimaPermintaan({
    required String aktivitasId,
    required String userId,
    required String namaUser,
  }) async {
    final aktivitasRef = _db.collection('aktivitasBermain').doc(aktivitasId);
    final permintaanRef = aktivitasRef.collection('permintaan').doc(userId);
    final notifRef = _db.collection('notifikasi').doc();

    try {
      await _db.runTransaction((transaction) async {
        final aktivitasSnap = await transaction.get(aktivitasRef);
        if (!aktivitasSnap.exists) {
          throw Exception('Aktivitas tidak ditemukan.');
        }
        final aktivitas = AktivitasBermainModel.fromFirestore(aktivitasSnap);

        // Jaga idempotensi: tanpa ini, dua tap "Terima" yang cepat pada
        // permintaan YANG SAMA bisa sama-sama lolos transaction (keduanya
        // membaca `jumlahPemainSaatIni` lama sebelum salah satu menulis),
        // menaikkan hitungannya dua kali untuk satu orang yang sama.
        final permintaanSnap = await transaction.get(permintaanRef);
        if (!permintaanSnap.exists) {
          throw Exception('Permintaan tidak ditemukan.');
        }
        if (permintaanSnap.data()?['status'] != 'MENUNGGU') {
          throw Exception('Permintaan ini sudah diproses.');
        }

        if (aktivitas.jumlahPemainSaatIni >= aktivitas.jumlahPemainDibutuhkan) {
          throw Exception('Slot penuh');
        }

        final jumlahBaru = aktivitas.jumlahPemainSaatIni + 1;
        final statusBaru = jumlahBaru >= aktivitas.jumlahPemainDibutuhkan
            ? 'PENUH'
            : aktivitas.status;

        transaction.update(aktivitasRef, {
          'jumlahPemainSaatIni': jumlahBaru,
          'status': statusBaru,
          'peserta': FieldValue.arrayUnion([userId]),
        });
        transaction.update(permintaanRef, {'status': 'DITERIMA'});
        transaction.set(
          notifRef,
          NotifikasiModel(
            notifikasiId: notifRef.id,
            untukUserId: userId,
            tipe: 'PERMINTAAN_DITERIMA',
            judul: 'Permintaan gabung diterima',
            pesan:
                '$namaUser diterima bergabung ke "${aktivitas.namaLapangan}".',
            refId: aktivitasId,
            dibuatPada: DateTime.now(),
          ).toFirestore(),
        );
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin menerima permintaan gabung.');
      }
      throw Exception('Gagal menerima permintaan. Coba lagi.');
    }
  }

  /// Tolak permintaan gabung — PRD AB-06, T-20, BB-19.
  ///
  /// Cukup `WriteBatch`, bukan transaction: tidak ada penghitung bersama
  /// yang dibaca-lalu-ditulis di sini, beda dari [terimaPermintaan].
  Future<void> tolakPermintaan({
    required String aktivitasId,
    required String userId,
    required String namaUser,
    required String namaLapangan,
  }) async {
    try {
      final permintaanRef = _db
          .collection('aktivitasBermain')
          .doc(aktivitasId)
          .collection('permintaan')
          .doc(userId);
      final notifRef = _db.collection('notifikasi').doc();

      final notifikasi = NotifikasiModel(
        notifikasiId: notifRef.id,
        untukUserId: userId,
        tipe: 'PERMINTAAN_DITOLAK',
        judul: 'Permintaan gabung ditolak',
        pesan: 'Permintaan gabungmu ke "$namaLapangan" ditolak.',
        refId: aktivitasId,
        dibuatPada: DateTime.now(),
      );

      final batch = _db.batch();
      batch.update(permintaanRef, {'status': 'DITOLAK'});
      batch.set(notifRef, notifikasi.toFirestore());
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin menolak permintaan gabung.');
      }
      throw Exception('Gagal menolak permintaan. Coba lagi.');
    }
  }
}
