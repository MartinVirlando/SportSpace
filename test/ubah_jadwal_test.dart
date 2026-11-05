import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/utils/ubah_jadwal.dart';

/// Uji otomatis untuk BB-76, BB-77, BB-78 (ubah jadwal booking, T-62).
Set<KunciSlot> _slot(String tanggal, String mulai, String selesai) {
  return kunciSlotBooking(
    tanggal: tanggal,
    jamMulai: mulai,
    jamSelesai: selesai,
  );
}

List<String> _teks(Set<KunciSlot> s) => (s.map((k) => '$k').toList()..sort());

void main() {
  group('kunciSlotBooking', () {
    test('19:00–21:00 → jam 19 dan 20 (selesai tidak ikut)', () {
      expect(
        _teks(_slot('2026-12-01', '19:00', '21:00')),
        ['2026-12-01_19', '2026-12-01_20'],
      );
    });

    test('satu jam saja', () {
      expect(_teks(_slot('2026-12-01', '08:00', '09:00')), ['2026-12-01_8']);
    });

    test('menit diabaikan', () {
      expect(
        _teks(_slot('2026-12-01', '08:30', '10:00')),
        ['2026-12-01_8', '2026-12-01_9'],
      );
    });

    test('jam selesai 24 (tutup tengah malam) tetap benar', () {
      expect(
        _teks(_slot('2026-12-01', '22:00', '24:00')),
        ['2026-12-01_22', '2026-12-01_23'],
      );
    });
  });

  group('KunciSlot (kesetaraan untuk Set)', () {
    test('isi sama dianggap satu kunci', () {
      const a = KunciSlot('2026-12-01', 19);
      const b = KunciSlot('2026-12-01', 19);
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      // Dimasukkan lewat daftar, supaya yang diuji memang perilaku Set.
      expect({...[a, b]}, hasLength(1));
    });

    test('beda tanggal atau beda jam dianggap berbeda', () {
      const dasar = KunciSlot('2026-12-01', 19);
      expect(dasar == const KunciSlot('2026-12-02', 19), isFalse);
      expect(dasar == const KunciSlot('2026-12-01', 20), isFalse);
    });

    test('toString sama dengan akhiran ID dokumen slotBooking', () {
      expect('${const KunciSlot('2026-12-01', 19)}', '2026-12-01_19');
    });
  });

  group('rencanaUbahSlot', () {
    test('pindah ke jam yang sama sekali berbeda (BB-76)', () {
      final rencana = rencanaUbahSlot(
        lama: _slot('2026-12-01', '19:00', '21:00'),
        baru: _slot('2026-12-01', '10:00', '12:00'),
      );
      expect(_teks(rencana.dihapus), ['2026-12-01_19', '2026-12-01_20']);
      expect(_teks(rencana.dibuat), ['2026-12-01_10', '2026-12-01_11']);
      expect(rencana.tidakBerubah, isFalse);
    });

    test('pindah ke tanggal lain, jam sama', () {
      final rencana = rencanaUbahSlot(
        lama: _slot('2026-12-01', '19:00', '20:00'),
        baru: _slot('2026-12-05', '19:00', '20:00'),
      );
      expect(_teks(rencana.dihapus), ['2026-12-01_19']);
      expect(_teks(rencana.dibuat), ['2026-12-05_19']);
    });

    test('menggeser jam yang TUMPANG TINDIH dengan jadwal sendiri (BB-78)', () {
      // 19:00–21:00 (jam 19,20) → 20:00–22:00 (jam 20,21)
      final rencana = rencanaUbahSlot(
        lama: _slot('2026-12-01', '19:00', '21:00'),
        baru: _slot('2026-12-01', '20:00', '22:00'),
      );
      // Jam 20 milik booking ini sendiri: TIDAK dihapus dan TIDAK dibuat.
      expect(_teks(rencana.dihapus), ['2026-12-01_19']);
      expect(_teks(rencana.dibuat), ['2026-12-01_21']);
    });

    test('memperpanjang durasi: hanya jam tambahan yang dibuat', () {
      final rencana = rencanaUbahSlot(
        lama: _slot('2026-12-01', '19:00', '20:00'),
        baru: _slot('2026-12-01', '19:00', '21:00'),
      );
      expect(rencana.dihapus, isEmpty);
      expect(_teks(rencana.dibuat), ['2026-12-01_20']);
    });

    test('memperpendek durasi: hanya jam yang dilepas yang dihapus', () {
      final rencana = rencanaUbahSlot(
        lama: _slot('2026-12-01', '19:00', '22:00'),
        baru: _slot('2026-12-01', '19:00', '20:00'),
      );
      expect(_teks(rencana.dihapus), ['2026-12-01_20', '2026-12-01_21']);
      expect(rencana.dibuat, isEmpty);
    });

    test('jadwal sama persis → tidak berubah', () {
      final rencana = rencanaUbahSlot(
        lama: _slot('2026-12-01', '19:00', '21:00'),
        baru: _slot('2026-12-01', '19:00', '21:00'),
      );
      expect(rencana.tidakBerubah, isTrue);
      expect(rencana.dihapus, isEmpty);
      expect(rencana.dibuat, isEmpty);
    });

    test('rencana tidak pernah menghapus dan membuat slot yang sama', () {
      final lama = _slot('2026-12-01', '18:00', '22:00');
      final baru = _slot('2026-12-01', '20:00', '23:00');
      final rencana = rencanaUbahSlot(lama: lama, baru: baru);
      expect(rencana.dihapus.intersection(rencana.dibuat), isEmpty);
      // Setelah diterapkan, himpunan akhir persis jadwal baru.
      final akhir = lama.difference(rencana.dihapus).union(rencana.dibuat);
      expect(akhir, baru);
    });
  });
}
