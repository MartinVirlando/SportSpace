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

**Status per 5 November 2026:** enam usulan tahap 1 (nomor 1, 2, 3, 5, 8, 10 = T-54, T-55, T-56, T-58, T-61, T-63) sudah dikodekan dan masuk `main` (PRD v1.4); delapan lainnya belum. *(Per 4 November 2026 belum ada satu pun.)* Nomor tugasnya T-54…T-67 (T-53 + nomor usulan) dan dicatat di `SPRINT-PLAN.md`, bagian "Backlog v1.3". Cabang forum sudah di-merge ke `main` (4 November 2026), jadi pembagian "tunggu forum" di bawah tidak berlaku lagi.

**Status per 6 November 2026: seluruh 14 usulan di atas sudah dikodekan dan masuk `main`** (T-54…T-67), ditambah T-68 (mode gelap) yang diminta pemilik produk. Ringkasan per tahap ada di `SPRINT-PLAN.md`, bagian "Backlog v1.3", dan spesifikasinya di `PRD.md` (AB-14 sampai AB-26).

## Usulan tahap 4 (6 November 2026) — hasil riset ulang AYO

Riset ulang halaman [App Store AYO](https://apps.apple.com/id/app/ayo/id1539581877) (catatan versi 6.6 sampai 6.10) dan [AVM, aplikasi pengelola venue](https://apps.apple.com/id/app/id1607354989). Masih berbasis halaman publik, bukan memakai aplikasinya. Hanya fitur yang belum ada di Sport Space yang didaftar.

| # | Usulan | Asal di AYO | Ukuran | Skema | Keputusan |
|---|---|---|---|---|---|
| 1 | Buat aktivitas dari booking | 6.10.0 "create a match, book a court, and invite opponents in one flow" | Kecil | Tidak ada | **Dikerjakan: T-69** |
| 2 | Daftar tunggu aktivitas | 6.8.0 "Match Waiting List" | Sedang | +1 field `aktivitasBermain` | Pengembangan lanjutan (Bab 5) |
| 3 | Level pemain (diisi sendiri) | 6.10.0 "Padel Levels" | Kecil–sedang | +1 field `users` | Pengembangan lanjutan (Bab 5) |
| 4 | Bagi tim otomatis | "Game Matchmaker" | Kecil | Tidak ada (lebih bermakna dengan nomor 3) | Pengembangan lanjutan (Bab 5) |
| 5 | Riwayat main (aktivitas selesai) | 6.10.0 "New profile / My Activity" | Kecil | Tidak ada | **Dikerjakan: T-70** |
| 6 | Co-host | 6.8.0 | Sedang | +1 field `aktivitasBermain` | Pengembangan lanjutan (Bab 5) |
| 7 | Autocomplete dan filter area | 6.8.0, 6.9.2 | Kecil | Tidak ada | Belum dipilih |
| 8 | Booking mingguan berulang | AVM: jadwal berulang | Sedang | Tidak ada | Belum dipilih |
| 9 | Bagikan pencapaian ke WhatsApp | "Share Results" | Kecil | Tidak ada | Belum dipilih |
| 10 | Lupa password | Keluhan pengguna AYO soal pemulihan akun | Kecil | Tidak ada | Belum dipilih; masih di daftar yang ditolak `CLAUDE.md` |

**Alasan keputusan:** ERD Bab 3 sudah berubah di empat entitas (`lapangan`, `booking`, `aktivitasBermain`, `rating`) dan T-39 (gambar ERD) menunggu atribut final, jadi hanya usulan **tanpa skema baru** yang dipilih (nomor 1 dan 5). Nomor 2, 3, 4, dan 6 baik dijadikan bahan bahasan "saran pengembangan lanjutan" di Bab 5.

**Perlu keputusan eksplisit bila ingin dikerjakan** (menyentuh larangan): "kudos" antar pemain (dekat dengan larangan rating antar-pengguna, PRD §12c); tanda DP/lunas manual oleh mitra (harus tetap informasi saja, tanpa pembayaran); daftar pelanggan untuk mitra (dekat dengan larangan statistik dashboard mitra).

**Tidak disarankan** (terlalu besar atau terhalang aturan): booking pelatih, turnamen Americano/Mexicano, direktori tim atau komunitas, liga, chat, multi-bahasa.
