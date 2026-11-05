import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/status_booking.dart';
import '../../../core/utils/stream_terakhir.dart';
import '../../../models/aktivitas_bermain_model.dart';
import '../../../models/booking_model.dart';
import '../../../models/favorit_model.dart';
import '../../../models/lapangan_model.dart';
import '../../../repositories/aktivitas_repository.dart';
import '../../../repositories/booking_repository.dart';
import '../../../repositories/favorit_repository.dart';
import '../../../repositories/lapangan_repository.dart';

/// ViewModel untuk tab Profil (L-13).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Tiga repository
/// dipakai: [BookingRepository] untuk riwayat pemesanan (+ AB-07),
/// [AktivitasRepository] untuk daftar aktivitas yang dibuat/diikuti,
/// [FavoritRepository] hanya untuk kotak angka "Favorit" (AB-12) — daftar
/// Lapangan Favorit sendiri sudah pindah ke Home (L-04, T-41).
///
/// Riwayat booking dan aktivitas dipaparkan sebagai `Stream` lewat field
/// `final` yang dibuat sekali di konstruktor (bukan getter biasa — supaya
/// satu query Firestore dipakai bersama oleh kotak statistik AB-12 DAN
/// daftar di bawahnya, bukan dua listener terpisah untuk data yang sama),
/// dibaca View lewat `StreamBuilder` (CLAUDE.md aturan 6) — perlu langsung
/// hidup begitu statusnya berubah (dikonfirmasi mitra, atau SELESAI lewat
/// [tandaiSelesaiJikaPerlu]), atau begitu ada permintaan yang diterima.
///
/// Angka statistik (AB-12) sengaja TIDAK dihitung lewat query `count()`
/// terpisah — versi sebelumnya begitu, dan hasilnya basi (BB-36): angka
/// itu diambil sekali saat ProfilViewModel dibuat, lalu tidak pernah
/// dihitung ulang selama tab ini tetap hidup di `IndexedStack`
/// `ShellNavigasi` (mis. setelah menambah favorit dari Home dan kembali
/// ke Profil). Panjang list dari stream yang sama persis dipakai
/// `_SeksiRiwayatBooking`/`_SeksiAktivitasSaya` — jadi menghitungnya di
/// View lewat `snapshot.data?.length` otomatis ikut hidup, tanpa baca
/// Firestore tambahan.
///
/// Dibuat lokal tiap kali tab ini aktif (lewat ChangeNotifierProvider di
/// `profil_screen.dart`, disuntik oleh `ShellNavigasi` sama seperti
/// MapViewModel/AktivitasViewModel) — BUKAN Provider global.
class ProfilViewModel extends ChangeNotifier {
  final String userId;

  ProfilViewModel({
    required BookingRepository bookingRepository,
    required AktivitasRepository aktivitasRepository,
    required FavoritRepository favoritRepository,
    required LapanganRepository lapanganRepository,
    required this.userId,
    this.onRiwayatBookingBerubah,
  })  : _riwayatBooking = StreamTerakhir(
          bookingRepository.streamRiwayatBooking(userId),
        ),
        _aktivitasSaya = StreamTerakhir(
          aktivitasRepository.streamAktivitasSaya(userId),
        ),
        _daftarFavorit = StreamTerakhir(
          favoritRepository.streamDaftarFavorit(userId),
        ),
        _bookingRepository = bookingRepository,
        _lapanganRepository = lapanganRepository {
    // Pengingat jadwal (T-67, AB-23): setiap daftar booking berubah, kabari
    // pemanggil. Langganan dibuat DI SINI, bukan di widget, karena bagian
    // Riwayat Pemesanan ada di `ListView` yang membangun anaknya secara
    // malas — kalau bergantung pada `StreamBuilder`, pengingat baru
    // dijadwalkan setelah pengguna menggulir sampai ke sana.
    if (onRiwayatBookingBerubah != null) {
      _langgananBooking = _riwayatBooking.stream.listen(
        onRiwayatBookingBerubah,
        // Galatnya sudah ditampilkan bagian Riwayat sendiri; di sini cukup
        // tidak membiarkannya lolos sebagai galat tak tertangani.
        onError: (Object _) {},
      );
    }
  }

