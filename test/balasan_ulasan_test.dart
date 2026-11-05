import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/utils/validators.dart';
import 'package:sport_space/models/rating_model.dart';

/// Uji otomatis untuk balasan mitra terhadap ulasan — T-66, PRD AB-22,
/// BB-88 (validasi) dan pengaman Security Rules pada ulasan baru.
RatingModel _rating({String? balasan, DateTime? balasanPada}) {
  return RatingModel(
    ratingId: 'u1_l1',
    userId: 'u1',
    namaUser: 'Pengguna',
    lapanganId: 'l1',
    nilaiRating: 4,
    ulasanTeks: 'Bagus',
    tanggal: DateTime(2026, 11, 5, 12),
    balasanMitra: balasan,
    balasanPada: balasanPada,
  );
}

void main() {
  group('Validators.balasan (BB-88)', () {
    test('kosong, null, dan hanya spasi ditolak', () {
      expect(Validators.balasan(null), isNotNull);
      expect(Validators.balasan(''), isNotNull);
      expect(Validators.balasan('   '), isNotNull);
      expect(Validators.balasan('\n\t '), isNotNull);
    });

    test('satu karakter sampai 500 karakter diterima', () {
      expect(Validators.balasan('a'), isNull);
      expect(Validators.balasan('Terima kasih!'), isNull);
      expect(Validators.balasan('a' * 500), isNull);
    });

    test('501 karakter ditolak', () {
      expect(Validators.balasan('a' * 501), isNotNull);
    });

    test('batas dihitung SETELAH di-trim', () {
      // 500 karakter + spasi di kedua ujung tetap lolos, karena yang
      // dikirim ke Firestore sudah di-trim oleh Repository.
      expect(Validators.balasan('  ${'a' * 500}  '), isNull);
      expect(Validators.balasan('  ${'a' * 501}  '), isNotNull);
    });

    test('pesan galat berbahasa Indonesia dan berbeda untuk dua kasus', () {
      final kosong = Validators.balasan('');
      final panjang = Validators.balasan('a' * 501);
      expect(kosong, contains('wajib'));
      expect(panjang, contains('500'));
      expect(kosong, isNot(equals(panjang)));
    });
  });

  group('RatingModel.toFirestore — field balasan', () {
    test('ulasan baru TIDAK memuat kunci balasan (Security Rules melarangnya)',
        () {
      final peta = _rating().toFirestore();
      expect(peta.containsKey('balasanMitra'), isFalse);
      expect(peta.containsKey('balasanPada'), isFalse);
    });

    test('kunci balasan ikut ditulis kalau terisi', () {
      final waktu = DateTime(2026, 11, 5, 14);
      final peta = _rating(balasan: 'Terima kasih!', balasanPada: waktu)
          .toFirestore();
      expect(peta['balasanMitra'], 'Terima kasih!');
      expect(peta['balasanPada'], Timestamp.fromDate(waktu));
    });

    test('field lama tidak berubah oleh penambahan field balasan', () {
      final peta = _rating().toFirestore();
      expect(peta['ratingId'], 'u1_l1');
      expect(peta['userId'], 'u1');
      expect(peta['nilaiRating'], 4);
      expect(peta['ulasanTeks'], 'Bagus');
      expect(peta.keys.toSet(), {
        'ratingId',
        'userId',
        'namaUser',
        'lapanganId',
        'nilaiRating',
        'ulasanTeks',
        'tanggal',
      });
    });
  });
}
