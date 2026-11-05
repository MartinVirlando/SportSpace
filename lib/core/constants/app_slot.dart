/// Konstanta kunci slot — PRD 6.7 dan AB-17, v1.5 (T-59).
///
/// Slot yang diblokir manual oleh mitra memakai dokumen `slotBooking` yang
/// sama persis dengan slot booking biasa (ID deterministik yang sama), hanya
/// `bookingId`-nya diisi nilai tetap ini, bukan ID booking sungguhan.
///
/// Dibaca dua pihak: `BookingRepository` (menulis dan menghapusnya) dan
/// `AturSlotViewModel` (membedakan jam "diblokir" dari jam "dipesan"). Karena
/// itu nilainya di satu tempat bersama, bukan ditulis dua kali.
class AppSlot {
  AppSlot._();

  /// `slotBooking.bookingId` untuk slot yang diblokir mitra. Bukan ID
  /// dokumen `booking` mana pun — Firestore membuat ID acak 20 karakter,
  /// jadi tidak mungkin bentrok dengan kata ini.
  static const String bookingIdBlokir = 'BLOKIR';
}
