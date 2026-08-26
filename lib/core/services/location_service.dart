import 'package:geolocator/geolocator.dart';

/// Hasil permintaan lokasi. Dipakai ViewModel untuk memutuskan
/// apa yang ditampilkan (PRD AB-03).
enum StatusLokasi {
  /// GPS berhasil dibaca.
  berhasil,

  /// Pengguna menolak izin lokasi.
  izinDitolak,

  /// Pengguna menolak permanen — hanya bisa diaktifkan lewat Pengaturan.
  izinDitolakPermanen,

  /// Layanan lokasi di perangkat sedang mati.
  layananMati,

  /// Izin sudah diberikan tapi GPS gagal terbaca (timeout, sinyal lemah
  /// di dalam ruangan, atau error platform lain dari `geolocator`).
  gagalMembaca,
}

/// Posisi pengguna beserta status bagaimana ia diperoleh.
class HasilLokasi {
  final StatusLokasi status;
  final double? latitude;
  final double? longitude;

  const HasilLokasi({required this.status, this.latitude, this.longitude});

  bool get ada => latitude != null && longitude != null;
}

/// Pembungkus `geolocator`.
///
/// Seluruh urusan izin dan pembacaan GPS dikumpulkan di sini supaya
/// ViewModel tidak perlu tahu detail package-nya. Kalau suatu saat
/// geolocator diganti, cukup file ini yang berubah.
///
/// Kelas ini TIDAK pernah melempar Exception untuk kasus izin ditolak —
/// itu kondisi normal yang harus ditangani UI (AB-03 poin 4: aplikasi
/// tidak boleh crash dalam kondisi apa pun).
class LocationService {
  Future<HasilLokasi> ambilPosisi() async {
    // 1. Layanan lokasi perangkat menyala atau tidak.
    final layananAktif = await Geolocator.isLocationServiceEnabled();
    if (!layananAktif) {
      return const HasilLokasi(status: StatusLokasi.layananMati);
    }

    // 2. Cek izin, minta kalau belum diberikan.
    var izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
    }

    if (izin == LocationPermission.deniedForever) {
      return const HasilLokasi(status: StatusLokasi.izinDitolakPermanen);
    }
    if (izin == LocationPermission.denied) {
      return const HasilLokasi(status: StatusLokasi.izinDitolak);
    }

    // 3. Izin ada — baca posisinya.
    //
    // Dibungkus try/catch: `getCurrentPosition` melempar `TimeoutException`
    // kalau `timeLimit` di bawah terlampaui (umum di dalam ruangan/sinyal
    // GPS lemah), dan bisa juga melempar error platform lain. Tanpa ini,
    // exception itu menjalar ke HomeViewModel/MapViewModel dan langsung
    // dianggap "gagal total" — MELEWATI cadangan lokasi default (AB-03),
    // padahal harusnya diperlakukan sama seperti izin ditolak/layanan
    // mati: tetap coba `lokasiDefault` dulu sebelum menyerah. Kelas ini
    // sengaja tidak pernah melempar Exception (lihat docstring di atas).
    try {
      final posisi = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return HasilLokasi(
        status: StatusLokasi.berhasil,
        latitude: posisi.latitude,
        longitude: posisi.longitude,
      );
    } catch (_) {
      return const HasilLokasi(status: StatusLokasi.gagalMembaca);
    }
  }

  /// Membuka pengaturan lokasi perangkat — dipakai tombol pada
  /// tampilan "izin ditolak".
  Future<void> bukaPengaturanLokasi() => Geolocator.openLocationSettings();
}
