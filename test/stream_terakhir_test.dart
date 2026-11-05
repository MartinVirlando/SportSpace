import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sport_space/core/utils/stream_terakhir.dart';

/// Uji otomatis untuk perbaikan spinner "Aktivitas Saya" yang tidak pernah
/// selesai di Profil: pelanggan yang terlambat harus tetap menerima nilai
/// terakhir.
void main() {
  group('StreamTerakhir', () {
    test('pelanggan TERLAMBAT langsung menerima nilai terakhir', () async {
      final sumber = StreamController<int>.broadcast();
      final bungkus = StreamTerakhir<int>(sumber.stream);

      sumber.add(1);
      sumber.add(2);
      await Future<void>.delayed(Duration.zero);

      // Berlangganan SETELAH event lewat — dengan stream siaran biasa ini
      // tidak akan menerima apa pun.
      expect(await bungkus.stream.first, 2);

      await bungkus.dispose();
      await sumber.close();
    });

    test('stream siaran biasa memang kehilangan event lama (pembanding)', () async {
      final sumber = StreamController<int>.broadcast();
      sumber.add(1);
      await Future<void>.delayed(Duration.zero);

      final diterima = <int>[];
      final langganan = sumber.stream.listen(diterima.add);
      await Future<void>.delayed(Duration.zero);

      expect(diterima, isEmpty);
      await langganan.cancel();
      await sumber.close();
    });

    test('pelanggan awal dan terlambat sama-sama menerima event berikutnya',
        () async {
      final sumber = StreamController<int>.broadcast();
      final bungkus = StreamTerakhir<int>(sumber.stream);

      final awal = <int>[];
      final langgananAwal = bungkus.stream.listen(awal.add);

      sumber.add(10);
      await Future<void>.delayed(Duration.zero);

      final terlambat = <int>[];
      final langgananTerlambat = bungkus.stream.listen(terlambat.add);
      await Future<void>.delayed(Duration.zero);

      sumber.add(20);
      await Future<void>.delayed(Duration.zero);

      expect(awal, [10, 20]);
      expect(terlambat, [10, 20]);

      await langgananAwal.cancel();
      await langgananTerlambat.cancel();
      await bungkus.dispose();
      await sumber.close();
    });

    test('berlangganan, berhenti, lalu berlangganan lagi tetap dapat nilai',
        () async {
      final sumber = StreamController<String>.broadcast();
      final bungkus = StreamTerakhir<String>(sumber.stream);

      sumber.add('a');
      await Future<void>.delayed(Duration.zero);

      final pertama = bungkus.stream.listen((_) {});
      await Future<void>.delayed(Duration.zero);
      await pertama.cancel(); // meniru StreamBuilder yang terbuang saat digulir

      sumber.add('b');
      await Future<void>.delayed(Duration.zero);

      expect(await bungkus.stream.first, 'b');

      await bungkus.dispose();
      await sumber.close();
    });

    test('belum ada event: pelanggan menunggu, lalu menerima begitu datang',
        () async {
      final sumber = StreamController<int>.broadcast();
      final bungkus = StreamTerakhir<int>(sumber.stream);

      final diterima = <int>[];
      final langganan = bungkus.stream.listen(diterima.add);
      await Future<void>.delayed(Duration.zero);
      expect(diterima, isEmpty);

      sumber.add(7);
      await Future<void>.delayed(Duration.zero);
      expect(diterima, [7]);

      await langganan.cancel();
      await bungkus.dispose();
      await sumber.close();
    });

    test('galat diteruskan ke pelanggan awal dan terlambat', () async {
      final sumber = StreamController<int>.broadcast();
      final bungkus = StreamTerakhir<int>(sumber.stream);

      final galatAwal = <Object>[];
      final langgananAwal = bungkus.stream.listen((_) {}, onError: galatAwal.add);

      sumber.addError(Exception('gagal'));
      await Future<void>.delayed(Duration.zero);

      final galatTerlambat = <Object>[];
      final langgananTerlambat =
          bungkus.stream.listen((_) {}, onError: galatTerlambat.add);
      await Future<void>.delayed(Duration.zero);

      expect(galatAwal, hasLength(1));
      expect(galatTerlambat, hasLength(1));

      await langgananAwal.cancel();
      await langgananTerlambat.cancel();
      await bungkus.dispose();
      await sumber.close();
    });

    test('nilai baru menghapus galat lama untuk pelanggan baru', () async {
      final sumber = StreamController<int>.broadcast();
      final bungkus = StreamTerakhir<int>(sumber.stream);

      sumber.addError(Exception('sementara'));
      await Future<void>.delayed(Duration.zero);
      sumber.add(5);
      await Future<void>.delayed(Duration.zero);

      expect(await bungkus.stream.first, 5);

      await bungkus.dispose();
      await sumber.close();
    });

    test('objek stream SAMA tiap dibaca (StreamBuilder tidak resubscribe)', () {
      final sumber = StreamController<int>.broadcast();
      final bungkus = StreamTerakhir<int>(sumber.stream);

      expect(identical(bungkus.stream, bungkus.stream), isTrue);

      bungkus.dispose();
      sumber.close();
    });

    test('mendukung banyak pelanggan sekaligus', () async {
      final sumber = StreamController<int>.broadcast();
      final bungkus = StreamTerakhir<int>(sumber.stream);
      sumber.add(3);
      await Future<void>.delayed(Duration.zero);

      final hasil = await Future.wait([
        bungkus.stream.first,
        bungkus.stream.first,
        bungkus.stream.first,
      ]);
      expect(hasil, [3, 3, 3]);

      await bungkus.dispose();
      await sumber.close();
    });
  });
}
