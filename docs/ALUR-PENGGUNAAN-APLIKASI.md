# Alur Penggunaan Aplikasi (End to End)

Disusun 21 November 2026 sebagai bahan menggambar ulang diagram alur, flowchart, dan activity diagram di Bab 3.

- Alur di bawah dicocokkan dengan **kode aplikasi** (`lib/`), bukan hanya dengan PRD. Kalau keduanya berbeda, gambar sesuai kode. Selisih yang ditemukan ada di bagian akhir.
- Status uji tiap skenario diambil dari catatan di `SPRINT-PLAN.md` dan `docs/PANDUAN-BAB-4-5.md`, ditambah uji ulang end-to-end di emulator pada 21 November 2026 (lihat "Ringkasan status uji").

## Cara membaca

**Penanda ruang lingkup skripsi**

Arahan Pak Gintoro (5 November 2026): fitur pemanis tidak dibuatkan use case, diagram, atau subbab baru di Bab 3. Lihat `docs/SISA-REVISI-SKRIPSI.md`.

- **[Inti]**: boleh masuk diagram Bab 3.
- **[Pemanis]**: cukup jadi cabang kecil, atau tidak usah digambar.

**Penanda status uji**

- **HP**: lulus di emulator **dan** HP Android. Ini T-30 tanggal 19 Oktober 2026, BB-01…BB-41, 41/41 lulus.
- **Emulator**: lulus di emulator saja (kebanyakan 4–6 November 2026), belum diuji di HP fisik.
- **Otomatis**: hanya dibuktikan lewat `flutter test`.
- **Belum**: belum terbukti sama sekali.

**Aktor dan navigasi**

- **Pengguna** (`role: pengguna`) dan **Mitra** (`role: mitra`). Mitra bisa melakukan semua yang dilakukan Pengguna, ditambah Dashboard Mitra.
- Semua fitur hanya bisa dipakai setelah login.
- Navigasi bawah punya 5 tab: Home · Map · Teman · Profil · Forum.

---

## A. Masuk dan keluar aplikasi

### 1. Membuka aplikasi [Inti]
1. Pengguna membuka aplikasi dan Splash tampil (logo, tagline, tombol "Mulai Sekarang"). Status login sudah dicek di latar belakang.
2. Pengguna menekan "Mulai Sekarang".
   - Sudah login: masuk ke Home.
   - Belum login: masuk ke halaman Login.

**Status uji:** tidak punya kasus BB sendiri, tetapi dilalui di setiap sesi uji, termasuk di HP (19 Oktober). Restart aplikasi diuji di emulator pada 6 November.

### 2. Registrasi [Inti]
1. Di halaman Login, pengguna menekan tautan Daftar.
2. Pengguna mengisi nama, surel, nomor telepon, kata sandi, konfirmasi kata sandi, dan peran (Pengguna atau Pemilik Lapangan), lalu menekan Daftar.
   - Isian tidak valid: pesan muncul di form dan pengguna memperbaiki isiannya.
   - Surel sudah terdaftar: pesan kesalahan muncul dan akun tidak dibuat.
   - Berhasil: akun Auth dan dokumen `users` (beserta `role`) dibuat, lalu pengguna langsung masuk ke Home.

**Status uji:** HP (BB-01, BB-02).

### 3. Login [Inti]
1. Pengguna mengisi surel dan kata sandi, lalu menekan Masuk.
   - Salah: muncul "Surel atau kata sandi salah".
   - Berhasil: masuk ke Home.

**Status uji:** HP (BB-03, BB-04).

### 4. Keluar [Inti]
1. Pengguna membuka Profil dan menekan Keluar (tanpa dialog konfirmasi).
2. Pengingat jadwal yang belum muncul dibatalkan, akun keluar, lalu halaman Login tampil.

**Status uji:**
- HP (BB-30).
- Pembatalan pengingat saat keluar: Emulator (BB-91…95).

---

