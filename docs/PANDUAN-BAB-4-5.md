# Panduan Penulisan Bab 4 dan Bab 5

Disusun 21 November 2026 untuk penulis Bab 4–5 dan asisten AI yang membantunya.

Struktur panduan ini mengikuti **template Daftar Isi kampus (topik E-Application/Mobile Application)**. Isinya disusun dari:
- file skripsi `SportSpace_Revisi Bab 1-3 Highlight hijau_3.docx`;
- `PRD.md`;
- `SPRINT-PLAN.md`;
- kode aplikasi di repo ini.

Bagian bertanda **[ISI TIM]** adalah data yang belum ada dan harus dikumpulkan sendiri. Jangan diisi dengan perkiraan.

---

## 0. Sebelum mulai

### Baca dulu
1. File `_3`, Bab 1.2 (Rumusan Masalah) dan 1.4 (Tujuan). Simpulan di Bab 5 harus menjawab ketiganya satu per satu.
2. File `_3`, Bab 3.3. Semua yang ditampilkan di Bab 4 harus cocok dengan rancangan di sana.
3. `docs/SISA-REVISI-SKRIPSI.md` bagian "Sebelum mulai". Isinya keputusan tim yang tidak boleh dilanggar.

### Hal yang paling gampang ketahuan penguji
Bab 4 harus cocok dengan Bab 1–3 **dan** dengan aplikasi. Perhatikan:
- **Navigasi bawah 5 tab:** Home · Map · Teman · Profil · Forum. **Forum masuk skripsi** (keputusan 21 November 2026), jadi Forum ikut diuji dan dijelaskan.
- **Data lapangan:** 30 lapangan, terdiri atas 25 lapangan umum dan 5 lapangan mitra.
  - Lapangan umum diambil dari direktori pemesanan daring, lalu diverifikasi manual lewat Google Maps.
  - Lapangan mitra adalah **simulasi** yang didaftarkan lewat akun mitra uji. Fakta ini wajib disebut lagi di Bab 4 (PRD §14 M13).
  - Jangan menulis Google Places API, observasi langsung, atau konfirmasi telepon.
- **Urutan bawaan hasil pencarian murni jarak.** Jarak dihitung dengan Haversine yang **ditulis manual**, bukan dari library. Rating hanya informasi.
- **Notifikasi:**
  - Notifikasi antarpengguna dibuat di dalam aplikasi lewat Firestore listener.
  - Pengingat jadwal dijadwalkan **lokal di HP**.
  - Keduanya **bukan** push notification dan bukan Firebase Cloud Messaging.
- **Firebase Storage tidak dipakai.** Foto lapangan berupa URL. Foto profil dan gambar post forum disimpan sebagai Base64 di Firestore.
- **Rujukan.** Tulis "Anantha Sekoh et al. (2025)", bukan "Mutia et al.", dan "Puryanto dan Akbar (2025)".
- **Penomoran.** Gambar dan tabel dimulai ulang per bab: Gambar 4.1, Tabel 4.1, dan seterusnya.
- **Judul Bab 5 ikut template:** "SIMPULAN DAN SARAN". Bab 1.6 di file `_3` masih menulis "BAB 5 KESIMPULAN DAN SARAN", jadi samakan.

---

## 1. Kerangka sesuai template kampus

| Subbab template | Isi untuk Sport Space | Status bahan |
|---|---|---|
| **4.1 Spesifikasi Sistem** | Spesifikasi perangkat pengembangan dan uji, kebutuhan minimum aplikasi, implementasi arsitektur, basis data, dan algoritma | Sebagian siap. Spesifikasi laptop dan HP **[ISI TIM]** |
| **4.2 Prosedur Penggunaan Aplikasi** | Langkah pemakaian per aktor (Pengguna Umum, Pemilik Lapangan Mitra) disertai tangkapan layar | Aplikasi siap, tinggal mengambil tangkapan layar |
| **4.3.1 Evaluasi User Interface** | Delapan aturan emas Shneiderman, lima faktor manusia terukur, dan hasil SUS | Pemetaan aturan emas siap. Data SUS **[ISI TIM]**: kuesioner belum disebar |
| **4.3.2 Evaluasi Sistem** | Black Box Testing (kasus dari PRD §11) ditambah tes otomatis | Kasus siap. Hasil per kasus perlu dicatat ulang di APK final **[ISI TIM]** |
| **5.1 Simpulan** | Jawaban ketiga rumusan masalah beserta bukti dari Bab 4 | Setelah 4.3 selesai |
| **5.2 Saran** | Keterbatasan yang diakui dan saran pengembangan lanjutan | Daftar siap (bagian 5.2 di bawah) |

