import 'package:flutter/services.dart' show PlatformException;
import 'package:url_launcher/url_launcher.dart';

/// Membuka [tautan] di aplikasi atau peramban di luar Sport Space — dipakai
/// tombol Bagikan dan WhatsApp (PRD AB-15, T-61, T-63).
///
/// Mengembalikan `false` kalau tidak ada yang bisa membuka tautannya, supaya
/// pemanggil (View) menampilkan `SnackBar` berbahasa Indonesia — bukan
/// diam-diam gagal.
///
/// Sengaja TIDAK memanggil `canLaunchUrl`: di Android 11+ itu butuh deklarasi
/// `<queries>` di `AndroidManifest.xml`, sedangkan `launchUrl` untuk tautan
/// `https` langsung jalan. Pola yang sama dipakai tombol "Buka di Google
/// Maps" (T-51).
Future<bool> bukaTautanEksternal(Uri tautan) async {
  try {
    return await launchUrl(tautan, mode: LaunchMode.externalApplication);
  } on PlatformException {
    return false;
  }
}
