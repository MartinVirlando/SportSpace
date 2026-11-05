import '../../models/aktivitas_bermain_model.dart';
import '../../models/lapangan_model.dart';
import '../constants/app_aktivitas.dart';
import '../constants/app_sports.dart';
import '../constants/app_strings.dart';
import 'formatter.dart';

/// Penyusun tautan dan teks WhatsApp — PRD AB-15, v1.4 (T-61, T-63).
///
/// Semua fungsi di sini MURNI: tanpa Firestore, tanpa `url_launcher`, tanpa
/// state — masukan → keluaran saja, jadi bisa diuji otomatis
/// (`test/whatsapp_test.dart`). Membuka tautannya (`launchUrl`) dilakukan
/// View lewat `tautan_eksternal.dart`.

// ---------- Hubungi (T-61) ----------

/// Mengubah [nomorTelepon] ke format internasional tanpa `+` untuk `wa.me`,
/// atau `null` kalau nomor itu bukan nomor seluler yang bisa dipakai
/// WhatsApp — BB-60, BB-61.
///
/// Langkah (PRD AB-15):
/// 1. buang semua karakter bukan angka (spasi, `-`, `+`, tanda kurung);
/// 2. awalan `0` diganti `62` (`0813…` → `62813…`);
/// 3. hanya nomor seluler Indonesia yang lolos: diawali `628` dan panjang
///    total 11–15 digit (batas nomor internasional 15 digit).
///
/// Telepon rumah (`021…` → `6221…`) dan nomor kosong menghasilkan `null`,
/// jadi tombol WhatsApp tidak muncul — WhatsApp tidak bisa dipakai di sana.
String? nomorWhatsAppDari(String nomorTelepon) {
  var angka = nomorTelepon.replaceAll(RegExp(r'[^0-9]'), '');
  if (angka.startsWith('0')) {
    angka = '62${angka.substring(1)}';
  }

  final seluler = angka.startsWith('628');
  final panjangWajar = angka.length >= 11 && angka.length <= 15;
  return seluler && panjangWajar ? angka : null;
}

/// Tautan `wa.me` yang membuka percakapan langsung dengan
/// [nomorInternasional] (hasil [nomorWhatsAppDari], mis. `6281316441741`).
Uri tautanHubungiWhatsApp(String nomorInternasional) {
  return Uri.parse('https://wa.me/$nomorInternasional');
}

// ---------- Bagikan (T-63) ----------

/// Tautan `wa.me` yang membuka WhatsApp dengan [teks] sudah terisi dan
/// pengguna tinggal memilih kontak/grup tujuannya.
///
/// `Uri.encodeComponent` (bukan `Uri.https(queryParameters: ...)`) dipakai
/// supaya spasi menjadi `%20` dan baris baru `%0A` — itu yang pasti dipahami
/// WhatsApp; bentuk `+` untuk spasi tidak selalu dikenali.
Uri tautanBagikanWhatsApp(String teks) {
  return Uri.parse('https://wa.me/?text=${Uri.encodeComponent(teks)}');
}

/// Teks ringkasan aktivitas untuk dibagikan — BB-58. Baris tingkat kemampuan
/// dan catatan hanya muncul kalau ada isinya (dokumen lama tidak punya
/// tingkat).
///
/// [sertakanKode] (v1.5, T-64): untuk aktivitas privat, ikutkan kode akses
/// supaya penerima bisa bergabung. Diisi `true` HANYA oleh pembuat dan
/// peserta; siapa pun yang tidak terlibat tidak boleh ikut menyebarkan kode.
/// Aktivitas publik tidak pernah memuat kode.
String teksBagikanAktivitas(
  AktivitasBermainModel a, {
  bool sertakanKode = false,
}) {
  final tingkat = a.tingkatKemampuan;
  final catatan = a.catatan;
  final kode = a.kodeAkses;
  final adaKode = sertakanKode &&
      a.visibilitas == AppVisibilitas.privat &&
      kode != null &&
      kode.isNotEmpty;

  final baris = <String>[
    AppStrings.bagikanJudulAktivitas,
    '',
    '${AppSports.ikonDari(a.jenisOlahraga)} '
        '${AppSports.labelDari(a.jenisOlahraga)} · '
        '${AppJenisAktivitas.labelDari(a.jenisAktivitas)}'
        '${tingkat == null ? '' : ' · ${AppTingkat.labelDari(tingkat)}'}',
    '📍 ${AppStrings.bagikanLapangan}: ${a.namaLapangan}',
    '🕐 ${AppStrings.bagikanWaktu}: ${Formatter.tanggalDanJam(a.waktu)}',
    '👥 ${AppStrings.bagikanPemain}: '
        '${a.jumlahPemainSaatIni}/${a.jumlahPemainDibutuhkan}',
    '💰 ${AppStrings.bagikanBiaya}: ${Formatter.biayaPerOrang(a.biayaPerOrang)}'
        '${a.biayaPerOrang > 0 ? ' (${AppStrings.bantuBiayaPerOrang})' : ''}',
    if (catatan != null && catatan.trim().isNotEmpty)
      '📝 ${AppStrings.bagikanCatatan}: ${catatan.trim()}',
    if (adaKode) '🔒 ${AppStrings.bagikanKodeAkses}: $kode',
  ];

  return baris.join('\n');
}

/// Teks ringkasan lapangan untuk dibagikan — BB-59. Tautan Google Maps hanya
/// ikut kalau `tautanMaps` terisi.
String teksBagikanLapangan(LapanganModel l) {
  final olahraga = l.jenisOlahraga.map(AppSports.labelDari).join(', ');

  final baris = <String>[
    AppStrings.bagikanJudulLapangan,
    '',
    '🏟️ ${l.nama}',
    if (olahraga.isNotEmpty) '⚽ ${AppStrings.bagikanOlahraga}: $olahraga',
    '📍 ${AppStrings.bagikanAlamat}: ${l.alamat}',
    '🕐 ${AppStrings.bagikanJamBuka}: ${l.jamBuka} – ${l.jamTutup}',
    if (l.tautanMaps.isNotEmpty) '🗺️ ${AppStrings.bagikanPeta}: ${l.tautanMaps}',
  ];

  return baris.join('\n');
}
