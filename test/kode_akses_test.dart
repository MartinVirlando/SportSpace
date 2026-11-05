import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/utils/kode_akses.dart';

/// Uji otomatis untuk BB-79, BB-80, BB-81 (aktivitas privat, T-64).
void main() {
  group('buatKodeAkses', () {
    test('selalu tepat 6 karakter', () {
      final acak = Random(1);
      for (var i = 0; i < 200; i++) {
        expect(buatKodeAkses(acak), hasLength(panjangKodeAkses));
      }
    });

    test('hanya memakai alfabet yang diizinkan (tanpa I, O, 0, 1)', () {
      final acak = Random(2);
      for (var i = 0; i < 500; i++) {
        final kode = buatKodeAkses(acak);
        for (final huruf in kode.split('')) {
          expect(alfabetKodeAkses.contains(huruf), isTrue, reason: kode);
        }
        expect(kode, isNot(matches(RegExp('[IO01]'))), reason: kode);
      }
    });

    test('alfabet 32 karakter tanpa duplikat', () {
      expect(alfabetKodeAkses, hasLength(32));
      expect(alfabetKodeAkses.split('').toSet(), hasLength(32));
    });

    test('seed sama menghasilkan kode sama (bisa diuji)', () {
      expect(buatKodeAkses(Random(42)), buatKodeAkses(Random(42)));
    });

    test('kode berbeda tidak selalu sama (sebaran cukup)', () {
      final acak = Random(3);
      final kumpulan = {for (var i = 0; i < 200; i++) buatKodeAkses(acak)};
      expect(kumpulan.length, greaterThan(190));
    });

    test('Random.secure() juga berfungsi', () {
      expect(kodeAksesValid(buatKodeAkses(Random.secure())), isTrue);
    });
  });

  group('normalisasiKodeAkses (BB-80)', () {
    test('huruf kecil dijadikan besar', () {
      expect(normalisasiKodeAkses('ab3k9x'), 'AB3K9X');
    });

    test('spasi di tepi dibuang, di tengah dibiarkan', () {
      expect(normalisasiKodeAkses('  ab3k9x \n'), 'AB3K9X');
      expect(normalisasiKodeAkses('ab 3k9x'), 'AB 3K9X');
    });
  });

  group('kodeAksesValid (BB-81)', () {
    test('kode sah diterima', () {
      expect(kodeAksesValid('AB3K9X'), isTrue);
      expect(kodeAksesValid('ZZZZZZ'), isTrue);
      expect(kodeAksesValid('234567'), isTrue);
    });

    test('terlalu pendek atau terlalu panjang ditolak', () {
      expect(kodeAksesValid(''), isFalse);
      expect(kodeAksesValid('AB3K9'), isFalse);
      expect(kodeAksesValid('AB3K9XY'), isFalse);
    });

    test('huruf yang dibuang dari alfabet ditolak (I, O, 0, 1)', () {
      expect(kodeAksesValid('IBCDEF'), isFalse);
      expect(kodeAksesValid('OBCDEF'), isFalse);
      expect(kodeAksesValid('0BCDEF'), isFalse);
      expect(kodeAksesValid('1BCDEF'), isFalse);
    });

    test('huruf kecil, spasi, dan simbol ditolak (harus dinormalkan dulu)', () {
      expect(kodeAksesValid('ab3k9x'), isFalse);
      expect(kodeAksesValid('AB 3K9'), isFalse);
      expect(kodeAksesValid('AB3K9!'), isFalse);
    });

    test('alur lengkap: ketikan pengguna → normalisasi → valid', () {
      expect(kodeAksesValid(normalisasiKodeAkses('  ab3k9x ')), isTrue);
    });
  });
}
