import 'package:flutter/foundation.dart';

import '../../../core/utils/harga.dart';
import '../../../core/utils/produk_tambahan.dart';
import '../../../models/booking_model.dart';
import '../../../models/lapangan_model.dart';
import '../../../models/produk_tambahan_model.dart';
import '../../../repositories/booking_repository.dart';

/// Kondisi memuat slot terisi untuk tanggal yang dipilih — bukan kondisi
/// keseluruhan layar, karena form tetap bisa dilihat (cuma daftar chip jam
/// yang menunggu/gagal) sementara tanggal & durasi sudah bisa diisi.
enum KondisiSlot { memuat, berhasil, gagal }

/// ViewModel untuk form Ajukan Reservasi (L-10).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data dibaca/ditulis
/// lewat [BookingRepository] (AB-04, AB-08).
///
/// Dibuat lokal tiap kali layar ini dibuka (lewat ChangeNotifierProvider
/// di `ajukan_reservasi_screen.dart`) — bukan Provider global, sama
/// seperti BuatAktivitasViewModel/BeriRatingViewModel.
class BookingViewModel extends ChangeNotifier {
  final BookingRepository _repository;

  BookingViewModel({required BookingRepository repository})
      : _repository = repository;

  KondisiSlot _kondisiSlot = KondisiSlot.berhasil;
  KondisiSlot get kondisiSlot => _kondisiSlot;

  Set<int> _slotTerisi = {};
  Set<int> get slotTerisi => _slotTerisi;

  bool _sedangProses = false;
  bool get sedangProses => _sedangProses;

  String? _pesanError;
  String? get pesanError => _pesanError;

  /// Memuat jam yang sudah terisi untuk [lapanganId] pada [tanggal]
  /// ("yyyy-MM-dd") — dipanggil ulang tiap kali tanggal diganti, supaya
  /// chip jam yang bertanda "Penuh" (PRD L-10) selalu sesuai tanggal aktif.
  Future<void> muatSlotTerisi({
    required String lapanganId,
    required String tanggal,
  }) async {
    _kondisiSlot = KondisiSlot.memuat;
    notifyListeners();

    try {
      _slotTerisi = await _repository.ambilSlotTerisi(
        lapanganId: lapanganId,
        tanggal: tanggal,
      );
      _kondisiSlot = KondisiSlot.berhasil;
    } catch (_) {
      _kondisiSlot = KondisiSlot.gagal;
    }

    notifyListeners();
  }

  /// Rincian estimasi harga (AB-08, AB-18): sewa asli, potongan promo, dan
  /// total. Perhitungannya fungsi murni di `core/utils/harga.dart`
  /// (sebelumnya ada di sini); ViewModel hanya meneruskannya ke View.
  ///
  /// [produkDipilih] (T-60, AB-19) ditambahkan setelah diskon dan tidak
  /// ikut didiskon.
  RincianHarga hitungRincian(
    LapanganModel lapangan,
    List<int> daftarJam, {
    List<ProdukPesananModel> produkDipilih = const [],
  }) {
    return hitungRincianHarga(
      lapangan: lapangan,
      daftarJam: daftarJam,
      totalProduk: hitungTotalProduk(produkDipilih),
    );
  }

  /// Mengembalikan [BookingModel] kalau berhasil, `null` kalau gagal —
  /// baca [pesanError] untuk pesan yang siap ditampilkan (BB-24, BB-25).
  Future<BookingModel?> ajukanReservasi({
    required String lapanganId,
    required String namaLapangan,
    required String pemilikId,
    required String userId,
    required String namaUser,
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
    required int totalHarga,
    List<ProdukPesananModel> produkTambahan = const [],
  }) async {
    _sedangProses = true;
    _pesanError = null;
    notifyListeners();

    try {
      final booking = await _repository.ajukanReservasi(
        lapanganId: lapanganId,
        namaLapangan: namaLapangan,
        pemilikId: pemilikId,
        userId: userId,
        namaUser: namaUser,
        tanggal: tanggal,
        jamMulai: jamMulai,
        jamSelesai: jamSelesai,
        totalHarga: totalHarga,
        produkTambahan: produkTambahan,
      );
      _sedangProses = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _pesanError = e.toString().replaceFirst('Exception: ', '');
      _sedangProses = false;
      notifyListeners();
      return null;
    }
  }
}
