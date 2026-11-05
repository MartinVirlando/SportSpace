import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/utils/pengingat_jadwal.dart';
import 'package:sport_space/models/booking_model.dart';

/// Uji otomatis untuk pengingat jadwal booking — T-67, PRD AB-23,
/// BB-91…BB-95.
BookingModel _b(
  String id, {
  String status = 'DIKONFIRMASI',
  String tanggal = '2026-11-27',
  String jamMulai = '19:00',
  String jamSelesai = '21:00',
  String nama = 'Candra Wijaya',
}) {
  return BookingModel(
    bookingId: id,
    userId: 'u1',
    namaUser: 'Pengguna',
    lapanganId: 'l1',
    namaLapangan: nama,
    pemilikId: 'm1',
    tanggal: tanggal,
    jamMulai: jamMulai,
    jamSelesai: jamSelesai,
    status: status,
    totalHarga: 100000,
    dibuatPada: DateTime(2026, 11, 1),
  );
}

void main() {
  // Sekarang = 27 Nov 2026 pukul 10:00; booking 19:00 → pengingat 18:00.
  final sekarang = DateTime(2026, 11, 27, 10);

  group('rencanakanPengingat — status', () {
    test('hanya booking DIKONFIRMASI yang diingatkan (BB-91)', () {
      final hasil = rencanakanPengingat(
        [
          _b('a', status: 'MENUNGGU'),
          _b('b', status: 'DIKONFIRMASI'),
          _b('c', status: 'DITOLAK'),
          _b('d', status: 'DIBATALKAN'),
          _b('e', status: 'SELESAI'),
        ],
        sekarang,
      );

      expect(hasil, hasLength(1));
      expect(hasil.single.id, idPengingatDari('b'));
    });

    test('daftar kosong menghasilkan daftar kosong', () {
      expect(rencanakanPengingat([], sekarang), isEmpty);
    });
  });

  group('rencanakanPengingat — waktu', () {
    test('pengingat muncul tepat 60 menit sebelum jam mulai', () {
      final hasil = rencanakanPengingat([_b('a')], sekarang);
      expect(hasil.single.waktuTampil, DateTime(2026, 11, 27, 18));
    });

    test('menitSebelum bisa diubah', () {
      final hasil = rencanakanPengingat([_b('a')], sekarang, menitSebelum: 30);
      expect(hasil.single.waktuTampil, DateTime(2026, 11, 27, 18, 30));
    });

    test('booking yang waktu pengingatnya sudah lewat dilewati (BB-92)', () {
      // 19:00 → pengingat 18:00, tetapi sekarang sudah 18:30.
      final hasil = rencanakanPengingat(
        [_b('a')],
        DateTime(2026, 11, 27, 18, 30),
      );
      expect(hasil, isEmpty);
    });

    test('tepat pada detik pengingat juga dilewati (tidak ada yang "sekarang")',
        () {
      final hasil = rencanakanPengingat([_b('a')], DateTime(2026, 11, 27, 18));
      expect(hasil, isEmpty);
    });

    test('satu detik sebelum waktu pengingat masih dijadwalkan', () {
      final hasil = rencanakanPengingat(
        [_b('a')],
        DateTime(2026, 11, 27, 17, 59, 59),
      );
      expect(hasil, hasLength(1));
    });

    test('booking tanggal lampau tidak diingatkan', () {
      final hasil = rencanakanPengingat(
        [_b('a', tanggal: '2026-10-01')],
        sekarang,
      );
      expect(hasil, isEmpty);
    });

    test(
        'booking pagi hari lewat tengah malam: pengingat jatuh di hari sebelumnya',
        () {
      // Main 00:30 tanggal 28 → pengingat 23:30 tanggal 27.
      final hasil = rencanakanPengingat(
        [_b('a', tanggal: '2026-11-28', jamMulai: '00:30')],
        sekarang,
      );
      expect(hasil.single.waktuTampil, DateTime(2026, 11, 27, 23, 30));
    });
  });

  group('rencanakanPengingat — isi dan urutan', () {
    test('lama dinyatakan "menit" bila bukan kelipatan 60', () {
      final hasil = rencanakanPengingat(
        [_b('a')],
        sekarang,
        menitSebelum: 30,
      );
      expect(hasil.single.isi, contains('sekitar 30 menit'));
    });

    test('isi notifikasi memuat nama lapangan, jam, dan lama', () {
      final hasil = rencanakanPengingat([_b('a', nama: 'Hey Beach')], sekarang);
      expect(hasil.single.judul, isNotEmpty);
      expect(hasil.single.isi, contains('Hey Beach'));
      expect(hasil.single.isi, contains('19:00'));
      expect(hasil.single.isi, contains('21:00'));
      expect(hasil.single.isi, contains('sekitar 1 jam'));
    });

    test('diurutkan dari yang paling dekat', () {
      final hasil = rencanakanPengingat([
        _b('jauh', tanggal: '2026-11-30'),
        _b('dekat', jamMulai: '15:00', jamSelesai: '16:00'),
        _b('tengah', tanggal: '2026-11-28'),
      ],
        sekarang,
      );

      expect(
        hasil.map((p) => p.id).toList(),
        [
          idPengingatDari('dekat'),
          idPengingatDari('tengah'),
          idPengingatDari('jauh'),
        ],
      );
    });

    test('dipotong sampai batasPengingat, yang terdekat dipertahankan (BB-93)',
        () {
      final banyak = [
        for (var i = 0; i < 30; i++)
          _b('b$i', tanggal: '2026-12-${(i + 1).toString().padLeft(2, '0')}'),
      ];
      final hasil = rencanakanPengingat(banyak, sekarang);

      expect(hasil, hasLength(batasPengingat));
      expect(hasil.first.id, idPengingatDari('b0'));
      expect(hasil.last.id, idPengingatDari('b${batasPengingat - 1}'));
    });

    test('batas bisa diubah lewat parameter', () {
      final hasil = rencanakanPengingat(
        [
          _b('a'),
          _b('b', tanggal: '2026-11-28'),
          _b('c', tanggal: '2026-11-29'),
        ],
        sekarang,
        batas: 2,
      );
      expect(hasil, hasLength(2));
    });
  });

  group('rencanakanPengingat — data rusak', () {
    test(
        'tanggal atau jam yang tidak terbaca dilewati tanpa menggagalkan yang lain',
        () {
      final hasil = rencanakanPengingat(
        [
          _b('rusak1', tanggal: ''),
          _b('rusak2', jamMulai: ''),
          _b('rusak3', tanggal: '27/11/2026'),
          _b('rusak4', jamMulai: 'sore'),
          _b('rusak5', tanggal: '2026-11'),
          _b('baik'),
        ],
        sekarang,
      );

      expect(hasil, hasLength(1));
      expect(hasil.single.id, idPengingatDari('baik'));
    });
  });

  group('idPengingatDari', () {
    test('stabil: bookingId yang sama selalu menghasilkan ID yang sama', () {
      expect(idPengingatDari('abc123'), idPengingatDari('abc123'));
    });

    test('bookingId berbeda menghasilkan ID berbeda', () {
      final ids = {
        for (var i = 0; i < 200; i++) idPengingatDari('booking_$i'),
      };
      expect(ids, hasLength(200));
    });

    test('selalu tidak negatif dan muat di 31 bit (ID notifikasi Android)', () {
      for (final teks in [
        '',
        'a',
        'booking_1',
        'x' * 500,
        'Candra_2026-11-27_19',
      ]) {
        final id = idPengingatDari(teks);
        expect(id, greaterThanOrEqualTo(0));
        expect(id, lessThanOrEqualTo(0x7fffffff));
      }
    });

    test('nilai acuan tetap (FNV-1a) — mencegah ID berubah diam-diam', () {
      // Nilai dihitung dari algoritma FNV-1a 32-bit; jika berubah, pengingat
      // lama di HP pengguna tidak akan tertimpa saat aplikasi diperbarui.
      expect(idPengingatDari(''), 0x811c9dc5 & 0x7fffffff);
      expect(idPengingatDari('a'), 0xe40c292c & 0x7fffffff);
    });
  });
}
