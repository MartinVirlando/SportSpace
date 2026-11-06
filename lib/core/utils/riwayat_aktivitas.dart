import '../../models/aktivitas_bermain_model.dart';

/// Paling banyak berapa aktivitas lampau yang ditampilkan di "Riwayat Main".
/// Cukup untuk melihat kegiatan terakhir tanpa membuat Profil sangat panjang;
/// jumlah seluruhnya tetap diberitahukan lewat [AktivitasSaya.jumlahRiwayat].
const batasRiwayatMain = 10;

/// Hasil memisahkan aktivitas milik satu pengguna menjadi yang akan datang
/// dan yang sudah lewat — PRD AB-26, v1.5 (T-70).
class AktivitasSaya {
  /// Yang belum mulai, DIURUTKAN dari yang paling dekat.
  final List<AktivitasBermainModel> mendatang;

  /// Yang sudah lewat, DIURUTKAN dari yang paling baru, dipotong sampai
  /// `batasRiwayat`.
  final List<AktivitasBermainModel> riwayat;

  /// Jumlah SELURUH aktivitas lampau, sebelum dipotong — supaya tampilan bisa
  /// berkata "10 dari 23".
  final int jumlahRiwayat;

  const AktivitasSaya({
    required this.mendatang,
    required this.riwayat,
    required this.jumlahRiwayat,
  });
}

/// Memisahkan [daftar] menjadi aktivitas mendatang dan riwayat main — PRD
/// AB-26, BB-105 dan BB-106.
///
/// Fungsi murni: tanpa Firestore dan tanpa membaca jam sendiri ([sekarang]
/// disuntikkan), sehingga bisa diuji otomatis (`test/riwayat_aktivitas_test.dart`).
///
/// Aturan:
/// - **Mendatang**: `waktu` belum lewat ([sekarang] atau sesudahnya). Tepat
///   pada [sekarang] dianggap masih mendatang (belum lewat).
/// - **Riwayat**: `waktu` sudah lewat.
/// - Aktivitas berstatus `DIBATALKAN` tidak masuk ke keduanya. (Pembatalan
///   lewat aplikasi menghapus dokumennya, tapi dokumen lama bisa saja masih
///   berstatus itu.)
/// - Waktu yang sama diurutkan menurut `aktivitasId` supaya urutannya tidak
///   berubah-ubah antar pemanggilan.
///
/// Statistik dan lencana di Profil (AB-12, AB-14) TETAP menghitung seluruh
/// daftar — fungsi ini hanya untuk tampilan.
AktivitasSaya pisahkanAktivitasSaya(
  List<AktivitasBermainModel> daftar,
  DateTime sekarang, {
  int batasRiwayat = batasRiwayatMain,
}) {
  final mendatang = <AktivitasBermainModel>[];
  final lampau = <AktivitasBermainModel>[];

  for (final a in daftar) {
    if (a.status == 'DIBATALKAN') continue;
    if (a.waktu.isBefore(sekarang)) {
      lampau.add(a);
    } else {
      mendatang.add(a);
    }
  }

  int cocok(AktivitasBermainModel a, AktivitasBermainModel b) {
    final menurutWaktu = a.waktu.compareTo(b.waktu);
    return menurutWaktu != 0 ? menurutWaktu : a.aktivitasId.compareTo(b.aktivitasId);
  }

  mendatang.sort(cocok); // yang paling dekat dulu
  lampau.sort((a, b) => cocok(b, a)); // yang paling baru dulu

  return AktivitasSaya(
    mendatang: mendatang,
    riwayat: lampau.length > batasRiwayat ? lampau.sublist(0, batasRiwayat) : lampau,
    jumlahRiwayat: lampau.length,
  );
}
