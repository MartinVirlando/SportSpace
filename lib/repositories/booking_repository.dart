import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_model.dart';
import '../models/notifikasi_model.dart';

/// Satu-satunya lapisan yang boleh menyentuh Firestore untuk data booking.
///
/// ATURAN LAPISAN (CLAUDE.md): View dan ViewModel TIDAK BOLEH
/// `import cloud_firestore`. Semua akses data lewat kelas ini.
class BookingRepository {
  final FirebaseFirestore _db;

  BookingRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Ajukan reservasi — PRD AB-04, T-23, BB-24/BB-25.
  ///
  /// **Jebakan Firestore Transaction (CLAUDE.md):** `transaction.get()`
  /// hanya menerima `DocumentReference`, tidak bisa Query. Jadi "cek
  /// bentrok lalu tulis" tidak bisa dibuat atomik lewat kueri. Dipakai
  /// pola kunci slot dengan ID dokumen deterministik
  /// `slotBooking/{lapanganId}_{tanggal}_{jam}` — dua pengguna yang
  /// menekan tombol bersamaan untuk jam yang sama tidak bisa sama-sama
  /// lolos, karena `transaction.get()` pada dokumen yang sama akan
  /// membuat salah satunya retry/gagal.
  ///
  /// [jamMulai] dan [jamSelesai] format "HH:mm". Slot jam dipecah per
  /// jam genap, mis. 19:00–21:00 → jam [19, 20], sesuai contoh PRD AB-04.
  Future<BookingModel> ajukanReservasi({
    required String lapanganId,
    required String namaLapangan,
    required String pemilikId,
    required String userId,
    required String namaUser,
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
    required int totalHarga,
  }) async {
    final jamAwal = int.parse(jamMulai.split(':')[0]);
    final jamAkhir = int.parse(jamSelesai.split(':')[0]);
    final daftarJam = [for (var jam = jamAwal; jam < jamAkhir; jam++) jam];

    final bookingRef = _db.collection('booking').doc();
    final notifRef = _db.collection('notifikasi').doc();
    final slotRefs = {
      for (final jam in daftarJam)
        jam: _db
            .collection('slotBooking')
            .doc('${lapanganId}_${tanggal}_$jam'),
    };

    final booking = BookingModel(
      bookingId: bookingRef.id,
      userId: userId,
      namaUser: namaUser,
      lapanganId: lapanganId,
      namaLapangan: namaLapangan,
      pemilikId: pemilikId,
      tanggal: tanggal,
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
      status: 'MENUNGGU',
      totalHarga: totalHarga,
      dibuatPada: DateTime.now(),
    );

    try {
      await _db.runTransaction((transaction) async {
        // Cek seluruh jam dulu sebelum menulis apa pun — kalau satu saja
        // bentrok, seluruh reservasi dibatalkan (bukan sebagian jam).
        for (final ref in slotRefs.values) {
          final snap = await transaction.get(ref);
          if (snap.exists) {
            throw Exception('Slot sudah dipesan');
          }
        }

        transaction.set(bookingRef, booking.toFirestore());
        for (final entry in slotRefs.entries) {
          transaction.set(entry.value, {
            'bookingId': bookingRef.id,
            'lapanganId': lapanganId,
            'tanggal': tanggal,
            'jam': entry.key,
          });
        }
        transaction.set(
          notifRef,
          NotifikasiModel(
            notifikasiId: notifRef.id,
            untukUserId: pemilikId,
            tipe: 'BOOKING_BARU',
            judul: 'Reservasi baru',
            pesan: '$namaUser mengajukan reservasi "$namaLapangan".',
            refId: bookingRef.id,
            dibuatPada: DateTime.now(),
          ).toFirestore(),
        );
      });
      return booking;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin mengajukan reservasi.');
      }
      throw Exception('Gagal mengajukan reservasi. Coba lagi.');
    }
  }

  /// Stream booking masuk milik satu mitra — PRD L-14, T-25.
  ///
  /// `Stream`, bukan `Future` (CLAUDE.md aturan 6): daftar ini perlu
  /// langsung hidup, sama seperti `streamPermintaan` di
  /// `aktivitas_repository.dart` — booking baru (BB-24) harus muncul di
  /// Dashboard Mitra tanpa mitra menarik untuk menyegarkan.
  ///
  /// Index #8 — (pemilikId ASC, dibuatPada DESC).
  Stream<List<BookingModel>> streamBookingMasuk(String pemilikId) {
    return _db
        .collection('booking')
        .where('pemilikId', isEqualTo: pemilikId)
        .orderBy('dibuatPada', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca booking masuk.');
      }
      throw Exception('Gagal memuat booking masuk. Coba lagi.');
    });
  }

  /// Mitra mengonfirmasi booking — PRD L-14, T-25, BB-26.
  ///
  /// Cukup `WriteBatch`, bukan transaction: tidak ada penghitung bersama
  /// yang dibaca-lalu-ditulis di sini (beda dari [ajukanReservasi]) —
  /// sama alasannya dengan `terimaPermintaan` vs `tolakPermintaan` di
  /// `aktivitas_repository.dart`.
  Future<void> konfirmasiBooking(BookingModel booking) async {
    try {
      final bookingRef = _db.collection('booking').doc(booking.bookingId);
      final notifRef = _db.collection('notifikasi').doc();

      final batch = _db.batch();
      batch.update(bookingRef, {'status': 'DIKONFIRMASI'});
      batch.set(
        notifRef,
        NotifikasiModel(
          notifikasiId: notifRef.id,
          untukUserId: booking.userId,
          tipe: 'BOOKING_DIKONFIRMASI',
          judul: 'Reservasi dikonfirmasi',
          pesan: 'Reservasimu di "${booking.namaLapangan}" dikonfirmasi.',
          refId: booking.bookingId,
          dibuatPada: DateTime.now(),
        ).toFirestore(),
      );
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin mengonfirmasi booking.');
      }
      throw Exception('Gagal mengonfirmasi booking. Coba lagi.');
    }
  }

  /// Mitra menolak booking — PRD L-14, T-25, BB-27.
  ///
  /// Menghapus seluruh dokumen `slotBooking` milik booking ini supaya
  /// slotnya terbuka lagi (PRD AB-04) — ID-nya dihitung ulang dari
  /// `jamMulai`/`jamSelesai` dengan pola deterministik yang sama seperti
  /// [ajukanReservasi], BUKAN query, jadi aman digabung dalam satu batch.
  Future<void> tolakBooking(BookingModel booking) async {
    try {
      final jamAwal = int.parse(booking.jamMulai.split(':')[0]);
      final jamAkhir = int.parse(booking.jamSelesai.split(':')[0]);

      final bookingRef = _db.collection('booking').doc(booking.bookingId);
      final notifRef = _db.collection('notifikasi').doc();

      final batch = _db.batch();
      batch.update(bookingRef, {'status': 'DITOLAK'});
      for (var jam = jamAwal; jam < jamAkhir; jam++) {
        batch.delete(
          _db
              .collection('slotBooking')
              .doc('${booking.lapanganId}_${booking.tanggal}_$jam'),
        );
      }
      batch.set(
        notifRef,
        NotifikasiModel(
          notifikasiId: notifRef.id,
          untukUserId: booking.userId,
          tipe: 'BOOKING_DITOLAK',
          judul: 'Reservasi ditolak',
          pesan: 'Reservasimu di "${booking.namaLapangan}" ditolak.',
          refId: booking.bookingId,
          dibuatPada: DateTime.now(),
        ).toFirestore(),
      );
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin menolak booking.');
      }
      throw Exception('Gagal menolak booking. Coba lagi.');
    }
  }

  /// Stream riwayat booking milik satu pengguna — PRD L-13, T-27, BB-28.
  ///
  /// `Stream`, bukan `Future`: sama alasannya dengan [streamBookingMasuk]
  /// — riwayat pemesanan perlu langsung hidup, termasuk begitu status
  /// berubah jadi `SELESAI` lewat [tandaiBookingSelesai] (AB-07).
  ///
  /// Index #7 — (userId ASC, dibuatPada DESC).
  Stream<List<BookingModel>> streamRiwayatBooking(String userId) {
    return _db
        .collection('booking')
        .where('userId', isEqualTo: userId)
        .orderBy('dibuatPada', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList(),
        )
        .handleError((Object error) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca riwayat pemesanan.');
      }
      throw Exception('Gagal memuat riwayat pemesanan. Coba lagi.');
    });
  }

  /// Tandai booking `SELESAI` — PRD AB-07, T-27, BB-28.
  ///
  /// Tidak ada Cloud Functions, jadi transisi status ini dihitung di
  /// klien (ProfilViewModel membandingkan `tanggal`+`jamSelesai` dengan
  /// waktu sekarang) lalu ditulis balik lewat method ini. Cukup `update`
  /// biasa — bukan transaction, karena tidak ada penghitung bersama.
  Future<void> tandaiBookingSelesai(String bookingId) async {
    try {
      await _db
          .collection('booking')
          .doc(bookingId)
          .update({'status': 'SELESAI'});
    } on FirebaseException {
      // Diam-diam gagal: ini penulisan latar belakang yang dipicu saat
      // memuat daftar (AB-07), bukan aksi yang ditekan pengguna — tidak
      // ada tombol yang perlu menampilkan pesan kesalahan untuk ini.
      // Tampilan tetap benar karena [ProfilViewModel.statusTampilan]
      // menghitung ulang dari tanggal/jam, bukan dari field `status`.
    }
  }

  /// Ambil jam yang sudah terisi untuk satu lapangan pada satu tanggal —
  /// PRD L-10, dipakai mulai T-24 untuk menandai chip jam "Penuh".
  ///
  /// Index #10 — (lapanganId ASC, tanggal ASC, jam ASC). Sekali ambil
  /// (bukan Stream): dipanggil saat form dibuka atau tanggal diganti,
  /// bukan daftar yang perlu tetap hidup seperti notifikasi. Query baca
  /// ini terpisah dari transaction di [ajukanReservasi] — lihat catatan
  /// "Jebakan" di sana, transaction tidak boleh dicampur dengan Query.
  Future<Set<int>> ambilSlotTerisi({
    required String lapanganId,
    required String tanggal,
  }) async {
    try {
      final snap = await _db
          .collection('slotBooking')
          .where('lapanganId', isEqualTo: lapanganId)
          .where('tanggal', isEqualTo: tanggal)
          .orderBy('jam')
          .get();
      return snap.docs.map((d) => (d['jam'] as num).toInt()).toSet();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca slot booking.');
      }
      throw Exception('Gagal memuat slot booking. Coba lagi.');
    }
  }
}
