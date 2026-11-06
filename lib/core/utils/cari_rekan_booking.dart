import '../../models/booking_model.dart';
import '../constants/app_sports.dart';
import 'waktu_booking.dart';

/// Nilai awal form Buat Aktivitas (L-08) yang diturunkan dari satu booking —
/// PRD AB-25, v1.5 (T-69). Hanya pembawa data; tidak ada logika di sini.
class IsianAwalAktivitas {
  final String lapanganId;
  final String namaLapangan;

  /// Hanya tanggalnya (jam 00:00); jamnya ada di [jam] dan [menit].
  final DateTime tanggal;
  final int jam;
  final int menit;

  /// Olahraga yang dipilih otomatis, atau `null` kalau lapangannya tidak
  /// punya satu pun dari empat cabang yang didukung (form memakai bawaannya).
  final String? olahraga;

  const IsianAwalAktivitas({
    required this.lapanganId,
    required this.namaLapangan,
    required this.tanggal,
    required this.jam,
    required this.menit,
    required this.olahraga,
  });
}

/// Apakah tombol "Cari Rekan" boleh tampil untuk [booking] — AB-25, BB-101.
///
/// - Hanya `DIKONFIRMASI`: booking `MENUNGGU` belum pasti terjadi, dan
///   mengundang orang ke jadwal yang bisa ditolak mitra membingungkan mereka.
/// - Jam mulainya harus masih di depan [sekarang]: aktivitas yang waktunya
///   sudah lewat ditolak form (BB-15), jadi tombolnya tidak ditawarkan.
/// - Jam mulai yang tidak terbaca → `false`, bukan galat.
bool bolehCariRekan(BookingModel booking, DateTime sekarang) {
  if (booking.status != 'DIKONFIRMASI') return false;
  final mulai = waktuMulaiBooking(booking);
  return mulai != null && mulai.isAfter(sekarang);
}

/// Menurunkan nilai awal form dari [booking] — AB-25, BB-102.
///
/// [jenisOlahragaLapangan] diisi `lapangan.jenisOlahraga`; olahraga yang
/// dipilih adalah yang PERTAMA di daftar itu yang termasuk empat cabang
/// didukung (satu lapangan bisa melayani lebih dari satu cabang — pembuat
/// masih bisa menggantinya di form).
///
/// Mengembalikan `null` kalau jam mulai booking tidak terbaca.
IsianAwalAktivitas? isianAwalDariBooking(
  BookingModel booking, {
  List<String> jenisOlahragaLapangan = const [],
}) {
  final mulai = waktuMulaiBooking(booking);
  if (mulai == null) return null;

  const didukung = [
    AppSports.futsal,
    AppSports.miniSoccer,
    AppSports.badminton,
    AppSports.padel,
  ];
  String? olahraga;
  for (final kode in jenisOlahragaLapangan) {
    if (didukung.contains(kode)) {
      olahraga = kode;
      break;
    }
  }

  return IsianAwalAktivitas(
    lapanganId: booking.lapanganId,
    namaLapangan: booking.namaLapangan,
    tanggal: DateTime(mulai.year, mulai.month, mulai.day),
    jam: mulai.hour,
    menit: mulai.minute,
    olahraga: olahraga,
  );
}
