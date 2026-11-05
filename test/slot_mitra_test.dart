import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/constants/app_slot.dart';
import 'package:sport_space/core/utils/slot_mitra.dart';

/// Uji otomatis untuk BB-67, BB-68, BB-69 (atur slot mitra, T-59).
void main() {
  group('jamOperasional', () {
    test('08:00–23:00 → jam 8 sampai 22', () {
      expect(jamOperasional('08:00', '23:00'), [
        8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, //
      ]);
    });

    test('tutup "00:00" = tengah malam: 08:00–00:00 → jam 8 sampai 23', () {
      final jam = jamOperasional('08:00', '00:00');
      expect(jam.first, 8);
      expect(jam.last, 23);
      expect(jam, hasLength(16));
    });

    test('lewat tengah malam: 18:00–02:00 → jam 18 sampai 25', () {
      final jam = jamOperasional('18:00', '02:00');
      expect(jam.first, 18);
      expect(jam.last, 25);
      expect(jam, hasLength(8));
    });

    test('buka 24 jam: 00:00–00:00 → jam 0 sampai 23', () {
      final jam = jamOperasional('00:00', '00:00');
      expect(jam.first, 0);
      expect(jam.last, 23);
      expect(jam, hasLength(24));
    });

    test('menit diabaikan', () {
      expect(jamOperasional('08:30', '10:45'), [8, 9]);
    });

    test('format rusak → daftar kosong, tidak crash', () {
      expect(jamOperasional('', ''), isEmpty);
      expect(jamOperasional('abc', '23:00'), isEmpty);
      expect(jamOperasional('08:00', '2300'), isEmpty);
      expect(jamOperasional('08:00', '30:00'), isEmpty);
    });
  });

  group('statusSlotMitra', () {
    final slot = {
      19: AppSlot.bookingIdBlokir,
      20: 'booking123',
    };

    StatusSlotMitra status(int jam, {bool hariIni = false, int sekarang = 12}) {
      return statusSlotMitra(
        jam: jam,
        slotTerisi: slot,
        hariIni: hariIni,
        jamSekarang: sekarang,
      );
    }

    test('tanpa dokumen slot → kosong (bisa diblokir)', () {
      expect(status(18), StatusSlotMitra.kosong);
    });

    test('bookingId "BLOKIR" → diblokir (BB-68: bisa dibuka)', () {
      expect(status(19), StatusSlotMitra.diblokir);
    });

    test('bookingId booking sungguhan → dipesan (BB-69: tidak bisa disentuh)', () {
      expect(status(20), StatusSlotMitra.dipesan);
    });

    test('hari ini: jam yang sudah lewat → lewat, jam sesudahnya → kosong', () {
      expect(status(10, hariIni: true), StatusSlotMitra.lewat);
      expect(status(12, hariIni: true), StatusSlotMitra.lewat);
      expect(status(13, hariIni: true), StatusSlotMitra.kosong);
    });

    test('bukan hari ini: jam kecil tetap kosong', () {
      expect(status(8), StatusSlotMitra.kosong);
    });

    test('jam lampau yang dipesan tetap "dipesan", bukan "lewat"', () {
      final hasil = statusSlotMitra(
        jam: 9,
        slotTerisi: {9: 'booking999'},
        hariIni: true,
        jamSekarang: 15,
      );
      expect(hasil, StatusSlotMitra.dipesan);
    });

    test('jam lampau yang diblokir tetap "diblokir" (bisa dibuka)', () {
      final hasil = statusSlotMitra(
        jam: 9,
        slotTerisi: {9: AppSlot.bookingIdBlokir},
        hariIni: true,
        jamSekarang: 15,
      );
      expect(hasil, StatusSlotMitra.diblokir);
    });
  });
}
