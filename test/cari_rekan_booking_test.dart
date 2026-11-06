import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/constants/app_sports.dart';
import 'package:sport_space/core/utils/cari_rekan_booking.dart';
import 'package:sport_space/core/utils/waktu_booking.dart';
import 'package:sport_space/models/booking_model.dart';

/// Uji otomatis untuk "Cari rekan dari booking" — T-69, PRD AB-25,
/// BB-101 dan BB-102.
BookingModel _b({
  String status = 'DIKONFIRMASI',
  String tanggal = '2026-11-27',
  String jamMulai = '19:00',
  String lapanganId = 'lap1',
  String nama = 'Candra Wijaya',
}) {
  return BookingModel(
    bookingId: 'b1',
    userId: 'u1',
    namaUser: 'Pengguna',
    lapanganId: lapanganId,
    namaLapangan: nama,
    pemilikId: 'm1',
    tanggal: tanggal,
    jamMulai: jamMulai,
    jamSelesai: '21:00',
    status: status,
    totalHarga: 100000,
    dibuatPada: DateTime(2026, 11, 1),
  );
}

void main() {
  group('waktuMulaiBooking', () {
    test('menggabungkan tanggal dan jam mulai', () {
      expect(waktuMulaiBooking(_b()), DateTime(2026, 11, 27, 19));
      expect(
        waktuMulaiBooking(_b(tanggal: '2026-01-05', jamMulai: '06:30')),
        DateTime(2026, 1, 5, 6, 30),
      );
    });

    test('jam 00:00 (tengah malam) terbaca', () {
      expect(
        waktuMulaiBooking(_b(jamMulai: '00:00')),
        DateTime(2026, 11, 27),
      );
    });

    test('format rusak menghasilkan null, bukan galat', () {
      for (final tanggal in ['', '2026-11', '27/11/2026', 'besok', '2026-aa-27']) {
        expect(waktuMulaiBooking(_b(tanggal: tanggal)), isNull, reason: tanggal);
      }
      for (final jam in ['', '19', '19.00', 'sore', '19:aa']) {
        expect(waktuMulaiBooking(_b(jamMulai: jam)), isNull, reason: jam);
      }
    });
  });

  group('bolehCariRekan (BB-101)', () {
    // Sekarang = 27 Nov 2026 pukul 10:00; booking 19:00 masih di depan.
    final sekarang = DateTime(2026, 11, 27, 10);

    test('booking DIKONFIRMASI yang belum mulai: boleh', () {
      expect(bolehCariRekan(_b(), sekarang), isTrue);
    });

    test('status lain tidak boleh', () {
      for (final status in ['MENUNGGU', 'DITOLAK', 'DIBATALKAN', 'SELESAI']) {
        expect(bolehCariRekan(_b(status: status), sekarang), isFalse, reason: status);
      }
    });

    test('sudah lewat jam mulai: tidak boleh', () {
      expect(
        bolehCariRekan(_b(), DateTime(2026, 11, 27, 19, 30)),
        isFalse,
      );
      expect(bolehCariRekan(_b(tanggal: '2026-10-01'), sekarang), isFalse);
    });

    test('tepat pada jam mulai dianggap sudah mulai', () {
      expect(bolehCariRekan(_b(), DateTime(2026, 11, 27, 19)), isFalse);
    });

    test('satu menit sebelum mulai masih boleh', () {
      expect(bolehCariRekan(_b(), DateTime(2026, 11, 27, 18, 59)), isTrue);
    });

    test('jam mulai tidak terbaca: tidak boleh (tanpa galat)', () {
      expect(bolehCariRekan(_b(jamMulai: 'sore'), sekarang), isFalse);
      expect(bolehCariRekan(_b(tanggal: ''), sekarang), isFalse);
    });
  });

  group('isianAwalDariBooking (BB-102)', () {
    test('lapangan, tanggal, dan jam diturunkan dari booking', () {
      final isian = isianAwalDariBooking(
        _b(lapanganId: 'lapX', nama: 'Hey Beach', jamMulai: '20:30'),
        jenisOlahragaLapangan: const ['padel'],
      )!;

      expect(isian.lapanganId, 'lapX');
      expect(isian.namaLapangan, 'Hey Beach');
      expect(isian.tanggal, DateTime(2026, 11, 27));
      expect(isian.jam, 20);
      expect(isian.menit, 30);
      expect(isian.olahraga, AppSports.padel);
    });

    test('olahraga yang dipilih = yang PERTAMA didukung di daftar lapangan', () {
      final isian = isianAwalDariBooking(
        _b(),
        jenisOlahragaLapangan: const [AppSports.badminton, AppSports.padel],
      )!;
      expect(isian.olahraga, AppSports.badminton);
    });

    test('kode tidak dikenal dilewati, yang didukung berikutnya dipakai', () {
      final isian = isianAwalDariBooking(
        _b(),
        jenisOlahragaLapangan: const ['basket', 'voli', AppSports.miniSoccer],
      )!;
      expect(isian.olahraga, AppSports.miniSoccer);
    });

    test('tanpa olahraga yang didukung: olahraga null (form pakai bawaannya)', () {
      expect(
        isianAwalDariBooking(_b(), jenisOlahragaLapangan: const ['basket'])!
            .olahraga,
        isNull,
      );
      expect(isianAwalDariBooking(_b())!.olahraga, isNull);
    });

    test('keempat cabang yang didukung semuanya dikenali', () {
      for (final kode in [
        AppSports.futsal,
        AppSports.miniSoccer,
        AppSports.badminton,
        AppSports.padel,
      ]) {
        expect(
          isianAwalDariBooking(_b(), jenisOlahragaLapangan: [kode])!.olahraga,
          kode,
        );
      }
    });

    test('jam mulai tidak terbaca: null', () {
      expect(isianAwalDariBooking(_b(jamMulai: 'sore')), isNull);
      expect(isianAwalDariBooking(_b(tanggal: '')), isNull);
    });

    test('tanggal hanya memuat hari (jam 00:00), jam di field terpisah', () {
      final isian = isianAwalDariBooking(_b(jamMulai: '19:45'))!;
      expect(isian.tanggal.hour, 0);
      expect(isian.tanggal.minute, 0);
      expect(isian.jam, 19);
      expect(isian.menit, 45);
    });
  });
}
