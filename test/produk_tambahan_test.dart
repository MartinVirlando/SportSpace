import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/constants/app_strings.dart';
import 'package:sport_space/core/utils/harga.dart';
import 'package:sport_space/core/utils/produk_tambahan.dart';
import 'package:sport_space/core/utils/validators.dart';
import 'package:sport_space/models/lapangan_model.dart';
import 'package:sport_space/models/produk_tambahan_model.dart';

/// Uji otomatis untuk BB-73, BB-74, BB-75 (produk tambahan, T-60).
const _bola = ProdukPesananModel(nama: 'Sewa Bola', harga: 15000, jumlah: 2);
const _rompi = ProdukPesananModel(nama: 'Rompi', harga: 5000, jumlah: 1);

LapanganModel _lapangan({int diskon = 0}) {
  return LapanganModel(
    lapanganId: 'lap1',
    nama: 'Lapangan Uji',
    alamat: 'Jl. Contoh',
    latitude: -6.2,
    longitude: 106.6,
    jenisOlahraga: const ['futsal'],
    harga: 100000,
    jamBuka: '08:00',
    jamTutup: '23:00',
    fasilitas: const [],
    fotoURL: const [],
    isMitra: true,
    pemilikId: 'mitra1',
    sumberData: 'mitra',
    ratingTotal: 0,
    jumlahRating: 0,
    ratingRata2: 0,
    diskonPersen: diskon,
    produkTambahan: const [
      ProdukTambahanModel(nama: 'Sewa Bola', harga: 15000),
    ],
  );
}

