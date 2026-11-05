import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_strings.dart';
import '../utils/pengingat_jadwal.dart';

/// Pembungkus plugin notifikasi lokal — PRD AB-23, v1.5 (T-67).
///
/// Notifikasi dijadwalkan DI HP (lewat AlarmManager Android), bukan dikirim
/// dari server: tidak memakai Firebase Cloud Messaging atau Cloud Functions
/// (dilarang CLAUDE.md), jadi tidak ada biaya dan tidak butuh jaringan saat
/// pengingat muncul. Kelas ini satu-satunya tempat yang menyentuh plugin
/// (seperti `LocationService` untuk GPS); ViewModel hanya memanggilnya.
class PengingatService {
  static const _idKanal = 'pengingat_jadwal';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  /// Dipanggil sekali di `main()` sebelum `runApp`. Menyiapkan plugin dan
  /// membuat kanal notifikasi (Android 8+ mewajibkan kanal; pengguna bisa
  /// mematikannya terpisah lewat pengaturan HP).
  Future<void> inisialisasi() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _idKanal,
        AppStrings.namaKanalPengingat,
        description: AppStrings.deskripsiKanalPengingat,
        importance: Importance.high,
      ),
    );
  }

  /// Apakah pengguna mengizinkan notifikasi untuk aplikasi ini.
  Future<bool> izinDiberikan() async =>
      await _android?.areNotificationsEnabled() ?? false;

  /// Memunculkan dialog izin notifikasi (Android 13+). Mengembalikan `true`
  /// kalau diizinkan. Android berhenti menampilkan dialog setelah ditolak
  /// dua kali; pada saat itu pengguna harus membukanya lewat pengaturan HP.
  Future<bool> mintaIzin() async =>
      await _android?.requestNotificationsPermission() ?? false;

  /// Mengganti SELURUH pengingat terjadwal dengan [daftar]: yang lama
  /// dibatalkan lebih dulu, lalu yang baru dijadwalkan. Dengan begitu
  /// booking yang dibatalkan atau dijadwal ulang otomatis hilang
  /// pengingatnya, tanpa perlu melacak mana yang berubah.
  ///
  /// `cancelAllPendingNotifications` hanya membatalkan yang BELUM muncul;
  /// notifikasi yang sudah ada di bilah notifikasi dibiarkan.
  ///
  /// Mode `inexactAllowWhileIdle`: waktu muncul boleh bergeser beberapa
  /// menit, tapi tidak butuh izin alarm tepat-waktu (yang perlu persetujuan
  /// khusus). Untuk "satu jam sebelum main", itu cukup.
  Future<void> jadwalkan(List<PengingatJadwal> daftar) async {
    await _plugin.cancelAllPendingNotifications();

    for (final pengingat in daftar) {
      await _plugin.zonedSchedule(
        id: pengingat.id,
        title: pengingat.judul,
        body: pengingat.isi,
        // Waktu setempat → instan mutlak; lokasi zona waktu tidak
        // memengaruhi kapan alarm berbunyi, jadi UTC dipakai sebagai wadah
        // dan data zona waktu tidak perlu dimuat.
        scheduledDate: tz.TZDateTime.from(pengingat.waktuTampil, tz.UTC),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _idKanal,
            AppStrings.namaKanalPengingat,
            channelDescription: AppStrings.deskripsiKanalPengingat,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Membatalkan semua pengingat yang belum muncul — dipanggil saat keluar
  /// akun, supaya pengguna berikutnya di HP yang sama tidak menerima
  /// pengingat milik orang lain.
  Future<void> batalkanSemua() => _plugin.cancelAllPendingNotifications();
}
