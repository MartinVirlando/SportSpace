import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/constants/app_aktivitas.dart';
import 'package:sport_space/core/utils/saring_aktivitas.dart';
import 'package:sport_space/models/aktivitas_bermain_model.dart';

/// Membuat aktivitas contoh — hanya field yang relevan untuk penyaringan
/// yang bisa diatur, sisanya nilai tetap. [tingkat] `null` meniru dokumen
/// lama (sebelum v1.4) yang belum punya `tingkatKemampuan`.
AktivitasBermainModel _aktivitas(
  String id, {
  required String jenis,
  String? tingkat,
}) {
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
    tingkatKemampuan: tingkat,
    biayaPerOrang: 0,
  );
}

List<String> _id(List<AktivitasBermainModel> daftar) =>
    daftar.map((a) => a.aktivitasId).toList();

void main() {
  // a: main bareng, pemula   b: sparring, mahir   c: main bareng, menengah
  // d: main bareng, tanpa tingkat (dokumen lama)
  final daftar = [
    _aktivitas(
      'a',
      jenis: AppJenisAktivitas.mainBareng,
      tingkat: AppTingkat.pemula,
    ),
    _aktivitas(
      'b',
      jenis: AppJenisAktivitas.sparring,
      tingkat: AppTingkat.mahir,
    ),
    _aktivitas(
      'c',
      jenis: AppJenisAktivitas.mainBareng,
      tingkat: AppTingkat.menengah,
    ),
    _aktivitas('d', jenis: AppJenisAktivitas.mainBareng),
  ];

  group('saringAktivitas — jenis (T-54)', () {
    test('tanpa filter mengembalikan seluruh daftar dengan urutan sama', () {
      expect(_id(saringAktivitas(daftar)), ['a', 'b', 'c', 'd']);
    });

    test('Sparring hanya mengembalikan aktivitas sparring', () {
      final hasil = saringAktivitas(daftar, jenis: AppJenisAktivitas.sparring);
      expect(_id(hasil), ['b']);
    });

    test('Main Bareng mengembalikan yang main bareng, termasuk dokumen lama',
        () {
      final hasil =
          saringAktivitas(daftar, jenis: AppJenisAktivitas.mainBareng);
      expect(_id(hasil), ['a', 'c', 'd']);
    });

    test('daftar kosong tetap kosong', () {
      expect(
        saringAktivitas(const [], jenis: AppJenisAktivitas.sparring),
        isEmpty,
      );
    });
  });

  group('saringAktivitas — tingkat (T-55)', () {
    test('Pemula hanya mengembalikan aktivitas bertingkat pemula', () {
      expect(_id(saringAktivitas(daftar, tingkat: AppTingkat.pemula)), ['a']);
    });

    test('Mahir hanya mengembalikan aktivitas bertingkat mahir', () {
      expect(_id(saringAktivitas(daftar, tingkat: AppTingkat.mahir)), ['b']);
    });

    test('dokumen lama tanpa tingkat tidak lolos filter tingkat apa pun', () {
      for (final tingkat in AppTingkat.daftarPilihan) {
        final hasil = saringAktivitas(daftar, tingkat: tingkat);
        expect(_id(hasil).contains('d'), isFalse, reason: tingkat);
      }
    });

    test('"Semua tingkat" meloloskan dokumen lama tanpa tingkat', () {
      final hasil = saringAktivitas(daftar, tingkat: AppTingkat.semua);
      expect(_id(hasil).contains('d'), isTrue);
    });
  });

  group('saringAktivitas — jenis dan tingkat digabung', () {
    test('Main Bareng + Menengah', () {
      final hasil = saringAktivitas(
        daftar,
        jenis: AppJenisAktivitas.mainBareng,
        tingkat: AppTingkat.menengah,
      );
      expect(_id(hasil), ['c']);
    });

    test('Sparring + Pemula tidak punya hasil', () {
      final hasil = saringAktivitas(
        daftar,
        jenis: AppJenisAktivitas.sparring,
        tingkat: AppTingkat.pemula,
      );
      expect(hasil, isEmpty);
    });
  });

  group('AppJenisAktivitas dan AppTingkat', () {
    test('valid hanya menerima nilai pilihan, bukan "semua"', () {
      expect(AppJenisAktivitas.valid('main_bareng'), isTrue);
      expect(AppJenisAktivitas.valid('sparring'), isTrue);
      expect(AppJenisAktivitas.valid(AppJenisAktivitas.semua), isFalse);
      expect(AppJenisAktivitas.valid('turnamen'), isFalse);

      expect(AppTingkat.valid('pemula'), isTrue);
      expect(AppTingkat.valid('menengah'), isTrue);
      expect(AppTingkat.valid('mahir'), isTrue);
      expect(AppTingkat.valid(AppTingkat.semua), isFalse);
      expect(AppTingkat.valid('dewa'), isFalse);
    });

    test('label berbahasa Indonesia', () {
      expect(AppJenisAktivitas.labelDari('main_bareng'), 'Main Bareng');
      expect(AppJenisAktivitas.labelDari('sparring'), 'Sparring');
      expect(AppTingkat.labelDari('pemula'), 'Pemula');
      expect(AppTingkat.labelDari(AppTingkat.semua), 'Semua tingkat');
    });
  });
}