  /// Dipanggil tiap daftar booking pengguna berubah — dipakai untuk
  /// menyinkronkan pengingat jadwal. `null` kalau tidak diperlukan.
  final void Function(List<BookingModel> daftar)? onRiwayatBookingBerubah;

  StreamSubscription<List<BookingModel>>? _langgananBooking;

  final BookingRepository _bookingRepository;
  final LapanganRepository _lapanganRepository;

  // Tiga stream di bawah dibungkus [StreamTerakhir]: satu langganan ke
  // Firestore, dan setiap `StreamBuilder` — termasuk yang baru dibangun
  // belakangan karena `ListView` membangun bagian layar secara malas —
  // langsung menerima nilai terakhirnya. Tanpa ini, bagian yang ada jauh di
  // bawah (mis. Aktivitas Saya) menunggu event yang sudah lewat dan
  // spinner-nya tidak pernah selesai.
  final StreamTerakhir<List<BookingModel>> _riwayatBooking;
  final StreamTerakhir<List<AktivitasBermainModel>> _aktivitasSaya;
  final StreamTerakhir<List<FavoritModel>> _daftarFavorit;

  Stream<List<BookingModel>> get streamRiwayatBooking => _riwayatBooking.stream;
  Stream<List<AktivitasBermainModel>> get streamAktivitasSaya =>
      _aktivitasSaya.stream;

  /// Dipakai HANYA untuk kotak statistik "Favorit" (AB-12) — daftar
  /// lengkapnya sendiri sudah pindah ke Home (L-04, T-41).
  Stream<List<FavoritModel>> get streamDaftarFavorit => _daftarFavorit.stream;

  @override
  void dispose() {
    _langgananBooking?.cancel();
    _riwayatBooking.dispose();
    _aktivitasSaya.dispose();
    _daftarFavorit.dispose();
    super.dispose();
  }

  /// Status yang DITAMPILKAN untuk satu booking — PRD AB-07, BB-28. Lihat
  /// `core/utils/status_booking.dart` — logika yang sama dipakai
  /// DashboardMitraViewModel supaya penyewa dan mitra melihat status yang
  /// konsisten, bukan cuma sisi penyewa yang menghitung ulang.
  String statusTampilan(BookingModel booking) => statusTampilanBooking(booking);

  /// Tulis balik status `SELESAI` ke Firestore — PRD AB-07. Dipanggil
  /// View saat membangun tiap baris riwayat (bukan aksi tombol, jadi
  /// tidak melapor sukses/gagal). Aman dipanggil berulang: setelah
  /// tersimpan, `booking.status` dari stream sudah `SELESAI` sehingga
  /// syarat di [statusTampilan] tidak lagi terpenuhi dan berhenti
  /// menulis ulang.
  void tandaiSelesaiJikaPerlu(BookingModel booking) {
    if (booking.status == 'DIKONFIRMASI' && sudahLewatJamSelesai(booking)) {
      _bookingRepository.tandaiBookingSelesai(booking.bookingId);
    }
  }

  /// Ambil lapangan untuk form Ubah Jadwal (T-62, AB-20). Melempar
  /// `Exception` berpesan Indonesia kalau gagal — View yang menampilkannya.
  Future<LapanganModel> ambilLapangan(String lapanganId) =>
      _lapanganRepository.ambilSatuLapangan(lapanganId);

  /// Batalkan booking milik pengguna — PRD AB-04 lanjutan, T-46.
  /// Mengembalikan `null` kalau berhasil, atau pesan kesalahan kalau gagal.
  Future<String?> batalkanBooking(BookingModel booking) async {
    try {
      await _bookingRepository.batalkanBooking(booking);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