Judul bab di template adalah "Hasil dan **Pembahasan**". Jadi setiap hasil di 4.3 perlu diikuti satu-dua paragraf pembahasan: apa artinya, dan bagaimana kaitannya dengan rumusan masalah. Jangan hanya menampilkan tabel.

---

## 2. BAB 4 HASIL DAN PEMBAHASAN

### 4.1 Spesifikasi Sistem

#### 4.1.1 Perangkat dan lingkungan pengembangan
| Komponen | Isi |
|---|---|
| Laptop pengembangan | Prosesor, RAM, sistem operasi **[ISI TIM]** |
| Framework dan bahasa | Flutter 3.47.9 (kanal stable), Dart 3.13.7 |
| IDE | Android Studio dan/atau Visual Studio Code, versi **[ISI TIM]** |
| Backend | Firebase: Cloud Firestore dan Firebase Authentication, paket gratis Spark |
| Pengelolaan kode | Git dan GitHub |

#### 4.1.2 Perangkat uji dan kebutuhan minimum aplikasi
| Komponen | Isi |
|---|---|
| Emulator | Android Emulator `sportspace_pixel` (Android 16) |
| HP fisik | Merek, tipe, dan versi Android **[ISI TIM]**. Wajib dicatat (PRD §14 #6, #15, #19, #23). Rencana T-29: minimal 3 perangkat |
| Minimum OS | Android 7.0 (API 24); target API 36 |
| Ukuran APK rilis | ± 60,5 MB (build 9 November 2026). **Bangun ulang APK final** sebelum SUS, lihat bagian 6 |
| Izin aplikasi | Lokasi (presisi dan perkiraan), internet, notifikasi (ditanyakan saat saklar "Pengingat jadwal" dinyalakan, Android 13 ke atas), dan menjadwalkan ulang pengingat setelah HP dinyalakan ulang |
| Jaringan | Butuh internet. Data tersimpan di Cloud Firestore, dengan cache offline terbatas |

#### 4.1.3 Implementasi arsitektur dan basis data
- **Arsitektur MVVM** dengan Provider. Alurnya View → ViewModel → Repository → Firestore, dan hanya Repository yang mengakses Firestore. Struktur folder bisa ditampilkan sebagai gambar dari `lib/`:
  - `lib/models`;
  - `lib/repositories`;
  - `lib/features/<fitur>/view` dan `lib/features/<fitur>/viewmodel`;
  - `lib/core`;
  - `lib/widgets`.

  Penjelasan tiap folder ada di `docs/PENJELASAN-PROJECT.md`.
- **Koleksi Firestore** (sesuai ERD Tabel 3.17):
  - `users`;
  - `lapangan`;
  - `aktivitasBermain`, dengan subkoleksi `permintaan`;
  - `rating`;
  - `booking`;
  - `slotBooking`;
  - `notifikasi`;
  - `forum_posts`, dengan subkoleksi `komentar`.
- **Composite index.** Satu paragraf dan tabel 11 index dari `docs/FIRESTORE-INDEXES.md` (bagian "Ringkasan" dan "Catatan untuk Bab 4 dan Bab 5"). Pesannya: Firestore menukar fleksibilitas kueri dengan keharusan mendeklarasikan index lebih dulu.
- **Security Rules.** Cukup ringkasan: siapa boleh membaca atau menulis apa (PRD §9).

#### 4.1.4 Implementasi algoritma dan mekanisme kunci
Tampilkan cuplikan kode singkat, sebagai gambar atau listing, untuk:

| Mekanisme | Letak di kode | Catatan |
|---|---|---|
| Haversine Formula | `lib/core/utils/haversine.dart`, fungsi `hitungJarakHaversine()` (jari-jari bumi 6371 km) | Ditulis manual (inti penelitian). Diuji otomatis di `test/haversine_test.dart`: 7 kasus, misalnya Binus Alam Sutera ke KM7 Mini Soccer ± 3,8 km |
| Urut jarak di Home | `HomeViewModel.muatLapangan()` | Ambil posisi, ambil lapangan, hitung Haversine, urutkan |
| Pencegahan double booking | `BookingRepository` | Firestore Transaction dengan ID dokumen tetap `slotBooking/{lapanganId}_{tanggal}_{jam}` (AB-04) |
| Rata-rata rating | `RatingRepository` | Transaction memperbarui `ratingTotal` dan `jumlahRating` (AB-05) |
| Penerimaan peserta | `AktivitasRepository.terimaPermintaan()` | Transaction: `peserta` bertambah, status menjadi PENUH bila kuota terpenuhi |
| Komentar forum | `ForumRepository.tambahKomentar()` | WriteBatch: komentar baru dan `jumlahKomentar` +1 dikirim bersamaan |

### 4.2 Prosedur Penggunaan Aplikasi
Tulis langkah demi langkah per aktor. Setiap langkah diberi tangkapan layar dari **APK final, mode terang** (mode terang = rancangan Figma). Akun uji "Pengguna Uji" dan "Mitra Uji" sudah ada. Minta kata sandinya ke Galih, karena kata sandi tidak disimpan di repo.

**Instalasi:** pasang APK (izinkan "sumber tidak dikenal"), buka aplikasi, izinkan lokasi.

| No | Layar | Yang harus terlihat di tangkapan layar |
|---|---|---|
| 1 | Splash | Logo asli dan tombol "Mulai Sekarang" (#16, #17) |
| 2 | Registrasi | Pilihan peran "Saya adalah: Pengguna / Pemilik Lapangan" |
| 3 | Login | Kolom surel dan kata sandi, tautan "Belum punya akun? Daftar" |
| 4 | Home | Header "Halo, [nama]" dengan lokasi "Tangerang Selatan", baris chip olahraga, kartu terurut jarak, **5 tab** |
| 5 | Map | Marker lapangan, kartu ringkas dengan tombol "Lihat", **atribusi "© OpenStreetMap contributors"** di kiri bawah |
| 6 | Detail Lapangan (non-mitra dan mitra) | Badge "✅ Mitra Terdaftar" dan tombol "Ajukan Reservasi" hanya pada lapangan mitra, tombol "Lihat di peta" dan "Buka di Google Maps", ulasan |
| 7 | Beri Rating | Bintang 1–5 dan ulasan |
| 8 | Ajukan Reservasi | Pilih tanggal dan jam, estimasi harga "dibayar di lokasi" |
| 9 | Notifikasi | Ikon lonceng di Home, daftar notifikasi |
| 10 | Cari Rekan | **Satu baris chip + ikon Filter**, lembar "Filter Aktivitas", kartu dengan bar progres, FAB (#58) |
| 11 | Buat Aktivitas | Form lengkap |
| 12 | Detail Aktivitas | Sisi pembuat: "Permintaan Masuk" dengan Terima/Tolak. Sisi peserta: "Batalkan Keikutsertaan" |
| 13 | Profil | Statistik, Riwayat Pemesanan (dengan tombol Batalkan), Aktivitas Saya, Pengaturan |
| 14 | Forum | Daftar post, Buat Post, Detail Post dengan komentar |
| 15 | Dashboard Mitra (akun mitra) | "Lapangan Saya", "Booking Masuk" dengan Konfirmasi/Tolak |
| 16 | Form Tambah Lapangan (akun mitra) | Kolom lapangan, tombol "Ambil Lokasi Saat Ini" |

**Fitur tambahan di luar rancangan awal (#46, #51).** Fitur-fitur ini ada di aplikasi tetapi sengaja tidak dimasukkan ke Bab 3 (arahan Pak Gintoro: fitur pemanis). Cukup satu paragraf, dengan tangkapan layar bila perlu:
- favorit lapangan, olahraga favorit, dan lokasi default;
- lencana pencapaian;
- tombol WhatsApp dan Bagikan;
- Filter & Urutkan di Home;
- blokir slot (Atur Slot) dan promo/diskon;
- produk tambahan dan ubah jadwal booking;
- aktivitas privat;
- balasan mitra atas ulasan;
- pengingat jadwal dan mode gelap;
- cari rekan dari booking dan riwayat main.

**Jangan** memasukkan Forum ke daftar ini, karena Forum sudah ada di rancangan Bab 3.

### 4.3 Evaluasi

#### 4.3.1 Evaluasi User Interface
**(a) Delapan aturan emas (Shneiderman et al., 2016).** Bab 3.3.2 poin 5 sudah mengklaim penerapan aturan 1, 3, 5, 6, dan 8, jadi Bab 4 wajib membuktikannya dengan tangkapan layar. Draf pemetaannya (cek lagi di aplikasi sebelum dipakai):

| Aturan | Penerapan di Sport Space |
|---|---|
| 1. Konsistensi | Navigasi bawah 5 tab di semua halaman utama; warna hijau utama, gaya kartu, dan chip yang sama di Home, Map, dan Cari Rekan |
| 2. Kegunaan universal | Seluruh teks berbahasa Indonesia; mode Terang/Gelap/Ikuti HP; fitur lanjutan (Filter & Urutkan) opsional sehingga pengguna baru tidak terbebani |
| 3. Umpan balik informatif | SnackBar setelah aksi (mis. "Permintaan gabung terkirim.", "Reservasi berhasil diajukan."); indikator memuat; pesan kosong dan pesan gagal di setiap layar |
| 4. Dialog yang menuntaskan | Alur reservasi berakhir dengan status pemesanan dan notifikasi; konfirmasi mitra langsung memberi notifikasi ke pengguna |
| 5. Pencegahan kesalahan | Validasi form (waktu lampau ditolak, tingkat kemampuan wajib); tombol "Ajukan Reservasi" hanya di lapangan mitra; slot yang sudah dipesan tidak bisa dipesan lagi |
| 6. Pembalikan aksi | Batalkan booking, ubah jadwal, batal ikut aktivitas, batalkan aktivitas, reset filter, edit/hapus post; semua dengan dialog konfirmasi |
| 7. Pengguna memegang kendali | Urutan dan filter dipilih sendiri (bawaan tetap jarak); pengingat bisa dimatikan; izin lokasi tidak memaksa karena ada lokasi default |
| 8. Mengurangi beban memori | Chip aktif selalu terlihat; kartu langsung memuat jarak, harga, dan rating; kartu ringkas di peta; label status pada riwayat pemesanan |

**(b) Lima faktor manusia terukur** (waktu belajar, kecepatan kinerja, tingkat kesalahan, daya ingat, kepuasan subjektif). Faktor **kepuasan subjektif** diukur dengan SUS. Faktor lain **hanya boleh ditulis kalau benar-benar diukur**, misalnya responden diberi tugas "cari lapangan terdekat lalu ajukan reservasi", kemudian waktu dan kesalahannya dicatat. Kalau tidak diukur, tulis bahwa evaluasi difokuskan pada kepuasan subjektif melalui SUS.

**(c) Hasil SUS** **[ISI TIM]**
- Prosedur sesuai Bab 1.3, 1.5, dan 2.11.3: 20–30 responden, purposive sampling, usia 17–35 tahun, aktif berolahraga, pengguna Android, sudah mencoba aplikasi.
- Instrumen: 10 pernyataan SUS standar (Brooke, 1996) dalam bahasa Indonesia, skala Likert 1–5.
- Perhitungan: pakai `Kalkulator_SUS_SportSpace.xlsx` (ada di laptop Galih, di luar repo). Item ganjil = nilai − 1, item genap = 5 − nilai, jumlah × 2,5.
- Tabel: skor per responden, rata-rata, dan interpretasi menurut Bangor et al. (2009), yaitu sekitar 68 = rata-rata dan di atas 80 = sangat baik (sesuai Bab 2.11.3).
- Status: kuesioner **belum disebar** (T-31).

#### 4.3.2 Evaluasi Sistem (Black Box Testing)
Kasus uji sudah siap di **`PRD.md` §11**, lengkap dengan kolom "Skenario" dan "Hasil yang diharapkan". Format tabel di Bab 4: No · ID · Skenario · Hasil yang diharapkan · Hasil pengujian · Status (Berhasil/Gagal).

**Kasus yang dimasukkan:**

| Kelompok | ID | Keputusan |
|---|---|---|
| Fitur yang ada di rancangan Bab 3 | BB-01…BB-30, BB-33, BB-34, BB-38, BB-39, BB-40, BB-41 | **Wajib** |
| Forum | BB-42…BB-49 | **Wajib** (Forum masuk skripsi, PRD §14 #43) |
| Favorit, lokasi default, statistik | BB-31, BB-32, BB-35, BB-36, BB-37 | Fitur ini tidak ada di Bab 3. Pilih salah satu: masukkan sebagai pengujian fitur tambahan, atau keluarkan. Kalau BB-36 dipakai, angka "Favorit" termasuk di dalamnya |
| Fitur tambahan lain | BB-50…BB-107 | Pilih: ikut diuji, atau tulis bahwa fitur tambahan di luar ruang lingkup pengujian (#47, #52) |

**Hasil yang sudah ada:**
- 19 Oktober 2026: BB-01…BB-41 **41/41 lulus** di emulator dan HP Android. Merek dan tipe HP belum dicatat **[ISI TIM]**.
- 6 November 2026: uji end-to-end di emulator tanpa bug, termasuk post, komentar, dan hapus di Forum. BB-42…BB-49 belum dicatat per kasus.
- 21 November 2026: `flutter test` 272 tes otomatis lulus. Untuk BB-13 (akurasi Haversine), tes otomatis ini bisa dijadikan bukti tambahan.

**Saran:** banyak fitur berubah setelah 19 Oktober. Jalankan ulang seluruh kasus yang dimasukkan pada **APK final**, lalu catat hasil per kasus beserta bukti tangkapan layarnya (bisa ditaruh di lampiran).

---

## 3. BAB 5 SIMPULAN DAN SARAN

### 5.1 Simpulan
Jawab ketiga rumusan masalah (Bab 1.2) satu per satu, masing-masing dengan bukti dari Bab 4. Angka SUS jangan ditulis sebelum datanya ada.

| Rumusan masalah | Bukti di Bab 4 |
|---|---|
| 1. Pencarian lapangan berbasis LBS yang menampilkan lapangan terdekat dan informasinya | BB-05…BB-13, BB-40; tes otomatis Haversine; tangkapan layar Home dan Map |
| 2. Pencarian rekan bermain multiolahraga (membuat, mencari, bergabung) | BB-14…BB-20, BB-39; tangkapan layar Cari Rekan dan Detail Aktivitas |
| 3. Platform informasi terpusat dengan rating dan reservasi pada lapangan mitra | BB-11, BB-12, BB-21…BB-29, BB-33, BB-34, BB-38, BB-41; tangkapan layar Detail Lapangan, Reservasi, Dashboard Mitra |
| Kemudahan penggunaan secara keseluruhan | Skor SUS beserta interpretasinya |

Forum disebut sebagai **fitur pendukung** interaksi antarpengguna (BB-42…BB-49). Forum tidak menjawab rumusan masalah tertentu.

### 5.2 Saran
Template hanya memuat Simpulan dan Saran. Karena itu keterbatasan ditulis sebagai dasar saran. Cara lainnya: tulis satu paragraf keterbatasan di akhir Bab 4, lalu saran di 5.2. Daftar yang sebaiknya diakui sendiri sebelum ditemukan penguji:

**Keterbatasan dan saran perbaikannya**

| Keterbatasan | Saran |
|---|---|
| Jarak Haversine dihitung di klien untuk semua lapangan, jadi biaya baca naik seiring jumlah lapangan | Geohash atau kueri spasial untuk skala besar |
| Posisi GPS dibaca sekali saat daftar dimuat, bukan dipantau terus-menerus | Pembaruan posisi berkala |
| Notifikasi hanya di dalam aplikasi. Pengingat jadwal hanya terjadwal saat aplikasi terbuka dan bisa terlambat beberapa menit | Push notification dari server |
| Ketersediaan slot hanya akurat untuk lapangan mitra. Harga, jam, dan fasilitas lapangan non-mitra hanya estimasi dari direktori daring | Menambah lapangan mitra dan pembaruan data berkala |
| Satu harga dan satu jam operasional untuk lapangan multi-olahraga (#24) | Harga dan jam per jenis olahraga |
| Security Rules longgar di beberapa titik karena tanpa Cloud Functions (update aktivitas, penghitung komentar forum) | Validasi di sisi server |
| Forum (#44): komentar tidak bisa diedit atau dihapus satu per satu, teks post tidak dibatasi panjangnya, satu gambar maksimal 500 KB per post, hanya 20 post terbaru tanpa paginasi, tidak ada notifikasi komentar | Paginasi, moderasi, notifikasi komentar |
| Aktivitas privat hanya disembunyikan dari daftar, tidak dilindungi Security Rules (#53) | Aturan akses berbasis kode |
| Promo, produk tambahan, dan biaya per orang hanya informasi, tanpa pembayaran (#48, #53) | Integrasi pembayaran daring |
| Balasan mitra tidak bisa dihapus dan tidak memberi notifikasi (#53) | — |
| Filter jenis dan tingkat aktivitas dijalankan di klien (#48) | Pemfilteran di kueri |
| Aktivitas yang dibuat dari booking tidak ikut berubah saat booking dibatalkan atau dijadwal ulang | Sinkronisasi otomatis |
| Peta tetap terang di mode gelap; layar sambut putih bawaan Android muncul sesaat (#56) | Tile peta versi gelap |
| Belum diuji: HP fisik untuk fitur tambahan, mode hemat daya, BB-77 yang butuh dua perangkat (#57) | Pengujian di lebih banyak perangkat |

**Saran pengembangan lanjutan** (fitur yang sengaja tidak dibangun):
- rating antar-pengguna (#7);
- daftar tunggu aktivitas, co-host, level pemain, dan pembagian tim otomatis;
- versi iOS;
- pemulihan kata sandi dan verifikasi surel;
- integrasi pembayaran.

---

## 4. Data yang harus dikumpulkan tim
- [ ] Spesifikasi laptop pengembangan dan versi IDE.
- [ ] Merek, tipe, dan versi Android HP uji (target minimal 3 perangkat, T-29).
- [ ] Hasil Black Box per kasus pada APK final, beserta tangkapan layar bukti.
- [ ] Tangkapan layar 4.2 (daftar 16 layar di atas), mode terang.
- [ ] Data SUS 20–30 responden, rekap skor, dan interpretasi.
- [ ] (Opsional) Pengukuran waktu dan kesalahan tugas untuk faktor manusia terukur selain kepuasan.

## 5. Sumber di repo
| Keperluan | Berkas |
|---|---|
| Daftar kasus Black Box | `PRD.md` §11 |
| Catatan revisi untuk Bab 4–5 (#6, #7, #15–#17, #19, #23, #24, #43, #44, #46–#58, M13) | `PRD.md` §14 |
| Aturan bisnis tiap fitur (AB-01…AB-26) | `PRD.md` §7 |
| Riwayat dan hasil pengujian | `SPRINT-PLAN.md` (Sprint 5, "Uji end-to-end 6 November 2026", catatan uji regresi) |
| Tabel 11 composite index | `docs/FIRESTORE-INDEXES.md` |
| Penjelasan struktur project | `docs/PENJELASAN-PROJECT.md` |
| Tes otomatis | Folder `test/` (jalankan `flutter test`) |

## 6. Urutan kerja yang disarankan
1. Pastikan semua perubahan kode sudah masuk `main`, termasuk atribusi OpenStreetMap di peta (21 November 2026).
2. Bangun **APK final**: `flutter build apk --release`. APK 9 November belum memuat atribusi peta, jadi jangan dibagikan lagi.
3. Jalankan Black Box pada APK final dan catat hasilnya.
4. Sebarkan APK dan kuesioner SUS ke responden.
5. Ambil tangkapan layar 4.2.
6. Tulis Bab 4, lalu Bab 5.
7. Cek ulang konsistensi dengan Bab 1–3 memakai daftar di bagian 0.
