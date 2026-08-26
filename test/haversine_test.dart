import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/utils/haversine.dart';

/// Uji otomatis untuk BB-13: "Selisih dengan perhitungan manual < 0,1 km".
///
/// Jalankan dengan:  flutter test
///
/// Kenapa ini berharga untuk skripsi: penguji hampir pasti menanyakan
/// bagaimana kalian membuktikan Haversine-nya benar. "Sudah kami cek
/// manual" lemah. "Ada uji otomatis yang jalan tiap kali kode berubah,
/// ini hasilnya" jauh lebih kuat — dan tangkapan layarnya bisa langsung
/// masuk Bab 4 sebagai bukti BB-13.
void main() {
  group('hitungJarakHaversine', () {
    // Toleransi 0,1 km mengikuti kriteria BB-13.
    const toleransi = 0.1;

    test('titik yang sama menghasilkan jarak nol', () {
      final jarak = hitungJarakHaversine(
        -6.2214, 106.6520, // Binus Alam Sutera
        -6.2214, 106.6520,
      );
      expect(jarak, closeTo(0.0, 0.0001));
    });

    test('Monas ke Gedung Sate kira-kira 119 km', () {
      // Jarak garis lurus Jakarta–Bandung yang umum dikutip: ~119 km.
      final jarak = hitungJarakHaversine(
        -6.1754, 106.8272, // Monas, Jakarta
        -6.9025, 107.6186, // Gedung Sate, Bandung
      );
      expect(jarak, closeTo(119.08, 0.5));
    });

    test('Binus Alam Sutera ke KM7 Mini Soccer kira-kira 3,8 km', () {
      // Koordinat KM7 terverifikasi dari halaman resmi venue.
      final jarak = hitungJarakHaversine(
        -6.2214, 106.6520,
        -6.2552602, 106.6515011,
      );
      expect(jarak, closeTo(3.765, toleransi));
    });

    test('Binus Alam Sutera ke Arsa Sport Mini Soccer kira-kira 9,9 km', () {
      final jarak = hitungJarakHaversine(
        -6.2214, 106.6520,
        -6.3085641, 106.6679653,
      );
      expect(jarak, closeTo(9.852, toleransi));
    });

    test('hasilnya simetris — f(A,B) sama dengan f(B,A)', () {
      final ab = hitungJarakHaversine(-6.22, 106.65, -6.30, 106.66);
      final ba = hitungJarakHaversine(-6.30, 106.66, -6.22, 106.65);
      expect(ab, closeTo(ba, 0.000001));
    });

    test('menangani lintas belahan bumi tanpa hasil negatif', () {
      // Jarak tidak pernah negatif, berapa pun tanda koordinatnya.
      final jarak = hitungJarakHaversine(-6.2, 106.8, 51.5, -0.12); // ke London
      expect(jarak, greaterThan(0));
      expect(jarak, closeTo(11719, 50));
    });

    test('beda 1 derajat lintang kira-kira 111 km', () {
      // Pemeriksaan kewarasan: satu derajat lintang selalu ~111,2 km
      // di mana pun di bumi. Kalau uji ini gagal, kemungkinan besar
      // konversi derajat ke radian yang salah.
      final jarak = hitungJarakHaversine(0.0, 0.0, 1.0, 0.0);
      expect(jarak, closeTo(111.19, 0.5));
    });
  });
}
