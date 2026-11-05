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
String teksBagikanAktivitas(AktivitasBermainModel a) {
  final tingkat = a.tingkatKemampuan;
  final catatan = a.catatan;

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