## B. Pencarian lapangan (Gambar 3.2, 3.5, 3.8)

### 5. Mencari lapangan terdekat di Home [Inti, alur Haversine]
1. Pengguna membuka tab Home dan aplikasi meminta izin lokasi.
   - **Izin diberikan:** posisi diambil dari GPS.
   - **Izin ditolak atau GPS mati, dan pengguna punya lokasi default:** lokasi default dipakai, dan spanduk "Memakai lokasi default…" tampil. *[Pemanis]*
   - **Izin ditolak atau GPS mati, tanpa lokasi default:** tampil pesan "Lokasi belum aktif" dengan tombol Buka Pengaturan. Setelah pengguna kembali dari pengaturan, aplikasi memuat ulang.
2. Aplikasi mengambil seluruh dokumen `lapangan` dari Firestore (maksimal 500).
3. Untuk setiap lapangan, aplikasi menghitung jarak dengan `hitungJarakHaversine()`.
4. Daftar diurutkan dari jarak terdekat, lalu ditampilkan sebagai kartu (foto, nama, alamat, jarak, harga, rating).
   - Gagal memuat: tampil pesan kesalahan dengan tombol Coba Lagi.
   - Data kosong: tampil "Belum ada lapangan di sekitar kamu."
5. Pengguna menekan kartu dan masuk ke Detail Lapangan (skenario 8).

**Status uji:** HP (BB-05, BB-06, BB-13, BB-35).

### 6. Menyaring daftar di Home
- [Inti] Mengetik kata kunci di kotak pencarian (nama atau alamat).
- [Inti] Memilih chip olahraga: Semua, Futsal, Mini Soccer, Badminton, atau Padel.
- [Pemanis] Menyalakan tombol ♥ supaya hanya lapangan favorit yang tampil.
- [Pemanis] Membuka "Filter & Urutkan":
  - urutan Terdekat (bawaan), Rating tertinggi, atau Terpopuler;
  - saklar Buka sekarang;
  - fasilitas;
  - tombol Reset.
- Semua saringan berlaku bersamaan. Kalau hasilnya kosong, tampil pesan "tidak ada yang cocok".

**Status uji:**
- Kata kunci dan chip: HP (BB-07, BB-08).
- Favorit: HP (BB-31, BB-32).
- Filter & Urutkan: Emulator (BB-62…66).

### 7. Mencari lewat Peta [Inti]
1. Pengguna membuka tab Map dan izin lokasi diminta (cabangnya sama seperti skenario 5).
2. Peta OSM tampil dengan marker posisi pengguna dan marker tiap lapangan.
3. Pengguna menekan marker dan kartu ringkas tampil (nama, jarak, harga).
4. Pengguna menekan "Lihat" dan masuk ke Detail Lapangan.
- Tombol lain di peta: zoom +/−, "kembali ke posisi saya", dan atribusi OSM.

**Status uji:**
- HP (BB-09, BB-10, BB-40).
- Atribusi OSM: Emulator (21 November).

### 8. Melihat Detail Lapangan [Inti]
1. Layar menampilkan foto, nama, olahraga, rating, badge Mitra (kalau mitra), alamat, jam operasional, fasilitas, harga, kontak, dan daftar ulasan.
2. Aksi yang tersedia:
   - "Lihat di peta" memindahkan ke tab Map dan memfokuskan peta ke lapangan itu.
   - [Pemanis] "Buka di Google Maps" (hanya kalau tautan tersedia).
   - [Pemanis] tombol WhatsApp (hanya untuk nomor seluler) dan tombol Bagikan.
   - [Pemanis] ikon ♡ untuk favorit atau batal favorit.
   - "Beri Rating" (skenario 9).
   - "Ajukan Reservasi": **hanya muncul kalau `isMitra == true`** (skenario 10).

