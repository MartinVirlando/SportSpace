import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/slot_mitra.dart';
import '../../../models/lapangan_model.dart';
import '../../../repositories/booking_repository.dart';

/// Kondisi memuat slot untuk tanggal yang dipilih. Bukan kondisi seluruh
/// layar: pemilih tanggal tetap tampil selagi jamnya memuat/gagal.
enum KondisiAturSlot { belumPilihTanggal, memuat, berhasil, gagal }

/// ViewModel untuk layar Atur Slot (L-19) — PRD AB-17, v1.5 (T-59).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data lewat
/// [BookingRepository] (koleksi `slotBooking` milik booking, jadi
/// repository-nya juga yang itu).
///
/// Dibuat lokal tiap kali layar dibuka (lewat ChangeNotifierProvider di
/// `atur_slot_screen.dart`), bukan Provider global — sama seperti
/// `BookingViewModel`. Slot dibaca sekali per tanggal (bukan `Stream`):
/// ini layar kerja satu mitra, dan setiap aksinya memuat ulang sendiri.
class AturSlotViewModel extends ChangeNotifier {
  final BookingRepository _repository;
  final LapanganModel lapangan;
  final String mitraId;

  AturSlotViewModel({
    required BookingRepository repository,
    required this.lapangan,
    required this.mitraId,
  }) : _repository = repository;

  KondisiAturSlot _kondisi = KondisiAturSlot.belumPilihTanggal;
  KondisiAturSlot get kondisi => _kondisi;

  DateTime? _tanggal;
  DateTime? get tanggal => _tanggal;

  /// jam → bookingId dari dokumen `slotBooking` tanggal terpilih.
  Map<int, String> _slot = {};

  /// Jam yang aksi blokir/bukanya sedang berjalan — dipakai View untuk
  /// menonaktifkan chip itu saja, bukan seluruh layar.
  final Set<int> _sedangDiproses = {};
  bool sedangDiproses(int jam) => _sedangDiproses.contains(jam);

  /// Jam operasional lapangan (aturan tengah malam: `core/utils/slot_mitra`).
  List<int> get daftarJam =>
      jamOperasional(lapangan.jamBuka, lapangan.jamTutup);

  String get tanggalFormat => DateFormat('yyyy-MM-dd').format(_tanggal!);

  bool get _hariIni {
    final t = _tanggal;
    if (t == null) return false;
    final sekarang = DateTime.now();
    return t.year == sekarang.year &&
        t.month == sekarang.month &&
        t.day == sekarang.day;
  }

  StatusSlotMitra statusJam(int jam) => statusSlotMitra(
        jam: jam,
        slotTerisi: _slot,
        hariIni: _hariIni,
        jamSekarang: DateTime.now().hour,
      );

  Future<void> pilihTanggal(DateTime tanggal) async {
    _tanggal = tanggal;
    await muatSlot();
  }

  Future<void> muatSlot() async {
    if (_tanggal == null) return;

    _kondisi = KondisiAturSlot.memuat;
    notifyListeners();

    try {
      _slot = await _repository.ambilSlotLapangan(
        lapanganId: lapangan.lapanganId,
        tanggal: tanggalFormat,
      );
      _kondisi = KondisiAturSlot.berhasil;
    } catch (_) {
      _kondisi = KondisiAturSlot.gagal;
    }

    notifyListeners();
  }

  /// Blokir [jam]. Mengembalikan `null` kalau berhasil, atau pesan
  /// kesalahan yang siap ditampilkan (BB-67). Apa pun hasilnya, slot dimuat
  /// ulang supaya tampilan sama dengan Firestore (mis. jam yang barusan
  /// dipesan orang lain langsung berubah jadi "Dipesan").
  Future<String?> blokir(int jam) => _jalankan(
        jam,
        () => _repository.blokirSlot(
          lapanganId: lapangan.lapanganId,
          tanggal: tanggalFormat,
          jam: jam,
          mitraId: mitraId,
        ),
      );

  /// Buka blokir [jam] — BB-68. Hanya berhasil untuk slot "BLOKIR"; slot
  /// pesanan pengguna ditolak oleh repository (BB-69).
  Future<String?> bukaBlokir(int jam) => _jalankan(
        jam,
        () => _repository.bukaBlokir(
          lapanganId: lapangan.lapanganId,
          tanggal: tanggalFormat,
          jam: jam,
          mitraId: mitraId,
        ),
      );

  Future<String?> _jalankan(int jam, Future<void> Function() aksi) async {
    _sedangDiproses.add(jam);
    notifyListeners();

    String? pesanError;
    try {
      await aksi();
    } catch (e) {
      pesanError = e.toString().replaceFirst('Exception: ', '');
    }

    _sedangDiproses.remove(jam);
    // Muat ulang apa pun hasilnya. Kalau pemuatan ulang gagal, kondisi
    // jadi `gagal` dan View menampilkan tombol coba lagi.
    await muatSlot();
    return pesanError;
  }
}
