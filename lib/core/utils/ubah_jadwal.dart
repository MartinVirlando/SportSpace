// Perencanaan slot untuk ubah jadwal booking — PRD AB-20, v1.5 (T-62).
//
// Fungsi di sini MURNI: tanpa Firestore dan tanpa state. Ia hanya menjawab
// "slot mana yang harus dihapus, dibuat, dan diperiksa", supaya aturan yang
// paling rawan (jadwal baru yang tumpang tindih dengan jadwal lama milik
// booking itu sendiri) bisa diuji otomatis (`test/ubah_jadwal_test.dart`,
// BB-76 sampai BB-78). `BookingRepository.ubahJadwalBooking` memakainya di
// dalam transaction.

/// Satu kunci slot: tanggal ("yyyy-MM-dd") dan jam (0–25+). ID dokumen
/// `slotBooking`-nya `{lapanganId}_{tanggal}_{jam}`, jadi pasangan ini
/// identik dengan satu dokumen.
///
/// `==` dan `hashCode` ditulis supaya dua kunci dengan isi sama dianggap satu
/// saat dimasukkan ke `Set`.
class KunciSlot {
  final String tanggal;
  final int jam;

  const KunciSlot(this.tanggal, this.jam);

  @override
  bool operator ==(Object other) =>
      other is KunciSlot && other.tanggal == tanggal && other.jam == jam;

  @override
  int get hashCode => Object.hash(tanggal, jam);

  @override
  String toString() => '${tanggal}_$jam';
}

/// Hasil [rencanaUbahSlot].
class RencanaSlot {
  /// Slot milik jadwal LAMA yang tidak dipakai lagi → harus dihapus.
  final Set<KunciSlot> dihapus;

  /// Slot milik jadwal BARU yang belum dimiliki booking ini → harus dibuat,
  /// dan SEBELUM itu harus diperiksa belum ada yang memakainya.
  final Set<KunciSlot> dibuat;

  const RencanaSlot({required this.dihapus, required this.dibuat});

  /// Jadwal baru identik dengan yang lama: tidak ada yang berubah.
  bool get tidakBerubah => dihapus.isEmpty && dibuat.isEmpty;
}

/// Seluruh kunci slot untuk satu booking: tiap jam dari [jamMulai] sampai
/// sebelum [jamSelesai] pada [tanggal]. Sama dengan pola di
/// `ajukanReservasi`: 19:00–21:00 → jam 19 dan 20.
///
/// [jamMulai] dan [jamSelesai] berformat "HH:mm"; menitnya diabaikan.
Set<KunciSlot> kunciSlotBooking({
  required String tanggal,
  required String jamMulai,
  required String jamSelesai,
}) {
  final awal = int.parse(jamMulai.split(':')[0]);
  final akhir = int.parse(jamSelesai.split(':')[0]);
  return {for (var jam = awal; jam < akhir; jam++) KunciSlot(tanggal, jam)};
}

/// Menghitung slot yang berubah dari jadwal lama ke jadwal baru — AB-20,
/// BB-76 sampai BB-78.
///
/// Intinya selisih himpunan: slot yang ada di lama tapi tidak di baru
/// dihapus, dan slot yang ada di baru tapi tidak di lama dibuat. Slot yang
/// ada di KEDUANYA tidak disentuh sama sekali. Itu yang membuat menggeser
/// 19:00–21:00 menjadi 20:00–22:00 berhasil: jam 20 tumpang tindih tetapi
/// milik booking ini sendiri, jadi tidak diperiksa sebagai "sudah dipesan"
/// dan tidak dihapus lalu dibuat ulang.
RencanaSlot rencanaUbahSlot({
  required Set<KunciSlot> lama,
  required Set<KunciSlot> baru,
}) {
  return RencanaSlot(
    dihapus: lama.difference(baru),
    dibuat: baru.difference(lama),
  );
}
