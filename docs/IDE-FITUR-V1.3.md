# Catatan Ide Fitur v1.3 — Belajar dari AYO

> **Status: CATATAN SAJA (19 Oktober 2026).** Belum masuk `PRD.md`, belum masuk `SPRINT-PLAN.md`, belum dibangun.
> Sesuai `CLAUDE.md`, fitur di luar PRD tidak boleh dibuat sebelum PRD diperbarui. Langkah kalau disetujui: PRD v1.3 → tugas T-54 dst. di SPRINT-PLAN → implementasi.

**Ringkasan: 14 usulan** — 12 terinspirasi AYO (nomor 1–12) dan 2 ide tambahan di luar AYO (nomor 13–14).

## Latar belakang

Dosen menilai aplikasi sudah baik dan fungsi utamanya selesai, lalu menyarankan menambah fitur dengan belajar dari aplikasi **AYO** (ayo.co.id, "Super Sport Community App").

## Batas riset (jujur soal apa yang sudah dan belum dilihat)

Riset dilakukan lewat halaman publik, **bukan** dengan memakai aplikasinya.

- **Sudah terbaca:** beranda ayo.co.id, halaman daftar venue (ayo.co.id/venues), deskripsi dan catatan versi di App Store (v6.9.4), deskripsi di GameLoop, satu blog pengalaman pakai, dan beberapa artikel media.
- **Belum terjangkau:** layar di dalam aplikasi (login, checkout, profil, notifikasi), halaman detail venue, Play Store, dan AYO Venue Management (sisi mitra).
- Karena itu daftar di bawah masih berbasis deskripsi, belum diverifikasi lewat tangkapan layar. Kalau nanti ada tangkapan layar dari aplikasi AYO, usulan ini bisa diperbarui.

## Fitur AYO yang teramati

| Area | Fitur AYO |
|---|---|
| Booking | Sewa lapangan, ketersediaan slot real-time, konfirmasi instan, DP atau bayar penuh, promo dan voucher brand, produk tambahan saat checkout, reschedule dan batalkan lewat "Atur Booking" (hanya di aplikasi), 32 cabang olahraga |
| Daftar venue | Urutan Populer (bawaan) / Harga Terendah / Harga Tertinggi, toggle "venue tersedia", filter rentang harga, urut jarak bila lokasi aktif, kartu berisi foto + nama + rating + kota + harga mulai |
| Sparring | Cari tim lawan, sistem level tim dan pemain, skor dan statistik tersimpan |
| Main Bareng | Cari aktivitas terdekat, filter olahraga/lokasi/waktu/level, buat aktivitas publik atau privat, undangan, pembagian biaya antar pemain, sesi coaching |
| Profil | Riwayat pertandingan, gol dan assist, leaderboard, lencana, hasil bisa dibagikan ke WhatsApp dan Instagram |
| Turnamen | Format Americano dan Mexicano, rotasi pemain otomatis, papan skor, matchmaker tim seimbang |
| Lain-lain | Direktori tim, kompetisi dan klasemen, login Google, dua bahasa, blog |

**Keluhan pengguna AYO** (dari ulasan App Store dan blog): biaya layanan tambahan saat checkout, loading lambat (dilaporkan sampai 7 menit di jam sibuk), halaman komunitas macet, reschedule diproses terlambat, pemulihan akun gagal, dan menu booking sulit ditemukan.

## 14 usulan fitur

Semuanya muat di Firestore + Provider. Hanya #14 yang butuh package baru (perlu izin dulu).

| # | Usulan | Cara | Dampak skema | Skala |
|---|---|---|---|---|
| 1 | **Jenis aktivitas: Main Bareng / Sparring** | Field `jenisAktivitas` + chip filter di tab Teman | `aktivitasBermain` (ERD Bab 3) | Kecil |
| 2 | **Tingkat kemampuan** (Pemula / Menengah / Mahir) | Field di aktivitas + filter di Cari Rekan, dipilih manual pembuat | `aktivitasBermain` (ERD Bab 3) | Kecil |
| 3 | **Biaya per orang** di aktivitas | Informasi saja, tanpa pembayaran (bayar di lokasi) | `aktivitasBermain` (ERD Bab 3) | Kecil |
| 4 | **Sort dan filter lanjutan di Home** | Urut jarak / rating / harga / **Populer** (dari `jumlahRating`, datanya sudah ada), filter fasilitas, "Buka sekarang" dari `jamBuka`/`jamTutup`, semua dihitung di klien. Filter harga pernah dibatalkan (T-49), jadi sort harga perlu keputusan ulang | Tidak ada | Kecil |
| 5 | **Lencana pencapaian di Profil** | Dihitung dari statistik AB-12 yang sudah ada | Tidak ada | Kecil |
| 6 | **Mitra: blokir slot manual** | Mitra menutup jam tertentu (booking offline, perawatan) memakai kunci `slotBooking` yang ada. Bukan statistik, jadi tidak melanggar PRD §2.2 | Tidak ada koleksi baru | Sedang |
| 7 | **Produk tambahan saat booking** | Mitra mendaftarkan item (sewa bola, rompi) beserta harga, total harga ikut bertambah | `booking` + L-10 | Sedang–besar |
| 8 | **Tombol WhatsApp di Detail Lapangan** | `url_launcher` + `nomorTelepon` yang sudah ada, sekitar 1 jam | Tidak ada | Kecil |
| 9 | **Ubah jadwal booking (reschedule)** | Satu transaction menghapus kunci `slotBooking` lama dan membuat yang baru. Kunci ID-nya deterministik jadi tetap aman di klien. Pembatalan sudah ada (T-46) | Tidak ada koleksi baru | Sedang |
| 10 | **Bagikan aktivitas atau lapangan ke WhatsApp** | `url_launcher` dengan tautan `wa.me/?text=...`, tanpa package baru | Tidak ada | Kecil |
| 11 | **Aktivitas publik atau privat** | Field `visibilitas`. Aktivitas privat tidak tampil di daftar dan hanya bisa dibuka lewat kode | `aktivitasBermain` (ERD Bab 3) | Sedang |
| 12 | **Promo atau diskon dari mitra** | Mitra mengisi persen diskon. Badge muncul di kartu dan Detail, estimasi harga di L-10 ikut berubah. Tanpa pembayaran | `lapangan` | Kecil–sedang |
| 13 | **Mitra membalas ulasan** *(ide di luar AYO)* | Field balasan pada dokumen `rating` | `rating` | Kecil |
| 14 | **Pengingat jadwal booking** *(ide di luar AYO)* | Notifikasi lokal sebelum jam main. **Butuh package notifikasi lokal baru, minta izin dulu** (CLAUDE.md) | Tidak ada | Sedang |

