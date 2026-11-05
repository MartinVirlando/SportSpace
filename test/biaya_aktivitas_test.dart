import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/constants/app_aktivitas.dart';
import 'package:sport_space/core/constants/app_strings.dart';
import 'package:sport_space/core/utils/formatter.dart';
import 'package:sport_space/core/utils/validators.dart';

/// Uji otomatis untuk BB-54 dan BB-55 (biaya per orang, T-56).
///
/// Biaya hanya informasi — tidak ada pembayaran di aplikasi (PRD §2.1).
void main() {
  group('Validators.biayaPerOrang', () {
    test('kosong dianggap valid (opsional, dibaca gratis)', () {
      expect(Validators.biayaPerOrang(null), isNull);
      expect(Validators.biayaPerOrang(''), isNull);
      expect(Validators.biayaPerOrang('   '), isNull);
    });

    test('0, 25000, dan batas atas 1.000.000 valid', () {
      expect(Validators.biayaPerOrang('0'), isNull);
      expect(Validators.biayaPerOrang('25000'), isNull);
      expect(Validators.biayaPerOrang('1000000'), isNull);
    });

    test('di atas batas ditolak dengan pesan rentang', () {
      expect(
        Validators.biayaPerOrang('1000001'),
        AppStrings.errBiayaRentang,
      );
    });

    test('negatif ditolak dengan pesan rentang', () {
      expect(Validators.biayaPerOrang('-5'), AppStrings.errBiayaRentang);
    });

    test('bukan angka ditolak dengan pesan angka', () {
      expect(Validators.biayaPerOrang('abc'), AppStrings.errBiayaAngka);
      expect(Validators.biayaPerOrang('25.5'), AppStrings.errBiayaAngka);
    });
  });

  group('Formatter.biayaPerOrang', () {
    test('0 tampil "Gratis"', () {
      expect(Formatter.biayaPerOrang(0), 'Gratis');
    });

    test('nilai negatif (data rusak) juga tampil "Gratis", tidak crash', () {
      expect(Formatter.biayaPerOrang(-1), 'Gratis');
    });

    test('25000 tampil dengan pemisah ribuan dan satuan "/ orang"', () {
      final hasil = Formatter.biayaPerOrang(25000);
      expect(hasil, contains('25.000'));
      expect(hasil, endsWith('/ orang'));
    });
  });

  group('AppBiaya', () {
    test('valid pada batas dan tidak di luarnya', () {
      expect(AppBiaya.valid(0), isTrue);
      expect(AppBiaya.valid(1000000), isTrue);
      expect(AppBiaya.valid(-1), isFalse);
      expect(AppBiaya.valid(1000001), isFalse);
    });
  });
}
