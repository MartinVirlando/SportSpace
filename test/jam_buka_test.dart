import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/utils/jam_buka.dart';

/// Uji otomatis untuk BB-64 ("Buka sekarang", T-57).
DateTime _jam(int jam, [int menit = 0]) => DateTime(2026, 11, 5, jam, menit);

void main() {
  group('jam operasional biasa (08:00–23:00)', () {
    test('di dalam rentang → buka', () {
      expect(sedangBuka('08:00', '23:00', _jam(12)), isTrue);
      expect(sedangBuka('08:00', '23:00', _jam(22, 59)), isTrue);
    });

    test('tepat jam buka → buka, tepat jam tutup → tutup', () {
      expect(sedangBuka('08:00', '23:00', _jam(8)), isTrue);
      expect(sedangBuka('08:00', '23:00', _jam(23)), isFalse);
    });

    test('sebelum buka dan sesudah tutup → tutup', () {
      expect(sedangBuka('08:00', '23:00', _jam(7, 59)), isFalse);
      expect(sedangBuka('08:00', '23:00', _jam(3)), isFalse);
      expect(sedangBuka('08:00', '23:00', _jam(23, 30)), isFalse);
    });
  });

  group('tutup "00:00" = tengah malam, bukan jam 0 (jebakan CLAUDE.md)', () {
    test('08:00–00:00 buka sampai 23:59', () {
      expect(sedangBuka('08:00', '00:00', _jam(23, 59)), isTrue);
      expect(sedangBuka('08:00', '00:00', _jam(15)), isTrue);
    });

    test('08:00–00:00 sudah tutup pukul 00:00 dan dini hari', () {
      expect(sedangBuka('08:00', '00:00', _jam(0)), isFalse);
      expect(sedangBuka('08:00', '00:00', _jam(4)), isFalse);
      expect(sedangBuka('08:00', '00:00', _jam(7, 59)), isFalse);
    });
  });

  group('tutup lewat tengah malam (18:00–02:00)', () {
    test('malam hari dan dini hari → buka', () {
      expect(sedangBuka('18:00', '02:00', _jam(20)), isTrue);
      expect(sedangBuka('18:00', '02:00', _jam(0, 30)), isTrue);
      expect(sedangBuka('18:00', '02:00', _jam(1, 59)), isTrue);
    });

    test('siang hari dan tepat jam tutup → tutup', () {
      expect(sedangBuka('18:00', '02:00', _jam(2)), isFalse);
      expect(sedangBuka('18:00', '02:00', _jam(12)), isFalse);
      expect(sedangBuka('18:00', '02:00', _jam(17, 59)), isFalse);
    });
  });

  group('buka 24 jam (jam buka == jam tutup)', () {
    test('00:00–00:00 selalu buka', () {
      for (final jam in [0, 1, 6, 12, 18, 23]) {
        expect(sedangBuka('00:00', '00:00', _jam(jam)), isTrue, reason: '$jam');
      }
      expect(sedangBuka('00:00', '00:00', _jam(23, 59)), isTrue);
    });

    test('06:00–06:00 buka sepanjang hari', () {
      expect(sedangBuka('06:00', '06:00', _jam(5)), isTrue);
      expect(sedangBuka('06:00', '06:00', _jam(6)), isTrue);
    });
  });

  group('data rusak', () {
    test('format salah dianggap tutup, tidak crash', () {
      expect(sedangBuka('', '', _jam(12)), isFalse);
      expect(sedangBuka('abc', '23:00', _jam(12)), isFalse);
      expect(sedangBuka('08:00', '2300', _jam(12)), isFalse);
      expect(sedangBuka('08:00', '25:00', _jam(12)), isFalse);
      expect(sedangBuka('08:61', '23:00', _jam(12)), isFalse);
    });
  });
}
