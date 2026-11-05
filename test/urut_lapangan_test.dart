import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/utils/urut_lapangan.dart';
import 'package:sport_space/models/lapangan_model.dart';

/// Uji otomatis untuk BB-62, BB-63, BB-65 (urut dan saring Home, T-57).
LapanganModel _l(
  String id, {
  int jumlahRating = 0,
  double rating = 0,
  double? jarak,
  List<String> fasilitas = const [],
}) {
  return LapanganModel(
    lapanganId: id,
    nama: id,
    alamat: 'Alamat $id',
    latitude: -6.2,
    longitude: 106.6,
    jenisOlahraga: const ['futsal'],
    harga: 100000,
    jamBuka: '08:00',
    jamTutup: '23:00',
    fasilitas: fasilitas,
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
  group('urutkanLapangan — terdekat (bawaan, AB-02)', () {
    test('mempertahankan urutan masukan, tidak mengurutkan ulang', () {
      final daftar = [
        _l('a', jarak: 1, rating: 2, jumlahRating: 1),
        _l('b', jarak: 2, rating: 5, jumlahRating: 9),
        _l('c', jarak: 3),
      ];
      expect(
        _id(urutkanLapangan(daftar, UrutanLapangan.terdekat)),
        ['a', 'b', 'c'],
      );
    });

    test('mengembalikan salinan; daftar asli tidak diubah', () {
      final daftar = [_l('a', jarak: 1), _l('b', jarak: 2)];
      final hasil = urutkanLapangan(daftar, UrutanLapangan.rating);
      expect(identical(hasil, daftar), isFalse);
      expect(_id(daftar), ['a', 'b']);
    });
  });

  group('urutkanLapangan — rating (BB-62)', () {
    test('rating tertinggi dulu', () {
      final daftar = [
        _l('rendah', rating: 3.0, jumlahRating: 5, jarak: 1),
        _l('tinggi', rating: 4.8, jumlahRating: 2, jarak: 5),
        _l('sedang', rating: 4.0, jumlahRating: 9, jarak: 3),
      ];
      expect(
        _id(urutkanLapangan(daftar, UrutanLapangan.rating)),
        ['tinggi', 'sedang', 'rendah'],
      );
    });

    test('yang belum punya ulasan selalu di akhir, walau paling dekat', () {
      final daftar = [
        _l('baru', jumlahRating: 0, jarak: 0.1),
        _l('bagus', rating: 4.5, jumlahRating: 3, jarak: 9),
        _l('jelek', rating: 1.0, jumlahRating: 1, jarak: 8),
      ];
      expect(
        _id(urutkanLapangan(daftar, UrutanLapangan.rating)),
        ['bagus', 'jelek', 'baru'],
      );
    });

    test('rating sama → jarak menaik; jarak null dianggap paling jauh', () {
      final daftar = [
        _l('jauh', rating: 4.0, jumlahRating: 2, jarak: 7),
        _l('tanpaJarak', rating: 4.0, jumlahRating: 2),
        _l('dekat', rating: 4.0, jumlahRating: 2, jarak: 1),
      ];
      expect(
        _id(urutkanLapangan(daftar, UrutanLapangan.rating)),
        ['dekat', 'jauh', 'tanpaJarak'],
      );
    });

    test('beberapa lapangan tanpa ulasan diurutkan menurut jarak', () {
      final daftar = [
        _l('x', jarak: 5),
        _l('y', jarak: 2),
      ];
      expect(_id(urutkanLapangan(daftar, UrutanLapangan.rating)), ['y', 'x']);
    });
  });

  group('urutkanLapangan — populer (BB-63)', () {
    test('jumlah ulasan terbanyak dulu', () {
      final daftar = [
        _l('sepi', rating: 5.0, jumlahRating: 1, jarak: 1),
        _l('ramai', rating: 3.0, jumlahRating: 20, jarak: 9),
        _l('lumayan', rating: 4.0, jumlahRating: 7, jarak: 4),
      ];
      expect(
        _id(urutkanLapangan(daftar, UrutanLapangan.populer)),
        ['ramai', 'lumayan', 'sepi'],
      );
    });

    test('jumlah sama → rating tertinggi, lalu jarak', () {
      final daftar = [
        _l('a', rating: 3.0, jumlahRating: 4, jarak: 1),
        _l('b', rating: 4.5, jumlahRating: 4, jarak: 9),
        _l('c', rating: 4.5, jumlahRating: 4, jarak: 2),
      ];
      expect(
        _id(urutkanLapangan(daftar, UrutanLapangan.populer)),
        ['c', 'b', 'a'],
      );
    });
  });

  group('saringFasilitas (BB-65)', () {
    final daftar = [
      _l('lengkap', fasilitas: const ['parkir', 'toilet', 'kantin']),
      _l('parkirSaja', fasilitas: const ['parkir']),
      _l('toiletSaja', fasilitas: const ['toilet']),
      _l('kosong'),
    ];

    test('tanpa pilihan → semua lapangan', () {
      expect(
        _id(saringFasilitas(daftar, {})),
        ['lengkap', 'parkirSaja', 'toiletSaja', 'kosong'],
      );
    });

    test('satu fasilitas → yang punya fasilitas itu', () {
      expect(
        _id(saringFasilitas(daftar, {'parkir'})),
        ['lengkap', 'parkirSaja'],
      );
    });

    test('dua fasilitas → harus punya KEDUANYA (bukan salah satu)', () {
      expect(_id(saringFasilitas(daftar, {'parkir', 'toilet'})), ['lengkap']);
    });

    test('fasilitas yang tidak dimiliki siapa pun → kosong', () {
      expect(saringFasilitas(daftar, {'shower'}), isEmpty);
    });

    test('urutan masukan tetap terjaga', () {
      final hasil = saringFasilitas(daftar, {'toilet'});
      expect(_id(hasil), ['lengkap', 'toiletSaja']);
    });
  });
}
