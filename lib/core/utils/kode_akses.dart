import 'dart:math';

/// Kode akses aktivitas privat — PRD AB-21, v1.5 (T-64), BB-79 sampai BB-81.
///
/// Fungsi di sini MURNI (selain sumber acak yang diberikan pemanggil): tanpa
/// Firestore dan tanpa state, diuji di `test/kode_akses_test.dart`.

/// Panjang kode.
const int panjangKodeAkses = 6;

/// Huruf dan angka yang dipakai kode. Huruf `I`, `O` dan angka `0`, `1`
/// SENGAJA dibuang karena mudah tertukar saat kode dibaca atau diketik dari
/// pesan WhatsApp (`O` vs `0`, `I` vs `1`).
const String alfabetKodeAkses = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

/// Membangkitkan satu kode acak sepanjang [panjangKodeAkses].
///
/// [acak] diberikan pemanggil: `AktivitasRepository` memakai `Random.secure()`
/// (kode tidak boleh mudah ditebak), sedangkan tes memberi `Random` ber-seed
/// supaya hasilnya bisa diprediksi.
///
/// Dengan 32 karakter dan panjang 6 ada 32^6 ≈ 1,07 miliar kemungkinan, jadi
/// tabrakan sangat jarang; `AktivitasRepository` tetap memeriksa kode belum
/// dipakai sebelum menyimpannya.
String buatKodeAkses(Random acak) {
  final buffer = StringBuffer();
  for (var i = 0; i < panjangKodeAkses; i++) {
    buffer.write(alfabetKodeAkses[acak.nextInt(alfabetKodeAkses.length)]);
  }
  return buffer.toString();
}

/// Merapikan kode yang diketik pengguna: buang spasi di tepi dan jadikan
/// huruf besar — BB-80 (huruf kecil tetap diterima). Spasi di tengah tidak
/// dibuang, jadi kode seperti `AB C12` tetap tidak valid.
String normalisasiKodeAkses(String masukan) => masukan.trim().toUpperCase();

/// Apakah [kode] (sudah dinormalkan) berbentuk kode akses yang sah: tepat
/// [panjangKodeAkses] karakter, semuanya dari [alfabetKodeAkses].
///
/// Dipakai sebelum mengirim query ke Firestore, supaya masukan sembarang
/// (kosong, terlalu pendek, berisi simbol) langsung ditolak tanpa baca data.
bool kodeAksesValid(String kode) {
  if (kode.length != panjangKodeAkses) return false;
  return kode.split('').every(alfabetKodeAkses.contains);
}
