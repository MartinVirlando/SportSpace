/// Apakah lapangan sedang buka pada waktu [sekarang] — PRD AB-16, v1.5
/// (T-57), BB-64.
///
/// [jamBuka] dan [jamTutup] berformat `"HH:mm"` (PRD 6.2). Aturannya:
/// - Jam tutup yang LEBIH KECIL ATAU SAMA dengan jam buka berarti tutupnya
///   di hari berikutnya. `"00:00"` berarti TENGAH MALAM, bukan jam 0 di hari
///   yang sama — 14 dari 30 lapangan seed tutup `"00:00"`. Perbandingan
///   menit-mentah akan salah menganggapnya selalu tutup. Aturan yang sama
///   dipakai `ajukan_reservasi_screen.dart` (`_jamTutupHour`).
/// - Jam buka SAMA dengan jam tutup (mis. `00:00`–`00:00`) berarti buka
///   24 jam.
///
/// Fungsi murni: tidak membaca jam sendiri ([sekarang] diberikan pemanggil)
/// supaya bisa diuji dengan jam apa pun (`test/jam_buka_test.dart`). Jam
/// memakai zona waktu perangkat.
///
/// Data yang rusak (format bukan `HH:mm`) dianggap tidak buka, bukan crash.
bool sedangBuka(String jamBuka, String jamTutup, DateTime sekarang) {
  final buka = _menit(jamBuka);
  var tutup = _menit(jamTutup);
  if (buka == null || tutup == null) return false;

  // Tutup <= buka → tutupnya lewat tengah malam: geser ke hari berikutnya.
  if (tutup <= buka) tutup += 24 * 60;

  final sekarangMenit = sekarang.hour * 60 + sekarang.minute;

  // Dua kemungkinan: sekarang masih di hari yang sama dengan jam buka, atau
  // sudah lewat tengah malam (bagian sesudah 24:00 dari jam operasional).
  final hariIni = sekarangMenit >= buka && sekarangMenit < tutup;
  final lewatTengahMalam =
      sekarangMenit + 24 * 60 >= buka && sekarangMenit + 24 * 60 < tutup;

  return hariIni || lewatTengahMalam;
}

/// "HH:mm" → menit sejak 00:00, atau `null` kalau formatnya salah.
int? _menit(String hhmm) {
  final bagian = hhmm.split(':');
  if (bagian.length != 2) return null;
  final jam = int.tryParse(bagian[0]);
  final menit = int.tryParse(bagian[1]);
  if (jam == null || menit == null) return null;
  if (jam < 0 || jam > 24 || menit < 0 || menit > 59) return null;
  return jam * 60 + menit;
}
