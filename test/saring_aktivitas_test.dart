import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/constants/app_aktivitas.dart';
import 'package:sport_space/core/utils/saring_aktivitas.dart';
import 'package:sport_space/models/aktivitas_bermain_model.dart';

/// Membuat aktivitas contoh — hanya field yang relevan untuk penyaringan
/// yang bisa diatur, sisanya nilai tetap.
AktivitasBermainModel _aktivitas(String id, {required String jenis}) {
  return AktivitasBermainModel(
    aktivitasId: id,
    jenisOlahraga: 'futsal',
    jumlahPemainDibutuhkan: 10,
    jumlahPemainSaatIni: 1,
    waktu: DateTime(2026, 12, 1, 19),
    lapanganId: 'lap1',
    namaLapangan: 'Lapangan Uji',
    pembuatId: 'u1',
    namaPembuat: 'Pembuat',
    status: 'TERBUKA',
    peserta: const ['u1'],
    dibuatPada: DateTime(2026, 11, 1),
    jenisAktivitas: jenis,
  );
}

void main() {
  final daftar = [
    _aktivitas('a', jenis: AppJenisAktivitas.mainBareng),
    _aktivitas('b', jenis: AppJenisAktivitas.sparring),
    _aktivitas('c', jenis: AppJenisAktivitas.mainBareng),
  ];

  group('saringAktivitas — jenis (T-54)', () {
    test('"Semua" mengembalikan seluruh daftar dengan urutan sama', () {
      final hasil = saringAktivitas(daftar);
      expect(hasil.map((a) => a.aktivitasId), ['a', 'b', 'c']);
    });

    test('Sparring hanya mengembalikan aktivitas sparring', () {
      final hasil = saringAktivitas(daftar, jenis: AppJenisAktivitas.sparring);
      expect(hasil.map((a) => a.aktivitasId), ['b']);
    });

    test('Main Bareng hanya mengembalikan aktivitas main bareng', () {
      final hasil =
          saringAktivitas(daftar, jenis: AppJenisAktivitas.mainBareng);
      expect(hasil.map((a) => a.aktivitasId), ['a', 'c']);
    });

    test('daftar kosong tetap kosong', () {
      expect(
        saringAktivitas(const [], jenis: AppJenisAktivitas.sparring),
        isEmpty,
      );
    });
  });

  group('AppJenisAktivitas', () {
    test('valid hanya menerima dua nilai, bukan "semua"', () {
      expect(AppJenisAktivitas.valid('main_bareng'), isTrue);
      expect(AppJenisAktivitas.valid('sparring'), isTrue);
      expect(AppJenisAktivitas.valid(AppJenisAktivitas.semua), isFalse);
      expect(AppJenisAktivitas.valid('turnamen'), isFalse);
    });

    test('label berbahasa Indonesia', () {
      expect(AppJenisAktivitas.labelDari('main_bareng'), 'Main Bareng');
      expect(AppJenisAktivitas.labelDari('sparring'), 'Sparring');
    });
  });
}
