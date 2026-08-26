import 'package:flutter/foundation.dart';

import '../../../core/utils/status_booking.dart';
import '../../../models/booking_model.dart';
import '../../../models/lapangan_model.dart';
import '../../../repositories/booking_repository.dart';
import '../../../repositories/lapangan_repository.dart';

/// ViewModel untuk Dashboard Mitra (L-14).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Dua repository
/// dipakai: [LapanganRepository] untuk daftar lapangan milik mitra,
/// [BookingRepository] untuk booking masuk + aksi Konfirmasi/Tolak.
///
/// Dibuat lokal tiap kali layar ini dibuka (lewat ChangeNotifierProvider
/// di `dashboard_mitra_screen.dart`) — bukan Provider global, sama
/// seperti BuatAktivitasViewModel/DetailAktivitasViewModel.
///
/// Kedua daftar dipaparkan sebagai `Stream` lewat getter, dibaca View
/// lewat `StreamBuilder` (CLAUDE.md aturan 6) — booking masuk perlu
/// langsung hidup begitu ada reservasi baru (BB-24), dan lapangan mitra
/// perlu langsung hidup begitu T-26 selesai mendaftarkan lapangan baru.
class DashboardMitraViewModel extends ChangeNotifier {
  final LapanganRepository _lapanganRepository;
  final BookingRepository _bookingRepository;
  final String pemilikId;

  DashboardMitraViewModel({
    required LapanganRepository lapanganRepository,
    required BookingRepository bookingRepository,
    required this.pemilikId,
  })  : _lapanganRepository = lapanganRepository,
        _bookingRepository = bookingRepository;

  Stream<List<LapanganModel>> get streamLapanganMitra =>
      _lapanganRepository.streamLapanganMitra(pemilikId);

  Stream<List<BookingModel>> get streamBookingMasuk =>
      _bookingRepository.streamBookingMasuk(pemilikId);

  /// Konfirmasi satu booking — PRD AB-08, T-25, BB-26. Mengembalikan
  /// `null` kalau berhasil, atau pesan kesalahan kalau gagal.
  ///
  /// Tidak memakai state proses/error bersama — sama seperti
  /// `terimaPermintaan`/`tolakPermintaan` di `DetailAktivitasViewModel`,
  /// daftar booking masuk bisa lebih dari satu baris, jadi status proses
  /// per-baris ditangani View lewat `StatefulWidget` lokal.
  Future<String?> konfirmasiBooking(BookingModel booking) async {
    try {
      await _bookingRepository.konfirmasiBooking(booking);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Tolak satu booking — PRD AB-04 (buka slot lagi), T-25, BB-27.
  /// Mengembalikan `null` kalau berhasil, atau pesan kesalahan kalau
  /// gagal.
  Future<String?> tolakBooking(BookingModel booking) async {
    try {
      await _bookingRepository.tolakBooking(booking);
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Status yang DITAMPILKAN untuk satu booking — PRD AB-07, BB-28.
  ///
  /// Sebelumnya Dashboard Mitra hanya membaca `booking.status` mentah,
  /// jadi booking `DIKONFIRMASI` yang jam selesainya sudah lewat tampil
  /// "Dikonfirmasi" selamanya di sisi mitra kalau penyewa tidak pernah
  /// membuka tab Profil-nya lagi (satu-satunya tempat yang sebelumnya
  /// menghitung ulang status ini). Sekarang dua sisi memakai logika yang
  /// sama dari `core/utils/status_booking.dart`.
  String statusTampilan(BookingModel booking) => statusTampilanBooking(booking);

  /// Tulis balik status `SELESAI` ke Firestore — PRD AB-07. Dipanggil
  /// View saat membangun tiap baris booking masuk, sama seperti
  /// `ProfilViewModel.tandaiSelesaiJikaPerlu`.
  void tandaiSelesaiJikaPerlu(BookingModel booking) {
    if (booking.status == 'DIKONFIRMASI' && sudahLewatJamSelesai(booking)) {
      _bookingRepository.tandaiBookingSelesai(booking.bookingId);
    }
  }
}