**Status uji:**
- HP (BB-11, BB-12, BB-33, BB-34, BB-41).
- WhatsApp dan Bagikan: Emulator (BB-58…61). Tautannya baru terbuka di Chrome, karena emulator tidak punya aplikasi WhatsApp. **Membuka aplikasi WhatsApp asli belum diuji.**

### 9. Memberi atau mengubah rating [Inti]
1. Pengguna menekan "Beri Rating" dan aplikasi memuat rating lama miliknya.
   - Gagal memuat: pesan dengan tombol Coba Lagi. Form sengaja tidak dibuka.
   - Sudah pernah menilai: judul "Ubah Rating" dan form terisi nilai lama.
   - Belum pernah: form kosong.
2. Pengguna memilih bintang 1–5, mengisi ulasan (opsional, maksimal 500 karakter), lalu menekan Kirim.
3. Sebuah transaction menyimpan rating dan memperbarui `ratingTotal`, `jumlahRating`, dan `ratingRata2`.
4. Ulasan baru langsung tampil.

**Status uji:**
- Perhitungan rating: HP (BB-21…23).
- Form "Ubah Rating" dan pesan gagal memuat: Emulator (BB-83…85, diperbaiki 5 November).

---

## C. Reservasi lapangan mitra

### 10. Mengajukan reservasi [Inti]
1. Di Detail Lapangan mitra, pengguna menekan "Ajukan Reservasi".
2. Pengguna memilih tanggal (hari ini sampai 60 hari ke depan). Jam yang sudah dipesan atau diblokir tampil "Penuh".
3. Pengguna memilih jam mulai dan durasi.
4. [Pemanis] Pengguna mengatur jumlah produk tambahan, kalau lapangan menyediakannya.
5. Estimasi total tampil dengan label "dibayar di lokasi". [Pemanis] Kalau ada promo, potongan diskonnya dirinci.
6. Pengguna menekan Ajukan Reservasi dan sebuah transaction mengecek setiap kunci `slotBooking`.
   - Ada slot yang sudah terisi: muncul "Slot sudah dipesan" dan pengguna memilih jam lain.
   - Semua kosong: booking dibuat dengan status **MENUNGGU**, slot dikunci, notifikasi **BOOKING_BARU** dikirim ke mitra, lalu pengguna kembali ke Detail Lapangan.

**Status uji:**
- HP (BB-24, BB-25).
- Diskon dan produk tambahan: Emulator (BB-70…74). BB-75 hanya Otomatis.

### 11. Mitra mengonfirmasi atau menolak booking [Inti]
1. Mitra menerima notifikasi BOOKING_BARU. Menekannya membuka Dashboard Mitra (atau mitra membuka Profil lalu Dashboard Mitra).
2. Di daftar booking masuk, mitra memilih tindakan (hanya untuk status MENUNGGU):
   - **Konfirmasi:** status menjadi **DIKONFIRMASI** dan notifikasi BOOKING_DIKONFIRMASI dikirim ke penyewa.
   - **Tolak:** status menjadi **DITOLAK**, slot dibuka lagi, dan notifikasi BOOKING_DITOLAK dikirim ke penyewa.
   - Sudah diproses sebelumnya: muncul "Booking ini sudah diproses."
3. Penyewa menekan notifikasinya dan masuk ke tab Profil, tempat statusnya terlihat di Riwayat Pemesanan.

**Status uji:**
- HP (BB-26, BB-27).
- Notifikasi yang membuka tab Profil: Emulator (6 November).

### 12. Penyewa membatalkan booking [Inti]
1. Di Profil, Riwayat Pemesanan, penyewa menekan "Batalkan". Tombol ini hanya ada selama status MENUNGGU atau DIKONFIRMASI dan jam selesai belum lewat.
2. Dialog konfirmasi tampil, lalu penyewa menekan Ya.
3. Status menjadi **DIBATALKAN**, slot dibuka lagi, dan notifikasi BOOKING_DIBATALKAN dikirim ke mitra.

**Status uji:** HP (BB-38).

