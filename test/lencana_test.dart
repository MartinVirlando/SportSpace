import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/constants/app_strings.dart';
import 'package:sport_space/core/utils/lencana.dart';

/// Uji otomatis untuk BB-56 dan BB-57 (lencana pencapaian, T-58).
List<String> _diraih(int booking, int aktivitas, int favorit) {
  return hitungLencana(
    jumlahBooking: booking,
    jumlahAktivitas: aktivitas,
    jumlahFavorit: favorit,
  ).where((l) => l.diraih).map((l) => l.nama).toList();
}

void main() {
  test('ada tepat lima lencana, urutannya tetap', () {
    final daftar = hitungLencana(
      jumlahBooking: 0,
      jumlahAktivitas: 0,
      jumlahFavorit: 0,
    );
    expect(daftar.map((l) => l.nama), [
      AppStrings.lencanaPemesanPertama,
      AppStrings.lencanaLangganan,
      AppStrings.lencanaRekanBermain,
      AppStrings.lencanaPenggerak,
      AppStrings.lencanaKolektorFavorit,
    ]);
  });

  test('akun baru: semua lencana belum diraih (BB-56)', () {
    expect(_diraih(0, 0, 0), isEmpty);
  });

  test('booking pertama: hanya Pemesan Pertama menyala (BB-57)', () {
    expect(_diraih(1, 0, 0), [AppStrings.lencanaPemesanPertama]);
  });

  test('batas booking: 4 belum Langganan, 5 sudah', () {
    expect(_diraih(4, 0, 0), [AppStrings.lencanaPemesanPertama]);
    expect(_diraih(5, 0, 0), [
      AppStrings.lencanaPemesanPertama,
      AppStrings.lencanaLangganan,
    ]);
  });

  test('batas aktivitas: 1 Rekan Bermain, 4 belum Penggerak, 5 sudah', () {
    expect(_diraih(0, 1, 0), [AppStrings.lencanaRekanBermain]);
    expect(_diraih(0, 4, 0), [AppStrings.lencanaRekanBermain]);
    expect(_diraih(0, 5, 0), [
      AppStrings.lencanaRekanBermain,
      AppStrings.lencanaPenggerak,
    ]);
  });

  test('batas favorit: 2 belum Kolektor, 3 sudah', () {
    expect(_diraih(0, 0, 2), isEmpty);
    expect(_diraih(0, 0, 3), [AppStrings.lencanaKolektorFavorit]);
  });

  test('semua angka tinggi: kelima lencana menyala', () {
    expect(_diraih(10, 10, 10), hasLength(5));
  });

  test('setiap lencana punya ikon, nama, dan syarat yang terisi', () {
    final daftar = hitungLencana(
      jumlahBooking: 0,
      jumlahAktivitas: 0,
      jumlahFavorit: 0,
    );
    for (final l in daftar) {
      expect(l.ikon, isNotEmpty);
      expect(l.nama, isNotEmpty);
      expect(l.syarat, isNotEmpty);
    }
  });
}
