import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_slot.dart';
import '../core/utils/formatter.dart';
import '../core/utils/produk_tambahan.dart';
import '../core/utils/status_booking.dart';
import '../core/utils/ubah_jadwal.dart';
import '../models/booking_model.dart';
import '../models/notifikasi_model.dart';
import '../models/produk_tambahan_model.dart';

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
    List<ProdukPesananModel> produkTambahan = const [],
  }) async {
    // Pengaman kedua (PRD AB-19): form L-10 hanya menawarkan jumlah 0–10,
    // tapi produk yang dikirim pemanggil lain tetap diperiksa di sini.
    final pesanProduk = periksaPesananProduk(produkTambahan);
    if (pesanProduk != null) throw Exception(pesanProduk);

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
      produkTambahan: produkTambahan,
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
  /// Transaction (bukan `WriteBatch` biasa) supaya idempoten: status
  /// booking dibaca dulu dan hanya diproses kalau masih `MENUNGGU`. Tanpa
  /// ini, dua tap cepat "Konfirmasi"/"Tolak" pada booking yang sama bisa
  /// sama-sama lolos (UI menonaktifkan tombol lewat `setState`, yang
  /// tidak langsung merender ulang pada frame yang sama) — mengirim dua
  /// notifikasi, atau (kasus Tolak) menghapus `slotBooking` padahal
  /// booking sudah `DIKONFIRMASI`.
  Future<void> konfirmasiBooking(BookingModel booking) async {
    try {
      final bookingRef = _db.collection('booking').doc(booking.bookingId);
      final notifRef = _db.collection('notifikasi').doc();

      await _db.runTransaction((transaction) async {
        final snap = await transaction.get(bookingRef);
        if (!snap.exists) {
          throw Exception('Booking tidak ditemukan.');
        }
        if (snap.data()?['status'] != 'MENUNGGU') {
          throw Exception('Booking ini sudah diproses.');
        }

        transaction.update(bookingRef, {'status': 'DIKONFIRMASI'});
        transaction.set(
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
      });
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
  /// [ajukanReservasi], BUKAN query, jadi aman dibaca-tulis dalam satu
  /// transaction. Transaction (bukan `WriteBatch`) untuk alasan idempotensi
  /// yang sama dengan [konfirmasiBooking] — lihat catatannya.
  Future<void> tolakBooking(BookingModel booking) async {
    try {
      final jamAwal = int.parse(booking.jamMulai.split(':')[0]);
      final jamAkhir = int.parse(booking.jamSelesai.split(':')[0]);

      final bookingRef = _db.collection('booking').doc(booking.bookingId);
      final notifRef = _db.collection('notifikasi').doc();

      await _db.runTransaction((transaction) async {
        final snap = await transaction.get(bookingRef);
        if (!snap.exists) {
          throw Exception('Booking tidak ditemukan.');
        }
        if (snap.data()?['status'] != 'MENUNGGU') {
          throw Exception('Booking ini sudah diproses.');
        }

        transaction.update(bookingRef, {'status': 'DITOLAK'});
        for (var jam = jamAwal; jam < jamAkhir; jam++) {
          transaction.delete(
            _db
                .collection('slotBooking')
                .doc('${booking.lapanganId}_${booking.tanggal}_$jam'),
          );
        }
        transaction.set(
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
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin menolak booking.');
      }
      throw Exception('Gagal menolak booking. Coba lagi.');
    }
  }

  /// Pengguna membatalkan booking miliknya — PRD AB-04 lanjutan, T-46.
  ///
  /// Kebalikan dari [tolakBooking] tapi dipicu pengguna, bukan mitra: sama
  /// polanya (transaction baca-status-dulu untuk idempotensi, hapus
  /// `slotBooking` dengan ID deterministik supaya slotnya terbuka lagi).
  /// Hanya bisa dibatalkan dari status `MENUNGGU`/`DIKONFIRMASI` dan
  /// sebelum jam selesainya lewat — booking yang sudah `DITOLAK`/`SELESAI`/
  /// `DIBATALKAN` ditolak di sini juga (bukan cuma disembunyikan View).
  Future<void> batalkanBooking(BookingModel booking) async {
    try {
      final jamAwal = int.parse(booking.jamMulai.split(':')[0]);
      final jamAkhir = int.parse(booking.jamSelesai.split(':')[0]);

      final bookingRef = _db.collection('booking').doc(booking.bookingId);
      final notifRef = _db.collection('notifikasi').doc();

      await _db.runTransaction((transaction) async {
        final snap = await transaction.get(bookingRef);
        if (!snap.exists) {
          throw Exception('Booking tidak ditemukan.');
        }
        final status = snap.data()?['status'] as String?;
        if (status != 'MENUNGGU' && status != 'DIKONFIRMASI') {
          throw Exception('Booking ini tidak bisa dibatalkan.');
        }
        if (sudahLewatJamSelesai(booking)) {
          throw Exception('Booking ini sudah lewat jam selesainya.');
        }

        transaction.update(bookingRef, {'status': 'DIBATALKAN'});
        for (var jam = jamAwal; jam < jamAkhir; jam++) {
          transaction.delete(
            _db
                .collection('slotBooking')
                .doc('${booking.lapanganId}_${booking.tanggal}_$jam'),
          );
        }
        transaction.set(
          notifRef,
          NotifikasiModel(
            notifikasiId: notifRef.id,
            untukUserId: booking.pemilikId,
            tipe: 'BOOKING_DIBATALKAN',
            judul: 'Reservasi dibatalkan',
            pesan:
                '${booking.namaUser} membatalkan reservasi di "${booking.namaLapangan}".',
            refId: booking.bookingId,
            dibuatPada: DateTime.now(),
          ).toFirestore(),
        );
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin membatalkan booking.');
      }
      throw Exception('Gagal membatalkan booking. Coba lagi.');
    }
  }

  /// Pengguna mengubah jadwal booking miliknya — PRD AB-20, v1.5 (T-62),
  /// BB-76, BB-77, BB-78.
  ///
  /// SATU transaction: slot lama dilepas, slot baru dikunci, booking
  /// diperbarui, dan mitra diberi tahu — semuanya atau tidak sama sekali.
  /// Kalau jadwal baru bentrok (BB-77), jadwal dan slot lama tidak berubah
  /// sedikit pun.
  ///
  /// **Jebakan transaction (CLAUDE.md #1):** `transaction.get()` hanya
  /// menerima `DocumentReference`, bukan Query, dan seluruh pembacaan harus
  /// SEBELUM penulisan pertama. Karena itu kunci slot ber-ID deterministik
  /// `{lapanganId}_{tanggal}_{jam}` dipakai lagi (sama seperti
  /// [ajukanReservasi]), dan selisih slot lama-baru dihitung oleh fungsi
  /// murni `rencanaUbahSlot` (`core/utils/ubah_jadwal.dart`).
  ///
  /// Jadwal LAMA dibaca dari dokumen booking di dalam transaction, bukan dari
  /// [booking] yang dioper View — View bisa memegang salinan basi (mis.
  /// mitra baru saja menolak booking ini). [booking] hanya dipakai untuk ID
  /// dan nama.
  ///
  /// Status kembali `MENUNGGU`: mitra mengonfirmasi jadwal lama, bukan yang
  /// baru, jadi harus mengonfirmasi ulang. Mitra menerima notifikasi
  /// `BOOKING_DIJADWALKAN_ULANG`.
  ///
  /// [totalHargaBaru] dihitung pemanggil (harga dan diskon lapangan saat ini,
  /// ditambah produk tambahan booking yang sama — AB-18/AB-19).
  Future<void> ubahJadwalBooking({
    required BookingModel booking,
    required String userId,
    required String tanggalBaru,
    required String jamMulaiBaru,
    required String jamSelesaiBaru,
    required int totalHargaBaru,
  }) async {
    final bookingRef = _db.collection('booking').doc(booking.bookingId);
    final notifRef = _db.collection('notifikasi').doc();

    DocumentReference slotRef(KunciSlot k) => _db
        .collection('slotBooking')
        .doc('${booking.lapanganId}_${k.tanggal}_${k.jam}');

    try {
      await _db.runTransaction((transaction) async {
        // ---- BACA (seluruhnya sebelum penulisan pertama) ----
        final bookingSnap = await transaction.get(bookingRef);
        if (!bookingSnap.exists) {
          throw Exception('Booking tidak ditemukan.');
        }
        final lama = BookingModel.fromFirestore(bookingSnap);

        if (lama.userId != userId) {
          throw Exception('Ini bukan booking milikmu.');
        }
        if (lama.status != 'MENUNGGU' && lama.status != 'DIKONFIRMASI') {
          throw Exception('Booking ini tidak bisa diubah jadwalnya.');
        }
        if (sudahLewatJamSelesai(lama)) {
          throw Exception('Booking ini sudah lewat jam selesainya.');
        }

        final mulaiBaru = _waktuBooking(tanggalBaru, jamMulaiBaru);
        if (!mulaiBaru.isAfter(DateTime.now())) {
          throw Exception('Jadwal baru harus di masa depan.');
        }

        final rencana = rencanaUbahSlot(
          lama: kunciSlotBooking(
            tanggal: lama.tanggal,
            jamMulai: lama.jamMulai,
            jamSelesai: lama.jamSelesai,
          ),
          baru: kunciSlotBooking(
            tanggal: tanggalBaru,
            jamMulai: jamMulaiBaru,
            jamSelesai: jamSelesaiBaru,
          ),
        );
        if (rencana.tidakBerubah) {
          throw Exception('Jadwal tidak berubah.');
        }

        // Slot baru (yang belum milik booking ini) tidak boleh sudah ada.
        for (final k in rencana.dibuat) {
          final snap = await transaction.get(slotRef(k));
          if (snap.exists) {
            throw Exception('Slot sudah dipesan');
          }
        }

        // Slot lama hanya dihapus kalau memang milik booking ini — jangan
        // pernah menghapus slot orang lain walau datanya ganjil.
        final hapus = <KunciSlot>[];
        for (final k in rencana.dihapus) {
          final snap = await transaction.get(slotRef(k));
          final data = snap.data() as Map<String, dynamic>?;
          if (snap.exists && data?['bookingId'] == booking.bookingId) {
            hapus.add(k);
          }
        }

        // ---- TULIS ----
        for (final k in hapus) {
          transaction.delete(slotRef(k));
        }
        for (final k in rencana.dibuat) {
          transaction.set(slotRef(k), {
            'bookingId': booking.bookingId,
            'lapanganId': booking.lapanganId,
            'tanggal': k.tanggal,
            'jam': k.jam,
          });
        }
        transaction.update(bookingRef, {
          'tanggal': tanggalBaru,
          'jamMulai': jamMulaiBaru,
          'jamSelesai': jamSelesaiBaru,
          'totalHarga': totalHargaBaru,
          'status': 'MENUNGGU',
        });
        transaction.set(
          notifRef,
          NotifikasiModel(
            notifikasiId: notifRef.id,
            untukUserId: lama.pemilikId,
            tipe: 'BOOKING_DIJADWALKAN_ULANG',
            judul: 'Jadwal reservasi diubah',
            pesan: '${lama.namaUser} mengubah jadwal reservasi '
                '"${lama.namaLapangan}" menjadi '
                '${Formatter.tanggalDariTeks(tanggalBaru)} '
                '$jamMulaiBaru–$jamSelesaiBaru. Mohon konfirmasi ulang.',
            refId: booking.bookingId,
            dibuatPada: DateTime.now(),
          ).toFirestore(),
        );
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin mengubah jadwal booking.');
      }
      throw Exception('Gagal mengubah jadwal booking. Coba lagi.');
    }
  }

  /// "yyyy-MM-dd" + "HH:mm" → [DateTime]. Jam 24 ke atas (tutup tengah
  /// malam) menggulung ke hari berikutnya, seperti di `status_booking.dart`.
  DateTime _waktuBooking(String tanggal, String jam) {
    final t = tanggal.split('-').map(int.parse).toList();
    final j = jam.split(':').map(int.parse).toList();
    return DateTime(t[0], t[1], t[2], j[0], j[1]);
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
  ///
  /// [abaikanBookingId] (v1.5, T-62): slot milik booking ini tidak ikut
  /// dihitung "terisi". Dipakai mode Ubah Jadwal di L-10, supaya jam milik
  /// booking itu sendiri tidak tampil "Penuh" dan bisa dipilih lagi.
  Future<Set<int>> ambilSlotTerisi({
    required String lapanganId,
    required String tanggal,
    String? abaikanBookingId,
  }) async {
    final slot = await ambilSlotLapangan(
      lapanganId: lapanganId,
      tanggal: tanggal,
    );
    return {
      for (final entry in slot.entries)
        if (entry.value != abaikanBookingId) entry.key,
    };
  }

  /// Sama dengan [ambilSlotTerisi], tapi mengembalikan juga `bookingId`
  /// tiap slot (jam → bookingId) — v1.5 (T-59). Layar Atur Slot (L-19)
  /// membutuhkannya untuk membedakan jam yang DIBLOKIR mitra
  /// (`AppSlot.bookingIdBlokir`) dari jam yang DIPESAN pengguna.
  ///
  /// Query dan index-nya sama persis dengan yang lama (index #10), jadi
  /// tidak ada index baru. [ambilSlotTerisi] sekarang memanggil ini supaya
  /// query-nya hanya ada di satu tempat.
  Future<Map<int, String>> ambilSlotLapangan({
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
      return {
        for (final d in snap.docs)
          (d['jam'] as num).toInt(): (d.data()['bookingId'] as String?) ?? '',
      };
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin membaca slot booking.');
      }
      throw Exception('Gagal memuat slot booking. Coba lagi.');
    }
  }

  /// Mitra memblokir satu jam — PRD AB-17, v1.5 (T-59), BB-67.
  ///
  /// Memakai dokumen `slotBooking` ber-ID deterministik yang SAMA dengan slot
  /// booking biasa (`{lapanganId}_{tanggal}_{jam}`), jadi pengguna melihatnya
  /// sebagai jam "Penuh" dan [ajukanReservasi] otomatis menolaknya, tanpa
  /// kode tambahan di sana.
  ///
  /// Transaction: dokumen slot dibaca dulu, dan kalau sudah ada (diblokir
  /// atau dipesan) ditolak — dua mitra/perangkat yang menekan bersamaan, atau
  /// pengguna yang baru saja memesan jam itu, tidak bisa saling menimpa.
  /// Semua `transaction.get()` di sini pada `DocumentReference`, bukan
  /// Query (jebakan #1 di CLAUDE.md).
  ///
  /// Lapangan dibaca juga untuk memastikan [mitraId] adalah `pemilikId`-nya.
  /// Security Rules `slotBooking` mengizinkan semua pengguna login menulis
  /// (§9), jadi pemeriksaan kepemilikan ini ditegakkan di sini.
  Future<void> blokirSlot({
    required String lapanganId,
    required String tanggal,
    required int jam,
    required String mitraId,
  }) async {
    final lapanganRef = _db.collection('lapangan').doc(lapanganId);
    final slotRef =
        _db.collection('slotBooking').doc('${lapanganId}_${tanggal}_$jam');

    try {
      await _db.runTransaction((transaction) async {
        final lapanganSnap = await transaction.get(lapanganRef);
        _pastikanPemilik(lapanganSnap, mitraId);

        final slotSnap = await transaction.get(slotRef);
        if (slotSnap.exists) {
          throw Exception('Slot sudah terisi.');
        }

        transaction.set(slotRef, {
          'bookingId': AppSlot.bookingIdBlokir,
          'lapanganId': lapanganId,
          'tanggal': tanggal,
          'jam': jam,
          'diblokirOleh': mitraId,
        });
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin memblokir slot.');
      }
      throw Exception('Gagal memblokir slot. Coba lagi.');
    }
  }

  /// Mitra membuka blokir satu jam — PRD AB-17, v1.5 (T-59), BB-68, BB-69.
  ///
  /// HANYA menghapus dokumen yang `bookingId`-nya `AppSlot.bookingIdBlokir`.
  /// Slot milik booking sungguhan tidak pernah boleh dihapus dari sini —
  /// menghapusnya akan membuka jam yang masih punya pemesan dan memungkinkan
  /// double booking, yang justru dicegah AB-04.
  ///
  /// Idempoten: slot yang sudah tidak ada (mis. sudah dibuka dari perangkat
  /// lain) dianggap berhasil, bukan galat.
  Future<void> bukaBlokir({
    required String lapanganId,
    required String tanggal,
    required int jam,
    required String mitraId,
  }) async {
    final lapanganRef = _db.collection('lapangan').doc(lapanganId);
    final slotRef =
        _db.collection('slotBooking').doc('${lapanganId}_${tanggal}_$jam');

    try {
      await _db.runTransaction((transaction) async {
        final lapanganSnap = await transaction.get(lapanganRef);
        _pastikanPemilik(lapanganSnap, mitraId);

        final slotSnap = await transaction.get(slotRef);
        if (!slotSnap.exists) return;

        if (slotSnap.data()?['bookingId'] != AppSlot.bookingIdBlokir) {
          throw Exception('Slot ini dipesan pengguna, tidak bisa dibuka.');
        }

        transaction.delete(slotRef);
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Tidak punya izin membuka blokir slot.');
      }
      throw Exception('Gagal membuka blokir slot. Coba lagi.');
    }
  }

  /// Pastikan [lapanganSnap] ada dan `pemilikId`-nya [mitraId].
  void _pastikanPemilik(DocumentSnapshot lapanganSnap, String mitraId) {
    if (!lapanganSnap.exists) {
      throw Exception('Lapangan tidak ditemukan.');
    }
    final data = lapanganSnap.data() as Map<String, dynamic>?;
    if (data?['pemilikId'] != mitraId) {
      throw Exception('Ini bukan lapangan milikmu.');
    }
  }
}