### 13. Mengubah jadwal booking [Pemanis]
1. Di Riwayat Pemesanan, penyewa menekan "Ubah Jadwal" (syaratnya sama dengan Batalkan).
2. Layar reservasi terbuka dalam mode ubah, terisi jadwal lama.
3. Penyewa memilih jadwal baru lalu menekan "Simpan Jadwal Baru".
   - Jadwal sama dengan yang lama: "Jadwal tidak berubah".
   - Slot baru sudah terisi: "Slot sudah dipesan".
   - Berhasil: slot lama dilepas, slot baru dikunci, status kembali **MENUNGGU**, dan notifikasi BOOKING_DIJADWALKAN_ULANG dikirim ke mitra. Setelah itu mitra mengonfirmasi ulang lewat skenario 11.

**Status uji:**
- Emulator (BB-76, BB-78).
- **BB-77 (rebutan slot saat ubah jadwal): hanya Otomatis.** Kasus ini butuh dua perangkat bersamaan.

### 14. Booking menjadi SELESAI otomatis [Inti, tanpa aksi pengguna]
- Saat riwayat dimuat, booking DIKONFIRMASI yang tanggal dan jam selesainya sudah lewat berubah menjadi **SELESAI**, dan perubahan itu ditulis ke Firestore.

**Status uji:** HP (BB-28).

### 15. Pengingat jadwal [Pemanis]
- Setiap booking DIKONFIRMASI dijadwalkan pengingat lokal di HP, 1 jam sebelum main.
- Notifikasinya berbunyi "Sebentar lagi waktunya main!".
- Pengingat bisa dimatikan lewat saklar di Profil, Pengaturan.

**Status uji:**
- Emulator (BB-91…95).
- **Belum:** HP fisik, mode hemat daya, dan penjadwalan ulang setelah HP dinyalakan ulang.

---

## D. Cari rekan bermain (Gambar 3.3, 3.6, 3.9)

### 16. Membuat aktivitas [Inti]
1. Pengguna membuka tab Teman dan menekan FAB +.
2. Pengguna mengisi:
   - olahraga, lapangan, tanggal dan jam, jumlah pemain (2–30), catatan (opsional);
   - [Pemanis] jenis (Main Bareng atau Sparring), tingkat kemampuan (wajib), biaya per orang (opsional), dan visibilitas (Publik atau Privat).
3. Pengguna menekan Simpan.
   - Validasi gagal (waktu sudah lewat, lapangan atau tingkat belum dipilih, dan seterusnya): SnackBar berisi pesan.
   - Publik: aktivitas tersimpan dengan status TERBUKA, lalu pengguna kembali ke daftar.
   - [Pemanis] Privat: kode akses 6 karakter dibuat, lalu dialog menampilkan kode itu beserta tombol salin.

**Status uji:**
- HP (BB-14, BB-15).
- Jenis, tingkat, dan biaya: Emulator (BB-50…55).
- Privat: Emulator (BB-79…81). BB-82 hanya Otomatis.

### 17. Membuat aktivitas dari booking [Pemanis]
1. Di Riwayat Pemesanan, untuk booking DIKONFIRMASI yang belum mulai, pengguna menekan "Cari rekan untuk jadwal ini".
2. Form Buat Aktivitas terbuka, sudah terisi lapangan, olahraga, tanggal, dan jam.
3. Pengguna melengkapi isian lain, lalu alurnya sama dengan skenario 16.

**Status uji:** Emulator (BB-101…104).

### 18. Mencari dan bergabung ke aktivitas [Inti]
1. Tab Teman menampilkan daftar aktivitas terbuka. Aktivitas yang penuh, sudah lewat, atau privat tidak tampil.
2. Pengguna menyaring dengan chip olahraga. [Pemanis] Ikon Filter menyaring jenis dan tingkat.
   - Kosong: tampil pesan kosong, atau "tidak cocok dengan filter".
