import '../constants/app_slot.dart';

/// Keadaan satu jam di layar Atur Slot (L-19) — PRD AB-17, v1.5 (T-59).
enum StatusSlotMitra {
  /// Belum ada dokumen `slotBooking`: bisa diblokir.
  kosong,

  /// `slotBooking.bookingId == "BLOKIR"`: bisa dibuka lagi oleh mitra.
  diblokir,

  /// `slotBooking.bookingId` berisi ID booking sungguhan: TIDAK bisa
  /// disentuh dari sini.
  dipesan,

  /// Jam hari ini yang sudah lewat dan tidak ada dokumen slotnya: tidak
  /// ada gunanya diblokir.
  lewat,
}

/// Jam-jam operasional lapangan sebagai daftar bilangan bulat — dipakai L-19
/// (dan aturan yang sama dipakai L-10 untuk memilih jam mulai).
///
/// [jamBuka] dan [jamTutup] berformat `"HH:mm"` (PRD 6.2); menitnya
/// diabaikan karena seluruh slot per jam penuh (PRD 6.6).
///
/// Jam tutup yang LEBIH KECIL ATAU SAMA dengan jam buka berarti tutupnya di
/// hari berikutnya, jadi ditambah 24. `"00:00"` berarti TENGAH MALAM, bukan
/// jam 0 (jebakan di `CLAUDE.md`). Contoh:
/// - `08:00`–`23:00` → 8..22
/// - `08:00`–`00:00` → 8..23
/// - `18:00`–`02:00` → 18..25 (jam 24 dan 25 = pukul 00 dan 01 dini hari,
///   tetap dihitung dalam tanggal yang sama, seperti di L-10)
/// - `00:00`–`00:00` → 0..23 (buka 24 jam)
///
/// Format yang rusak menghasilkan daftar kosong, bukan crash.
List<int> jamOperasional(String jamBuka, String jamTutup) {
  final buka = _jam(jamBuka);
  final tutup = _jam(jamTutup);
  if (buka == null || tutup == null) return const [];

  final tutupEfektif = tutup <= buka ? tutup + 24 : tutup;
  return [for (var jam = buka; jam < tutupEfektif; jam++) jam];
}

/// Menentukan [StatusSlotMitra] satu [jam] — PRD AB-17.
///
/// [slotTerisi] memetakan jam → `bookingId` dari dokumen `slotBooking`
/// tanggal yang dipilih. [hariIni] dan [jamSekarang] dipakai supaya jam yang
/// sudah lewat hari ini tidak ditawarkan untuk diblokir (aturan yang sama
/// dengan L-10: `jam <= jamSekarang` dianggap lewat).
///
/// Slot yang sudah ada dokumennya selalu menang atas "lewat": jam lampau
/// yang dipesan tetap tampil "Dipesan", bukan "Lewat".
StatusSlotMitra statusSlotMitra({
  required int jam,
  required Map<int, String> slotTerisi,
  required bool hariIni,
  required int jamSekarang,
}) {
  final bookingId = slotTerisi[jam];
  if (bookingId != null) {
    return bookingId == AppSlot.bookingIdBlokir
        ? StatusSlotMitra.diblokir
        : StatusSlotMitra.dipesan;
  }
  if (hariIni && jam <= jamSekarang) return StatusSlotMitra.lewat;
  return StatusSlotMitra.kosong;
}

/// "HH:mm" → jam (bilangan bulat), atau `null` kalau formatnya salah.
int? _jam(String hhmm) {
  final bagian = hhmm.split(':');
  if (bagian.length != 2) return null;
  final jam = int.tryParse(bagian[0]);
  if (jam == null || jam < 0 || jam > 24) return null;
  return jam;
}
