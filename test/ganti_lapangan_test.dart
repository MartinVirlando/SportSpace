import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/utils/ganti_lapangan.dart';
import 'package:sport_space/core/utils/urut_lapangan.dart';
import 'package:sport_space/models/lapangan_model.dart';

/// Uji otomatis untuk penyegaran kartu Home setelah rating baru (BB-84).
LapanganModel _l(
  String id, {
  int jumlahRating = 0,
  double rating = 0,
  double? jarak,
}) {
  return LapanganModel(
    lapanganId: id,
    nama: id,
    alamat: 'Alamat $id',
    latitude: -6.2,
    longitude: 106.6,
    jenisOlahraga: const ['padel'],
    harga: 100000,
    jamBuka: '08:00',
    jamTutup: '23:00',
    fasilitas: const [],
    fotoURL: const [],
    isMitra: false,
    sumberData: 'direktori_daring',
    ratingTotal: 0,
    jumlahRating: jumlahRating,
    ratingRata2: rating,
    jarakKm: jarak,
  );
}

List<String> _id(List<LapanganModel> daftar) =>
    daftar.map((l) => l.lapanganId).toList();

void main() {
  group('gantiLapanganDalamDaftar', () {
    test('hanya lapangan ber-ID sama yang diganti; lainnya tetap objek yang sama',
        () {
      final a = _l('a', jarak: 1);
      final b = _l('b', jarak: 2, rating: 3, jumlahRating: 1);
      final c = _l('c', jarak: 3);
      final baru = _l('b', rating: 4, jumlahRating: 2);

      final hasil = gantiLapanganDalamDaftar([a, b, c], baru);

      expect(identical(hasil[0], a), isTrue);
      expect(identical(hasil[2], c), isTrue);
      expect(hasil[1].ratingRata2, 4);
      expect(hasil[1].jumlahRating, 2);
    });

    test('jarakKm lama dipertahankan walau dokumen baru tidak membawa jarak',
        () {
      final lama = _l('b', jarak: 6.0, rating: 3, jumlahRating: 1);
      final baru = _l('b', rating: 4, jumlahRating: 2); // jarak null

      final hasil = gantiLapanganDalamDaftar([lama], baru);

      expect(hasil.single.jarakKm, 6.0);
      expect(hasil.single.ratingRata2, 4);
    });

    test('urutan elemen tidak berubah', () {
      final daftar = [_l('a', jarak: 1), _l('b', jarak: 2), _l('c', jarak: 3)];
      final hasil = gantiLapanganDalamDaftar(daftar, _l('b', rating: 5));
      expect(_id(hasil), ['a', 'b', 'c']);
    });

    test('ID tidak ada di daftar: isinya tidak berubah', () {
      final daftar = [_l('a', jarak: 1), _l('b', jarak: 2)];
      final hasil = gantiLapanganDalamDaftar(daftar, _l('z', rating: 5));
      expect(_id(hasil), ['a', 'b']);
      expect(identical(hasil[0], daftar[0]), isTrue);
      expect(identical(hasil[1], daftar[1]), isTrue);
    });

    test('daftar kosong menghasilkan daftar kosong', () {
      expect(gantiLapanganDalamDaftar([], _l('a')), isEmpty);
    });

    test('daftar asli tidak diubah (mengembalikan daftar baru)', () {
      final b = _l('b', jarak: 2, rating: 3, jumlahRating: 1);
      final daftar = [_l('a', jarak: 1), b];

      final hasil = gantiLapanganDalamDaftar(
        daftar,
        _l('b', rating: 5, jumlahRating: 2),
      );

      expect(identical(hasil, daftar), isFalse);
      expect(identical(daftar[1], b), isTrue);
      expect(daftar[1].ratingRata2, 3);
    });

    test('jarak lama null: memakai dokumen baru apa adanya', () {
      final hasil = gantiLapanganDalamDaftar(
        [_l('a')],
        _l('a', jarak: 9, rating: 4),
      );
      expect(hasil.single.jarakKm, 9);
    });
  });

  group('rating baru memengaruhi urutan Home yang dipilih pengguna', () {
    // Kasus uji emulator 5 November 2026: The Good Padel (3,0 dari 1 ulasan)
    // mendapat ulasan kedua 5 bintang → 4,0 dari 2 ulasan.
    LapanganModel powerhouse() => _l('powerhouse', jarak: 5.0, rating: 5, jumlahRating: 1);
    LapanganModel goodPadel() => _l('goodPadel', jarak: 6.0, rating: 3, jumlahRating: 1);
    LapanganModel stadiums() => _l('stadiums', jarak: 6.8, rating: 5, jumlahRating: 1);

    test('Terpopuler: lapangan dengan 2 ulasan naik ke posisi pertama', () {
      final sebelum = [powerhouse(), goodPadel(), stadiums()];
      final sesudah = gantiLapanganDalamDaftar(
        sebelum,
        _l('goodPadel', rating: 4, jumlahRating: 2),
      );

      expect(
        _id(urutkanLapangan(sebelum, UrutanLapangan.populer)),
        ['powerhouse', 'stadiums', 'goodPadel'],
      );
      expect(
        _id(urutkanLapangan(sesudah, UrutanLapangan.populer)),
        ['goodPadel', 'powerhouse', 'stadiums'],
      );
    });

    test('Rating tertinggi: 4,0 tetap di belakang dua lapangan 5,0', () {
      final sesudah = gantiLapanganDalamDaftar(
        [powerhouse(), goodPadel(), stadiums()],
        _l('goodPadel', rating: 4, jumlahRating: 2),
      );
      expect(
        _id(urutkanLapangan(sesudah, UrutanLapangan.rating)),
        ['powerhouse', 'stadiums', 'goodPadel'],
      );
    });

    test('Terdekat (bawaan): urutan jarak tidak bergeser', () {
      final sesudah = gantiLapanganDalamDaftar(
        [powerhouse(), goodPadel(), stadiums()],
        _l('goodPadel', rating: 4, jumlahRating: 2),
      );
      expect(
        _id(urutkanLapangan(sesudah, UrutanLapangan.terdekat)),
        ['powerhouse', 'goodPadel', 'stadiums'],
      );
    });
  });
}