3. Pengguna menekan **Gabung**, langsung dari kartu atau setelah membuka Detail Aktivitas.
4. Permintaan dibuat dengan status **MENUNGGU** dan notifikasi PERMINTAAN_GABUNG dikirim ke pembuat.
5. Selama menunggu, Detail Aktivitas menampilkan label "Menunggu persetujuan".

**Status uji:**
- HP (BB-16, BB-20).
- Filter jenis dan tingkat: Emulator.

### 19. Bergabung lewat kode, untuk aktivitas privat [Pemanis]
1. Di tab Teman, pengguna menekan "Punya kode?" lalu mengetik kodenya.
   - Kode tidak ada: muncul "Kode tidak ditemukan."
   - Ketemu: Detail Aktivitas terbuka, lalu pengguna menekan Gabung (lanjut seperti skenario 18 langkah 4).

**Status uji:** Emulator (BB-79…81).

### 20. Pembuat menerima atau menolak permintaan [Inti]
1. Pembuat menerima notifikasi PERMINTAAN_GABUNG. Menekannya membuka Detail Aktivitas.
2. Daftar permintaan tampil dengan tombol Terima dan Tolak.
   - **Terima** (transaction):
     - Kalau sudah penuh: muncul "Slot penuh".
     - Kalau belum: pemohon masuk `peserta`, jumlah pemain bertambah 1, status menjadi **PENUH** bila kuotanya tercapai, dan notifikasi PERMINTAAN_DITERIMA dikirim ke pemohon.
   - **Tolak:** status permintaan menjadi DITOLAK dan notifikasi PERMINTAAN_DITOLAK dikirim ke pemohon.
3. Pemohon menekan notifikasinya dan Detail Aktivitas terbuka.

**Status uji:** HP (BB-17…19).

### 21. Peserta membatalkan keikutsertaan [Inti]
1. Di Detail Aktivitas, peserta (bukan pembuat) menekan "Batalkan Keikutsertaan", lalu dialog konfirmasi tampil.
2. Peserta dikeluarkan dan jumlah pemain berkurang 1. Kalau status sebelumnya PENUH, status kembali TERBUKA.
3. Dokumen permintaannya dihapus, jadi peserta bisa mengajukan lagi nanti.
4. Notifikasi PESERTA_KELUAR dikirim ke pembuat.

**Status uji:** Emulator (BB-108, lulus 21 November). Kasus BB-108 baru ditambahkan 21 November karena alur ini termasuk use case Bab 3, tetapi sebelumnya belum punya kasus uji. Belum diuji di HP.

### 22. Pembuat membatalkan aktivitas [Inti]
1. Di Detail Aktivitas, pembuat menekan "Batalkan Aktivitas", lalu dialog konfirmasi tampil.
2. Dokumen aktivitas **dihapus** dan notifikasi AKTIVITAS_DIBATALKAN dikirim ke semua peserta selain pembuat.
3. Notifikasi ini tidak membuka halaman apa pun, karena aktivitasnya sudah tidak ada.

**Status uji:** HP (BB-39).

### 23. Membagikan aktivitas [Pemanis]
- Di Detail Aktivitas, tombol Bagikan membuka WhatsApp berisi ringkasan aktivitas. Untuk aktivitas privat, kodenya ikut dibagikan.

**Status uji:** Emulator (BB-58, BB-59), terbuka lewat Chrome. Aplikasi WhatsApp asli belum diuji.

---

## E. Notifikasi

### 24. Membuka notifikasi [Inti]
1. Di Home, pengguna menekan ikon lonceng (badge-nya menunjukkan jumlah yang belum dibaca).
2. Daftar notifikasi tampil, terbaru di atas.
3. Pengguna menekan satu notifikasi. Notifikasi itu ditandai sudah dibaca, lalu aplikasi membuka tujuannya:

