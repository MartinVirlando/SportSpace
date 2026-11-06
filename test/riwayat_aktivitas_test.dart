import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/utils/riwayat_aktivitas.dart';
import 'package:sport_space/models/aktivitas_bermain_model.dart';

/// Uji otomatis untuk "Riwayat Main" di Profil — T-70, PRD AB-26,
/// BB-105 dan BB-106.
AktivitasBermainModel _a(
  String id,
  DateTime waktu, {
  String status = 'TERBUKA',
}) {
  return AktivitasBermainModel(
    aktivitasId: id,
    jenisOlahraga: 'badminton',
    jumlahPemainDibutuhkan: 4,
    jumlahPemainSaatIni: 1,
    waktu: waktu,
    lapanganId: 'l1',
    namaLapangan: 'Candra',
    pembuatId: 'u1',
    namaPembuat: 'Pengguna',
    status: status,
    peserta: const ['u1'],
    dibuatPada: DateTime(2026, 11, 1),
    jenisAktivitas: 'main_bareng',
    biayaPerOrang: 0,
  );
}

List<String> _id(List<AktivitasBermainModel> daftar) =>
    daftar.map((a) => a.aktivitasId).toList();

void main() {
  final sekarang = DateTime(2026, 11, 10, 12);

  group('pisahkanAktivitasSaya — pemisahan (BB-105)', () {
    test('yang belum mulai masuk mendatang, yang sudah lewat masuk riwayat',
        () {
      final hasil = pisahkanAktivitasSaya(
        [
          _a('depan', DateTime(2026, 11, 12, 19)),
          _a('lalu', DateTime(2026, 11, 5, 19)),
        ],
        sekarang,
      );

      expect(_id(hasil.mendatang), ['depan']);
      expect(_id(hasil.riwayat), ['lalu']);
      expect(hasil.jumlahRiwayat, 1);
    });

    test('tepat pada waktu sekarang masih mendatang', () {
      final hasil = pisahkanAktivitasSaya([_a('x', sekarang)], sekarang);
      expect(_id(hasil.mendatang), ['x']);
      expect(hasil.riwayat, isEmpty);
    });

    test('satu detik sebelum sekarang sudah riwayat', () {
      final hasil = pisahkanAktivitasSaya(
        [_a('x', sekarang.subtract(const Duration(seconds: 1)))],
        sekarang,
      );
      expect(hasil.mendatang, isEmpty);
      expect(_id(hasil.riwayat), ['x']);
    });

    test('daftar kosong menghasilkan dua daftar kosong', () {
      final hasil = pisahkanAktivitasSaya([], sekarang);
      expect(hasil.mendatang, isEmpty);
      expect(hasil.riwayat, isEmpty);
      expect(hasil.jumlahRiwayat, 0);
    });

    test('status DIBATALKAN tidak masuk ke keduanya', () {
      final hasil = pisahkanAktivitasSaya(
        [
          _a('batal-depan', DateTime(2026, 11, 12), status: 'DIBATALKAN'),
          _a('batal-lalu', DateTime(2026, 11, 1), status: 'DIBATALKAN'),
          _a('ok', DateTime(2026, 11, 12)),
        ],
        sekarang,
      );

      expect(_id(hasil.mendatang), ['ok']);
      expect(hasil.riwayat, isEmpty);
      expect(hasil.jumlahRiwayat, 0);
    });

    test('status PENUH dan SELESAI tetap ikut (menurut waktu)', () {
      final hasil = pisahkanAktivitasSaya(
        [
          _a('penuh', DateTime(2026, 11, 12), status: 'PENUH'),
          _a('selesai', DateTime(2026, 11, 1), status: 'SELESAI'),
        ],
        sekarang,
      );

      expect(_id(hasil.mendatang), ['penuh']);
      expect(_id(hasil.riwayat), ['selesai']);
    });
  });

  group('pisahkanAktivitasSaya — urutan', () {
    test('mendatang: yang paling dekat dulu', () {
      final hasil = pisahkanAktivitasSaya(
        [
          _a('jauh', DateTime(2026, 12, 1)),
          _a('dekat', DateTime(2026, 11, 11)),
          _a('tengah', DateTime(2026, 11, 20)),
        ],
        sekarang,
      );
      expect(_id(hasil.mendatang), ['dekat', 'tengah', 'jauh']);
    });

    test('riwayat: yang paling baru dulu', () {
      final hasil = pisahkanAktivitasSaya(
        [
          _a('lama', DateTime(2026, 9, 1)),
          _a('baru', DateTime(2026, 11, 9)),
          _a('tengah', DateTime(2026, 10, 10)),
        ],
        sekarang,
      );
      expect(_id(hasil.riwayat), ['baru', 'tengah', 'lama']);
    });

    test('waktu sama: urutan tetap menurut aktivitasId (stabil)', () {
      final waktu = DateTime(2026, 11, 15, 19);
      final a = pisahkanAktivitasSaya(
        [_a('c', waktu), _a('a', waktu), _a('b', waktu)],
        sekarang,
      );
      final b = pisahkanAktivitasSaya(
        [_a('b', waktu), _a('c', waktu), _a('a', waktu)],
        sekarang,
      );
      expect(_id(a.mendatang), ['a', 'b', 'c']);
      expect(_id(b.mendatang), ['a', 'b', 'c']);
    });
  });

  group('pisahkanAktivitasSaya — batas riwayat (BB-106)', () {
    List<AktivitasBermainModel> lampau(int n) => [
          for (var i = 1; i <= n; i++)
            _a('h$i', sekarang.subtract(Duration(days: i))),
        ];

    test('dipotong sampai batasRiwayatMain; yang terbaru dipertahankan', () {
      final hasil = pisahkanAktivitasSaya(lampau(25), sekarang);

      expect(hasil.riwayat, hasLength(batasRiwayatMain));
      expect(hasil.riwayat.first.aktivitasId, 'h1'); // kemarin
      expect(hasil.riwayat.last.aktivitasId, 'h$batasRiwayatMain');
    });

    test('jumlahRiwayat memuat total sebelum dipotong', () {
      expect(pisahkanAktivitasSaya(lampau(25), sekarang).jumlahRiwayat, 25);
    });

    test('tepat sebatas batas: tidak ada yang terpotong', () {
      final hasil = pisahkanAktivitasSaya(lampau(batasRiwayatMain), sekarang);
      expect(hasil.riwayat, hasLength(batasRiwayatMain));
      expect(hasil.jumlahRiwayat, batasRiwayatMain);
    });

    test('batas bisa diubah lewat parameter', () {
      final hasil = pisahkanAktivitasSaya(lampau(5), sekarang, batasRiwayat: 2);
      expect(_id(hasil.riwayat), ['h1', 'h2']);
      expect(hasil.jumlahRiwayat, 5);
    });

    test('batas tidak memengaruhi daftar mendatang', () {
      final banyak = [
        for (var i = 1; i <= 15; i++)
          _a('d$i', sekarang.add(Duration(days: i))),
      ];
      final hasil = pisahkanAktivitasSaya(banyak, sekarang);
      expect(hasil.mendatang, hasLength(15));
    });
  });

  test('daftar asli tidak diubah', () {
    final daftar = [
      _a('b', DateTime(2026, 11, 12)),
      _a('a', DateTime(2026, 11, 1)),
    ];
    pisahkanAktivitasSaya(daftar, sekarang);
    expect(_id(daftar), ['b', 'a']);
  });
}
