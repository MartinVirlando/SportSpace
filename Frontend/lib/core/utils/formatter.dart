import 'package:intl/intl.dart';

/// Format rupiah, tanggal, dan jam.
///
/// CLAUDE.md: jangan memformat manual di dalam widget — semua lewat sini,
/// supaya kalau formatnya berubah cukup satu tempat yang disunting.
class Formatter {
  Formatter._();

  static final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// 150000 → "Rp 150.000"
  static String rupiah(int nilai) => _rupiah.format(nilai);

  /// 150000 → "Rp 150k" — versi ringkas untuk kartu, mengikuti Figma.
  static String rupiahRingkas(int nilai) {
    if (nilai >= 1000000) {
      final juta = nilai / 1000000;
      return 'Rp ${juta.toStringAsFixed(juta.truncateToDouble() == juta ? 0 : 1)}jt';
    }
    if (nilai >= 1000) return 'Rp ${nilai ~/ 1000}k';
    return 'Rp $nilai';
  }

  /// DateTime → "Sen, 17 Agu 2026"
  static String tanggal(DateTime waktu) =>
      DateFormat('EEE, d MMM yyyy', 'id_ID').format(waktu);

  /// DateTime → "19:00"
  static String jam(DateTime waktu) => DateFormat('HH:mm').format(waktu);

  /// DateTime → "Sen, 17 Agu · 19:00"
  static String tanggalDanJam(DateTime waktu) =>
      '${DateFormat('EEE, d MMM', 'id_ID').format(waktu)} · ${jam(waktu)}';

  /// 3.7 → "3.7 km" · 0.42 → "420 m"
  static String jarak(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }
}
