import '../../models/booking_model.dart';

/// `tanggal` ("yyyy-MM-dd") + `jamMulai` ("HH:mm") milik [booking] menjadi
/// `DateTime` setempat, atau `null` kalau formatnya tidak terbaca (mis. data
/// rusak atau field kosong).
///
/// Dipakai bersama oleh pengingat jadwal (AB-23) dan "Cari rekan dari
/// booking" (AB-25), supaya keduanya membaca jam mulai dengan cara yang sama.
/// Sengaja mengembalikan `null` — bukan melempar galat — agar satu booking
/// rusak tidak menggagalkan seluruh daftar.
DateTime? waktuMulaiBooking(BookingModel booking) {
  final tanggal = booking.tanggal.split('-');
  final jam = booking.jamMulai.split(':');
  if (tanggal.length != 3 || jam.length != 2) return null;

  final tahun = int.tryParse(tanggal[0]);
  final bulan = int.tryParse(tanggal[1]);
  final hari = int.tryParse(tanggal[2]);
  final jamMulai = int.tryParse(jam[0]);
  final menit = int.tryParse(jam[1]);
  if (tahun == null ||
      bulan == null ||
      hari == null ||
      jamMulai == null ||
      menit == null) {
    return null;
  }

  return DateTime(tahun, bulan, hari, jamMulai, menit);
}
