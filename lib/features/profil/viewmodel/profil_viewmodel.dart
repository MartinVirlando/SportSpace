import 'package:flutter/foundation.dart';

import '../../../models/aktivitas_bermain_model.dart';
import '../../../models/booking_model.dart';
import '../../../models/favorit_model.dart';
import '../../../repositories/aktivitas_repository.dart';
import '../../../repositories/booking_repository.dart';
import '../../../repositories/favorit_repository.dart';

/// Kondisi kotak statistik (Booking · Aktivitas · Favorit) — PRD AB-12,
/// T-38. Terpisah dari [KondisiHome]/[KondisiDetail] karena ini cuma
/// mengontrol satu bagian kecil layar Profil, bukan seluruh layar.
enum KondisiStatistik { memuat, berhasil, gagal }

/// ViewModel untuk tab Profil (L-13).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Tiga repository
/// dipakai: [BookingRepository] untuk riwayat pemesanan (+ AB-07) dan
/// jumlah booking (AB-12), [AktivitasRepository] untuk daftar aktivitas
/// yang dibuat/diikuti dan jumlahnya, [FavoritRepository] untuk daftar
/// Lapangan Favorit (T-35, AB-10) dan jumlahnya.
///
/// Riwayat booking, aktivitas, dan favorit dipaparkan sebagai `Stream`
/// lewat getter, dibaca View lewat `StreamBuilder` (CLAUDE.md aturan 6) —
/// perlu langsung hidup begitu statusnya berubah (dikonfirmasi mitra,
/// atau SELESAI lewat [tandaiSelesaiJikaPerlu]), begitu ada permintaan
/// yang diterima, atau begitu ikon ♡ ditekan di L-04/L-06.
///
/// Statistik (AB-12) BEDA pola: `count()` adalah query sekali ambil,
/// bukan listener — jadi dipaparkan lewat [muatStatistik] + state
/// eksplisit ([kondisiStatistik]/[jumlahBooking]/dst), pola yang sama
/// dengan HomeViewModel (CLAUDE.md aturan 6).
///
/// Dibuat lokal tiap kali tab ini aktif (lewat ChangeNotifierProvider di
/// `profil_screen.dart`, disuntik oleh `ShellNavigasi` sama seperti
/// MapViewModel/AktivitasViewModel) — BUKAN Provider global.
class ProfilViewModel extends ChangeNotifier {
  final BookingRepository _bookingRepository;
  final AktivitasRepository _aktivitasRepository;
  final FavoritRepository _favoritRepository;
  final String userId;

  ProfilViewModel({
    required BookingRepository bookingRepository,
    required AktivitasRepository aktivitasRepository,
    required FavoritRepository favoritRepository,
    required this.userId,
  })  : _bookingRepository = bookingRepository,
        _aktivitasRepository = aktivitasRepository,
        _favoritRepository = favoritRepository;

  Stream<List<BookingModel>> get streamRiwayatBooking =>
      _bookingRepository.streamRiwayatBooking(userId);

  Stream<List<AktivitasBermainModel>> get streamAktivitasSaya =>
      _aktivitasRepository.streamAktivitasSaya(userId);

  Stream<List<FavoritModel>> get streamDaftarFavorit =>
      _favoritRepository.streamDaftarFavorit(userId);

  // ---------- Statistik (AB-12, T-38) ----------

  KondisiStatistik _kondisiStatistik = KondisiStatistik.memuat;
  KondisiStatistik get kondisiStatistik => _kondisiStatistik;

  int _jumlahBooking = 0;
  int get jumlahBooking => _jumlahBooking;

  int _jumlahAktivitas = 0;
  int get jumlahAktivitas => _jumlahAktivitas;

  int _jumlahFavorit = 0;
  int get jumlahFavorit => _jumlahFavorit;

  /// Memuat ketiga angka statistik sekaligus — PRD AB-12. Dipanggil sekali
  /// saat ProfilViewModel dibuat (lihat `profil_screen.dart`), mengikuti
  /// pola `..muatDetail()` di DetailLapanganViewModel.
  Future<void> muatStatistik() async {
    _kondisiStatistik = KondisiStatistik.memuat;
    notifyListeners();

    try {
      final hasil = await Future.wait([
        _bookingRepository.hitungBooking(userId),
        _aktivitasRepository.hitungAktivitasSaya(userId),
        _favoritRepository.hitungFavorit(userId),
      ]);
      _jumlahBooking = hasil[0];
      _jumlahAktivitas = hasil[1];
      _jumlahFavorit = hasil[2];
      _kondisiStatistik = KondisiStatistik.berhasil;
    } catch (_) {
      _kondisiStatistik = KondisiStatistik.gagal;
    }

    notifyListeners();
  }

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
