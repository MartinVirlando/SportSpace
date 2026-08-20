import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/data/seed_lapangan.dart';
import '../models/lapangan_model.dart';

/// Nama 7 lapangan yang koordinatnya sudah terverifikasi — dipakai
/// `seedPrototipe()` sebagai seed awal sebelum T-10 (30 lapangan penuh)
/// dikerjakan. Lihat catatan di `seedPrototipe()`.
const _namaLapanganTerverifikasi = [
  'MS Sport Arena',
  'Kicktopia Mini Soccer Gading Serpong',
  'KM7 Mini Soccer',
  'Sabnani Football',
  'Arsa Sport Mini Soccer',
  'Candra Wijaya International Badminton Centre',
  'The Good Padel Club',
];

/// Satu-satunya lapisan yang boleh menyentuh Firestore untuk data lapangan.
///
/// ATURAN LAPISAN (CLAUDE.md): View dan ViewModel TIDAK BOLEH
/// `import cloud_firestore`. Semua akses data lewat kelas ini.
///
/// Repository melempar `Exception` dengan pesan berbahasa Indonesia yang
/// sudah siap ditampilkan ke pengguna. ViewModel menangkapnya dan
/// menyimpannya ke `pesanError`.
class LapanganRepository {
  final FirebaseFirestore _db;

  /// `_db` bisa disuntik dari luar supaya nanti mudah diuji.
  /// Kalau tidak diisi, pakai instance bawaan.
  LapanganRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Mengambil seluruh lapangan — PRD AB-02.
  ///
  /// Sengaja TANPA `.where()` dan TANPA `.orderBy()`. Penyaringan olahraga,
  /// pencarian teks, dan pengurutan jarak semuanya dikerjakan di klien.
  /// Dua alasannya:
  ///
  /// 1. Jarak Haversine tidak bisa dihitung Firestore, jadi pengurutan
  ///    jarak memang harus di klien (AB-02).
  /// 2. Query tanpa where/orderBy tidak butuh composite index sama sekali.
  ///
  /// Batas 500 mengikuti PRD. Untuk 30 lapangan hasil seeding ini sangat
  /// longgar; batasnya ada supaya kalau data membengkak, aplikasi tidak
  /// diam-diam menarik ribuan dokumen.
  Future<List<LapanganModel>> ambilSemuaLapangan() async {
    try {
      final snapshot = await _db.collection('lapangan').limit(500).get();

      return snapshot.docs
          .map((doc) => LapanganModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      // Pesan bawaan Firebase berbahasa Inggris dan teknis. Diterjemahkan
      // di sini supaya View tinggal menampilkan apa adanya.
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca data lapangan.');
      }
      if (e.code == 'unavailable') {
        throw Exception('Tidak ada koneksi internet. Coba lagi.');
      }
      throw Exception('Gagal memuat data lapangan. Coba lagi.');
    }
  }

  /// Seed sementara sebelum T-10 (AdminSeedScreen + 30 lapangan penuh)
  /// dikerjakan. Menulis 7 lapangan dari [seedLapangan] yang koordinatnya
  /// SUDAH terverifikasi (lihat `_namaLapanganTerverifikasi`) — bukan data
  /// karangan, persis nilai yang akan dipakai T-10 nanti untuk 7 entri
  /// yang sama. [uidMitra] diisi ke `pemilikId` untuk entri yang
  /// `isMitra == true`.
  ///
  /// TODO(T-10): hapus method ini setelah AdminSeedScreen sungguhan
  /// (30 lapangan, semua koordinat terverifikasi) menggantikannya —
  /// jangan lupa hapus 7 dokumen prototipe ini dulu sebelum seed penuh,
  /// supaya tidak dobel.
  Future<int> seedPrototipe({required String uidMitra}) async {
    final existing = await _db
        .collection('lapangan')
        .where('nama', whereIn: _namaLapanganTerverifikasi)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('Data prototipe sudah pernah di-seed sebelumnya.');
    }

    final entri = seedLapangan
        .where((e) => _namaLapanganTerverifikasi.contains(e['nama']))
        .toList();

    final batch = _db.batch();
    for (final data in entri) {
      final ref = _db.collection('lapangan').doc();
      batch.set(ref, {
        ...data,
        'lapanganId': ref.id,
        'pemilikId': data['isMitra'] == true ? uidMitra : null,
      });
    }
    await batch.commit();
    return entri.length;
  }

  /// Stream lapangan milik satu mitra — PRD L-14, T-25.
  ///
  /// `Stream`, bukan `Future` (CLAUDE.md aturan 6): dashboard mitra perlu
  /// langsung menunjukkan lapangan yang baru didaftarkan (T-26) tanpa
  /// menyegarkan layar. Beda dari [ambilSemuaLapangan] (Home, AB-02) yang
  /// sengaja sekali ambil karena datanya besar dan diolah di klien.
  ///
  /// Index #1 — (pemilikId ASC, nama ASC).
  Stream<List<LapanganModel>> streamLapanganMitra(String pemilikId) {
    return _db
        .collection('lapangan')
        .where('pemilikId', isEqualTo: pemilikId)
        .orderBy('nama')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LapanganModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca lapangan milikmu.');
      }
      throw Exception('Gagal memuat lapangan milikmu. Coba lagi.');
    });
  }

  /// Tambah lapangan baru oleh mitra — PRD L-15, T-26, BB-29.
  ///
  /// `isMitra`, `pemilikId`, `sumberData`, dan field rating awal DITENTUKAN
  /// di sini, bukan diisi form — PRD Bagian 10: lapangan yang didaftarkan
  /// lewat aplikasi selalu `sumberData: "mitra"` dan `isMitra: true`.
  Future<LapanganModel> tambahLapangan({
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
    try {
      final ref = _db.collection('lapangan').doc();
      final lapangan = LapanganModel(
        lapanganId: ref.id,
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
        isMitra: true,
        pemilikId: pemilikId,
        sumberData: 'mitra',
        ratingTotal: 0,
        jumlahRating: 0,
        ratingRata2: 0.0,
      );
      await ref.set(lapangan.toFirestore());
      return lapangan;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin menambah lapangan.');
      }
      throw Exception('Gagal menambah lapangan. Coba lagi.');
    }
  }

  /// Perbarui lapangan milik mitra — PRD L-15, T-26.
  ///
  /// [lapangan] harus sudah membawa `lapanganId`, `pemilikId`, `isMitra`,
  /// `sumberData`, dan field rating APA ADANYA (tidak diubah form edit)
  /// — lihat cara `_FormLapanganBody` menyusunnya di `form_lapangan_screen.dart`.
  Future<void> perbaruiLapangan(LapanganModel lapangan) async {
    try {
      await _db
          .collection('lapangan')
          .doc(lapangan.lapanganId)
          .set(lapangan.toFirestore());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin mengubah lapangan ini.');
      }
      throw Exception('Gagal menyimpan perubahan lapangan. Coba lagi.');
    }
  }

  /// Mengambil satu lapangan — dipakai halaman Detail (L-06).
  Future<LapanganModel> ambilSatuLapangan(String lapanganId) async {
    try {
      final doc = await _db.collection('lapangan').doc(lapanganId).get();

      if (!doc.exists) {
        throw Exception('Lapangan tidak ditemukan.');
      }
      return LapanganModel.fromFirestore(doc);
    } on FirebaseException {
      throw Exception('Gagal memuat detail lapangan. Coba lagi.');
    }
  }
}