| Tipe | Penerima | Tujuan saat ditekan |
|---|---|---|
| PERMINTAAN_GABUNG / _DITERIMA / _DITOLAK | pembuat / pemohon | Detail Aktivitas |
| BOOKING_BARU, BOOKING_DIBATALKAN, BOOKING_DIJADWALKAN_ULANG | mitra | Dashboard Mitra |
| BOOKING_DIKONFIRMASI / _DITOLAK | penyewa | tab Profil |
| PESERTA_KELUAR, AKTIVITAS_DIBATALKAN | pembuat / peserta | tidak membuka apa pun |

**Status uji:**
- Pembuatan notifikasi: HP (lewat BB-16, 17, 19, 24, 26).
- Ketukan yang membuka layar yang tepat: Emulator (6 November; diulang 21 November untuk BOOKING_BARU, BOOKING_DIKONFIRMASI, BOOKING_DIBATALKAN, PERMINTAAN_GABUNG, PERMINTAAN_DITERIMA, dan PESERTA_KELUAR).

---

## F. Forum (masuk skripsi, tetapi Activity Diagram-nya sengaja tidak dibuat)

### 25. Forum [Inti]
1. Pengguna membuka tab Forum dan daftar post tampil (20 terbaru, real-time).
   - Kosong: "Belum ada post. Jadi yang pertama!"
   - Gagal: tampil pesan "Gagal memuat".
2. **Membuat post:**
   1. Pengguna menekan FAB +, mengisi teks, dan boleh menambah satu foto dari galeri.
   2. Pengguna menekan Kirim.
      - Teks dan foto sama-sama kosong: ditolak dengan pesan "Post tidak boleh kosong."
      - Foto lebih dari 500 KB: muncul "Ukuran foto terlalu besar".
      - Berhasil: post tampil di daftar.
3. **Berkomentar:** pengguna menekan kartu post, Detail Post terbuka, lalu ia menulis komentar dan menekan kirim. Jumlah komentar bertambah 1.
4. **Edit post (khusus pemilik):** menu ⋮, pilih Edit Post, ubah isinya, lalu Kirim. Post ditandai "(diedit)".
5. **Hapus post (khusus pemilik):** menu ⋮, pilih Hapus Post, lalu konfirmasi. Semua komentar dihapus lebih dulu, baru postnya.

**Status uji:**
- Emulator (BB-43, 44, 46, 47, 48; 4 dan 9 November).
- **Belum:**
  - BB-42 kondisi forum kosong: butuh forum tanpa satu pun post.
  - Jalur "Ukuran foto terlalu besar" (bagian dari BB-45): tidak bisa dipicu di emulator, karena `image_picker` sudah mengompres foto.
  - BB-49: hanya bisa dipicu di luar UI.
  - Forum di HP fisik.

---

## G. Profil

### 26. Melihat profil [Inti]
- Profil menampilkan header (avatar, nama, surel, telepon) dan statistik Booking, Aktivitas, dan Favorit.
- Bagian lain: [Pemanis] lencana; Riwayat Pemesanan; Aktivitas Saya (yang mendatang); [Pemanis] Riwayat Main (yang sudah lewat).
- Menekan kartu aktivitas membuka Detail Aktivitas.

**Status uji:**
- HP (BB-36).
- Lencana: Emulator (BB-56, BB-57).
- Riwayat Main: Emulator (BB-105, BB-107). BB-106 hanya Otomatis.

### 27. Edit profil [Inti]
1. Pengguna menekan Edit Profil.
2. Pengguna mengubah nama, nomor telepon, dan foto (dari galeri, maksimal 500 KB, disimpan sebagai Base64), lalu menyimpan.

**Status uji:** Emulator (15 September dan 6 November). Belum punya kasus BB.

### 28. Olahraga favorit dan lokasi default [Pemanis]
- **Olahraga favorit:** pilih dari 4 olahraga, lalu simpan.
- **Lokasi default:** beri nama (misalnya "Rumah"), tekan "Ambil Lokasi Saat Ini", lalu simpan. Lokasi ini dipakai skenario 5 saat GPS ditolak.

