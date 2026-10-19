# Catatan Ide Fitur v1.3 — Belajar dari AYO

> **Status: CATATAN SAJA (19 Oktober 2026).** Belum masuk `PRD.md`, belum masuk `SPRINT-PLAN.md`, belum dibangun.
> Sesuai `CLAUDE.md`, fitur di luar PRD tidak boleh dibuat sebelum PRD diperbarui. Langkah kalau disetujui: PRD v1.3 → tugas T-54 dst. di SPRINT-PLAN → implementasi.

## Latar belakang

Dosen menilai aplikasi sudah baik dan fungsi utamanya selesai, lalu menyarankan menambah fitur dengan belajar dari aplikasi **AYO** (ayo.co.id, "Super Sport Community App").

Riset dilakukan dari situs publik ayo.co.id, deskripsi aplikasi di GameLoop (v6.6.4), dan artikel media. Aplikasinya sendiri tidak dicoba (butuh login), dan detail produk "AYO Venue Management" untuk mitra tidak ditemukan.

## Fitur AYO yang teramati

| Area | Fitur AYO |
|---|---|
| Booking | Sewa lapangan, DP atau bayar penuh, promo, produk tambahan saat checkout, 32 cabang olahraga |
| Sparring | Cari tim lawan, sistem level tim dan pemain, skor dan statistik tersimpan |
| Main Bareng | Cari event terdekat, buat event publik atau komunitas, biaya per pemain |
| Profil | Riwayat pertandingan, gol dan assist, leaderboard, lencana |
| Lain-lain | Direktori tim, kompetisi dan klasemen, login Google, dua bahasa, blog |

## 8 usulan fitur (urut prioritas)

Semuanya muat di Firestore + Provider, tanpa package baru.

| # | Usulan | Cara | Dampak skema |
|---|---|---|---|
| 1 | **Jenis aktivitas: Main Bareng / Sparring** | Field `jenisAktivitas` + chip filter di tab Teman | `aktivitasBermain` (ERD Bab 3) |
| 2 | **Tingkat kemampuan** (Pemula / Menengah / Mahir) | Field di aktivitas + filter di Cari Rekan, dipilih manual pembuat | `aktivitasBermain` (ERD Bab 3) |
| 3 | **Biaya per orang** di aktivitas | Informasi saja, tanpa pembayaran (bayar di lokasi) | `aktivitasBermain` (ERD Bab 3) |
| 4 | **Sort dan filter lanjutan di Home** | Urut jarak/rating/harga, filter fasilitas, "Buka sekarang" dari `jamBuka`/`jamTutup`, dihitung di klien | Tidak ada. Catatan: filter harga pernah dibatalkan (T-49), jadi sort harga perlu keputusan ulang |
| 5 | **Lencana pencapaian di Profil** | Dihitung dari statistik AB-12 yang sudah ada | Tidak ada |
| 6 | **Mitra: blokir slot manual** | Mitra menutup jam tertentu (booking offline, perawatan), memakai kunci `slotBooking` yang ada. Bukan statistik, jadi tidak melanggar PRD §2.2 | Tidak ada koleksi baru |
| 7 | **Produk tambahan saat booking** | Mitra mendaftarkan item (sewa bola, rompi) beserta harga, total harga ikut bertambah | `booking` + L-10 (lebih besar) |
| 8 | **Tombol WhatsApp di Detail Lapangan** | `url_launcher` + `nomorTelepon` yang sudah ada, sekitar 1 jam | Tidak ada |

**Rekomendasi tahap 1:** nomor 1, 2, 3, 5, dan 8. Kecil, saling melengkapi, dan bisa dijelaskan sebagai "meniru konsep AYO tanpa pembayaran dan tanpa server". Nomor 6 dan 7 menyusul kalau waktu cukup.

## Fitur AYO yang tidak ditiru, dan alasannya

**Terhalang batasan teknis atau biaya**

- **Pembayaran online (DP, Gopay, virtual account):** butuh server untuk membuat transaksi dan menerima callback pembayaran, yaitu Cloud Functions (paket Blaze, dilarang PRD §2.1). Kalau logikanya dipindah ke klien, status "sudah bayar" bisa dipalsukan. Pembayaran tetap di lokasi.
- **Push notification saat aplikasi tertutup:** butuh FCM dan server pengirim. Kita memakai notifikasi in-app lewat Firestore listener.

**Secara teknis bisa, tapi dikunci PRD §2.2**

- **Chat:** butuh banyak layar, moderasi, dan notifikasi pesan baru. Tidak menjawab rumusan masalah.
- **Multi-bahasa:** semua teks dibuat dan diuji dua kali, tanpa nilai untuk penelitian.
- **Lupa password:** Firebase Auth punya `sendPasswordResetEmail`, jadi ini yang paling murah dan layak dipertimbangkan ulang. Kendala: akun uji memakai email palsu (`@sportspace.test`).
- **Upload foto ke Storage:** butuh Blaze, sudah diputuskan di PRD §12b (Opsi A).
- **Rating antar-pengguna:** subsistem baru yang utuh (PRD §12c), ditunda ke Bab 5.

**Terlalu besar**

- **Kompetisi, klasemen, direktori tim:** butuh entitas tim, aktor penyelenggara, validasi skor, dan algoritma klasemen. Hampir satu aplikasi tersendiri.

## Hal yang perlu dibicarakan dengan dosen

Usulan 1–3 mengubah skema `aktivitasBermain` yang tercantum di ERD Bab 3, jadi skripsi harus ikut direvisi. Dosen perlu tahu sebelum fitur dibangun.
