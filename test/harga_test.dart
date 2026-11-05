import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/constants/app_strings.dart';
import 'package:sport_space/core/utils/harga.dart';
import 'package:sport_space/core/utils/validators.dart';
import 'package:sport_space/models/lapangan_model.dart';

/// Uji otomatis untuk BB-70, BB-71, BB-72 (promo/diskon, T-65).
LapanganModel _lapangan({
  int harga = 100000,
  Map<String, int>? hargaSlot,
  int diskon = 0,
}) {
  return LapanganModel(
    lapanganId: 'lap1',
    nama: 'Lapangan Uji',
    alamat: 'Jl. Contoh',
    latitude: -6.2,
    longitude: 106.6,
    jenisOlahraga: const ['futsal'],
    harga: harga,
    hargaSlot: hargaSlot,
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
  );
}

void main() {
  group('hargaSetelahDiskon', () {
    test('0 persen → harga tidak berubah', () {
      expect(hargaSetelahDiskon(150000, 0), 150000);
    });

    test('20 persen dari 100.000 → 80.000', () {
      expect(hargaSetelahDiskon(100000, 20), 80000);
    });

    test('dibulatkan ke rupiah terdekat (ke atas pada .5)', () {
      // 333 × 85% = 283,05 → 283 ; 335 × 85% = 284,75 → 285 ; 10 × 95% = 9,5 → 10
      expect(hargaSetelahDiskon(333, 15), 283);
      expect(hargaSetelahDiskon(335, 15), 285);
      expect(hargaSetelahDiskon(10, 5), 10);
    });

    test('diskon maksimal 90 persen', () {
      expect(hargaSetelahDiskon(200000, 90), 20000);
    });

    test('persen di luar 0–100 dijepit, tidak pernah negatif atau naik', () {
      expect(hargaSetelahDiskon(100000, -10), 100000);
      expect(hargaSetelahDiskon(100000, 150), 0);
    });

    test('nilai 0 tetap 0', () {
      expect(hargaSetelahDiskon(0, 50), 0);
    });
  });

  group('hitungSewaSebelumDiskon (AB-08)', () {
    test('tanpa hargaSlot: harga × jumlah jam', () {
      expect(hitungSewaSebelumDiskon(_lapangan(), [19, 20]), 200000);
    });

    test('dengan hargaSlot: jumlah per periode (pagi < 12, siang < 18, malam)', () {
      final l = _lapangan(
        hargaSlot: const {'pagi': 80000, 'siang': 100000, 'malam': 150000},
      );
      expect(hitungSewaSebelumDiskon(l, [9]), 80000);
      expect(hitungSewaSebelumDiskon(l, [12]), 100000);
      expect(hitungSewaSebelumDiskon(l, [17]), 100000);
      expect(hitungSewaSebelumDiskon(l, [18]), 150000);
      expect(hitungSewaSebelumDiskon(l, [17, 18]), 250000);
    });

    test('periode yang tidak ada di hargaSlot memakai harga dasar', () {
      final l = _lapangan(hargaSlot: const {'malam': 150000});
      expect(hitungSewaSebelumDiskon(l, [9]), 100000);
    });

    test('daftar jam kosong → 0', () {
      expect(hitungSewaSebelumDiskon(_lapangan(), const []), 0);
    });
  });

  group('hitungRincianHarga (BB-71)', () {
    test('tanpa promo: potongan 0, total = sewa', () {
      final r = hitungRincianHarga(lapangan: _lapangan(), daftarJam: [19, 20]);
      expect(r.sewaAsli, 200000);
      expect(r.potongan, 0);
      expect(r.sewaSetelahDiskon, 200000);
      expect(r.total, 200000);
    });

    test('diskon 20% dua jam: potongan, sewa, dan total konsisten', () {
      final r = hitungRincianHarga(
        lapangan: _lapangan(diskon: 20),
        daftarJam: [19, 20],
      );
      expect(r.sewaAsli, 200000);
      expect(r.sewaSetelahDiskon, 160000);
      expect(r.potongan, 40000);
      expect(r.sewaAsli - r.potongan, r.sewaSetelahDiskon);
      expect(r.total, 160000);
    });

    test('diskon berlaku juga pada harga per periode', () {
      final l = _lapangan(
        diskon: 50,
        hargaSlot: const {'pagi': 80000, 'siang': 100000, 'malam': 150000},
      );
      final r = hitungRincianHarga(lapangan: l, daftarJam: [17, 18]);
      expect(r.sewaAsli, 250000);
      expect(r.total, 125000);
    });

    test('produk tambahan ditambahkan SETELAH diskon, tidak ikut didiskon', () {
      final r = hitungRincianHarga(
        lapangan: _lapangan(diskon: 20),
        daftarJam: [19],
        totalProduk: 30000,
      );
      expect(r.sewaSetelahDiskon, 80000);
      expect(r.totalProduk, 30000);
      expect(r.total, 110000);
    });
  });

  group('LapanganModel.diskonPersen', () {
    test('bawaan 0', () {
      expect(_lapangan().diskonPersen, 0);
    });

    test('salinDenganJarak TIDAK menghilangkan diskon (bug nyata kalau lupa)', () {
      final salinan = _lapangan(diskon: 25).salinDenganJarak(3.5);
      expect(salinan.diskonPersen, 25);
      expect(salinan.jarakKm, 3.5);
    });
  });

  group('Validators.diskonPersen (BB-72)', () {
    test('kosong valid (opsional, dibaca 0)', () {
      expect(Validators.diskonPersen(null), isNull);
      expect(Validators.diskonPersen(''), isNull);
      expect(Validators.diskonPersen('  '), isNull);
    });

    test('0, 20, dan batas 90 valid', () {
      expect(Validators.diskonPersen('0'), isNull);
      expect(Validators.diskonPersen('20'), isNull);
      expect(Validators.diskonPersen('90'), isNull);
    });

    test('91 dan negatif ditolak dengan pesan rentang', () {
      expect(Validators.diskonPersen('91'), AppStrings.errDiskonRentang);
      expect(Validators.diskonPersen('-5'), AppStrings.errDiskonRentang);
      expect(Validators.diskonPersen('100'), AppStrings.errDiskonRentang);
    });

    test('huruf dan desimal ditolak dengan pesan angka', () {
      expect(Validators.diskonPersen('abc'), AppStrings.errDiskonAngka);
      expect(Validators.diskonPersen('12.5'), AppStrings.errDiskonAngka);
    });
  });
}
