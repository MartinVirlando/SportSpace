import 'package:flutter/foundation.dart';

import '../../../core/utils/status_booking.dart';
import '../../../models/aktivitas_bermain_model.dart';
import '../../../models/booking_model.dart';
import '../../../models/favorit_model.dart';
import '../../../repositories/aktivitas_repository.dart';
import '../../../repositories/booking_repository.dart';
import '../../../repositories/favorit_repository.dart';

/// ViewModel untuk tab Profil (L-13).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Tiga repository
/// dipakai: [BookingRepository] untuk riwayat pemesanan (+ AB-07),
/// [AktivitasRepository] untuk daftar aktivitas yang dibuat/diikuti,
/// [FavoritRepository] untuk daftar Lapangan Favorit (T-35, AB-10).
///
/// Riwayat booking, aktivitas, dan favorit dipaparkan sebagai `Stream`
/// lewat field `final` yang dibuat sekali di konstruktor (bukan getter
/// biasa — supaya satu query Firestore dipakai bersama oleh kotak
/// statistik AB-12 DAN daftar di bawahnya, bukan dua listener terpisah
/// untuk data yang sama), dibaca View lewat `StreamBuilder` (CLAUDE.md
/// aturan 6) — perlu langsung hidup begitu statusnya berubah
/// (dikonfirmasi mitra, atau SELESAI lewat
/// [tandaiSelesaiJikaPerlu]), begitu ada permintaan yang diterima, atau
/// begitu ikon ♡ ditekan di L-04/L-06.
///
/// Angka statistik (AB-12) sengaja TIDAK dihitung lewat query `count()`
/// terpisah — versi sebelumnya begitu, dan hasilnya basi (BB-36): angka
/// itu diambil sekali saat ProfilViewModel dibuat, lalu tidak pernah
/// dihitung ulang selama tab ini tetap hidup di `IndexedStack`
/// `ShellNavigasi` (mis. setelah menambah favorit dari Home dan kembali
/// ke Profil). Panjang list dari stream yang sama persis dipakai
/// `_SeksiRiwayatBooking`/`_SeksiAktivitasSaya`/`_SeksiLapanganFavorit` —
/// jadi menghitungnya di View lewat `snapshot.data?.length` otomatis ikut
/// hidup, tanpa baca Firestore tambahan.
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
    required this.userId,
  })  : streamRiwayatBooking = bookingRepository.streamRiwayatBooking(userId),
        streamAktivitasSaya =
            aktivitasRepository.streamAktivitasSaya(userId),
        streamDaftarFavorit =
            favoritRepository.streamDaftarFavorit(userId),
        _bookingRepository = bookingRepository,
        _favoritRepository = favoritRepository;

  final BookingRepository _bookingRepository;
  final FavoritRepository _favoritRepository;

  final Stream<List<BookingModel>> streamRiwayatBooking;
  final Stream<List<AktivitasBermainModel>> streamAktivitasSaya;
  final Stream<List<FavoritModel>> streamDaftarFavorit;

  /// Menekan ♥ pada daftar favorit di Profil — selalu berarti batal
  /// favorit, karena item ini hanya muncul kalau sudah difavoritkan
  /// (PRD AB-10).
  Future<void> hapusFavorit(String lapanganId, String namaLapangan) {
    return _favoritRepository.toggleFavorit(
      userId: userId,
      lapanganId: lapanganId,
      namaLapangan: namaLapangan,
    );
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
}
