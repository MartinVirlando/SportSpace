/// Seluruh teks yang dilihat pengguna.
///
/// PRD Bagian 2.3 mewajibkan semua teks antarmuka berbahasa Indonesia.
/// Menaruhnya di satu tempat membuat aturan itu mudah diperiksa — cukup
/// baca berkas ini, tidak perlu menyisir puluhan widget.
///
/// Ini BUKAN persiapan multi-bahasa. Multi-bahasa (i18n) ada di daftar
/// "tidak dibangun" PRD Bagian 2.2.
class AppStrings {
  AppStrings._();

  static const namaAplikasi = 'Sport Space';
  static const tagline = 'Temukan lapangan & rekan olahraga di sekitarmu';

  // ---------- Navigasi bawah (4 tab, PRD v1.1) ----------
  static const tabHome = 'Home';
  static const tabMap = 'Map';
  static const tabTeman = 'Teman';
  static const tabProfil = 'Profil';

  // ---------- Umum ----------
  static const cobaLagi = 'Coba Lagi';
  static const batal = 'Batal';
  static const simpan = 'Simpan';
  static const kirim = 'Kirim';
  static const memuat = 'Memuat...';

  // ---------- Auth (L-02, L-03) ----------
  static const masuk = 'Masuk';
  static const daftar = 'Daftar';
  static const keluar = 'Keluar';
  static const surel = 'Surel';
  static const kataSandi = 'Kata Sandi';
  static const konfirmasiKataSandi = 'Konfirmasi Kata Sandi';
  static const nama = 'Nama';
  static const nomorTelepon = 'Nomor Telepon';
  static const perannya = 'Saya adalah';
  static const peranPengguna = 'Pengguna';
  static const peranMitra = 'Pemilik Lapangan';

  static const errKredensialSalah = 'Surel atau kata sandi salah.';
  static const errSurelTerpakai = 'Surel ini sudah terdaftar.';
  static const errKataSandiBeda = 'Konfirmasi kata sandi tidak cocok.';

  // ---------- Home (L-04) ----------
  static const sapaan = 'Halo';
  static const cariLapangan = 'Cari lapangan olahraga...';
  static const kosongLapangan = 'Belum ada lapangan di sekitar kamu.';
  static const kosongHasilFilter =
      'Coba ubah kata kunci atau pilih olahraga lain.';

  // ---------- Lokasi (AB-03) ----------
  static const lokasiBelumAktif = 'Lokasi belum aktif';
  static const lokasiKeterangan =
      'Aktifkan izin lokasi supaya kami bisa menghitung jarak lapangan '
      'dari posisimu.';
  static const bukaPengaturan = 'Buka Pengaturan';
  static const spandukLokasiDefault =
      'Memakai lokasi default. Aktifkan GPS untuk hasil lebih akurat.';

  // ---------- Detail Lapangan (L-06) ----------
  static const jamBuka = 'Jam Buka';
  static const harga = 'Harga';
  static const fasilitas = 'Fasilitas';
  static const jenisOlahraga = 'Jenis';
  static const beriRating = 'Beri Rating';
  static const ajukanReservasi = 'Ajukan Reservasi';
  static const ulasanPengguna = 'Ulasan Pengguna';
  static const belumAdaUlasan = 'Belum ada ulasan';
  static const badgeMitra = '✅ Mitra Terdaftar';
  static const badgeTerverifikasi = '🏅 Terverifikasi';

  // ---------- Cari Rekan (L-07) ----------
  static const cariRekan = 'Cari Rekan Bermain';
  static const buatAktivitas = 'Buat Aktivitas';
  static const gabung = 'Gabung';
  static const terima = 'Terima';
  static const tolak = 'Tolak';
  static const errSlotPenuh = 'Slot penuh';
  static const kosongAktivitas = 'Belum ada aktivitas untuk filter ini.';

  // ---------- Detail Aktivitas (L-09) ----------
  static const detailAktivitas = 'Detail Aktivitas';
  static const daftarPeserta = 'Daftar Peserta';
  static const permintaanMasuk = 'Permintaan Masuk';
  static const kosongPermintaan = 'Belum ada permintaan gabung.';
  static const permintaanTerkirim = 'Permintaan gabung terkirim.';
  static const menungguPersetujuan = 'Menunggu persetujuan pembuat';
  static const sudahBergabung = 'Kamu sudah bergabung';
  static const pembuatAktivitas = 'Pembuat';

  // ---------- Booking (L-10) ----------
  static const pilihSlot = 'Pilih Slot';
  static const slotPenuh = 'Penuh';
  static const estimasiDibayarDiLokasi = 'Estimasi, dibayar di lokasi';
  static const errSlotSudahDipesan = 'Slot sudah dipesan';

  // ---------- Profil (L-13) ----------
  static const editProfil = 'Edit Profil';
  static const statBooking = 'Booking';
  static const statAktivitas = 'Aktivitas';
  static const statFavorit = 'Favorit';
  static const olahragaFavorit = 'Olahraga Favorit';
  static const lokasiDefault = 'Lokasi Default';
  static const lapanganFavorit = 'Lapangan Favorit';
  static const riwayatPemesanan = 'Riwayat Pemesanan';
  static const aktivitasSaya = 'Aktivitas Saya';
  static const dashboardMitra = 'Dashboard Mitra';
  static const errMasukDuluFavorit = 'Masuk dulu untuk menyimpan favorit.';

  // ---------- Kesalahan umum ----------
  static const errGagalMuat = 'Gagal memuat';
  static const errTanpaKoneksi = 'Tidak ada koneksi internet. Coba lagi.';
}
