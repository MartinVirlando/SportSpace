import 'dart:math';

/// Menghitung jarak (km) antara dua koordinat GPS dengan Haversine Formula.
///
/// Rumus ini WAJIB ditulis manual (PRD AB-01) — tidak boleh memakai
/// `Distance()` dari package latlong2. Ini inti kontribusi penelitian
/// dan pasti ditanya penguji, jadi setiap baris di bawah harus bisa
/// kamu jelaskan sendiri.
///
/// Sesuai persamaan (1)(2)(3) di Bab 2.3:
///
///   a = sin²(Δφ/2) + cos φ₁ · cos φ₂ · sin²(Δλ/2)
///   c = 2 · atan2(√a, √(1−a))
///   d = R · c
///
/// dengan R = 6371 km (jari-jari rata-rata bumi).
double hitungJarakHaversine(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double R = 6371.0;

  // Rumus trigonometri Dart bekerja dalam radian, sedangkan koordinat GPS
  // dalam derajat. Konversinya: radian = derajat × π / 180.
  double toRad(double derajat) => derajat * pi / 180.0;

  final dLat = toRad(lat2 - lat1);
  final dLon = toRad(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(toRad(lat1)) * cos(toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
}