void main() {
  group('hitungTotalProduk (BB-74)', () {
    test('tanpa produk → 0', () {
      expect(hitungTotalProduk(const []), 0);
    });

    test('2 × 15.000 → 30.000', () {
      expect(hitungTotalProduk([_bola]), 30000);
    });

    test('beberapa produk dijumlahkan: 2 × 15.000 + 1 × 5.000 → 35.000', () {
      expect(hitungTotalProduk([_bola, _rompi]), 35000);
    });
  });

  group('ringkasProduk (BB-74)', () {
    test('satu produk', () {
      expect(ringkasProduk([_bola]), 'Sewa Bola ×2');
    });

    test('beberapa produk dipisah titik tengah', () {
      expect(ringkasProduk([_bola, _rompi]), 'Sewa Bola ×2 · Rompi ×1');
    });

    test('kosong → string kosong (pemanggil menyembunyikan barisnya)', () {
      expect(ringkasProduk(const []), '');
    });
  });

  group('produk tidak didiskon, masuk total (AB-18 + AB-19)', () {
    test('sewa 2 jam diskon 20% + 2 bola = 160.000 + 30.000', () {
      final r = hitungRincianHarga(
        lapangan: _lapangan(diskon: 20),
        daftarJam: [19, 20],
        totalProduk: hitungTotalProduk([_bola]),
      );
      expect(r.sewaSetelahDiskon, 160000);
      expect(r.totalProduk, 30000);
      expect(r.total, 190000);
    });
  });

  group('periksaDaftarProduk (BB-73)', () {
    ProdukTambahanModel p(String nama, int harga) =>
        ProdukTambahanModel(nama: nama, harga: harga);

    test('daftar kosong dan daftar valid → null', () {
      expect(periksaDaftarProduk(const []), isNull);
      expect(periksaDaftarProduk([p('Sewa Bola', 15000)]), isNull);
    });

    test('tepat 5 produk boleh, 6 ditolak', () {
      final lima = [for (var i = 1; i <= 5; i++) p('Produk $i', 1000)];
      expect(periksaDaftarProduk(lima), isNull);
      expect(
        periksaDaftarProduk([...lima, p('Produk 6', 1000)]),
        AppStrings.errProdukTerlalubanyak,
      );
    });

    test('nama kosong, hanya spasi, atau lebih dari 30 karakter ditolak', () {
      expect(periksaDaftarProduk([p('', 1000)]), AppStrings.errNamaProdukRentang);
      expect(
        periksaDaftarProduk([p('   ', 1000)]),
        AppStrings.errNamaProdukRentang,
      );
      expect(
        periksaDaftarProduk([p('x' * 31, 1000)]),
        AppStrings.errNamaProdukRentang,
      );
      expect(periksaDaftarProduk([p('x' * 30, 1000)]), isNull);
    });

    test('harga di bawah 1 atau di atas 1.000.000 ditolak', () {
      expect(periksaDaftarProduk([p('A', 0)]), AppStrings.errHargaProdukRentang);
      expect(
        periksaDaftarProduk([p('A', 1000001)]),
        AppStrings.errHargaProdukRentang,
      );
      expect(periksaDaftarProduk([p('A', 1)]), isNull);
      expect(periksaDaftarProduk([p('A', 1000000)]), isNull);
    });
  });

  group('periksaPesananProduk', () {
    test('jumlah 1–10 valid', () {
      expect(periksaPesananProduk([_bola]), isNull);
      const sepuluh = ProdukPesananModel(nama: 'A', harga: 1, jumlah: 10);
      expect(periksaPesananProduk([sepuluh]), isNull);
    });

    test('jumlah 0 atau 11 ditolak', () {
      const nol = ProdukPesananModel(nama: 'A', harga: 1, jumlah: 0);
      const sebelas = ProdukPesananModel(nama: 'A', harga: 1, jumlah: 11);
      expect(periksaPesananProduk([nol]), AppStrings.errProdukPesananTidakValid);
      expect(
        periksaPesananProduk([sebelas]),
        AppStrings.errProdukPesananTidakValid,
      );
    });

    test('nama kosong atau harga 0 ditolak', () {
      const tanpaNama = ProdukPesananModel(nama: ' ', harga: 1, jumlah: 1);
      const gratis = ProdukPesananModel(nama: 'A', harga: 0, jumlah: 1);
      expect(
        periksaPesananProduk([tanpaNama]),
        AppStrings.errProdukPesananTidakValid,
      );
      expect(
        periksaPesananProduk([gratis]),
        AppStrings.errProdukPesananTidakValid,
      );
    });
  });

  group('Validators produk (kolom form)', () {
    test('namaProduk: wajib dan maksimal 30', () {
      expect(Validators.namaProduk(null), AppStrings.errNamaProdukWajib);
      expect(Validators.namaProduk('  '), AppStrings.errNamaProdukWajib);
      expect(Validators.namaProduk('x' * 31), AppStrings.errNamaProdukRentang);
      expect(Validators.namaProduk('Rompi'), isNull);
    });

    test('hargaProduk: wajib, angka, 1–1.000.000', () {
      expect(Validators.hargaProduk(''), AppStrings.errHargaProdukWajib);
      expect(Validators.hargaProduk('abc'), AppStrings.errHargaProdukAngka);
      expect(Validators.hargaProduk('0'), AppStrings.errHargaProdukRentang);
      expect(Validators.hargaProduk('1000001'), AppStrings.errHargaProdukRentang);
      expect(Validators.hargaProduk('15000'), isNull);
    });
  });

  group('konversi Map ↔ model', () {
    test('ProdukTambahanModel bolak-balik utuh', () {
      const asli = ProdukTambahanModel(nama: 'Sewa Bola', harga: 15000);
      final salinan = ProdukTambahanModel.fromMap(asli.toMap());
      expect(salinan.nama, 'Sewa Bola');
      expect(salinan.harga, 15000);
    });

    test('ProdukPesananModel bolak-balik utuh', () {
      final salinan = ProdukPesananModel.fromMap(_bola.toMap());
      expect(salinan.nama, 'Sewa Bola');
      expect(salinan.harga, 15000);
      expect(salinan.jumlah, 2);
    });

    test('angka double dari Firestore dibaca aman (jebakan #3 CLAUDE.md)', () {
      final p = ProdukPesananModel.fromMap({
        'nama': 'A',
        'harga': 15000.0,
        'jumlah': 2.0,
      });
      expect(p.harga, 15000);
      expect(p.jumlah, 2);
    });

    test('map rusak tidak crash, jadi nilai kosong', () {
      final p = ProdukPesananModel.fromMap(const {});
      expect(p.nama, '');
      expect(p.harga, 0);
      expect(p.jumlah, 0);
    });
  });

  group('LapanganModel.produkTambahan', () {
    test('bawaan daftar kosong', () {
      const l = LapanganModel(
        lapanganId: 'a',
        nama: 'a',
        alamat: 'a',
        latitude: 0,
        longitude: 0,
        jenisOlahraga: [],
        harga: 1,
        jamBuka: '08:00',
        jamTutup: '23:00',
        fasilitas: [],
        fotoURL: [],
        isMitra: false,
        sumberData: 'x',
        ratingTotal: 0,
        jumlahRating: 0,
        ratingRata2: 0,
      );
      expect(l.produkTambahan, isEmpty);
    });

    test('salinDenganJarak TIDAK menghilangkan produk (bug nyata kalau lupa)', () {
      final salinan = _lapangan().salinDenganJarak(2.0);
      expect(salinan.produkTambahan, hasLength(1));
      expect(salinan.produkTambahan.first.nama, 'Sewa Bola');
    });
  });
}
