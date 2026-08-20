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