**Status uji:**
- Pemakaian lokasi default di Home: HP (BB-35).
- Mengubah keduanya, termasuk validasi isian kosong: Emulator (6 November).

### 29. Pengaturan [Pemanis]
- Mode tampilan: Terang, Gelap, atau Ikuti HP. Berlaku seketika.
- Saklar pengingat jadwal. Kalau izin notifikasi Android belum diberikan, tampil petunjuk berwarna oranye.

**Status uji:** Emulator (BB-96…100 dan BB-91…95).

### 30. Halaman statis [Inti]
- Bantuan, Kebijakan Privasi, dan Tentang: halaman yang hanya berisi teks.

**Status uji:** Emulator (dilihat di mode terang dan gelap, 6 November). Tidak punya kasus BB.

---

## H. Khusus Mitra

### 31. Membuka Dashboard Mitra [Inti]
- Di Profil, menu Dashboard Mitra (hanya muncul kalau `role == mitra`) membuka daftar lapangan milik mitra dan daftar booking masuk.

**Status uji:** HP (lewat BB-26, BB-27).

### 32. Menambah lapangan [Inti]
1. Mitra menekan tombol tambah lapangan.
2. Mitra mengisi:
   - nama, alamat, koordinat (diketik atau "ambil dari lokasi saat ini");
   - jenis olahraga, harga, jam buka dan tutup, fasilitas, URL foto;
   - [Pemanis] diskon 0–90% dan produk tambahan (maksimal 5).
3. Mitra menekan Simpan.
   - Validasi gagal: pesan muncul di form.
   - Berhasil: lapangan tersimpan dengan `isMitra = true` dan langsung bisa direservasi pengguna.

**Status uji:**
- HP (BB-29).
- Diskon dan produk tambahan: Emulator.

### 33. Mengedit lapangan [Inti]
- Mitra menekan kartu lapangan, form terbuka berisi data lama, lalu mitra mengubah dan menyimpan.
- Booking lama tidak ikut berubah, misalnya ketika diskon diganti.

**Status uji:** Emulator (BB-109, lulus 21 November). Kasus BB-109 baru ditambahkan 21 November karena use case "pembaruan informasi operasional lapangan" di Bab 3 sebelumnya belum punya kasus uji. Belum diuji di HP.

### 34. Atur slot [Pemanis]
1. Mitra menekan "Atur Slot" pada kartu lapangan, lalu memilih tanggal.
2. Chip jam tampil dalam tiga keadaan:
   - Kosong: ditekan untuk memblokir.
   - Diblokir: ditekan untuk membuka lagi.
   - Dipesan: tidak bisa ditekan.
3. Setiap tekanan menampilkan SnackBar berisi hasilnya.

**Status uji:** Emulator (BB-67…69).

### 35. Membalas ulasan [Pemanis]
1. Di Detail Lapangan miliknya, mitra menekan "Balas" atau "Ubah balasan" pada sebuah ulasan.
2. Mitra mengisi teks (maksimal 500 karakter) lalu menekan Kirim.
3. Blok "Balasan pemilik" tampil untuk semua pengguna.

**Status uji:**
- BB-86…89: diuji 6 November setelah rules di-deploy, dengan Firestore produksi.
- BB-90: hanya lewat 35 skenario di emulator Firestore lokal.

---

## Ringkasan status uji

**Sudah terbukti di HP Android (T-30, 19 Oktober 2026, BB-01…BB-41):**
- registrasi, login, dan keluar;
- pencarian lapangan (Haversine, saringan, peta, favorit, lokasi default);
- detail lapangan dan rating;
- reservasi, konfirmasi dan tolak oleh mitra, pembatalan booking, status SELESAI;
- buat aktivitas, gabung, terima dan tolak, pembatalan aktivitas;
- statistik profil;
- tambah lapangan mitra.