**Rekomendasi tahap 1:** nomor 1, 2, 3, 5, 10, lalu 8. Kecil, saling melengkapi, dan bisa dijelaskan sebagai "meniru konsep AYO tanpa pembayaran dan tanpa server". Nomor 4, 6, 9, dan 12 menyusul. Nomor 7, 11, 13, dan 14 paling akhir.

**Sengaja tidak dipakai:** fitur "venue tersedia hari ini" milik AYO. Itu menuntut membaca `slotBooking` untuk tiap lapangan sehingga boros pembacaan Firestore.

## Urutan pengerjaan terkait cabang forum

Cabang `secondary` (forum, Martin) belum di-merge. Sampai 19 Oktober isinya baru model, repository, dan ViewModel forum, serta satu perubahan di `detail_lapangan_screen.dart`.

| Aman dikerjakan lebih dulu | Tunggu forum selesai atau di-merge |
|---|---|
| #1, #2, #3, #11 (aktivitas), #4 (Home), #5 (Profil), #10 (bagikan di Detail Aktivitas) | #8 (tombol WhatsApp, menyentuh `detail_lapangan_screen.dart` yang sedang konflik), #6, #7, #9, #12 (menyentuh `booking`/`lapangan`, rules, dan model) |

Aturan: satu cabang per fitur, mulai dari `main` terbaru, tarik `main` ke cabang secara berkala, dan perubahan di `models/` hanya oleh integrator.

**Catatan untuk cabang `secondary`:** file `detail_lapangan_screen.dart` di cabang itu menghapus tombol "Buka di Google Maps" (T-51) dan import `url_launcher`, kemungkinan karena versi filenya lebih lama. Saat `main` digabung ke cabang itu, pakai versi `main` untuk file tersebut kecuali perubahannya memang disengaja.

## Fitur AYO yang tidak ditiru, dan alasannya

**Terhalang batasan teknis atau biaya**

- **Pembayaran online (DP, Gopay, virtual account):** butuh server untuk membuat transaksi dan menerima callback pembayaran, yaitu Cloud Functions (paket Blaze, dilarang PRD §2.1). Kalau logikanya dipindah ke klien, status "sudah bayar" bisa dipalsukan. Pembayaran tetap di lokasi.
- **Push notification saat aplikasi tertutup:** butuh FCM dan server pengirim. Kita memakai notifikasi in-app lewat Firestore listener.

**Secara teknis bisa, tapi dikunci PRD §2.2**

- **Chat:** butuh banyak layar, moderasi, dan notifikasi pesan baru. Tidak menjawab rumusan masalah.
- **Multi-bahasa:** semua teks dibuat dan diuji dua kali, tanpa nilai untuk penelitian.
- **Lupa password:** Firebase Auth punya `sendPasswordResetEmail`, jadi ini yang paling murah dan layak dipertimbangkan ulang (pemulihan akun juga salah satu keluhan pengguna AYO). Kendala: akun uji memakai email palsu (`@sportspace.test`).
- **Upload foto ke Storage:** butuh Blaze, sudah diputuskan di PRD §12b (Opsi A).
- **Rating antar-pengguna:** subsistem baru yang utuh (PRD §12c), ditunda ke Bab 5.

**Terlalu besar**

- **Kompetisi, klasemen, turnamen Americano/Mexicano, direktori tim:** butuh entitas tim, aktor penyelenggara, validasi skor, dan algoritma klasemen. Hampir satu aplikasi tersendiri.

## Bahan argumen untuk skripsi (Bab 5)

Keluhan pengguna AYO bisa dipakai sebagai pembanding: aplikasi kita tidak punya biaya layanan karena bayar di lokasi, UI lebih sederhana, dan tidak bergantung pada server yang bisa macet saat ramai.

## Hal yang perlu dibicarakan dengan dosen

- Usulan 1, 2, 3, 11, 12, dan 13 mengubah skema yang tercantum di ERD Bab 3, jadi skripsi harus ikut direvisi. Dosen perlu tahu sebelum fitur dibangun.
- Fitur forum (cabang `secondary`) belum ada di PRD maupun skripsi, memakai gambar Base64 per postingan (PRD membatasi pola ini untuk foto profil), dan mirip chat (PRD §2.2). Perlu diputuskan apakah dijadikan fitur resmi atau dikecilkan.
