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

  // ---------- Beri Rating (L-11) ----------
  static const ulasanOpsional = 'Ulasan (opsional)';
  static const errPilihBintang = 'Pilih rating bintang dulu.';
  static const ratingTerkirim = 'Terima kasih atas ratingmu!';

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

  // ---------- Notifikasi (L-12) ----------
  static const notifikasi = 'Notifikasi';
  static const kosongNotifikasi = 'Belum ada notifikasi.';

  // ---------- Booking (L-10) ----------
  static const pilihSlot = 'Pilih Slot';
  static const slotPenuh = 'Penuh';
  static const estimasiDibayarDiLokasi = 'Estimasi, dibayar di lokasi';
  static const errSlotSudahDipesan = 'Slot sudah dipesan';
  static const tanggal = 'Tanggal';
  static const jamMulai = 'Jam Mulai';
  static const durasi = 'Durasi';
  static const satuanJam = 'jam';
  static const totalEstimasi = 'Total Estimasi';
  static const reservasiTerkirim = 'Reservasi berhasil diajukan.';
  static const errPilihTanggalDulu = 'Pilih tanggal dulu.';
  static const errPilihJamMulai = 'Pilih jam mulai.';
  static const kosongJamTersedia = 'Tidak ada jam tersedia di tanggal ini.';

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
  static const namaLokasi = 'Nama Lokasi';
  static const contohNamaLokasi = 'Rumah, Kantor, dll';

  // ---------- Dashboard Mitra (L-14) ----------
  static const lapanganSaya = 'Lapangan Saya';
  static const tambahLapangan = 'Tambah Lapangan';
  static const bookingMasuk = 'Booking Masuk';
  static const konfirmasi = 'Konfirmasi';
  static const kosongLapanganMitra = 'Belum ada lapangan terdaftar.';
  static const kosongBookingMasuk = 'Belum ada booking masuk.';
  static const bookingDikonfirmasi = 'Booking dikonfirmasi.';
  static const bookingDitolak = 'Booking ditolak.';

  // ---------- Tambah/Edit Lapangan (L-15) ----------
  static const tambahLapanganJudul = 'Tambah Lapangan';
  static const editLapanganJudul = 'Edit Lapangan';
  static const alamat = 'Alamat';
  static const latitude = 'Latitude';
  static const longitude = 'Longitude';
  static const ambilLokasiSaatIni = 'Ambil Lokasi Saat Ini';
  static const jamTutup = 'Jam Tutup';
  static const urlFotoOpsional = 'URL Foto (opsional)';
  static const lapanganTersimpan = 'Lapangan berhasil disimpan.';
  static const errPilihOlahraga = 'Pilih minimal satu jenis olahraga.';
  static const errGagalAmbilLokasi =
      'Gagal mengambil lokasi. Isi koordinat manual.';

  // ---------- Kesalahan umum ----------
  static const errGagalMuat = 'Gagal memuat';
  static const errTanpaKoneksi = 'Tidak ada koneksi internet. Coba lagi.';

  // ---------- Profil (L-13) lanjutan ----------
  static const segeraHadir = 'Segera hadir.';
  static const belumDipilih = 'Belum dipilih';
  static const belumDiatur = 'Belum diatur';
  static const ubah = 'Ubah';
  static const kosongRiwayatBooking = 'Belum ada riwayat pemesanan.';
  static const kosongAktivitasSaya = 'Belum ada aktivitas yang kamu buat atau ikuti.';
  static const kosongLapanganFavorit = 'Belum ada lapangan favorit.';
  static const bantuan = 'Bantuan';
  static const kebijakanPrivasi = 'Kebijakan Privasi';
  static const tentang = 'Tentang';

  static const isiBantuan =
      'Sport Space membantu kamu menemukan lapangan olahraga dan rekan '
      'bermain di sekitarmu.\n\n'
      '• Cari lapangan lewat tab Home, urut berdasarkan jarak terdekat.\n'
      '• Buka tab Map untuk melihat lapangan di peta.\n'
      '• Buat atau gabung aktivitas bermain lewat tab Teman.\n'
      '• Lapangan bertanda "Mitra Terdaftar" bisa direservasi langsung '
      'lewat aplikasi; pembayaran dilakukan di lokasi.\n\n'
      'Ada kendala? Hubungi peneliti lewat kontak yang tertera pada '
      'lembar kuesioner.';

  static const isiKebijakanPrivasi =
      'Data yang kamu masukkan (nama, surel, nomor telepon, lokasi) '
      'hanya dipakai untuk menjalankan fitur aplikasi ini: pencarian '
      'lapangan berbasis lokasi, rekan bermain, dan reservasi.\n\n'
      'Data disimpan di Firebase (Google Cloud) dan tidak dibagikan ke '
      'pihak ketiga di luar keperluan operasional aplikasi. Aplikasi ini '
      'dibangun untuk keperluan penelitian skripsi, bukan produk '
      'komersial.';

  // ---------- Admin Seed (T-10, sementara — lihat catatan di admin_seed_screen.dart) ----------
  static const adminSeedJudul = 'Seed Data Awal';
  static const adminSeedKeterangan =
      'Mengisi 7 lapangan prototipe (koordinat sudah terverifikasi) ke '
      'Firestore, termasuk 3 lapangan mitra yang dimiliki akun ini — '
      'supaya alur reservasi bisa dicoba sebelum data 30 lapangan penuh '
      '(T-10) siap.';
  static const adminSeedTombol = 'Isi Data Awal';
  static const adminSeedBerhasil = 'lapangan berhasil ditambahkan.';
  static const adminSeedPerluLogin = 'Masuk dulu untuk menjalankan seed data.';

  static const isiTentang =
      'Sport Space v1.1\n\n'
      'Aplikasi pencarian lapangan olahraga dan rekan bermain berbasis '
      'lokasi, dikembangkan sebagai bagian dari tugas akhir (skripsi).\n\n'
      'Dibangun dengan Flutter dan Firebase. Perhitungan jarak memakai '
      'rumus Haversine yang ditulis manual sebagai kontribusi penelitian.';
}