Bisa dikatakan seluruh skenario **[Inti]** sudah terbukti di HP, **kecuali**:
- Forum (skenario 25);
- batalkan keikutsertaan (21);
- edit profil (27);
- edit lapangan (33);
- ketukan notifikasi yang membuka layar tujuan (24).

Kelimanya baru diuji di emulator.

**Uji ulang end-to-end di emulator, 21 November 2026.** Uji ini memakai APK debug dari `main` (commit `935daf8`) dan Firestore produksi, dengan akun `pengguna.uji` dan `mitra.uji`, posisi GPS Alam Sutera. Semua yang dicoba lulus, dan logcat bersih (tanpa `permission-denied`, `FirebaseException`, maupun exception tak tertangani):
- Splash dan langsung masuk Home; login salah ("Surel atau kata sandi salah."), login benar, dan keluar.
- Home berurut jarak. Jarak lapangan terdekat 0,7 km; hitungan manual memberi 0,701 km.
- Pencarian mencakup alamat; chip Badminton.
- Peta: marker, kartu ringkas, "Lihat", atribusi ikut naik. Dari Detail Lapangan, "Lihat di peta" kembali ke tab Map.
- Badge dan tombol reservasi hanya ada di lapangan mitra. Lembar Beri Rating terbuka, tetapi tidak dikirim.
- Reservasi:
  - pengajuan berstatus Menunggu; estimasi memakai harga slot pagi Rp 220.000;
  - mitra mengonfirmasi dari notifikasi;
  - tombol "Cari rekan" muncul setelah booking dikonfirmasi;
  - pembatalan oleh penyewa: status Dibatalkan, slot terbuka lagi, mitra mendapat notifikasi.
- Edit Profil (diubah, lalu dikembalikan).
- BB-109: harga lapangan diubah, tampil di Dashboard, Home, dan Detail; booking lama tetap; harga lalu dikembalikan.
- Aktivitas:
  - "Punya kode?" dengan kode salah;
  - buat aktivitas 2 pemain;
  - gabung, lalu diterima lewat notifikasi; status PENUH dan aktivitas hilang dari daftar;
  - BB-108: batalkan keikutsertaan; jadi 1/2 pemain, tampil lagi di daftar, tombol Gabung muncul lagi, pembuat mendapat PESERTA_KELUAR;
  - BB-39: batalkan aktivitas.
- Forum: post kosong ditolak, buat post, menu ⋮ tidak ada untuk bukan pemilik, komentar (hitungan 0 → 1), edit ("(diedit)"), hapus beserta komentarnya.

**Hanya di emulator:** seluruh fitur pemanis v1.4–v1.5 (T-54…T-70) dan Forum. Uji end-to-end di emulator pada 6 November 2026 tidak menemukan bug. Pengujian ulang di HP fisik masih terbuka (`SPRINT-PLAN.md`, T-28).

**Belum terbukti sama sekali di perangkat:**
- BB-42 (forum kosong).
- Jalur foto lebih dari 500 KB.
- BB-49.
- BB-75, BB-77, BB-82, dan BB-106 (hanya Otomatis).
- BB-90 (hanya emulator rules).
- Aplikasi WhatsApp asli.
- Pengingat jadwal di HP fisik, dalam mode hemat daya, dan setelah HP dinyalakan ulang.

**APK rilis 9 November 2026:** baru *smoke test* (aplikasi terbuka tanpa crash). Login dan alur lain belum dicoba pada build ini. Sebelum dibagikan ke responden SUS, sebaiknya jalankan dulu satu putaran uji di HP fisik dengan APK ini.

## Selisih PRD dan kode

| Letak | PRD | Kode | Saran untuk diagram |
|---|---|---|---|
| AB-03, Home saat GPS ditolak dan tanpa lokasi default | Tombol coba lagi **dan** tautan untuk menetapkan lokasi default | Satu tombol "Buka Pengaturan", setelah itu aplikasi memuat ulang. Tidak ada tautan ke lokasi default | Gambar sesuai kode |
