import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sport_space/core/utils/formatter.dart';

/// T-28: tanggal booking disimpan sebagai teks "yyyy-MM-dd" dan harus
/// ditampilkan lewat Formatter, bukan mentah.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Formatter.tanggalDariTeks', () {
    test('mengubah "yyyy-MM-dd" menjadi tanggal Indonesia', () {
      // 27 November 2026 jatuh pada hari Jumat.
      expect(Formatter.tanggalDariTeks('2026-11-27'), 'Jum, 27 Nov 2026');
    });

    test('teks yang bukan tanggal dikembalikan apa adanya', () {
      expect(Formatter.tanggalDariTeks('bukan tanggal'), 'bukan tanggal');
      expect(Formatter.tanggalDariTeks(''), '');
    });
  });
}
