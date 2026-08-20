import 'package:flutter/foundation.dart';

import '../../../models/aktivitas_bermain_model.dart';
import '../../../models/booking_model.dart';
import '../../../repositories/aktivitas_repository.dart';
import '../../../repositories/booking_repository.dart';

/// ViewModel untuk tab Profil (L-13).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Dua repository
/// dipakai: [BookingRepository] untuk riwayat pemesanan (+ AB-07),
/// [AktivitasRepository] untuk daftar aktivitas yang dibuat/diikuti.
///
/// Dua daftar dipaparkan sebagai `Stream` lewat getter, dibaca View lewat
/// `StreamBuilder` (CLAUDE.md aturan 6) — riwayat booking perlu langsung
/// hidup begitu statusnya berubah (dikonfirmasi mitra, atau SELESAI lewat
/// [tandaiSelesaiJikaPerlu]), begitu juga aktivitas begitu ada permintaan
/// yang diterima.
///
/// Dibuat lokal tiap kali tab ini aktif (lewat ChangeNotifierProvider di
/// `profil_screen.dart`, disuntik oleh `ShellNavigasi` sama seperti
/// MapViewModel/AktivitasViewModel) — BUKAN Provider global.
class ProfilViewModel extends ChangeNotifier {
  final BookingRepository _bookingRepository;
  final AktivitasRepository _aktivitasRepository;
  final String userId;

  ProfilViewModel({
    required BookingRepository bookingRepository,
    required AktivitasRepository aktivitasRepository,
    required this.userId,
  })  : _bookingRepository = bookingRepository,
        _aktivitasRepository = aktivitasRepository;

  Stream<List<BookingModel>> get streamRiwayatBooking =>
      _bookingRepository.streamRiwayatBooking(userId);

  Stream<List<AktivitasBermainModel>> get streamAktivitasSaya =>
      _aktivitasRepository.streamAktivitasSaya(userId);

  /// Status yang DITAMPILKAN untuk satu booking — PRD AB-07, BB-28.
  ///
  /// Dihitung ulang dari `tanggal`+`jamSelesai` dibanding waktu sekarang,
  /// BUKAN langsung field `status` mentah — supaya baris yang baru saja
  /// lewat jam selesainya langsung tampil `SELESAI` walau tulis balik ke
  /// Firestore ([tandaiSelesaiJikaPerlu]) belum tuntas.
  String statusTampilan(BookingModel booking) {
    if (booking.status == 'DIKONFIRMASI' && _sudahLewat(booking)) {
      return 'SELESAI';
    }
    return booking.status;
  }

  bool _sudahLewat(BookingModel booking) {
    final tgl = booking.tanggal.split('-').map(int.parse).toList();
    final jam = booking.jamSelesai.split(':').map(int.parse).toList();
    final waktuSelesai = DateTime(tgl[0], tgl[1], tgl[2], jam[0], jam[1]);
    return waktuSelesai.isBefore(DateTime.now());
  }

  /// Tulis balik status `SELESAI` ke Firestore — PRD AB-07. Dipanggil
  /// View saat membangun tiap baris riwayat (bukan aksi tombol, jadi
  /// tidak melapor sukses/gagal). Aman dipanggil berulang: setelah
  /// tersimpan, `booking.status` dari stream sudah `SELESAI` sehingga
  /// syarat di [statusTampilan] tidak lagi terpenuhi dan berhenti
  /// menulis ulang.
  void tandaiSelesaiJikaPerlu(BookingModel booking) {
    if (booking.status == 'DIKONFIRMASI' && _sudahLewat(booking)) {
      _bookingRepository.tandaiBookingSelesai(booking.bookingId);
    }
  }
}
