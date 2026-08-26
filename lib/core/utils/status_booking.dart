import '../../models/booking_model.dart';

/// AB-07: status booking SELESAI dihitung di klien (tidak ada Cloud
/// Functions) — begitu `tanggal`+`jamSelesai` sudah lewat dari sekarang.
/// Dipakai bersama oleh ProfilViewModel (sisi penyewa) dan
/// DashboardMitraViewModel (sisi mitra) supaya kedua peran melihat status
/// yang sama, bukan hanya salah satu sisi yang menghitung ulang.
bool sudahLewatJamSelesai(BookingModel booking) {
  final tgl = booking.tanggal.split('-').map(int.parse).toList();
  final jam = booking.jamSelesai.split(':').map(int.parse).toList();
  final waktuSelesai = DateTime(tgl[0], tgl[1], tgl[2], jam[0], jam[1]);
  return waktuSelesai.isBefore(DateTime.now());
}

/// Status yang DITAMPILKAN untuk satu booking — PRD AB-07, BB-28.
///
/// Dihitung ulang dari `tanggal`+`jamSelesai` dibanding waktu sekarang,
/// BUKAN langsung field `status` mentah — supaya baris yang baru saja
/// lewat jam selesainya langsung tampil `SELESAI` walau tulis balik ke
/// Firestore belum tuntas.
String statusTampilanBooking(BookingModel booking) {
  if (booking.status == 'DIKONFIRMASI' && sudahLewatJamSelesai(booking)) {
    return 'SELESAI';
  }
  return booking.status;
}
