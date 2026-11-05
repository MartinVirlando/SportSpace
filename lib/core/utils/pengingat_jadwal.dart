import '../../models/booking_model.dart';
import '../constants/app_strings.dart';

/// Satu pengingat yang harus muncul di HP — PRD AB-23, v1.5 (T-67).
///
/// Hanya pembawa data untuk tampilan notifikasi. [id] stabil untuk satu
/// booking (lihat [idPengingatDari]) supaya penjadwalan ulang menimpa
/// pengingat yang sama, bukan menumpuk.
class PengingatJadwal {
  final int id;

  /// Saat notifikasi harus muncul (waktu setempat), BUKAN saat main.
  final DateTime waktuTampil;
  final String judul;
  final String isi;

  const PengingatJadwal({
    required this.id,
    required this.waktuTampil,
    required this.judul,
    required this.isi,
  });
}

/// Berapa menit sebelum jam mulai pengingat muncul — PRD AB-23.
const menitSebelumMain = 60;

/// Paling banyak berapa pengingat yang dijadwalkan sekaligus (yang terdekat
/// lebih dulu). Android membatasi jumlah alarm per aplikasi, dan booking
/// jauh di depan baru dijadwalkan ketika sudah mendekat — aplikasi dibuka
/// lagi dan daftar dihitung ulang.
const batasPengingat = 20;

/// ID notifikasi yang stabil dari `bookingId` (FNV-1a 32-bit, ditulis
/// manual). `String.hashCode` milik Dart tidak dijamin sama antar-proses,
/// sedangkan ID ini harus sama setiap aplikasi dibuka supaya pengingat lama
/// bisa ditimpa. Hasilnya dipangkas ke 31 bit karena ID notifikasi Android
/// adalah `int` bertanda 32-bit.
int idPengingatDari(String bookingId) {
  var hash = 0x811c9dc5;
  for (final kode in bookingId.codeUnits) {
    hash ^= kode;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

/// Menentukan pengingat mana yang harus dijadwalkan untuk [daftar] booking
/// milik satu pengguna — PRD AB-23, BB-91…BB-95.
///
/// Fungsi murni: tanpa plugin, tanpa Firestore, tanpa membaca jam sendiri
/// ([sekarang] disuntikkan) sehingga bisa diuji otomatis
/// (`test/pengingat_jadwal_test.dart`).
///
/// Aturan:
/// - Hanya booking `DIKONFIRMASI`. `MENUNGGU` belum pasti terjadi; `DITOLAK`,
///   `DIBATALKAN`, dan `SELESAI` tidak perlu pengingat.
/// - Pengingat muncul [menitSebelum] menit sebelum `jamMulai`. Kalau saat itu
///   sudah lewat (atau tepat sekarang), booking itu dilewati — tidak ada
///   pengingat "terlambat".
/// - `tanggal` atau `jamMulai` yang tidak terbaca (data rusak) dilewati, bukan
///   membuat seluruh daftar gagal.
/// - Hasil diurutkan dari yang paling dekat, dan dipotong sampai
///   [batasPengingat].
List<PengingatJadwal> rencanakanPengingat(
  List<BookingModel> daftar,
  DateTime sekarang, {
  int menitSebelum = menitSebelumMain,
  int batas = batasPengingat,
}) {
  final hasil = <PengingatJadwal>[];

  for (final booking in daftar) {
    if (booking.status != 'DIKONFIRMASI') continue;

    final mulai = _waktuMulai(booking);
    if (mulai == null) continue;

    final waktuTampil = mulai.subtract(Duration(minutes: menitSebelum));
    if (!waktuTampil.isAfter(sekarang)) continue;

    hasil.add(
      PengingatJadwal(
        id: idPengingatDari(booking.bookingId),
        waktuTampil: waktuTampil,
        judul: AppStrings.pengingatJudul,
        isi: AppStrings.pengingatIsi(
          booking.namaLapangan,
          booking.jamMulai,
          booking.jamSelesai,
          menitSebelum,
        ),
      ),
    );
  }

  hasil.sort((a, b) => a.waktuTampil.compareTo(b.waktuTampil));
  return hasil.length > batas ? hasil.sublist(0, batas) : hasil;
}

/// `tanggal` ("yyyy-MM-dd") + `jamMulai` ("HH:mm") menjadi `DateTime`
/// setempat, atau `null` kalau formatnya tidak terbaca.
DateTime? _waktuMulai(BookingModel booking) {
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
