# PRD — Sport Space

**Aplikasi Android pencarian lapangan olahraga dan rekan bermain berbasis lokasi**

Versi 1.5 · 5 November 2026 · Diturunkan dari Pre-Thesis Bab 1–3 (revisi)

> Dokumen ini adalah **sumber kebenaran tunggal** untuk implementasi. Jika ada pertentangan antara dokumen ini dan ingatan/asumsi, dokumen ini yang menang. Jika ada kebutuhan yang tidak tercantum di sini, **jangan dibangun** — tanyakan dulu.

### Perubahan di v1.1 (17 Agustus 2026)

Diselaraskan dengan prototipe Figma "App Skripsi - Sport Field Finder". Ringkasnya:

| # | Perubahan | Bagian yang terdampak |
|---|---|---|
| 1 | Navigasi bawah jadi **4 tab** (Home · Map · Teman · Profil) | §8, dan **Bab 3.3.2 poin 5 skripsi wajib direvisi** |
| 2 | Home tetap **daftar vertikal**; peta pindah ke tab Map, bukan tertanam di Home | §8 L-04, L-05 |
| 3 | Fitur **favorit lapangan** masuk ruang lingkup | §5, §6.9, §7 AB-10, §8, §9, §11 |
| 4 | Badge **Verified** dipetakan ke `sumberData`, tanpa field baru | §7 AB-11, §8 L-06 |
| 5 | **Olahraga favorit** dan **lokasi default** masuk ke koleksi `users` | §6.1, §7 AB-03, §8 L-13 |
| 6 | **Statistik profil** (booking, aktivitas) pakai agregasi `count()` | §7 AB-12, §8 L-13 |
| 7 | Rating antar-pengguna **ditunda** — lihat §12c | §12c |

> ⚠️ **Perubahan #1 punya konsekuensi di luar kode.** Bab 3.3.2 poin 5 menuliskan navigasi 3 tab. Itu harus direvisi bersama Pak Gintoro sebelum Bab 4 ditulis, supaya tangkapan layar di Bab 4 tidak bertentangan dengan rancangan di Bab 3.

### Perubahan v1.2 (15 September 2026)

Lima penambahan setelah pemakaian internal tim. Empat di antaranya perluasan dari fitur yang sudah ada (atribut/UI/logika baru pada entitas yang sudah ada di ERD); satu murni UI tambahan. **Tidak ada yang menyentuh rumusan masalah Bab 1** — beda dengan usulan "list teman" (sistem pertemanan) yang sempat dipertimbangkan lalu **dibatalkan** karena tidak menjawab satu pun dari 3 rumusan masalah dan butuh entitas ERD baru sama sekali (lihat riwayat diskusi tim).

| # | Perubahan | Bagian yang terdampak |
|---|---|---|
| 1 | **Favorit dipindah dari L-13 Profil ke L-04 Home**, jadi tombol toggle ♥ di search bar (bukan daftar terpisah). Aktif → tampilkan hanya lapangan favorit; tidak aktif → daftar normal. Kotak angka "Favorit" di L-13 tetap ada. **Tidak mengubah AB-02** (menyaring, bukan mengurutkan ulang). | §6.9, §7 AB-10, §8 L-04, L-13 |
| 2 | **Search bar ditambahkan di L-05 Map** — tidak ada di PRD/Figma awal. Menyaring marker berdasarkan nama/alamat di sisi klien, pola sama dengan L-04. Selagi field fokus dan ada kata kunci, muncul daftar saran (ala Google Maps) di bawahnya — menekan satu saran auto-pan peta ke lokasinya (pola sama dengan "Lihat di peta" L-06) sekaligus memunculkan kartu ringkas menuju Detail Lapangan. | §8 L-05 |
| 3 | **Foto profil bisa diisi langsung dari galeri (opsional)** — pakai `image_picker`, disimpan sebagai Base64 di dokumen Firestore (bukan URL, bukan Firebase Storage — pendekatan ketiga di luar Opsi A/B §12b, lihat penjelasan lengkap di §12b). `null`/kosong tetap jatuh balik ke avatar inisial. | §4, §6.1, §8 L-13, §12b |
| 4 | **Atribut baru `nomorTelepon` pada entitas `lapangan`** — kontak lapangan, opsional, ditampilkan di L-06 kalau terisi, diedit lewat form mitra L-15. Data untuk 30 lapangan seed diisi manual belakangan (bukan bagian dari perubahan ini). | §6.2, §8 L-06, L-15 |
| 5 | **Peserta aktivitas bisa membatalkan keikutsertaan** (AB-06 lanjutan) — sebelumnya sekali bergabung tidak ada jalan keluar sama sekali. Slot dan status ikut disesuaikan (transaction), permintaan lama dihapus supaya bisa gabung ulang, pembuat dapat notifikasi. Pembuat aktivitas TIDAK bisa membatalkan keikutsertaannya sendiri lewat jalur ini. | §6.3, §6.4, §7 AB-06, §8 L-09 |

### Perubahan v1.3 (4 November 2026) — Forum

Fitur **Forum** dibangun Martin di cabang `secondary` (1 Oktober–3 November 2026) dan digabung ke `main` lewat PR #1 pada 4 November 2026. Bagian PRD ini **menyusul** — ditulis setelah kodenya ada, mengikuti perilaku aplikasi apa adanya — supaya dokumen dan kode kembali sama.

| # | Perubahan | Bagian yang terdampak |
|---|---|---|
| 1 | Tab kelima **Forum**: post publik beserta komentar. Navigasi bawah jadi **5 tab** (Home · Map · Teman · Profil · Forum) | §2.2, §5, §6.10–6.11, §7 AB-13, §8 L-16–L-18, §9, §11 BB-42–BB-49, §14 |
| 2 | **Gambar post forum** (maksimal 1 per post) disimpan sebagai Base64 di dokumen `forum_posts` — pola yang sama dengan foto profil, dengan batas 500 KB mentah dan pengaman 700.000 karakter di Repository dan Security Rules | §2.1, §2.2, §12b |

> ⚠️ **Keputusan belum final, tetapi arahnya sudah ada (5 November 2026):** Pak Gintoro menyebut forum fitur pemanis, jadi jalur **(b)** di bawah yang paling mungkin. Forum tidak menjawab satu pun dari tiga rumusan masalah Bab 1 (pencarian lapangan berbasis lokasi, cari rekan bermain, reservasi) — posisinya sama dengan favorit pada putaran revisi 2. Tim dan Pak Gintoro masih harus memutuskan: **(a)** forum dimasukkan ke Bab 3–4 (tab jadi 5, ERD tambah dua entitas, kasus BB-42–BB-49), atau **(b)** forum tidak dimasukkan ke bab itu dan disebut sebagai pengembangan lanjutan di Bab 5. Kodenya sudah ada di aplikasi, jadi tangkapan layar Bab 4 akan menampilkan 5 tab kecuali tab Forum disembunyikan — lihat §14. Sampai diputuskan, PRD ini menganggap forum **bagian dari aplikasi**.

### Perubahan v1.4 (5 November 2026) — Fitur tambahan terinspirasi aplikasi AYO, tahap 1

Pak Gintoro menilai fitur tambahan seperti Forum dan fitur yang terinspirasi aplikasi **AYO** (`docs/IDE-FITUR-V1.3.md`) hanyalah **pemanis**; hanya **modul besar** yang perlu masuk Bab 3. Berdasarkan itu tim memutuskan (5 November 2026) membangun **enam fitur kecil tahap 1** tanpa meminta persetujuan per fitur, dan **tidak** menambahkannya ke Bab 3 sebagai use case atau diagram baru. Semuanya perluasan dari fitur yang sudah ada, tanpa koleksi baru, tanpa package baru, dan tanpa pembayaran.

| # | Tugas | Perubahan | Bagian yang terdampak |
|---|---|---|---|
| 1 | **T-54** | Atribut baru `jenisAktivitas` pada `aktivitasBermain`: **Main Bareng** atau **Sparring**. Dipilih pembuat di L-08, jadi label di kartu L-07 dan L-09, dan chip filter di L-07 | §6.3, §8 L-07–L-09, §11 BB-50–51 |
| 2 | **T-55** | Atribut baru `tingkatKemampuan`: **Pemula / Menengah / Mahir**, dipilih manual oleh pembuat. Chip filter kedua di L-07 | §6.3, §8 L-07–L-09, §11 BB-52–53 |
| 3 | **T-56** | Atribut baru `biayaPerOrang` (rupiah, `0` = gratis). **Informasi saja**, dibayar di lokasi, tanpa payment gateway | §6.3, §8 L-08–L-09, §11 BB-54–55 |
| 4 | **T-58** | **Lencana pencapaian** di L-13, dihitung dari tiga angka statistik AB-12 yang sudah ada. Tanpa field baru | §7 AB-14, §8 L-13, §11 BB-56–57 |
| 5 | **T-63** | Tombol **Bagikan ke WhatsApp** di L-09 (aktivitas) dan L-06 (lapangan), lewat tautan `wa.me` dan `url_launcher` yang sudah ada | §7 AB-15, §8 L-06, L-09, §11 BB-58–59 |
| 6 | **T-61** | Tombol **WhatsApp** di L-06 di samping nomor telepon, hanya untuk nomor seluler | §7 AB-15, §8 L-06, §11 BB-60–61 |

**Tidak ada composite index baru.** Filter jenis aktivitas dan tingkat kemampuan dijalankan **di klien** pada daftar yang sudah diambil `streamAktivitasTerbuka` (query-nya tidak berubah, tetap index #2 dan #3). Security Rules tidak berubah.

**Dokumen lama tetap terbaca.** Aktivitas yang dibuat sebelum v1.4 tidak punya ketiga atribut baru. `fromFirestore()` memberi nilai bawaan: `jenisAktivitas = "main_bareng"`, `tingkatKemampuan = null`, `biayaPerOrang = 0`. Tidak perlu migrasi data.

**Yang belum dikerjakan dari 14 usulan** (tahap 2 dan 3, tetap di backlog `SPRINT-PLAN.md`): T-57, T-59, T-60, T-62, T-64, T-65, T-66, T-67. T-67 butuh package baru, jadi izin harus diminta dulu (`CLAUDE.md`).

> ⚠️ **Konsekuensi ke skripsi kecil, tapi ada.** T-54 sampai T-56 menambah tiga atribut ke entitas `AktivitasBermain` yang sudah ada di ERD Bab 3. Gambar ERD (M1 di "Putaran revisi 2") sebaiknya dibuat **setelah** atribut ini final, atau ketiganya disebut sebagai "tambahan di luar rancangan awal". Lihat §14 "Tambahan akibat v1.4".

### Perubahan v1.5 (5 November 2026) — Fitur tambahan terinspirasi AYO, tahap 2 dan 3

Tim memutuskan (5 November 2026) melanjutkan sisa usulan terinspirasi AYO yang memang berasal dari AYO: T-57, T-59, T-60, T-62, T-64, dan T-65. **T-66 (mitra membalas ulasan) dan T-67 (pengingat jadwal) tidak ikut dikerjakan**: keduanya ide di luar AYO, dan T-67 butuh package baru yang belum diizinkan. (T-66 kemudian disetujui pemilik produk pada hari yang sama — lihat "Tambahan v1.5 … T-66" di bawah.) Seperti v1.4, ini fitur pemanis menurut Pak Gintoro, tanpa koleksi baru, tanpa pembayaran, **dan tanpa perubahan Security Rules** (rules yang ada sudah mengizinkan semua tulisan di bawah).

| # | Tugas | Perubahan | Bagian yang terdampak |
|---|---|---|---|
| 1 | **T-57** | **Urutkan dan saring lanjutan di Home** (L-04): urut Terdekat (bawaan, tetap AB-02) / Rating tertinggi / Terpopuler, saklar "Buka sekarang", dan filter fasilitas. Semua di klien | §7 AB-16, §8 L-04, §11 BB-62–66 |
| 2 | **T-59** | **Mitra memblokir slot manual** lewat layar baru L-19 "Atur Slot", memakai kunci `slotBooking` yang sudah ada | §6.7, §7 AB-17, §8 L-14, L-19, §11 BB-67–69 |
| 3 | **T-65** | **Promo dari mitra**: atribut `diskonPersen` pada `lapangan`. Badge di kartu dan Detail, estimasi dan `totalHarga` ikut turun. Tanpa pembayaran | §6.2, §7 AB-18, §8 L-04, L-06, L-10, L-15, §11 BB-70–72 |
| 4 | **T-60** | **Produk tambahan saat booking** (sewa bola, rompi): mitra mendaftarkan item di `lapangan.produkTambahan`, pengguna memilih jumlahnya di L-10, disalin ke `booking.produkTambahan` | §6.2, §6.6, §7 AB-19, §8 L-10, L-13, L-14, L-15, §11 BB-73–75 |
| 5 | **T-62** | **Ubah jadwal booking** (reschedule) dari L-13, satu transaction | §6.8, §7 AB-20, §8 L-10, L-13, §11 BB-76–78 |
| 6 | **T-64** | **Aktivitas publik atau privat**: atribut `visibilitas` dan `kodeAkses`. Aktivitas privat tidak tampil di daftar dan dibuka lewat kode | §6.3, §7 AB-21, §8 L-07–L-09, §11 BB-79–82 |

Urutan pengerjaan yang dipakai (menurut ketergantungan, bukan nomor): T-57, T-59, T-65, T-60, T-62, T-64. T-62 dikerjakan setelah T-65 dan T-60 karena menghitung ulang total harga memakai keduanya.

**Dokumen lama tetap terbaca.** `lapangan` tanpa `diskonPersen` dibaca `0` dan tanpa `produkTambahan` dibaca daftar kosong. `booking` tanpa `produkTambahan` dibaca daftar kosong. `aktivitasBermain` tanpa `visibilitas` dibaca `"publik"`. Tidak perlu migrasi data.

**Keputusan yang diambil** (tidak ada di rumusan masalah, dicatat supaya bisa dijelaskan):
- **Urut harga tidak diadakan.** T-49 (filter harga) dibatalkan 15 September 2026, dan harga lapangan non-mitra hanya estimasi (Bab 3), jadi mengurutkan berdasarkan harga menyesatkan.
- **AB-02 tidak berubah.** Urutan bawaan Home tetap murni jarak. Urut rating atau populer hanya terjadi bila pengguna memilihnya, dan kembali ke jarak lewat "Reset".
- **Aktivitas privat disaring di klien**, bukan di query: Firestore mengecualikan dokumen yang tidak punya field dari query `where`, jadi aktivitas lama akan hilang dari daftar. Konsekuensinya privat bukan rahasia sungguhan: pengguna login yang menebak `aktivitasId` atau membaca koleksi tetap bisa melihatnya. Dicatat sebagai keterbatasan di Bab 5.
- **Diskon hanya untuk sewa lapangan**, bukan produk tambahan.

> ⚠️ **Konsekuensi ke skripsi.** Tiga entitas ERD bertambah atribut lagi (`lapangan`, `booking`, `aktivitasBermain`). Gambar ERD (M1) sebaiknya dibuat **setelah** ini final — lihat §14 "Tambahan akibat v1.5".

### Tambahan v1.5 (5 November 2026, sore) — T-66 Mitra membalas ulasan

Pemilik produk menyetujui T-66 (5 November 2026). Berbeda dari tugas v1.5 di atas, **T-66 mengubah Security Rules** — jadi `firebase deploy --only firestore:rules` harus dijalankan sebelum fitur ini bisa dicoba di perangkat. Rinciannya di §7 AB-22, §6.5, dan §9.

| # | Tugas | Perubahan | Bagian yang terdampak |
|---|---|---|---|
| 7 | **T-66** | **Mitra pemilik lapangan membalas ulasan** pengguna. Dua atribut baru di `rating` (`balasanMitra`, `balasanPada`); balasan tampil di bawah ulasan di L-06. Tanpa notifikasi ke pengguna | §6.5, §7 AB-22, §8 L-06, §9, §11 BB-86–90 |

**Dokumen lama tetap terbaca.** `rating` tanpa `balasanMitra` berarti belum dibalas. Tidak perlu migrasi data. Security Rules baru juga **tidak merusak** aplikasi versi lama: menulis ulang rating yang belum punya balasan tetap diizinkan.

**Keputusan yang diambil** (dicatat supaya bisa dijelaskan):
- **Satu balasan per ulasan, boleh diganti, tidak bisa dihapus** — sejalan dengan aturan `rating` yang tidak pernah bisa dihapus (`delete: false`).
- **Pengguna mengubah ratingnya → balasan dipertahankan.** Balasan hanya bisa diubah mitra; pengguna tidak boleh menyentuhnya (Security Rules), jadi `beriRating` memakai `update` pada field yang berubah, bukan `set` seluruh dokumen yang akan menghapus balasan.
- **Tidak ada notifikasi** ke pengguna saat ulasannya dibalas. Balasan hanya terlihat di L-06. Bisa ditambahkan nanti lewat koleksi `notifikasi` yang sudah ada.

> ⚠️ **Konsekuensi ke skripsi.** Entitas `rating` di ERD Bab 3 bertambah dua atribut — lihat §14 #54.

### Tambahan v1.5 (5 November 2026, sore) — T-67 Pengingat jadwal booking

Pemilik produk menyetujui T-67 dan memberi izin package baru yang gratis (5 November 2026). Berbeda dari semua tugas v1.5 lain, **T-67 menambah tiga package dan mengubah konfigurasi Android** — lihat §4 dan AB-23.

| # | Tugas | Perubahan | Bagian yang terdampak |
|---|---|---|---|
| 8 | **T-67** | **Pengingat jadwal**: HP pengguna menampilkan notifikasi sekitar 1 jam sebelum jam mulai booking yang sudah `DIKONFIRMASI`. Dijadwalkan di HP lewat `flutter_local_notifications`, ada saklar di Profil. Tanpa koleksi baru, tanpa perubahan Security Rules | §4, §5, §7 AB-23, §8 L-13, §11 BB-91–95 |

**Keputusan yang diambil** (dicatat supaya bisa dijelaskan):
- **Bukan push notification.** Notifikasi dijadwalkan dan dibunyikan oleh HP sendiri (AlarmManager), tanpa Firebase Cloud Messaging dan tanpa Cloud Functions (dilarang `CLAUDE.md`). Gratis, dan tidak butuh jaringan saat pengingat muncul.
- **Alarm tidak-tepat-waktu (`inexactAllowWhileIdle`).** Izin alarm tepat-waktu (`SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM`) butuh persetujuan khusus dan sengaja tidak dipakai. Konsekuensinya notifikasi bisa terlambat beberapa menit (uji emulator: terlambat 2 menit 47 detik) dan, menurut Android, paling lama sampai sekitar satu jam di kondisi hemat daya. Karena itu teks berbunyi "mulai **sekitar** 1 jam lagi".
- **Bawaan menyala**, bisa dimatikan di Profil. Dialog izin notifikasi Android 13+ diminta **sekali per sesi** saat ada pengingat yang perlu dijadwalkan, dan selalu diminta ketika pengguna menyalakan saklar secara sengaja.
- **Waktu setempat.** Jam mulai booking dibaca sebagai waktu HP; zona waktu tidak dikonversi (aplikasi hanya untuk Indonesia).

### Tambahan v1.5 (5 November 2026, sore) — T-68 Mode gelap

Pemilik produk meminta mode gelap dengan pengaturannya di Profil (5 November 2026). **Mode gelap sebelumnya ada di daftar "di luar ruang lingkup" (§2.2 dan `CLAUDE.md`); daftar itu diperbarui.** Tidak ada package baru (memakai `shared_preferences` dari T-67), tidak ada koleksi baru, tidak ada perubahan Security Rules.

| # | Tugas | Perubahan | Bagian yang terdampak |
|---|---|---|---|
| 9 | **T-68** | **Mode tampilan Terang / Gelap / Ikuti HP**: pemilih di bagian Pengaturan pada Profil, pilihan tersimpan di HP, berlaku seketika di seluruh aplikasi. Bawaan Terang | §2.2, §5, §7 AB-24, §8 L-13, §11 BB-96–100 |

**Keputusan yang diambil** (dicatat supaya bisa dijelaskan):
- **Bawaan Terang**, bukan "Ikuti HP": tampilan tetap sama dengan Figma dan tangkapan layar di skripsi, dan pengguna yang HP-nya bermode gelap tidak tiba-tiba melihat tampilan berbeda.
- **Mode terang tidak diubah sama sekali.** Nilai warna terang disalin persis dari konstanta lama ke `AppPalette.terang` dan dijaga oleh tes.
- **Cara kerja (Flutter):** warna yang berbeda per mode dipindah ke `ThemeExtension` (`AppPalette`) dan dibaca lewat `context.warna`. Konstanta lama di `AppColors` (latar, permukaan, teks) **dihapus**, bukan dibiarkan, supaya setiap pemakaian yang terlewat menjadi galat kompilasi — bukan warna terang yang diam-diam muncul di mode gelap.

> ⚠️ **Keterbatasan yang diakui (Bab 5).** (1) **Peta tetap terang**: ubin OpenStreetMap yang dipakai `flutter_map` tidak punya versi gelap; kolom pencarian dan tombol di atasnya mengikuti mode. (2) **Layar sambut bawaan Android (putih) tetap muncul sesaat** saat aplikasi dimulai, sebelum Flutter berjalan: layar native itu tidak bisa membaca pilihan mode di dalam aplikasi.

> ⚠️ **Keterbatasan yang diakui (Bab 5).** Pengingat baru dijadwalkan ketika aplikasi **terbuka** dan melihat booking sudah dikonfirmasi. Kalau mitra mengonfirmasi saat aplikasi pengguna tertutup, pengingat baru terjadwal saat aplikasi dibuka berikutnya — jika itu sudah lewat waktu pengingatnya, tidak ada pengingat. Mengatasinya butuh push dari server (FCM), yang dilarang.

### Tambahan v1.5 (6 November 2026) — T-69 Cari rekan dari booking

Pemilik produk memilih dua usulan AYO tahap 4 yang **tanpa skema baru** (6 November 2026): nomor 1 (T-69) dan nomor 5 (T-70). Alasannya: ERD Bab 3 sudah berubah di empat entitas dan T-39 (gambar ERD) menunggu atribut final, jadi usulan yang mengubah skema (daftar tunggu, co-host, level pemain) dialihkan ke saran pengembangan lanjutan di Bab 5. Terinspirasi AYO 6.10.0: "create a match, book a court, and invite opponents in one flow".

| # | Tugas | Perubahan | Bagian yang terdampak |
|---|---|---|---|
| 10 | **T-69** | **Cari rekan dari booking**: tombol "Cari rekan untuk jadwal ini" di Riwayat Pemesanan untuk booking `DIKONFIRMASI` yang belum mulai; membuka L-08 yang sudah terisi lapangan, olahraga, tanggal, dan jam dari booking. Tanpa field baru, tanpa query baru, tanpa perubahan Security Rules | §7 AB-25, §8 L-08, L-13, §11 BB-101–104 |

**Keputusan yang diambil** (dicatat supaya bisa dijelaskan):
- **Aktivitas tidak menyimpan rujukan ke booking.** Tidak ada `bookingId` di `aktivitasBermain`, sehingga ERD tidak berubah. Konsekuensinya, dari satu booking bisa dibuat lebih dari satu aktivitas, dan aktivitas tidak ikut berubah bila booking dibatalkan atau dijadwal ulang. Dicatat sebagai keterbatasan.
- **Hanya booking `DIKONFIRMASI`.** Booking `MENUNGGU` bisa ditolak mitra, dan mengundang orang ke jadwal yang batal membingungkan mereka.
- **Tingkat kemampuan dan jumlah pemain tidak diisi otomatis**: pembuat wajib memilih (aturan T-55) dan jumlah pemain tidak bisa diturunkan dari booking.

### Koreksi teknis pasca-v1.1 (18 Agustus 2026)

Ditemukan dan diperbaiki selama implementasi Sprint 3 (T-13, T-14). Bukan perubahan ruang lingkup/fitur, jadi tidak menyentuh Bab 1–3 — murni supaya dokumen ini tetap cocok dengan kode dan Security Rules yang sudah di-deploy.

| # | Koreksi | Bagian yang terdampak |
|---|---|---|
| 1 | Aturan `create` untuk `lapangan` di Security Rules diperlonggar: `pemilikId == request.auth.uid` **atau** `pemilikId == null`. Versi lama akan membuat `AdminSeedScreen` (T-10) gagal total untuk lapangan non-mitra (25 dari 30 punya `pemilikId: null`, yang tidak akan pernah sama dengan uid manapun). | §9 |
| 2 | Tab Map (L-05) dapat tombol kecil "kembali ke posisi saya" — tidak ada di Figma/PRD awal, ditambahkan karena marker posisi pengguna bisa keluar layar tanpa cara kembali selain geser manual. | §8 L-05 |

### Koreksi teknis pasca-v1.1 (20 Agustus 2026)

Ditemukan dan diperbaiki selama implementasi Sprint 4 (T-15, T-19). Sama seperti koreksi 18 Agustus: bukan perubahan ruang lingkup/fitur, murni supaya dokumen ini tetap cocok dengan kode.

| # | Koreksi | Bagian yang terdampak |
|---|---|---|
| 3 | "Daftar peserta" di L-09 diturunkan dari `namaPembuat` (6.3) + `namaUser` pada dokumen subkoleksi `permintaan` berstatus `DITERIMA` (6.4) — BUKAN field baru. Dibutuhkan karena `peserta` di 6.3 cuma `List<String>` berisi `userId`, tanpa nama, jadi tidak bisa dipakai langsung untuk tampilan. | §6.3, §6.4, §8 L-09 |
| 4 | "Menekan item membuka objek terkait" di L-12 untuk sekarang hanya berlaku untuk tipe `PERMINTAAN_GABUNG`/`PERMINTAAN_DITERIMA`/`PERMINTAAN_DITOLAK` (`refId` = aktivitasId → Detail Aktivitas). Tipe `BOOKING_*` belum punya layar tujuan: `booking_repository.dart` (T-23) sudah bisa menulis dan membaca data booking, tapi layar Detail/Dashboard yang jadi tujuan navigasi baru dikerjakan di T-24…T-25 — item tetap bisa ditandai `sudahDibaca`, cuma belum berpindah layar. Perlu disambungkan saat T-25 selesai. | §8 L-12 |
| 5 | Koreksi #4 di atas kini sebagian tersambung (T-25): tipe `BOOKING_BARU` (penerimanya mitra) membuka Dashboard Mitra (L-14). Tipe `BOOKING_DIKONFIRMASI`/`BOOKING_DITOLAK` (penerimanya pemesan) SENGAJA masih belum — tujuan yang benar adalah "Riwayat Pemesanan" di Profil (L-13), bukan Dashboard Mitra, dan layar itu baru ada di T-27. Sampai T-27 selesai, Dashboard Mitra sendiri juga belum punya jalan masuk permanen (menu di Profil) — untuk sekarang hanya bisa dibuka lewat notifikasi `BOOKING_BARU`. | §8 L-12, L-13, L-14 |
| 6 | T-27 selesai: Profil (L-13) sekarang punya menu "Dashboard Mitra" permanen (`role == "mitra"`), jadi koreksi #5 di atas soal "belum ada jalan masuk permanen" sudah tidak berlaku. Riwayat Pemesanan (dengan AB-07) dan Aktivitas Saya juga sudah hidup penuh. Yang MASIH belum tersambung: tap pada notifikasi `BOOKING_DIKONFIRMASI`/`BOOKING_DITOLAK` belum berpindah ke tab Profil — Profil adalah tab di dalam `IndexedStack` milik `ShellNavigasi`, bukan layar yang di-`push`, jadi butuh mekanisme navigasi lintas-shell yang sengaja belum dibangun di T-27 (di luar cakupannya). Untuk sekarang, riwayat pemesanan tetap bisa dicek manual lewat tab Profil. Tiga bagian L-13 lain (kotak statistik, Lapangan Favorit, ubah Olahraga Favorit/Lokasi Default) juga sengaja masih placeholder "Segera hadir" — masing-masing menunggu T-38, T-35, T-37. | §8 L-12, L-13 |
| 7 | T-35, T-36, T-37, T-38 (keempat tugas v1.1 di Minggu 11) selesai — koreksi #6 di atas soal placeholder "Segera hadir" di L-13 sudah tidak berlaku lagi: kotak statistik, Lapangan Favorit, dan Ubah Olahraga Favorit/Lokasi Default sekarang hidup penuh. Sekaligus AB-03: `HomeViewModel.muatLapangan()` dan `MapViewModel.muatPeta()` sejak awal sudah punya parameter `latDefault`/`lonDefault`, tapi baru sekarang benar-benar disambungkan ke `users.lokasiDefault` — sebelum T-37, cadangan lokasi default belum terpakai walau field-nya sudah ada di skema sejak v1.1. **Sprint 3 dan 4 lengkap secara kode** per 20 Agustus 2026; sisa pekerjaan adalah T-00a–T-00f, T-06, T-10 (lihat `SPRINT-PLAN.md` papan pantau) sebelum Sprint 5 (T-28 pengujian) bisa mulai. | §7 AB-03, AB-10, AB-11, AB-12, §8 L-04, L-05, L-06, L-13 |
| 8 | **Bug ditemukan lewat testing manual di emulator (T-24), bukan Black Box formal**: `_jamTutupHour` di `ajukan_reservasi_screen.dart` membaca `jamTutup == "00:00"` (tengah malam) sebagai jam `0` literal, sehingga rentang `for (jam = jamBuka; jam < jamTutup; jam++)` selalu kosong untuk lapangan yang tutup tengah malam — daftar "Jam Mulai" di L-10 tidak pernah terisi sama sekali untuk lapangan seperti itu (di antaranya Candra Wijaya International Badminton Centre, salah satu dari 7 lapangan `seedPrototipe()`). Diperbaiki: jam tutup ditambah 24 kalau ≤ jam buka, merepresentasikan tengah malam/lewat tengah malam dengan benar. Diverifikasi ulang langsung di emulator — slot muncul, submit reservasi berhasil, mitra dapat notifikasi `BOOKING_BARU`. | §8 L-10 |

---

### Koreksi teknis pasca-v1.1 (26 Agustus 2026)

Ditemukan lewat audit kode menyeluruh saat T-28 (bukan Black Box formal — lihat `SPRINT-PLAN.md` untuk daftar lengkap ~12 temuan). Bukan perubahan ruang lingkup/fitur, murni perbaikan bug dan pengetatan keamanan. Yang paling berdampak ke dokumen ini:

| # | Koreksi | Bagian yang terdampak |
|---|---|---|
| 9 | **Security Rules dipersempit**: `users/{userId}` semula `allow read: if login()` — siapa pun yang login bisa membaca `nomorTelepon` dan `lokasiDefault` (koordinat rumah/kantor) milik pengguna LAIN mana pun. Tidak ada satu pun kode yang butuh baca profil pengguna lain (seluruh nama ditampilkan lewat field yang sudah didenormalisasi ke `aktivitasBermain`/`booking`/`rating`), jadi kelonggaran ini murni celah privasi, bukan kebutuhan fungsional seperti kelonggaran lain di berkas yang sudah didokumentasikan §9. Diperketat jadi `allow read: if pemilikDok(userId)`, konsisten dengan aturan `favorit` di match yang sama. | §9 |
| 10 | `LapanganRepository.perbaruiLapangan` (L-15) diganti dari `.set()` (timpa seluruh dokumen) menjadi `.update()` pada field yang memang bisa diedit form saja. Sebelumnya, tiap kali mitra mengedit lapangan (apa pun yang diubah), `hargaSlot` ikut tertimpa `null` karena form tidak punya kolom untuk field itu — memengaruhi 5 lapangan mitra hasil seeding yang justru punya `hargaSlot` terisi untuk demo AB-04. Perbaikan yang sama sekaligus mencegah `ratingTotal`/`jumlahRating`/`ratingRata2` tertimpa nilai basi kalau ada rating baru masuk (AB-05) tepat saat form edit sedang dibuka. | §6.2, §8 L-15 |

Kalau butuh detail lengkap perbaikan lain (race condition login/register, transaction idempotency booking/aktivitas, toggle favorit, dsb.), lihat riwayat commit T-28 dan catatan di `SPRINT-PLAN.md` — tidak semuanya dirinci di sini karena tidak mengubah kontrak PRD (murni bug internal, bukan perubahan aturan bisnis yang tertulis di dokumen ini).

---

### Koreksi teknis pasca-v1.1 (12 September 2026)

Ditemukan lewat T-30 (seluruh 37 kasus Black Box §11 dijalankan di emulator via adb/uiautomator — lihat `SPRINT-PLAN.md` "Testing manual keempat" untuk detail lengkap). Dua bug nyata ditemukan dan langsung diperbaiki di sesi yang sama; tidak ada perubahan ruang lingkup/fitur.

| # | Koreksi | Bagian yang terdampak |
|---|---|---|
| 11 | **BB-06 (izin lokasi ditolak) gagal**: `Geolocator.requestPermission()` di `LocationService.ambilPosisi()` tidak pernah selesai (bug plugin `geolocator_android` — Android kadang mengembalikan `grantResults` kosong ke callback izin), sehingga Home/Map macet selamanya di kondisi "memuat" alih-alih menampilkan cadangan lokasi default (AB-03). Diperbaiki dengan membungkus pemanggilan itu dengan `.timeout(Duration(seconds: 10))`, pola yang sama dengan `timeLimit` yang sudah ada di `getCurrentPosition()` — kalau plugin macet, dianggap izin ditolak biasa. Diverifikasi ulang dengan mereproduksi pemicu bug yang sama persis (dialog izin sistem + "Tolak") — sebelumnya macet, sekarang langsung tampil layar cadangan yang benar. | §7 AB-03 |
| 12 | **BB-36 (statistik Profil) gagal**: kotak statistik Booking/Aktivitas/Favorit (AB-12) diambil sekali lewat query `count()` saat `ProfilViewModel` dibuat, tapi karena tab Profil tetap hidup di `IndexedStack` `ShellNavigasi`, angkanya tidak pernah dihitung ulang — basi sampai logout/login. Diperbaiki dengan menghapus query `count()` terpisah sama sekali (`hitungBooking`/`hitungAktivitasSaya`/`hitungFavorit` dihapus dari repository, tidak dipakai di tempat lain) dan menghitung `snapshot.data?.length` dari `Stream` yang sama sudah dipakai daftar di bawahnya — angka jadi otomatis ikut hidup, dan baca Firestore yang tadinya dobel (sekali via `count()`, sekali via stream daftar) berkurang jadi sekali. **Perubahan #6 di "Perubahan v1.1" di atas** ("Statistik profil pakai agregasi `count()`") sudah tidak berlaku lagi — sekarang diturunkan dari stream yang sama, bukan agregasi terpisah. | §7 AB-12, §8 L-13 |

Keduanya diverifikasi `flutter analyze` bersih, `flutter test` (7 kasus Haversine) hijau, dan aturan lapisan MVVM bersih. **Masih perlu verifikasi ulang di perangkat Android nyata** sesuai Definisi Selesai §12 poin 1 — kedua perbaikan ini baru diuji di emulator.

---

### Koreksi teknis pasca-v1.1 (14 September 2026)

Ditemukan lewat audit kode menyeluruh (dibantu Claude, bukan Black Box formal) setelah T-29/T-30 — bukan perubahan ruang lingkup/fitur, murni menyambungkan elemen antarmuka yang sudah digambar tapi belum berfungsi.

| # | Koreksi | Bagian yang terdampak |
|---|---|---|
| 13 | **Tombol "Edit Profil" (L-13) tidak berfungsi**: `onPressed` kosong sejak dibuat. Disambungkan ke bottom sheet baru (`ubah_profil_sheet.dart`) mengikuti pola Ubah Olahraga Favorit/Lokasi Default (T-37) — hanya `nama` dan `nomorTelepon` yang bisa diubah (surel = email Firebase Auth, butuh re-autentikasi, di luar cakupan PRD). | §8 L-13 |
| 14 | **Tombol "Lihat di peta" (L-06) tidak berfungsi**: `onPressed` kosong (`TODO(T-14)`). Disambungkan: pop ke `ShellNavigasi` (selalu jadi rute root tunggal), pindah ke tab Map, dan memusatkan peta ke koordinat lapangan lewat `MapViewModel.fokusKeLapangan()` (`double` biasa, bukan `LatLng` — tipe itu tetap cuma boleh dipakai `flutter_map` di View). Butuh `GlobalKey<ShellNavigasiState>` (`AppRoutes.kunciShell`) supaya layar yang di-`push` di atas `ShellNavigasi` bisa memerintah pindah tab dari luar. | §8 L-06 |
| 15 | **Koreksi #6 (20 Agustus 2026) akhirnya ditutup**: notifikasi `BOOKING_DIKONFIRMASI`/`BOOKING_DITOLAK` sekarang berpindah ke tab Profil (L-13) saat ditekan, memakai mekanisme `AppRoutes.kunciShell` yang sama dengan koreksi #14 di atas. Sebelumnya item ini cuma ditandai `sudahDibaca` tanpa berpindah layar karena Profil ada di dalam `IndexedStack`, bukan rute yang bisa di-`push` — sekarang mekanisme itu sudah ada. | §8 L-12, L-13 |

Ketiganya diverifikasi `flutter analyze` bersih, `flutter test` hijau, aturan lapisan MVVM bersih. #13 dan #14 sudah dites langsung di emulator (edit profil dicek dua arah lewat Firestore REST API; lihat-di-peta dicoba dengan 2 lapangan berbeda). **Masih perlu verifikasi ulang di perangkat Android nyata** sesuai Definisi Selesai §12 poin 1.

### Koreksi teknis + v1.2 tahap baru (21 September 2026) — T-51

Dipicu cek manual satu-per-satu 30 data seed lapangan terhadap Google Maps (bukan sekadar audit kode) — ditemukan 3 koordinat masih meleset dan 2 lapangan ternyata multi-olahraga yang belum tercermin di nama tampilannya. Sekalian ditambah fitur baru yang diminta: link Google Maps eksternal per lapangan.

| # | Koreksi/penambahan | Bagian yang terdampak |
|---|---|---|
| 16 | **Atribut baru `tautanMaps` pada `lapangan`** — link Google Maps asli (bukan dibangkitkan dari koordinat), opsional. Tombol baru **"Buka di Google Maps"** di L-06 (dekat "Lihat di peta"), pakai `url_launcher` (paket baru, lihat §4) untuk membuka aplikasi/browser Maps eksternal — beda dari "Lihat di peta" yang tetap ke tab Map internal (flutter_map/OSM). | §4, §6.2, §8 L-06 |
| 17 | **3 koordinat lapangan dikoreksi** hasil cek ulang manual (Google Maps): MS Sport Arena, Arsa Sport Mini Soccer, Mad Padel Club BSD. Ditandai `// KOORDINAT DIKOREKSI (T-51)` di `seed_lapangan.dart`. | §6.2, §10 |
| 18 | **Raw Futsal ternyata multi-olahraga** (futsal & badminton, sama seperti Taruna Futsal yang sudah ada) — `jenisOlahraga` ditambah `badminton`, nama diganti jadi "Raw Futsal & Badminton". **Taruna Futsal** juga diganti nama jadi "Taruna Futsal & Badminton" (jenisOlahraga-nya sudah benar sejak awal, cuma nama tampilannya yang belum mencerminkan itu). | §6.2, §10 |

**Keterbatasan yang perlu ditulis di Bab Keterbatasan Penelitian:** untuk kedua lapangan multi-olahraga di atas, `harga`/`hargaSlot`/`jamBuka`/`jamTutup` tetap satu nilai berlaku untuk seluruh jenis olahraga di venue itu — sistem belum mendukung harga/jam berbeda per jenis olahraga dalam satu lapangan. Lihat `SPRINT-PLAN.md` bagian "Ide masa depan" untuk rencana kalau ini mau dikembangkan lebih lanjut.

**T-51 SELESAI (21 September 2026).** Data 30 lapangan sudah live di Firestore produksi sejak 21 Agustus 2026 dengan rating/booking asli menempel ke `lapanganId`-nya, jadi koreksi di atas tidak bisa ditulis dengan `.update()` per dokumen — `firestore.rules` hanya izinkan pemilik/`pemilikId` mengubah lapangan miliknya, dan 25 dari 30 lapangan non-mitra `pemilikId`-nya `null`. Jalan yang dipakai: **hapus koleksi `lapangan` di Firebase Console (dilakukan pemilik proyek), lalu jalankan ulang `AdminSeedScreen` dari akun `mitra.uji`** (bukan `pengguna.uji`) supaya 5 lapangan `isMitra: true` ter-assign ke `pemilikId` yang benar — tile "Seed Data Awal" dimunculkan sebentar untuk ini, lalu di-comment lagi setelah selesai. **Konsekuensi yang disetujui pemilik proyek:** rating dan favorit yang sudah ada untuk 30 lapangan ini ikut ter-reset (data uji, bukan data sidang), dan `lapanganId` seluruhnya berganti (dokumen baru).

Diverifikasi langsung di emulator (`sport_space_avd`) via `adb`/`uiautomator` terhadap Firestore produksi sungguhan: (1) urutan jarak di Home sekarang cocok persis dengan hitungan ulang manual (The Good Padel Club 0,95 km → Hey Beach Padel Club 1,89 km → Sabnani Football 3,69 km → KM7 Mini Soccer 3,77 km → Stadiums Futsal 3,92 km); (2) pencarian "Raw" menampilkan "Raw Futsal & Badminton" dengan jarak yang sudah memakai koordinat terkoreksi; (3) tombol "Buka di Google Maps" ditekan pada Sabnani Football dan berhasil membuka **aplikasi Google Maps asli** (bukan browser) tepat ke lokasinya; (4) baris Kontak tampil dengan nomor telepon yang benar. `flutter analyze` bersih, pemeriksaan lapisan MVVM bersih, `flutter test` hijau. **Belum diverifikasi di perangkat Android nyata** sesuai Definisi Selesai §12 poin 1 — juga belum dicek manual satu-per-satu ke-27 lapangan lain yang tidak diubah datanya (hanya ditambah `nomorTelepon`/`tautanMaps`) di luar 5 yang sudah dilihat langsung di atas.


### Koreksi teknis (7–19 Oktober 2026) — penyelarasan dengan skripsi `Highlight_2` + Definisi Selesai

| # | Perubahan | Bagian yang terdampak |
|---|---|---|
| 1 | **Badge "🏅 Terverifikasi" dihapus** dari Detail Lapangan (7 Oktober). Survei lapangan (T-00e) tidak pernah dilakukan dan klaim observasi sudah dicabut dari skripsi. Konstanta `AppStrings.badgeTerverifikasi` ikut dihapus | AB-11, L-06, BB-33/BB-34 |
| 2 | **`sumberData` `"places_api"` dan `"observasi"` digabung jadi `"direktori_daring"`** (19 Oktober) di `seed_lapangan.dart` dan default `LapanganModel.fromFirestore()`. Tidak ada efek fungsional — tidak ada layar yang membaca field ini. 25 dokumen produksi diubah manual lewat Firebase Console, **bukan reseed** | §6.2, §10, BB-34 |
| 3 | **Dialog bawaan Flutter berbahasa Indonesia** — `flutter_localizations` (bawaan Flutter SDK) ditambahkan dan `MaterialApp` dikunci ke `Locale('id', 'ID')`. Sebelumnya dialog pilih tanggal/jam di L-08, L-10, L-15 tampil "Select date", "Cancel", "OK" — melanggar §12 poin 4. `intl` ikut naik dari 0.19 ke 0.20 karena versinya dikunci oleh `flutter_localizations`. Efek samping yang disengaja: dialog jam jadi format 24 jam | §4, §12 poin 4 |
| 4 | **Jam hasil dialog ditampilkan lewat `Formatter.jamDariPilihan()`** ("19:00"). Dengan bahasa Indonesia, `TimeOfDay.format(context)` menghasilkan "19.00" (titik) — tidak cocok dengan tampilan lain dan data Firestore. Dua tampilan tanggal di widget (L-08, L-10) yang memakai `DateFormat` langsung juga dipindah ke `Formatter.tanggal()` | L-08, L-10, L-15 |
| 5 | **~65 teks antarmuka yang tertulis langsung di widget, ViewModel, dan `validators.dart` dipindah ke `AppStrings`** — termasuk label tab bawah, label status booking (dulu ditulis dua kali di Profil dan Dashboard Mitra), dan seluruh pesan validasi form. Teks yang tampil tidak berubah. Pesan `Exception` di Repository sengaja tidak dipindah (konvensi CLAUDE.md: Repository melempar pesan siap tampil) | §2.3 |

Diverifikasi 19 Oktober 2026: `flutter analyze` bersih, `flutter test` 7/7 hijau, cek aturan lapisan bersih, build Gradle berhasil, dan diuji di emulator (Home, Detail Lapangan mitra/non-mitra, Map, Teman, Profil, favorit, reservasi + batalkan, dialog tanggal/jam berbahasa Indonesia, pesan validasi form Buat Aktivitas).

---

## 1. Ringkasan Produk

Sport Space adalah aplikasi Android yang menyelesaikan tiga masalah yang selama ini terpisah:

| # | Masalah | Solusi di aplikasi |
|---|---|---|
| 1 | Susah menemukan lapangan yang tersedia | Pencarian berbasis GPS, urut jarak terdekat pakai Haversine, peta interaktif |
| 2 | Susah mencari rekan bermain | Buat/cari/gabung aktivitas bermain, 4 cabang olahraga |
| 3 | Informasi lapangan tersebar di banyak tempat | Satu halaman detail: harga, jam, fasilitas, rating, dan reservasi untuk lapangan mitra |

**Cabang olahraga yang didukung (persis empat, tidak lebih):** futsal, mini soccer, badminton, padel.

---

## 2. Batasan Wajib — BACA SEBELUM NGODING

Ini bukan preferensi. Ini keputusan terkunci yang sudah tertulis di skripsi dan tidak boleh diubah sepihak.

### 2.1 Yang DILARANG dipakai

| Dilarang | Alasan |
|---|---|
| **Firebase Cloud Functions** | Butuh paket Blaze berbayar. Semua logika server dipindah ke Firestore Transaction di klien |
| **Firebase Cloud Messaging (FCM)** | Mengirim notifikasi antar pengguna butuh server. Diganti notifikasi in-app berbasis Firestore listener |
| **Firebase Storage** | Butuh paket Blaze. Foto lapangan pakai URL eksternal (Google Drive, lihat §12b); foto profil disimpan Base64 langsung di dokumen `users` (v1.2, T-43), jatuh balik ke avatar inisial; gambar post forum juga Base64 di dokumen `forum_posts` (v1.3, §12b) |
| **Riverpod, BLoC, GetX** | State management sudah dikunci: **Provider** |
| **Google Maps SDK** | Sudah dikunci: **OpenStreetMap + flutter_map** |
| **Payment gateway apa pun** | Di luar ruang lingkup penelitian. Pembayaran dilakukan di lokasi |
| **Panggilan Google Places API saat runtime** | Data lapangan sudah di-*seed* ke Firestore lebih dulu. Aplikasi hanya baca Firestore |
| **Geohash / geoflutterfire** | Kalkulasi jarak dilakukan di klien pakai Haversine manual |
| **Package `latlong2` untuk hitung jarak** | Haversine **wajib ditulis manual** — ini inti kontribusi skripsi dan akan diperiksa penguji |

### 2.2 Yang TIDAK dibangun

Fitur di bawah ini terdengar masuk akal tapi **di luar ruang lingkup**. Jangan bangun meski terlihat mudah:

- Aplikasi iOS atau web
- Chat / pesan antar pengguna — **Forum (v1.3) bukan chat**: isinya post publik dan komentar di bawahnya, tanpa pesan pribadi dan tanpa percakapan real-time antar dua orang
- Multi-bahasa (i18n) dan onboarding slider. (**Mode gelap** pernah ada di daftar ini; dimasukkan sejak v1.5 atas permintaan pemilik produk — lihat §7 AB-24.)
- Statistik atau grafik di dashboard mitra
- Upload foto oleh pengguna ke penyimpanan server (Storage). Dua pengecualian, keduanya disimpan Base64 langsung di dokumen Firestore: foto profil (v1.2) dan gambar post forum (v1.3) — lihat §12b
- Lupa password / verifikasi email
- Halaman pengaturan yang fungsional (Bahasa, Kebijakan Privasi, Bantuan, Tentang) — **cukup halaman statis** **Pengecualian v1.5:** bagian "Pengaturan" di Profil berisi dua kontrol yang berfungsi — mode tampilan (AB-24) dan pengingat jadwal (AB-23). Bahasa, Kebijakan Privasi, Bantuan, dan Tentang tetap halaman statis.
- Laporan keuangan lapangan
- **Rating antar-pengguna** — lihat §12c

### 2.3 Yang WAJIB ada

- Haversine ditulis manual di `lib/core/utils/haversine.dart`
- Arsitektur MVVM terlihat jelas dari struktur folder
- Semua teks antarmuka berbahasa Indonesia — termasuk dialog bawaan Flutter (lewat `flutter_localizations`, sejak 19 Oktober 2026), dan seluruhnya ditaruh di `core/constants/app_strings.dart`
- Pencegahan double booking secara atomik
- Notifikasi in-app untuk permintaan gabung dan booking

### 2.4 Prototipe Figma sebagai rujukan visual

File Figma "App Skripsi - Sport Field Finder" adalah rujukan untuk **warna, tipografi, spacing, dan tata letak**. Nilainya sudah diekstrak ke `lib/core/constants/app_colors.dart`.

Batas kewenangannya: kalau Figma dan dokumen ini berbeda soal **fitur atau alur**, dokumen ini yang menang. Figma menang hanya untuk urusan **rupa**.

Layar yang **belum** ada di Figma dan harus dirancang sendiri saat implementasi (boleh menurunkan gaya dari 5 layar yang sudah ada): Login, Register, Buat Aktivitas, Detail Aktivitas, Ajukan Reservasi, Beri Rating, Notifikasi, Dashboard Mitra, Tambah/Edit Lapangan.

---

## 3. Aktor dan Peran

| Aktor | `role` di Firestore | Bisa melakukan |
|---|---|---|
| **Pengguna Umum** | `"pengguna"` | Cari lapangan, lihat detail, beri rating & ulasan, simpan favorit, buat/cari/gabung aktivitas bermain, ajukan booking lapangan mitra |
| **Pemilik Lapangan Mitra** | `"mitra"` | Semua yang bisa Pengguna Umum, ditambah: daftarkan lapangan, perbarui info lapangan, kelola booking masuk |

**Catatan pemetaan ke ERD:** Bab 3 memisahkan entitas `Users` dan `PemilikLapangan`. Di Firestore keduanya disatukan dalam koleksi `users` dan dibedakan oleh atribut `role`, karena Firebase Authentication hanya punya satu kumpulan pengguna. Relasi `PemilikLapangan.lapangan[]` diwujudkan sebagai kueri `lapangan where pemilikId == uid`. Pemetaan ini sudah didokumentasikan di Bab 3.3.1.

---

## 4. Stack Teknologi

```yaml
dependencies:
  flutter: sdk
  firebase_core: ^3.x        # inisialisasi Firebase
  firebase_auth: ^5.x        # login/register email + password
  cloud_firestore: ^5.x      # seluruh data aplikasi
  geolocator: ^13.x          # koordinat GPS + izin lokasi
  flutter_map: ^7.x          # peta OpenStreetMap
  latlong2: ^0.9.x           # HANYA untuk tipe LatLng milik flutter_map
  provider: ^6.x             # state management
  intl: ^0.20.x              # format tanggal dan rupiah (naik dari 0.19 pada 19 Oktober 2026 — dikunci flutter_localizations)
  flutter_localizations: sdk # 19 Oktober 2026 — bawaan Flutter SDK; dialog tanggal/jam bawaan berbahasa Indonesia (§12 poin 4). BUKAN fitur multi-bahasa: hanya Locale('id', 'ID')
  cached_network_image: ^3.x # foto lapangan
  image_picker: ^1.x         # v1.2 — pilih foto profil dari galeri (disimpan Base64, BUKAN Storage)
  url_launcher: ^6.x         # v1.2 (T-51) — tombol "Buka di Google Maps" (L-06), buka aplikasi/browser eksternal
  flutter_local_notifications: ^22.x # v1.5 (T-67) — pengingat jadwal booking, dijadwalkan DI HP (bukan FCM, bukan server). Butuh desugaring di android/app/build.gradle.kts
  timezone: ^0.11.x          # v1.5 (T-67) — tipe TZDateTime yang diminta zonedSchedule (dipakai dengan zona UTC; data zona waktu tidak dimuat)
  shared_preferences: ^2.x   # v1.5 (T-67) — pengaturan yang tersimpan di HP (saklar pengingat; nanti mode tampilan)

dev_dependencies:
  flutter_launcher_icons: ^0.14.x  # 16 September 2026 — generate ikon launcher Android dari assets/images/logo.jpg, dev-only, tidak ikut ke APK
```

> `latlong2` hanya dipakai untuk kelas `LatLng` yang dibutuhkan `flutter_map`. **Jangan** pakai `Distance()` bawaannya untuk menghitung jarak.

**Bahasa pemrograman:** Dart. **Framework:** Flutter.
**Target:** Android, minSdk 21.
**Firebase:** Firestore (mode produksi), Authentication (Email/Password).

---

## 5. Arsitektur & Struktur Folder

Pola: **MVVM** — View ⇄ ViewModel ⇄ Repository ⇄ Firestore.

**Aturan lapisan yang tidak boleh dilanggar:**

1. **View** tidak pernah menyentuh `FirebaseFirestore` langsung. Selalu lewat ViewModel.
2. **ViewModel** tidak pernah menyentuh `FirebaseFirestore` langsung. Selalu lewat Repository.
3. **Repository** adalah satu-satunya lapisan yang tahu Firestore ada.
4. **Model** hanya berisi data + `fromFirestore()` / `toFirestore()`. Tanpa logika bisnis.

```
lib/
  main.dart
  firebase_options.dart

  core/
    constants/
      app_colors.dart          # warna tema — diekstrak dari Figma
      app_sports.dart          # daftar 4 olahraga + label + ikon
      app_fasilitas.dart       # v1.5 — daftar fasilitas, dipakai form mitra L-15 dan filter Home (AB-16)
      app_strings.dart         # teks antarmuka berbahasa Indonesia
    data/
      seed_lapangan.dart       # data awal untuk AdminSeedScreen
    utils/
      haversine.dart           # WAJIB manual
      formatter.dart           # format rupiah, tanggal, jam
      validators.dart          # validasi form
      lencana.dart             # v1.4 — aturan lencana (AB-14), fungsi murni
      whatsapp.dart            # v1.4 — normalisasi nomor + teks bagikan (AB-15), fungsi murni
      tautan_eksternal.dart    # v1.4 — buka tautan di luar aplikasi (url_launcher), dipakai tombol Bagikan/WhatsApp
      jam_buka.dart            # v1.5 — sedangBuka(), filter "Buka sekarang" (AB-16), fungsi murni
      harga.dart               # v1.5 — diskon + total booking (AB-18, AB-19), fungsi murni
      kode_akses.dart          # v1.5 — pembangkit kode aktivitas privat (AB-21), fungsi murni
      pengingat_jadwal.dart    # v1.5 — rencanakanPengingat() + idPengingatDari() (AB-23), fungsi murni
      waktu_booking.dart       # v1.5 — waktuMulaiBooking(): tanggal + jamMulai → DateTime, dipakai AB-23 dan AB-25
      cari_rekan_booking.dart  # v1.5 — bolehCariRekan() + isianAwalDariBooking() (AB-25), fungsi murni
    services/
      location_service.dart    # bungkus geolocator
      pengingat_service.dart   # v1.5 — bungkus flutter_local_notifications (AB-23)
    theme/                     # v1.5 — mode gelap (AB-24)
      app_palette.dart         # ThemeExtension warna per mode + context.warna
      app_theme.dart           # ThemeData terang dan gelap (di-cache), pemetaan ModeTema → ThemeMode
      mode_tema.dart           # enum Terang / Gelap / Ikuti HP + kode untuk disimpan

  models/
    user_model.dart
    lapangan_model.dart
    aktivitas_bermain_model.dart
    permintaan_gabung_model.dart
    rating_model.dart
    booking_model.dart
    notifikasi_model.dart
    favorit_model.dart
    forum_post_model.dart
    forum_komentar_model.dart

  repositories/
    auth_repository.dart
    lapangan_repository.dart
    aktivitas_repository.dart
    rating_repository.dart
    booking_repository.dart
    notifikasi_repository.dart
    favorit_repository.dart
    forum_repository.dart

  features/
    auth/         { view/, viewmodel/ }
    lapangan/     { view/, viewmodel/ }
    aktivitas/    { view/, viewmodel/ }
    rating/       { view/, viewmodel/ }
    booking/      { view/, viewmodel/ }
    profil/       { view/, viewmodel/ }
    notifikasi/   { view/, viewmodel/ }
    favorit/      { view/, viewmodel/ }
    forum/        { view/, viewmodel/ }
    mitra/        { view/, viewmodel/ }

  widgets/                     # widget yang dipakai lintas fitur
  routes/app_routes.dart
```

---

## 6. Model Data (Firestore)

Nama atribut mengikuti ERD Bab 3 **persis**. Jangan diterjemahkan ke bahasa Inggris.

### 6.1 `users/{userId}`

`userId` = UID dari Firebase Authentication.

| Atribut | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `userId` | String | ✓ | sama dengan ID dokumen |
| `nama` | String | ✓ | |
| `surel` | String | ✓ | |
| `nomorTelepon` | String | | |
| `fotoProfilBase64` | String? | | **v1.2** — opsional, foto profil dari galeri (`image_picker`), disimpan sebagai Base64 langsung di dokumen ini (BUKAN URL, BUKAN Firebase Storage — lihat §12b). `null`/kosong → avatar dari inisial nama |
| `role` | String | ✓ | `"pengguna"` \| `"mitra"` |
| `tanggalDaftar` | Timestamp | ✓ | |
| `olahragaFavorit` | List\<String\> | ✓ | **v1.1** — subset dari 4 olahraga, boleh larik kosong |
| `lokasiDefault` | Map\<String,dynamic\>? | | **v1.1** — `{"nama":"Alam Sutera","latitude":-6.2214,"longitude":106.6520}`, dipakai sebagai cadangan bila GPS ditolak (AB-03) |

### 6.2 `lapangan/{lapanganId}`

| Atribut | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `lapanganId` | String | ✓ | sama dengan ID dokumen |
| `nama` | String | ✓ | |
| `alamat` | String | ✓ | |
| `latitude` | double | ✓ | |
| `longitude` | double | ✓ | |
| `jenisOlahraga` | List\<String\> | ✓ | subset dari `["futsal","mini_soccer","badminton","padel"]` |
| `harga` | int | ✓ | tarif dasar per jam, dalam rupiah |
| `hargaSlot` | Map\<String,int\>? | | `{"pagi":x,"siang":y,"malam":z}` — opsional, jika `null` pakai `harga` |
| `jamBuka` | String | ✓ | format `"HH:mm"` |
| `jamTutup` | String | ✓ | format `"HH:mm"`. `"00:00"` berarti **tengah malam**, bukan jam 0 — lihat "Koreksi teknis pasca-v1.1 (20 Agustus 2026)" #8 di atas kalau menulis logika baru yang mem-parsing field ini |
| `fasilitas` | List\<String\> | ✓ | mis. `["parkir","toilet","kantin","ruang ganti"]` |
| `fotoURL` | List\<String\> | ✓ | boleh larik kosong |
| `nomorTelepon` | String | | **v1.2** — kontak lapangan, opsional, boleh kosong sampai diisi manual/mitra |
| `tautanMaps` | String | | **v1.2 (T-51)** — link Google Maps asli hasil verifikasi manual (bukan dibangkitkan dari `latitude`/`longitude`), opsional, boleh kosong |
| `isMitra` | bool | ✓ | menentukan apakah tombol reservasi muncul |
| `pemilikId` | String? | | hanya terisi jika `isMitra == true` |
| `sumberData` | String | ✓ | `"direktori_daring"` \| `"mitra"` *(sebelum 19 Oktober 2026: `"places_api"` \| `"observasi"` \| `"mitra"`)* |
| `ratingTotal` | int | ✓ | jumlah seluruh nilai rating, awal `0` |
| `jumlahRating` | int | ✓ | banyak rating, awal `0` |
| `ratingRata2` | double | ✓ | atribut turunan, awal `0.0` |
| `diskonPersen` | int | ✓ | **v1.5 (T-65)** — persen promo dari mitra, `0`–`90`, `0` = tanpa promo. Dokumen lama dibaca `0` |
| `produkTambahan` | List\<Map\> | ✓ | **v1.5 (T-60)** — item tambahan yang bisa dipesan bersama booking, maksimal 5. Tiap elemen `{"nama": String, "harga": int}`. Dokumen lama dibaca daftar kosong |

> **`slotTersedia[]` TIDAK disimpan.** Di ERD ia atribut turunan, dihitung dari koleksi `slotBooking`. Jangan bikin fieldnya.
>
> **Badge status TIDAK menambah field.** Lihat AB-11 — sejak 7 Oktober 2026 hanya tersisa badge "✅ Mitra Terdaftar" yang diturunkan dari `isMitra`. `sumberData` sekarang tidak dibaca oleh layar mana pun; ia hanya catatan asal data.

### 6.3 `aktivitasBermain/{aktivitasId}`

| Atribut | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `aktivitasId` | String | ✓ | |
| `jenisOlahraga` | String | ✓ | satu nilai dari 4 olahraga |
| `jumlahPemainDibutuhkan` | int | ✓ | |
| `jumlahPemainSaatIni` | int | ✓ | awal `1` (pembuat ikut bermain) |
| `waktu` | Timestamp | ✓ | jadwal bermain |
| `lapanganId` | String | ✓ | |
| `namaLapangan` | String | ✓ | disalin agar daftar tidak perlu kueri tambahan |
| `pembuatId` | String | ✓ | |
| `namaPembuat` | String | ✓ | disalin |
| `status` | String | ✓ | `"TERBUKA"` \| `"PENUH"` \| `"SELESAI"` \| `"DIBATALKAN"` |
| `peserta` | List\<String\> | ✓ | daftar `userId`, awal berisi `pembuatId` |
| `catatan` | String? | | |
| `dibuatPada` | Timestamp | ✓ | |
| `jenisAktivitas` | String | ✓ | **v1.4 (T-54)** — `"main_bareng"` \| `"sparring"`. Dokumen lama tanpa field ini dibaca sebagai `"main_bareng"` |
| `tingkatKemampuan` | String? | | **v1.4 (T-55)** — `"pemula"` \| `"menengah"` \| `"mahir"`. Wajib dipilih saat membuat aktivitas baru; `null` hanya untuk dokumen lama |
| `biayaPerOrang` | int | ✓ | **v1.4 (T-56)** — rupiah, `0` = gratis, maksimal `1000000`. Informasi saja, dibayar di lokasi. Dokumen lama dibaca sebagai `0` |
| `visibilitas` | String | ✓ | **v1.5 (T-64)** — `"publik"` \| `"privat"`. Dokumen lama dibaca `"publik"` |
| `kodeAkses` | String? | | **v1.5 (T-64)** — kode 6 karakter, hanya terisi bila `visibilitas == "privat"`. Alfabet `ABCDEFGHJKLMNPQRSTUVWXYZ23456789` (tanpa I, O, 0, 1 agar tidak tertukar) |

### 6.4 `aktivitasBermain/{aktivitasId}/permintaan/{userId}` (subkoleksi)

ID dokumen = `userId` pemohon, supaya satu orang tidak bisa mengirim permintaan ganda.

| Atribut | Tipe | Keterangan |
|---|---|---|
| `userId` | String | |
| `namaUser` | String | |
| `status` | String | `"MENUNGGU"` \| `"DITERIMA"` \| `"DITOLAK"` |
| `dibuatPada` | Timestamp | |

### 6.5 `rating/{ratingId}`

ID dokumen = `"{userId}_{lapanganId}"` — satu pengguna hanya punya satu rating per lapangan, dan boleh memperbaruinya.

| Atribut | Tipe | Keterangan |
|---|---|---|
| `ratingId` | String | |
| `userId` | String | |
| `namaUser` | String | disalin |
| `lapanganId` | String | |
| `nilaiRating` | int | 1–5 |
| `ulasanTeks` | String? | opsional |
| `tanggal` | Timestamp | |
| `balasanMitra` | String? | **v1.5 (T-66).** Balasan mitra pemilik lapangan, 1–500 karakter. Tidak ada di dokumen baru sampai mitra membalas, dan **tidak boleh** ada saat pengguna membuat ulasan (Security Rules §9). Dokumen lama tanpa field ini dibaca `null` |
| `balasanPada` | Timestamp? | **v1.5 (T-66).** Waktu balasan terakhir; selalu ikut terisi bersama `balasanMitra` |

### 6.6 `booking/{bookingId}`

| Atribut | Tipe | Keterangan |
|---|---|---|
| `bookingId` | String | |
| `userId`, `namaUser` | String | |
| `lapanganId`, `namaLapangan` | String | |
| `pemilikId` | String | agar mitra bisa memfilter booking miliknya |
| `tanggal` | String | `"yyyy-MM-dd"` |
| `jamMulai`, `jamSelesai` | String | `"HH:mm"`, selalu kelipatan 1 jam |
| `status` | String | `MENUNGGU` \| `DIKONFIRMASI` \| `DITOLAK` \| `SELESAI` \| `DIBATALKAN` |
| `totalHarga` | int | estimasi, dibayar di lokasi. **v1.5:** sewa setelah diskon (T-65) ditambah seluruh produk tambahan (T-60) |
| `dibuatPada` | Timestamp | |
| `produkTambahan` | List\<Map\> | **v1.5 (T-60)** — salinan produk yang dipilih saat booking, `{"nama", "harga", "jumlah"}`. Disalin (bukan rujukan) supaya perubahan harga mitra tidak mengubah booking lama. Booking lama dibaca daftar kosong |

### 6.7 `slotBooking/{lapanganId}_{tanggal}_{jam}` — kunci slot

Koleksi teknis untuk mencegah double booking. **Bukan entitas di ERD** — ini mekanisme implementasi dari atribut turunan `slotTersedia[]`.

ID dokumen contoh: `abc123_2026-09-01_19` (lapangan abc123, 1 Sept 2026, jam 19:00–20:00).

| Atribut | Tipe |
|---|---|
| `bookingId` | String |
| `lapanganId` | String |
| `tanggal` | String |
| `jam` | int (0–23) |
| `diblokirOleh` | String | **v1.5 (T-59)** — hanya pada slot yang diblokir manual oleh mitra: `userId` mitra |

**v1.5 (T-59) — slot yang diblokir mitra** memakai dokumen yang sama persis dengan ID deterministik yang sama, dengan `bookingId = "BLOKIR"` (nilai tetap, bukan ID booking sungguhan) dan `diblokirOleh` terisi. Karena itu pengguna melihatnya sebagai jam "Penuh" tanpa kode tambahan, dan `ajukanReservasi` otomatis menolaknya. Membuka blokir hanya boleh menghapus dokumen yang `bookingId`-nya `"BLOKIR"`; slot milik booking sungguhan tidak pernah bisa dihapus dari sini.

### 6.8 `notifikasi/{notifikasiId}`

| Atribut | Tipe | Keterangan |
|---|---|---|
| `notifikasiId` | String | |
| `untukUserId` | String | penerima |
| `tipe` | String | `PERMINTAAN_GABUNG` \| `PERMINTAAN_DITERIMA` \| `PERMINTAAN_DITOLAK` \| `BOOKING_BARU` \| `BOOKING_DIKONFIRMASI` \| `BOOKING_DITOLAK` \| `BOOKING_DIBATALKAN` \| `PESERTA_KELUAR` \| `AKTIVITAS_DIBATALKAN` \| `BOOKING_DIJADWALKAN_ULANG` *(v1.5, T-62, penerimanya mitra)* |
| `judul` | String | |
| `pesan` | String | |
| `refId` | String | `aktivitasId` atau `bookingId` |
| `sudahDibaca` | bool | awal `false` |
| `dibuatPada` | Timestamp | |

### 6.9 `users/{userId}/favorit/{lapanganId}` (subkoleksi) — **v1.1**

ID dokumen = `lapanganId`. Pola yang sama dengan `permintaan` (6.4): ID deterministik membuat "sudah difavoritkan atau belum" cukup dibaca satu dokumen, dan mustahil dobel.

| Atribut | Tipe | Keterangan |
|---|---|---|
| `lapanganId` | String | sama dengan ID dokumen |
| `namaLapangan` | String | disalin, agar daftar favorit tidak perlu kueri tambahan |
| `dibuatPada` | Timestamp | |

> **Kenapa subkoleksi, bukan larik di `users`?** Larik tumbuh tanpa batas dan memaksa membaca seluruh dokumen pengguna hanya untuk mengecek satu lapangan. Subkoleksi dengan ID deterministik cukup satu `get()` dokumen. Konsisten juga dengan pola 6.4 yang sudah ada.

### 6.10 `forum_posts/{postId}` — **v1.3**

ID dokumen dibuat otomatis oleh Firestore dan tidak disimpan sebagai field.

| Atribut | Tipe | Keterangan |
|---|---|---|
| `userId` | String | pembuat post; harus sama dengan `auth.uid` saat dibuat |
| `namaUser` | String | nama pembuat, disalin saat post dibuat — dokumen `users` hanya bisa dibaca pemiliknya (§9), jadi daftar forum tidak bisa mengambil nama dari sana |
| `teks` | String | isi post; boleh kosong kalau ada gambar |
| `gambarBase64` | String? | gambar opsional, Base64 dari hasil kompresi `image_picker` (§12b); `null` kalau tanpa gambar |
| `jumlahKomentar` | int | awal `0`; naik 1 tiap komentar baru (denormalisasi, pola sama dengan `ratingTotal` di AB-05) |
| `createdAt` | Timestamp | |
| `dieditPada` | Timestamp? | `null` sampai pemilik mengedit |

### 6.11 `forum_posts/{postId}/komentar/{komentarId}` (subkoleksi) — **v1.3**

ID dokumen otomatis.

| Atribut | Tipe | Keterangan |
|---|---|---|
| `userId` | String | penulis komentar |
| `namaUser` | String | disalin saat komentar dibuat |
| `teks` | String | |
| `createdAt` | Timestamp | |

> Komentar **tidak bisa diedit** (rules `update: false`) dan tidak ada tombol hapus per komentar di aplikasi — komentar hanya hilang bersama postnya (AB-13).

---

## 7. Aturan Bisnis

### AB-01 · Haversine

Ditulis manual di `lib/core/utils/haversine.dart`. Jari-jari bumi **6371 km**.

```dart
/// Menghitung jarak (km) antara dua koordinat GPS dengan Haversine Formula.
/// R = 6371 km (jari-jari rata-rata bumi).
double hitungJarakHaversine(
  double lat1, double lon1,
  double lat2, double lon2,
) {
  const double R = 6371.0;
  double toRad(double d) => d * pi / 180.0;

  final dLat = toRad(lat2 - lat1);
  final dLon = toRad(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(toRad(lat1)) * cos(toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
}
```

Rumus ini harus persis sama dengan persamaan (1)(2)(3) di Bab 2.3. Jangan diganti dengan pendekatan lain.

### AB-02 · Pengurutan hasil pencarian

Hasil pencarian lapangan diurutkan **hanya berdasarkan jarak terdekat**. Rating ditampilkan sebagai informasi, **bukan** faktor pengurutan. (Ini keputusan sadar — lihat Bab 2.12 revisi.)

Alur: ambil seluruh dokumen `lapangan` (batasi 500) → hitung Haversine untuk tiap dokumen → urutkan menaik → tampilkan.

### AB-03 · Izin lokasi — **diperbarui v1.1**

1. Minta izin lewat `geolocator`.
2. Jika **diberikan**: pakai koordinat GPS.
3. Jika **ditolak** atau **layanan lokasi mati**:
   - Jika pengguna punya `lokasiDefault` (6.1), **pakai itu** dan tampilkan spanduk kecil: "Memakai lokasi default: {nama}. Aktifkan GPS untuk hasil lebih akurat."
   - Jika tidak punya, tampilkan halaman/pesan yang mengarahkan pengguna mengaktifkan lokasi lewat pengaturan perangkat, dengan tombol coba lagi **dan** tautan untuk menetapkan lokasi default.
4. Aplikasi **tidak boleh crash** dalam kondisi apa pun di atas.

> Cadangan `lokasiDefault` ini membuat aplikasi tetap berguna saat GPS ditolak — sebelumnya layar hanya menampilkan pesan kesalahan dan buntu.

### AB-04 · Pencegahan double booking (PENTING)

**Jebakan teknis:** Firestore Transaction di Flutter hanya bisa `transaction.get()` pada `DocumentReference`, **tidak bisa menjalankan Query**. Jadi "cek bentrok lalu tulis" dengan kueri **tidak** bisa dibuat atomik. Karena itu dipakai pola **kunci slot dengan ID dokumen deterministik**.

Alur saat pengguna mengajukan reservasi:

```
jamMulai = 19:00, jamSelesai = 21:00  →  slot jam = [19, 20]

runTransaction:
  untuk setiap jam di slot:
    ref = slotBooking/{lapanganId}_{tanggal}_{jam}
    snap = transaction.get(ref)
    jika snap.exists  →  lempar Exception("Slot sudah dipesan")
  buat dokumen booking (status MENUNGGU)
  untuk setiap jam di slot:
    transaction.set(ref, { bookingId, lapanganId, tanggal, jam })
  buat dokumen notifikasi untuk pemilikId (tipe BOOKING_BARU)
```

Saat booking **ditolak** atau **dibatalkan**: hapus seluruh dokumen `slotBooking` miliknya agar slot terbuka lagi.

Kunci diambil **saat pengajuan**, bukan saat konfirmasi pemilik. Ini sudah tertulis di Bab 3 Tabel 3.4.

### AB-05 · Kalkulasi rata-rata rating

Dilakukan dengan Firestore Transaction pada dokumen `lapangan` (satu dokumen, jadi aman).

```
runTransaction:
  ratingRef  = rating/{userId}_{lapanganId}
  lapRef     = lapangan/{lapanganId}
  ratingSnap = transaction.get(ratingRef)
  lapSnap    = transaction.get(lapRef)

  jika ratingSnap.exists:            # pengguna memperbarui rating lama
     selisih   = nilaiBaru - ratingSnap.nilaiRating
     ratingTotal += selisih
  sebaliknya:                        # rating baru
     ratingTotal += nilaiBaru
     jumlahRating += 1

  ratingRata2 = ratingTotal / jumlahRating
  transaction.set(ratingRef, dataRating)
  transaction.update(lapRef, { ratingTotal, jumlahRating, ratingRata2 })
```

Jangan hitung rata-rata dengan membaca seluruh koleksi rating — itu boros dan tidak atomik.

### AB-06 · Permintaan gabung aktivitas

```
Pemohon menekan "Gabung":
  buat aktivitasBermain/{id}/permintaan/{userId} status MENUNGGU
  buat notifikasi untuk pembuatId (tipe PERMINTAAN_GABUNG)

Pembuat menekan "Terima" (dalam satu transaction):
  jika jumlahPemainSaatIni >= jumlahPemainDibutuhkan → tolak dengan pesan "Slot penuh"
  permintaan.status = DITERIMA
  peserta.add(userId)
  jumlahPemainSaatIni += 1
  jika jumlahPemainSaatIni >= jumlahPemainDibutuhkan → status = "PENUH"
  buat notifikasi untuk pemohon (tipe PERMINTAAN_DITERIMA)

Pembuat menekan "Tolak":
  permintaan.status = DITOLAK
  buat notifikasi untuk pemohon (tipe PERMINTAAN_DITOLAK)

Peserta menekan "Batalkan Keikutsertaan" — v1.2 (dalam satu transaction):
  jika userId == pembuatId → tolak, pembuat tidak bisa membatalkan diri sendiri
  jika userId bukan peserta → tolak
  jika status SELESAI/DIBATALKAN → tolak
  peserta.remove(userId)
  jumlahPemainSaatIni -= 1
  jika status == PENUH dan jumlahPemainSaatIni < jumlahPemainDibutuhkan → status = TERBUKA
  hapus dokumen permintaan/{userId} (supaya bisa kirim permintaan baru lagi nanti)
  buat notifikasi untuk pembuatId (tipe PESERTA_KELUAR)
```

Aturan tambahan: pembuat aktivitas **tidak bisa** mengirim permintaan gabung ke aktivitasnya sendiri, atau membatalkan keikutsertaannya sendiri (v1.2) — satu-satunya cara pembuat "keluar" adalah menghapus aktivitasnya lewat Security Rules `delete` yang sudah ada, belum ada UI-nya. Pengguna yang sudah jadi peserta tidak bisa mengirim permintaan lagi (tapi bisa membatalkan lalu mengirim ulang).

### AB-07 · Status booking SELESAI

Tidak ada Cloud Functions, jadi transisi ini dihitung **di sisi klien**: saat memuat daftar booking, jika `status == DIKONFIRMASI` dan `tanggal + jamSelesai` sudah lewat dari waktu sekarang, tampilkan sebagai `SELESAI` dan tulis balik perubahan statusnya ke Firestore.

### AB-08 · Aturan reservasi

- Tombol "Ajukan Reservasi" **hanya muncul** jika `lapangan.isMitra == true`.
- Jam yang bisa dipilih dibatasi rentang `jamBuka`–`jamTutup`.
- Tidak bisa memesan untuk waktu yang sudah lewat.
- `totalHarga = harga × jumlah jam` (atau jumlah `hargaSlot` bila tersedia). Selalu tampilkan label **"estimasi, dibayar di lokasi"**.

### AB-09 · Aturan rating

- Hanya bisa memberi rating jika pengguna sudah login.
- Satu pengguna satu rating per lapangan, boleh diperbarui.
- `nilaiRating` wajib 1–5; `ulasanTeks` opsional, maksimal 500 karakter.

### AB-10 · Favorit lapangan — **v1.1**

```
Pengguna menekan ikon ♡ di L-06 atau di kartu L-04:
  ref = users/{uid}/favorit/{lapanganId}
  snap = ref.get()
  jika snap.exists  →  ref.delete()      # batal favorit, ikon jadi ♡
  sebaliknya        →  ref.set({ lapanganId, namaLapangan, dibuatPada })   # ikon jadi ♥
```

Aturan:

- Hanya bisa memfavoritkan kalau sudah login. Kalau belum, tampilkan pesan "Masuk dulu untuk menyimpan favorit."
- Tidak ada transaction — operasinya satu dokumen, jadi `set`/`delete` biasa sudah atomik.
- Tidak ada notifikasi untuk favorit.
- **v1.2 — daftar favorit dipindah ke L-04 Home**, lewat tombol toggle ♥ di search bar: aktif → tampilkan HANYA lapangan favorit; tidak aktif → daftar normal. (Sebelumnya daftar ini muncul di L-13 Profil — dihapus dari sana, kotak angka "Favorit" di L-13 tetap ada.)
- **Tidak memengaruhi pengurutan di L-04.** AB-02 tetap murni jarak — toggle ini MENYARING, bukan mengurutkan ulang. Urutan jarak tetap terjaga di kedua mode.

### AB-11 · Badge status lapangan — **v1.1**

Badge di L-06 diturunkan dari data yang **sudah ada**, tanpa field baru:

| Badge | Syarat | Arti |
|---|---|---|
| ✅ Mitra Terdaftar | `isMitra == true` | Bisa direservasi lewat aplikasi |
| ~~🏅 Terverifikasi~~ | ~~`sumberData == "observasi"`~~ | **Dihapus 7 Oktober 2026** — lihat catatan di bawah |

Lapangan non-mitra tidak menampilkan badge apa pun.

> **Badge "🏅 Terverifikasi" dihapus (7 Oktober 2026).** Artinya dulu "data dikonfirmasi langsung oleh peneliti di lokasi", tapi survei lapangan (T-00e) tidak pernah dilakukan dan klaim observasi sudah dicabut dari skripsi (§14 "Putaran revisi 2"). Nilai `sumberData: "observasi"` tetap ada di data (tidak di-reseed), hanya tidak lagi ditampilkan sebagai badge.

### AB-12 · Statistik profil — **v1.1, diperbarui 12 September 2026**

Tiga angka di L-13 dihitung dari **panjang `Stream`** yang sama sudah dipakai daftar Riwayat Pemesanan/Aktivitas Saya/Lapangan Favorit di bawahnya — **bukan** agregasi `count()` terpisah:

```dart
// snapshot.data?.length dari Stream YANG SAMA dipakai daftar di bawah
// kotak statistik ini — bukan query count() terpisah. Konsekuensinya:
// angka ikut hidup otomatis begitu ada perubahan (booking baru, gabung
// aktivitas, toggle favorit), tanpa perlu logout/login untuk melihat
// angka terbaru, dan tidak ada baca Firestore tambahan (datanya sudah
// dibaca untuk daftar di bawahnya).
StreamBuilder<List<BookingModel>>(
  stream: vm.streamRiwayatBooking, // sama dengan _SeksiRiwayatBooking
  builder: (context, snapshot) =>
      Text('${snapshot.data?.length ?? 0}'),
)
```

**Riwayat:** versi v1.1 awal memakai agregasi `count()` terpisah (alasannya saat itu: 1 baca per 1000 dokumen, lebih murah daripada `.get()` lalu `.length`). Pendekatan itu ternyata membuat angkanya basi selama tab Profil tetap hidup di `IndexedStack` `ShellNavigasi` — baru dihitung ulang setelah logout/login (BB-36, ditemukan 12 September 2026 lewat T-30). Diperbaiki dengan menurunkan angka dari `Stream` yang sama dipakai daftar di bawahnya: sama murahnya (data yang sama sudah dibaca untuk daftar itu, bukan baca tambahan) tapi tanpa bug basi. Lihat "Koreksi teknis pasca-v1.1 (12 September 2026)" #12 untuk detail lengkap.

Kotak statistik ketiga di Figma berlabel "4.9★ Rating" — itu **diganti** menjadi **jumlah favorit**. Alasannya di §12c.

### AB-13 · Forum — **v1.3**

1. **Siapa boleh apa.** Semua pengguna yang login (peran apa pun) boleh membaca forum, membuat post, dan berkomentar. Hanya **pemilik post** yang boleh mengedit dan menghapus postnya. Komentar tidak bisa diedit atau dihapus satu per satu lewat aplikasi.
2. **Post tidak boleh kosong:** harus ada teks (setelah `trim`) **atau** gambar. Komentar wajib berisi teks.
3. **Daftar post:** terbaru dulu, maksimal 20 (`limit(20)`), real-time lewat `StreamBuilder`. Tidak ada paginasi. Satu `orderBy('createdAt')` saja, jadi **tidak butuh composite index**.
4. **Komentar:** komentar baru dan kenaikan `jumlahKomentar` +1 dikirim dalam **satu `WriteBatch`** (`ForumRepository.tambahKomentar`), supaya angkanya tidak tertinggal. Security Rules hanya mengizinkan non-pemilik mengubah `jumlahKomentar` kalau naik tepat 1.
5. **Hapus post:** `ForumRepository.hapusPost` menghapus semua komentarnya dulu (batch per 400), baru postnya. Firestore tidak menghapus subkoleksi otomatis, dan post dihapus **terakhir** supaya rules masih bisa memeriksa pemilik post saat komentar dihapus.
6. **Edit post:** hanya `teks`, `gambarBase64`, dan `dieditPada` yang berubah; `userId`, `createdAt`, `jumlahKomentar` tidak. Post yang pernah diedit menampilkan penanda "(diedit)".
7. **Gambar:** maksimal satu per post, dipilih dari galeri lewat `image_picker` (`maxWidth`/`maxHeight` 1024, `imageQuality` 70). Tiga lapis batas — lihat §12b.
8. **Tidak ada notifikasi** untuk komentar atau post baru. Forum tidak menyentuh koleksi `notifikasi`.

### AB-14 · Lencana pencapaian — **v1.4 (T-58)**

Lencana **tidak disimpan** di Firestore. Ia diturunkan di klien dari tiga angka yang **sama persis** dengan kotak statistik AB-12 (panjang `Stream` yang sudah dibaca L-13), jadi tidak ada baca Firestore tambahan dan angkanya ikut hidup.

| Lencana | Syarat |
|---|---|
| Pemesan Pertama | Booking ≥ 1 |
| Langganan Lapangan | Booking ≥ 5 |
| Rekan Bermain | Aktivitas ≥ 1 |
| Penggerak Komunitas | Aktivitas ≥ 5 |
| Kolektor Favorit | Favorit ≥ 3 |

Lencana yang belum diraih tetap tampil **redup** beserta syaratnya, supaya pengguna tahu apa yang harus dilakukan. Judul seksi menampilkan jumlah yang sudah diraih (mis. `2/5`); saat angka belum termuat tampil spinner, dan bila salah satu aliran gagal tampil "Lencana belum bisa dimuat." Kondisi "kosong" tidak ada karena kelima lencana selalu tampil. Aturan penghitungannya satu fungsi murni di `core/utils/lencana.dart` agar bisa diuji otomatis. Catatan: angka "Booking" di AB-12 menghitung semua status (termasuk `DITOLAK` dan `DIBATALKAN`); lencana mengikuti angka itu apa adanya, sebagai penyederhanaan yang disengaja.

### AB-15 · Bagikan dan hubungi lewat WhatsApp — **v1.4 (T-61, T-63)**

Semuanya memakai `url_launcher` yang sudah ada sejak T-51, mode `LaunchMode.externalApplication`, **tanpa package baru** dan **tanpa `canLaunchUrl`** (yang di Android 11+ butuh deklarasi `<queries>`). Kalau tidak ada aplikasi yang bisa membuka tautan, tampilkan `SnackBar` berbahasa Indonesia.

- **Bagikan (T-63):** `https://wa.me/?text=<teks di-encode>`. Teks aktivitas memuat olahraga, jenis, tingkat, lapangan, waktu, jumlah pemain, dan biaya. Teks lapangan memuat nama, alamat, jam buka, dan `tautanMaps` bila terisi. Tidak ada tautan ke aplikasi (belum ada deep link atau halaman unduh).
- **Hubungi (T-61):** `https://wa.me/<nomor>`, dengan `nomorTelepon` dinormalkan ke format internasional tanpa `+`: buang semua karakter bukan angka, awalan `0` diganti `62`. Tombol **hanya muncul** kalau hasil normalisasi diawali `628` (nomor seluler) dan panjang totalnya 11–15 digit. Nomor telepon rumah seperti `021…` dan nomor kosong tidak menampilkan tombol, karena WhatsApp tidak bisa dipakai di sana.
- Normalisasi dan penyusunan teks adalah fungsi murni di `core/utils/whatsapp.dart`, supaya bisa diuji otomatis.

### AB-16 · Urutkan dan saring lanjutan di Home — **v1.5 (T-57)**

Semuanya dihitung **di klien** pada daftar yang sudah diambil `ambilSemuaLapangan` (AB-02). Query tidak berubah, tidak ada index baru, tidak ada baca Firestore tambahan.

| Pilihan | Aturan |
|---|---|
| Urut **Terdekat** *(bawaan)* | Murni jarak menaik — **persis AB-02**, tidak berubah |
| Urut **Rating tertinggi** | `ratingRata2` menurun. Lapangan `jumlahRating == 0` selalu di akhir. Seri → jarak menaik |
| Urut **Terpopuler** | `jumlahRating` menurun, lalu `ratingRata2` menurun, lalu jarak menaik |
| Saklar **Buka sekarang** | Hanya lapangan yang jam operasionalnya mencakup jam perangkat saat ini |
| Filter **Fasilitas** | Pilihan ganda; lapangan harus punya **semua** fasilitas yang dipilih |

- **Buka sekarang** memakai fungsi murni `sedangBuka(jamBuka, jamTutup, sekarang)` di `core/utils/jam_buka.dart`. Jam tutup yang lebih kecil atau sama dengan jam buka berarti lewat tengah malam (`"00:00"` = tengah malam, lihat §6.2). Jam buka sama dengan jam tutup (mis. `00:00`–`00:00`) berarti buka 24 jam. Jam memakai zona waktu perangkat.
- **Berlaku bersama** chip olahraga, kata kunci, dan toggle favorit (semuanya saling menyaring, `AND`).
- **Urut harga sengaja tidak ada** (lihat "Keputusan yang diambil" di Perubahan v1.5).
- Daftar fasilitas yang bisa dipilih adalah daftar yang sama dengan form mitra L-15 (`core/constants/app_fasilitas.dart`), supaya tidak ada dua sumber.

### AB-17 · Mitra memblokir slot manual — **v1.5 (T-59)**

Untuk jam yang tidak boleh dipesan lewat aplikasi (booking lewat telepon atau langsung, perawatan lapangan). Memakai kunci `slotBooking` yang sudah ada (§6.7), jadi tidak ada koleksi baru.

```
Mitra memilih lapangan miliknya dan sebuah tanggal di L-19.
Tiap jam operasional tampil dalam tiga keadaan:
  kosong     → bisa diblokir
  diblokir   → slotBooking.bookingId == "BLOKIR", bisa dibuka lagi
  dipesan    → slotBooking.bookingId lain, TIDAK bisa disentuh

Mitra menekan jam kosong — blokirSlot (satu transaction):
  baca lapangan/{id}: pemilikId harus == uid mitra, kalau tidak → tolak
  baca slotBooking/{lapanganId}_{tanggal}_{jam}: kalau sudah ada → tolak "Slot sudah terisi"
  set slotBooking {bookingId:"BLOKIR", lapanganId, tanggal, jam, diblokirOleh: uid}

Mitra menekan jam diblokir — bukaBlokir (satu transaction):
  baca slotBooking: kalau tidak ada → selesai (idempoten)
  kalau bookingId != "BLOKIR" → tolak (itu milik booking sungguhan)
  hapus dokumen
```

- Jam yang sudah lewat (pada hari ini) tidak bisa diblokir. Rentang tanggal sama dengan L-10 (maksimal 60 hari ke depan).
- Memblokir **tidak** membatalkan booking yang sudah ada dan **tidak** mengirim notifikasi.
- Booking yang ditolak, dibatalkan, atau diubah jadwalnya hanya menghapus slot milik booking itu sendiri (ID dihitung dari jam booking), jadi slot blokir di jam lain tidak terganggu.

### AB-18 · Promo dari mitra — **v1.5 (T-65)**

`lapangan.diskonPersen` (§6.2), `0`–`90`, diisi mitra di L-15. `0` berarti tidak ada promo.

```
hargaSetelahDiskon(nilai, persen) = (nilai × (100 − persen) + 50) ~/ 100     # dibulatkan ke rupiah terdekat
```

- Fungsi murni di `core/utils/harga.dart`, diuji otomatis.
- **Diskon hanya untuk sewa lapangan** (`harga × jumlah jam` atau jumlah `hargaSlot`, AB-08). Produk tambahan (AB-19) **tidak** didiskon.
- L-04 dan L-06: badge "Diskon X%", harga asli dicoret, harga setelah diskon di sampingnya. Tidak muncul kalau `diskonPersen == 0`.
- L-10: estimasi menampilkan sewa asli, potongan, dan total. `booking.totalHarga` menyimpan hasil **setelah** diskon.
- Booking yang sudah dibuat **tidak** berubah kalau mitra mengubah diskon kemudian.
- Hanya lapangan mitra (`isMitra`) yang bisa punya promo, karena hanya mitra yang punya form L-15.

### AB-19 · Produk tambahan saat booking — **v1.5 (T-60)**

Item tambahan seperti sewa bola atau rompi. Hanya **informasi dan perhitungan estimasi**; dibayar di lokasi, tanpa payment gateway.

- **Mitra (L-15):** daftar `produkTambahan` pada lapangan, maksimal **5** item. Tiap item wajib `nama` (1–30 karakter, setelah `trim`) dan `harga` (angka bulat 1–1.000.000).
- **Pengguna (L-10):** bagian "Tambahan (opsional)" hanya muncul kalau lapangan punya produk. Tiap item punya pengatur jumlah **0–10**. Item berjumlah 0 tidak disimpan.
- **Total:** `totalHarga = hargaSetelahDiskon(sewa, diskonPersen) + Σ(harga × jumlah)`. Fungsi murni di `core/utils/harga.dart`.
- **Disalin ke booking:** `nama`, `harga`, `jumlah` disalin ke `booking.produkTambahan`, bukan dirujuk, jadi perubahan atau penghapusan produk oleh mitra tidak mengubah booking lama.
- Ditampilkan di L-13 (Riwayat Pemesanan) dan L-14 (Booking Masuk), mis. "+ Sewa Bola ×2".

### AB-20 · Ubah jadwal booking — **v1.5 (T-62)**

Dipicu pengguna dari tombol **Ubah Jadwal** di L-13, selama status `MENUNGGU` atau `DIKONFIRMASI` dan jam selesainya belum lewat (syarat yang sama dengan Batalkan, AB-04 lanjutan). Memakai layar L-10 dalam mode ubah.

```
runTransaction:
  bookingSnap = get(booking/{id})
  tolak jika: tidak ada / bukan milik pengguna / status bukan MENUNGGU|DIKONFIRMASI / sudah lewat jam selesai
  tolak jika: jadwal baru sama persis dengan yang lama ("Jadwal tidak berubah")
  slotLama = { lapanganId_tanggalLama_jam }   ;  slotBaru = { lapanganId_tanggalBaru_jam }
  untuk tiap slot di slotBaru yang BUKAN anggota slotLama:
      get(slot) → kalau sudah ada → tolak "Slot sudah dipesan"
      (anggota slotLama dilewati — itu milik booking ini sendiri, mis. geser 19:00–21:00 jadi 20:00–22:00)
  hapus tiap slot di slotLama yang tidak ada di slotBaru
  buat tiap slot di slotBaru yang tidak ada di slotLama
  update booking { tanggal, jamMulai, jamSelesai, totalHarga, status: "MENUNGGU" }
  buat notifikasi untuk pemilikId (tipe BOOKING_DIJADWALKAN_ULANG)
```

- Semua pembacaan dilakukan **sebelum** penulisan pertama (aturan transaction Firestore), dan hanya lewat `DocumentReference` ber-ID deterministik, tidak lewat query (jebakan #1 di `CLAUDE.md`).
- **Status kembali `MENUNGGU`** karena mitra mengonfirmasi jadwal lama, bukan yang baru. Mitra diberi tahu dan harus mengonfirmasi ulang.
- `totalHarga` dihitung ulang dengan harga dan diskon lapangan **saat ini** (AB-18) ditambah `produkTambahan` booking yang sama (AB-19).
- Di L-10 mode ubah, jam milik booking itu sendiri pada tanggal yang sama **tidak** ditandai "Penuh".

### AB-21 · Aktivitas publik atau privat — **v1.5 (T-64)**

```
Pembuat memilih Publik (bawaan) atau Privat di L-08.
Privat → repository membangkitkan kodeAkses (6 karakter), memeriksa tidak dipakai
         aktivitas lain (query kodeAkses ==, maksimal 5 percobaan), lalu menyimpannya.

L-07 (daftar): aktivitas privat TIDAK tampil — disaring di klien (saringAktivitas).
L-07 tombol "Punya kode?": pengguna mengetik kode (di-trim dan dijadikan huruf besar)
   → query kodeAkses == kode, limit 1
   → ketemu: buka L-09 (alur Gabung di L-09 sama seperti aktivitas publik, AB-06)
   → tidak ketemu: "Kode tidak ditemukan."
L-09: label "Privat"; kode ditampilkan HANYA kepada pembuat dan peserta;
      teks Bagikan (AB-15) memuat kode.
```

- Query `kodeAkses ==` satu field, jadi **tidak butuh composite index**.
- Pembangkitan kode adalah fungsi murni di `core/utils/kode_akses.dart` (menerima `Random` agar bisa diuji).
- **Keterbatasan yang diakui:** privat hanya menyembunyikan dari daftar. Pengguna login yang tahu `aktivitasId`, atau membaca koleksi langsung, tetap bisa melihat dokumennya karena Security Rules `aktivitasBermain` mengizinkan `read` untuk semua pengguna login (§9). Untuk skripsi ini memadai; sebutkan di Bab 5.
- Aktivitas yang dibatalkan, penuh, atau sudah lewat tetap bisa dibuka lewat kode (L-09 sudah menangani statusnya).

### AB-22 · Mitra membalas ulasan — **v1.5 (T-66)**

```
L-06, daftar ulasan: untuk SETIAP ulasan, jika lapangan.pemilikId == uid pengguna yang login,
   tampil tombol "Balas" (belum dibalas) atau "Ubah balasan" (sudah dibalas).
Tombol → bottom sheet: kolom teks (terisi balasan lama bila ada), maksimal 500 karakter, tombol Kirim.
Kirim → RatingRepository.balasUlasan(ratingId, teks):
        update rating/{ratingId} { balasanMitra: teks yang di-trim, balasanPada: sekarang }
Ulasan yang sudah dibalas menampilkan blok "Balasan pemilik" + teks + tanggal, untuk SEMUA pengguna.
```

- **Hanya mitra pemilik lapangan** (`lapangan.pemilikId == request.auth.uid`). Tombol hanya digambar untuk mereka, dan Security Rules menegakkannya (§9) — penyewa yang memanggil `update` langsung tetap ditolak.
- **Validasi:** balasan wajib diisi (setelah di-trim) dan maksimal 500 karakter — fungsi `Validators.balasan`, diuji otomatis. Batas yang sama diulang di Repository dan Security Rules.
- **Tanpa query baru:** daftar ulasan tetap `streamUlasan` (index #6); balasan ikut terbawa di dokumen `rating` dan langsung tampil lewat `StreamBuilder`. Balasan tidak memengaruhi `ratingTotal`, `jumlahRating`, atau `ratingRata2`.
- **Pengguna mengubah ratingnya (AB-05)** tidak menghapus balasan: `beriRating` memakai `update` pada `nilaiRating`, `ulasanTeks`, `namaUser`, dan `tanggal` saja bila dokumennya sudah ada (membuat dokumen baru tetap `set`).
- **Keterbatasan yang diakui:** balasan tidak bisa dihapus, hanya diganti; pengguna tidak diberi tahu bahwa ulasannya dibalas. Sebutkan di Bab 5 bila perlu.

### AB-23 · Pengingat jadwal booking — **v1.5 (T-67)**

```
ProfilViewModel berlangganan riwayat booking pengguna (StreamTerakhir yang sama dengan L-13).
Tiap daftar berubah → PengaturanViewModel.sinkronkanPengingat(daftar):
   rencana = rencanakanPengingat(daftar, sekarang)        // fungsi murni, core/utils/pengingat_jadwal.dart
   saklar mati          → batalkan semua pengingat terjadwal
   saklar menyala       → izin notifikasi? (kalau belum & ada rencana: minta SEKALI per sesi)
                          lalu PengingatService.jadwalkan(rencana)   // batalkan semua, jadwalkan ulang
Keluar akun → batalkan semua pengingat yang belum muncul.
```

`rencanakanPengingat`:
- Hanya booking **`DIKONFIRMASI`**. `MENUNGGU`, `DITOLAK`, `DIBATALKAN`, `SELESAI` tidak diingatkan. Booking yang dijadwal ulang (T-62) kembali `MENUNGGU`, jadi pengingat lamanya hilang sampai mitra mengonfirmasi lagi.
- Waktu muncul = `tanggal` + `jamMulai` **dikurangi 60 menit** (`menitSebelumMain`). Kalau waktu itu sudah lewat atau tepat sekarang, booking dilewati — tidak ada pengingat terlambat.
- `tanggal`/`jamMulai` yang tidak terbaca dilewati, tidak menggagalkan booking lain.
- Diurutkan dari yang terdekat dan dipotong **20** (`batasPengingat`), karena Android membatasi jumlah alarm per aplikasi.
- ID notifikasi stabil dari `bookingId` (FNV-1a 32-bit, ditulis manual): `String.hashCode` Dart tidak dijamin sama antar-proses.

Notifikasi: judul **"Sebentar lagi waktunya main!"**, isi **"{nama lapangan} · {jamMulai}–{jamSelesai}, mulai sekitar 1 jam lagi."**, kanal "Pengingat Jadwal" (pengguna bisa mematikannya dari pengaturan HP).

- **Tanpa query dan tanpa Security Rules baru:** daftar booking datang dari stream `streamRiwayatBooking` yang sudah ada.
- **Konfigurasi Android:** desugaring (`isCoreLibraryDesugaringEnabled` + `desugar_jdk_libs`) di `build.gradle.kts`; izin `RECEIVE_BOOT_COMPLETED` dan dua receiver di `AndroidManifest.xml` (menjadwalkan ulang setelah HP restart atau aplikasi diperbarui); `POST_NOTIFICATIONS` ditambahkan plugin.
- **Penyimpanan pilihan:** `PengaturanRepository` (`shared_preferences`) — milik perangkat, bukan akun, sehingga tidak masuk Firestore dan tidak mengubah ERD.

### AB-24 · Mode tampilan terang / gelap — **v1.5 (T-68)**

```
Profil → Pengaturan → "Mode tampilan": SegmentedButton Terang | Gelap | Ikuti HP
pilih → PengaturanViewModel.ubahModeTema(mode):
          ganti state + notifyListeners   → main.dart (Selector) membangun ulang MaterialApp
          simpan ke PengaturanRepository  (shared_preferences, kunci "mode_tema")
MaterialApp: theme = AppTheme.terang(), darkTheme = AppTheme.gelap(),
             themeMode = Terang→light | Gelap→dark | Ikuti HP→system
Dibuka kembali → mode dibaca di main() SEBELUM runApp, jadi frame pertama sudah benar.
```

- **Warna per mode** ada di `AppPalette` (`core/theme/app_palette.dart`): `background`, `surface`, `surfaceVariant`, `textPrimary`, `textSecondary`, `textTertiary`, `mapBackground`, `mapGrid`, `shadowKartu`, `shadowChip`. Dibaca lewat `context.warna.X`. Gaya teks berwarna berupa fungsi: `AppTextStyles.judulSeksi(context)`. Warna yang sama di kedua mode (hijau merek `#1FA54E`, pastel olahraga) tetap di `AppColors`.
- **Mode gelap:** latar `#121212`, permukaan `#1E1E1E`, teks utama `#EDEDED`, teks sekunder `#A3A3A3`. Kontras teks utama minimal 7:1 dan teks sekunder minimal 4,5:1 di atas semua latar (WCAG 2.1 AA/AAA) — dihitung dan dijaga oleh tes. Permukaan Material (dialog, bilah navigasi, lembar bawah) memakai abu netral, bukan abu kehijauan bawaan `fromSeed`. Bayangan kartu dikosongkan.
- **Nilai tersimpan yang tidak dikenal** dibaca sebagai Terang (`ModeTema.dariKode`), bukan galat. Kalau penyimpanan gagal, pilihan tetap berlaku sampai aplikasi ditutup dan pengguna diberi tahu.
- **Tema `ThemeData` dibuat sekali** dan di-cache: `MaterialApp` dibangun ulang tiap `PengaturanViewModel` berubah, dan `ThemeData` baru tiap kali membuat Flutter menggambar ulang seluruh pohon.
- **Aturan untuk layar baru:** jangan menulis `Color(0x…)` atau `Colors.white`/`Colors.black` untuk latar atau teks; pakai `context.warna`. `Colors.white` hanya boleh sebagai warna teks/ikon DI ATAS hijau merek.
- **Tanpa query, tanpa Security Rules, tanpa package baru.** Tidak mengubah ERD.

### AB-25 · Cari rekan dari booking — **v1.5 (T-69)**

```
L-13, kartu Riwayat Pemesanan: bolehCariRekan(booking, sekarang) == true
   → tampil "Cari rekan untuk jadwal ini" (baris tersendiri di bawah status)
Ketuk → ProfilViewModel.ambilLapangan(booking.lapanganId)   // butuh jenisOlahraga
        isianAwalDariBooking(booking, jenisOlahragaLapangan: lapangan.jenisOlahraga)
        → buka BuatAktivitasScreen(isianAwal: …)            // L-08
L-08 terisi: lapangan, tanggal, jam, olahraga; kotak info "Dari booking di …"
Pembuat melengkapi jenis/visibilitas/tingkat/jumlah pemain → alur Buat Aktivitas biasa (L-08)
```

`bolehCariRekan` (fungsi murni, `core/utils/cari_rekan_booking.dart`): status **`DIKONFIRMASI`** dan **jam mulai masih di depan** sekarang (tepat pada jam mulai dianggap sudah mulai). Jam mulai yang tidak terbaca → `false`, bukan galat.

`isianAwalDariBooking`: lapangan, tanggal (jam 00:00), jam, dan menit dari booking. **Olahraga** = yang pertama di `lapangan.jenisOlahraga` yang termasuk empat cabang didukung; bila tidak ada, `null` dan form memakai bawaannya. Membaca jam mulai lewat `waktuMulaiBooking` (`core/utils/waktu_booking.dart`), yang juga dipakai pengingat jadwal (AB-23).

- **Tanpa query baru, tanpa Security Rules baru, tanpa package baru, tanpa field baru.** Memakai `ambilSatuLapangan` yang sudah ada.
- **Pengaman form:** dropdown lapangan menjatuhkan nilai awal yang tidak ada di daftar ke "belum dipilih" (bukan galat bawaan Flutter), dan `_submit` memakai `firstOrNull` sehingga lapangan yang sudah dihapus mitra menghasilkan pesan, bukan crash.
- **Keterbatasan yang diakui:** aktivitas tidak terhubung ke booking-nya (lihat "Keputusan yang diambil" di atas).

---

## 8. Spesifikasi Layar

Navigasi bawah punya **5 tab: Home · Map · Teman · Profil · Forum**. Empat tab pertama sejak v1.1 (mengikuti prototipe Figma); tab **Forum** ditambahkan v1.3.

> ⚠️ Bab 3.3.2 poin 5 semula menuliskan 3 tab; `Highlight_2` sudah menulis 4 tab. Dengan Forum, aplikasi punya **5 tab** — mana yang ditulis di skripsi bergantung pada keputusan forum di §14.

Tab **Map** langsung membuka L-05. Tab **Teman** membuka L-07. Tab **Forum** membuka L-16.

### L-01 · Splash Screen
Logo asli aplikasi (`assets/images/logo.jpg`, juga dipakai sebagai ikon launcher Android sejak 16 September 2026) + nama "Sport Space" di tengah, tagline di bawah logo, badge fitur utama, latar warna utama. **Tombol "Mulai Sekarang"** (Koreksi teknis 15 September 2026 — sebelumnya auto-pindah ~2 detik tanpa tombol; diubah karena figma memang menampilkan tombol ini dan pemilik produk memutuskan splash menunggu ditekan). Pengecekan status login (`AuthViewModel`/`authStateChanges`) tetap berjalan di latar belakang sejak splash dibuka, tidak menunggu tombol — begitu ditekan: sudah login → Home; belum → Login.

### L-02 · Login
Input surel + kata sandi, tombol Masuk, tautan ke Register. Tampilkan pesan kesalahan berbahasa Indonesia (mis. "Surel atau kata sandi salah").

### L-03 · Register
Input nama, surel, nomor telepon, kata sandi, konfirmasi kata sandi, dan pilihan peran (Pengguna / Pemilik Lapangan). Saat berhasil: buat akun Auth **dan** dokumen `users` dengan `role` sesuai pilihan, `olahragaFavorit: []`, `lokasiDefault: null`.

### L-04 · Home — **diperbarui v1.1**

| Elemen | Perilaku |
|---|---|
| Header sambutan | "Halo, {nama}" + lokasi terkini (atau nama `lokasiDefault` bila GPS ditolak) |
| Ikon lonceng | Membuka L-12, dengan badge jumlah notifikasi belum dibaca |
| Search bar | Filter daftar berdasarkan nama atau alamat lapangan (di sisi klien) |
| Tombol toggle ♥ Favorit | **v1.2** — di ujung search bar. Aktif: tampilkan HANYA lapangan favorit (urutan jarak tetap). Tidak aktif: daftar normal |
| Filter chip olahraga | Semua / Futsal / Mini Soccer / Badminton / Padel — **lima chip, termasuk "Semua"** |
| Tombol **Filter & Urutkan** | **v1.5 (T-57)** — ikon di ujung search bar, membuka lembar bawah berisi urutan (Terdekat / Rating tertinggi / Terpopuler), saklar "Buka sekarang", dan chip fasilitas, plus tombol **Reset**. Ada penanda titik pada ikon kalau ada pilihan selain bawaan. Aturan di AB-16 |
| Daftar kartu lapangan | **Daftar vertikal**, satu kartu per baris. Isi: foto, nama, alamat, **jarak (km, 1 desimal)**, harga per jam, rating rata-rata + jumlah ulasan, ikon ♡ favorit. **v1.5 (T-65):** kalau ada promo, harga asli dicoret dan harga setelah diskon di sampingnya, plus badge "Diskon X%" |
| Bottom navigation | Home · Map · Teman · Profil |

**Peta tidak tertanam di Home.** Peta punya tab sendiri (L-05). Frame Figma menampilkan peta 220px di dalam Home — bagian itu dihapus, digantikan daftar vertikal penuh.

Kondisi kosong: "Belum ada lapangan di sekitar kamu." Kondisi izin lokasi ditolak: sesuai AB-03.

### L-05 · Peta Lapangan
Dibuka dari tab **Map**. `FlutterMap` dengan tile OpenStreetMap, marker posisi pengguna + marker tiap lapangan. Menekan marker menampilkan kartu ringkas (nama, jarak, harga) dengan tombol menuju L-06. Tombol kecil "kembali ke posisi saya" (ikon target, pojok kanan bawah peta) menggeser peta balik ke posisi pengguna — ditambahkan saat implementasi (T-14) karena marker posisi bisa keluar layar setelah peta digeser untuk melihat lapangan lain, dan Figma/PRD sebelumnya tidak menyediakan jalan kembali selain geser manual. Tombol **zoom +/−** (di atasnya, pojok kanan bawah peta) memperbesar/memperkecil peta satu level per tekan — ditambahkan (T-50, 21 September 2026) sebagai pelengkap gestur pinch dan scroll mouse bawaan `flutter_map`, yang sudah aktif sejak awal lewat `InteractiveFlag.all` (default `MapOptions.interactionOptions`, tidak pernah diubah kode ini) tanpa perlu kode tambahan. Level zoom dibatasi **3–18** lewat `MapOptions.minZoom`/`maxZoom`, berlaku sekaligus untuk ketiga cara (tombol, pinch, scroll) supaya konsisten.

Tile URL: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
`userAgentPackageName` wajib diisi sesuai package aplikasi.

### L-06 · Detail Lapangan — **diperbarui v1.1**
Foto (satu gambar cukup), **ikon ♡ favorit di pojok kanan atas foto** (AB-10), nama + jenis olahraga + rating rata-rata, **badge status** (AB-11), alamat + tombol lihat di peta (internal, tab Map) + **tombol "Buka di Google Maps" (v1.2, T-51, hanya tampil kalau `tautanMaps` terisi, buka aplikasi/browser eksternal lewat `url_launcher`)**, jam operasional, daftar fasilitas (ikon + label), harga sewa, **kontak (v1.2, hanya tampil kalau `nomorTelepon` terisi)**, daftar ulasan pengguna, tombol **"Beri Rating"**, dan tombol **"Ajukan Reservasi"** — muncul hanya bila `isMitra == true`. **v1.5 (T-65):** kalau `diskonPersen > 0`, baris harga menampilkan harga asli dicoret, harga setelah diskon, dan badge "Diskon X%" (AB-18). **v1.4:** di samping nomor telepon ada tombol **WhatsApp** (T-61, hanya untuk nomor seluler, AB-15) dan di bagian atas ada tombol **Bagikan** (T-63, AB-15) yang membuka WhatsApp dengan ringkasan lapangan.

**v1.5 (T-66):** ulasan yang sudah dibalas mitra menampilkan blok **"Balasan pemilik"** (teks + tanggal) di bawah ulasannya. Untuk mitra **pemilik lapangan itu**, tiap ulasan punya tombol **"Balas"** / **"Ubah balasan"** yang membuka bottom sheet isian balasan (AB-22). Pengguna lain tidak melihat tombol itu.

> Figma menampilkan pemilihan slot jam langsung di layar ini. Pemilihan slot tetap di **L-10** sesuai PRD, karena butuh pemilihan tanggal dan perhitungan estimasi harga yang tidak muat di layar detail. Tombol "Booking Sekarang" di Figma = tombol "Ajukan Reservasi" yang membuka L-10.
>
> Figma juga menampilkan bottom navigation di dalam kartu detail. Itu keliru — layar detail dibuka di atas tab, tanpa bottom nav.

### L-07 · Cari Rekan
Dibuka dari tab **Teman**. Tab filter olahraga — **lima chip termasuk "Semua", dan Mini Soccer wajib ada** (Figma baru punya tiga). Daftar kartu aktivitas berisi nama pembuat, olahraga, nama lapangan, tanggal & jam, dan `jumlahPemainSaatIni/jumlahPemainDibutuhkan` dengan progress bar; tombol **Gabung** per kartu; FAB untuk membuat aktivitas baru (L-08). Aktivitas yang sudah `PENUH` atau waktunya lewat tidak ditampilkan.

**v1.4 (T-54, T-55, T-56):** di bawah chip olahraga ada dua baris chip filter tambahan. Baris **jenis** (Semua / Main Bareng / Sparring) dan baris **tingkat** (Semua tingkat / Pemula / Menengah / Mahir). Keduanya menyaring **di klien** dari daftar yang sudah diambil, jadi tidak butuh index baru, dan boleh dikombinasikan dengan chip olahraga. Aktivitas lama tanpa `tingkatKemampuan` hanya tampil di "Semua tingkat". Kartu memuat label jenis, label tingkat (bila ada), dan biaya ("Gratis" atau "Rp 25.000 / orang"). Kondisi kosong akibat filter memakai pesan tersendiri: "Tidak ada aktivitas yang cocok dengan filter."

**v1.5 (T-64):** aktivitas **privat tidak tampil** di daftar ini (disaring di klien). Di header ada tombol **"Punya kode?"** yang membuka dialog isian kode; kode yang cocok membuka L-09, kode yang tidak cocok menampilkan "Kode tidak ditemukan." (AB-21).

### L-08 · Buat Aktivitas (form)
Pilih olahraga, pilih lapangan (dari daftar lapangan), tanggal & jam, jumlah pemain dibutuhkan, catatan opsional. Validasi: semua wajib kecuali catatan; waktu harus di masa depan; jumlah pemain 2–30.

**v1.4:** tiga isian baru. **Jenis aktivitas** (dua pilihan, bawaan Main Bareng), **tingkat kemampuan** (tiga pilihan, **wajib dipilih**, tanpa nilai bawaan agar data tidak condong), dan **biaya per orang** (angka rupiah, opsional, kosong dibaca `0` atau gratis, maksimal 1.000.000, tidak boleh negatif atau berisi huruf). Label bantu: "Informasi saja, dibayar di lokasi."

**v1.5 (T-64):** satu isian lagi, **Visibilitas** (Publik bawaan, atau Privat). Pilihan Privat menampilkan keterangan bahwa kode akses dibuat otomatis setelah aktivitas disimpan.

**v1.5 (T-69):** kalau dibuka dari tombol "Cari rekan untuk jadwal ini" di L-13 (AB-25), form terisi **lapangan, olahraga, tanggal, dan jam** dari booking, dan di atasnya tampil kotak info "Dari booking di {nama lapangan}…". Pembukaan biasa lewat tombol + di tab Teman tetap kosong dan tanpa kotak info.

### L-09 · Detail Aktivitas
Info lengkap aktivitas, daftar peserta. Jika pengguna adalah pembuat: tampilkan daftar permintaan gabung dengan tombol **Terima** / **Tolak**, plus tombol **"Batalkan Aktivitas"** di bagian bawah (T-47, 15 September 2026, dengan dialog konfirmasi — menghapus seluruh dokumen aktivitas dan mengirim notifikasi ke semua peserta selain pembuat, lihat AB-06 lanjutan). Jika bukan pembuat: tombol **Gabung**, atau kalau sudah bergabung, label status + tombol **"Batalkan Keikutsertaan"** (v1.2, dengan dialog konfirmasi — lihat AB-06), atau label status permintaannya. **v1.4:** menampilkan jenis, tingkat kemampuan, dan biaya per orang, serta tombol **Bagikan** (T-63, AB-15) yang membuka WhatsApp dengan ringkasan aktivitas. **v1.5 (T-64):** untuk aktivitas privat tampil label "Privat", dan **kode akses hanya terlihat oleh pembuat dan peserta**; teks Bagikan ikut memuat kode (AB-21).

### L-10 · Ajukan Reservasi (form)
Pilih tanggal, jam mulai, durasi (jam). Tampilkan slot yang sudah terisi agar tidak dipilih (chip jam bertanda "Penuh", mengikuti gaya Figma). Tampilkan estimasi total harga. Tombol **Ajukan Reservasi** menjalankan AB-04.

**v1.5:** (a) kalau lapangan punya `produkTambahan`, ada bagian **"Tambahan (opsional)"** dengan pengatur jumlah 0–10 per item (T-60, AB-19); (b) kalau `diskonPersen > 0`, kotak estimasi merinci sewa asli, potongan, produk, dan total (T-65, AB-18); (c) layar ini juga dipakai dalam **mode Ubah Jadwal** (T-62, AB-20): judul "Ubah Jadwal", tanggal dan jam awal terisi jadwal lama, jam milik booking itu sendiri tidak ditandai "Penuh", produk tambahan tidak bisa diubah, dan tombolnya **Simpan Jadwal Baru**.

### L-11 · Beri Rating (form/modal)
Pilih bintang 1–5, isi ulasan opsional, tombol Kirim → menjalankan AB-05.

**Perbaikan 5 November 2026 (temuan uji ulang emulator):** rating itu satu per pengguna per lapangan dan boleh diperbarui (AB-05), jadi sebelum menampilkan form lembar ini **memuat rating lama pengguna** (`RatingRepository.ambilRatingSaya`, satu `get` dokumen `{userId}_{lapanganId}`, tanpa index baru). Kalau sudah pernah menilai: judul **"Ubah Rating"**, bintang dan teks ulasan **terisi nilai lama**, dan ada keterangan bahwa mengirim lagi akan **mengganti** rating dan ulasan sebelumnya. Kalau belum: judul "Beri Rating" dan form kosong seperti semula. Selama memuat tampil indikator; kalau gagal tampil pesan dengan tombol **Coba Lagi** — form sengaja **tidak** dibuka kosong, karena dari form kosong pengguna bisa menimpa ulasan lamanya tanpa tahu.

Setelah rating terkirim dari Detail Lapangan yang dibuka dari **Home**, kartu lapangan itu di Home ikut berubah (1 baca dokumen, bukan seluruh daftar); sebelumnya angka di Home baru benar setelah layar ditarik untuk menyegarkan. Detail Lapangan yang dibuka dari Peta tidak memicu penyegaran ini.

### L-12 · Notifikasi
Daftar dari koleksi `notifikasi` yang `untukUserId == uid`, urut terbaru. Menekan item membuka objek terkait dan menandai `sudahDibaca = true`.

### L-13 · Profil — **diperbarui v1.1**

Dibuka dari tab **Profil**.

| Bagian | Isi |
|---|---|
| Header | Avatar (foto dari `fotoProfilBase64` bila terisi — v1.2, jatuh balik ke inisial) + nama + surel + nomor telepon, tombol Edit Profil |
| Kotak statistik | **Booking** · **Aktivitas** · **Favorit** — dihitung dengan AB-12 |
| Lencana | **v1.4 (T-58)** — lima lencana pencapaian dari tiga angka statistik di atas (AB-14). Yang belum diraih tampil redup beserta syaratnya |
| Olahraga Favorit | Menampilkan `olahragaFavorit`, bisa diubah (pilih dari 4 olahraga) |
| Lokasi Default | Menampilkan `lokasiDefault.nama`, bisa diubah — dipakai AB-03 |
| Riwayat Pemesanan | Daftar booking pengguna dengan 5 status; tombol **"Batalkan"** (merah, dengan dialog konfirmasi) muncul selama status masih `MENUNGGU`/`DIKONFIRMASI` dan belum lewat jam selesai — T-46, 15 September 2026, lihat AB-04 lanjutan. **v1.5:** pada syarat yang sama muncul juga tombol **"Ubah Jadwal"** (T-62, AB-20), dan produk tambahan yang dipesan ditampilkan sebagai baris "+ Sewa Bola ×2" (T-60). **v1.5 (T-69):** booking `DIKONFIRMASI` yang belum mulai punya tombol **"Cari rekan untuk jadwal ini"** di baris tersendiri (AB-25) |
| Aktivitas Saya | Aktivitas yang dibuat dan yang diikuti |
| Pengaturan | **v1.5 (T-68)** — pemilih **"Mode tampilan"** Terang / Gelap / Ikuti HP (AB-24), bawaan Terang, berlaku seketika. **v1.5 (T-67)** — saklar **"Pengingat jadwal"** (AB-23), bawaan menyala. Kalau saklar menyala tetapi Android belum mengizinkan notifikasi, tampil petunjuk berwarna oranye; kalau gagal mengatur pengingat, tampil pesan galat berwarna merah. Pilihan disimpan di HP |
| Menu statis | Bantuan, Kebijakan Privasi, Tentang — halaman statis saja |
| Dashboard Mitra | Hanya muncul jika `role == "mitra"` |
| Keluar | Logout; **v1.5:** membatalkan pengingat jadwal yang belum muncul lebih dulu (AB-23) |

> Figma menampilkan menu "Notifikasi: Aktif" yang bisa diatur. Sampai v1.4 itu **tidak dibangun**: §2.2 mengunci pengaturan sebagai halaman statis, dan aplikasi tidak memakai FCM sehingga tidak ada yang bisa dimatikan. **Sejak v1.5 (T-67)** ada satu saklar yang bermakna — pengingat jadwal lokal — sehingga bagian "Pengaturan" di atas ditambahkan. Notifikasi in-app (L-12) tetap tanpa pengaturan.

### L-14 · Dashboard Mitra
Daftar lapangan milik mitra + tombol tambah lapangan; daftar booking masuk dengan tombol **Konfirmasi** / **Tolak**. **v1.5:** tiap kartu lapangan punya tombol **Atur Slot** yang membuka L-19 (T-59, AB-17), dan tiap baris booking menampilkan produk tambahan yang dipesan (T-60). Notifikasi `BOOKING_DIJADWALKAN_ULANG` (T-62) membuka layar ini.

### L-15 · Tambah/Edit Lapangan (form mitra)
Nama, alamat, koordinat (latitude & longitude diisi manual atau ambil dari lokasi saat ini), jenis olahraga (multi-pilih), harga, jam buka & tutup, fasilitas (multi-pilih), URL foto. Saat disimpan: `isMitra = true`, `pemilikId = uid`, `sumberData = "mitra"`.

**v1.5:** dua bagian baru. **Diskon (%)** (T-65, angka bulat 0–90, kosong dibaca 0, AB-18) dan **Produk Tambahan** (T-60, maksimal 5 baris nama + harga dengan tombol hapus per baris dan tombol tambah, AB-19).

### L-19 · Atur Slot (mitra) — **v1.5 (T-59)**
Dibuka dari tombol **Atur Slot** pada kartu lapangan di L-14, jadi hanya mitra pemilik lapangan itu yang sampai ke sini. Judul memuat nama lapangan. Tombol pilih **tanggal** (hari ini sampai 60 hari ke depan, sama seperti L-10). Di bawahnya **jam operasional** (`jamBuka`–`jamTutup`, aturan tengah malam sama seperti L-10) sebagai deretan chip dengan tiga keadaan: **kosong** (tekan untuk memblokir), **diblokir** (tekan untuk membuka, warna berbeda), dan **dipesan** (nonaktif, bertanda "Dipesan"). Tiga kondisi ditangani: memuat, kosong ("Lapangan ini tidak punya jam operasional untuk tanggal itu"), dan kesalahan dengan tombol coba lagi. Setiap tekan menampilkan `SnackBar` hasilnya. Aturan di AB-17.

### L-16 · Forum (daftar post) — **v1.3**
Dibuka dari tab **Forum**. Judul "Forum", daftar kartu post: nama pembuat, cuplikan teks, gambar (kalau ada), tanggal & jam, ikon komentar + jumlah komentar. FAB "+" membuka L-17; menekan kartu membuka L-18. Tiga kondisi ditangani: memuat (spinner), kosong ("Belum ada post. Jadi yang pertama!"), dan kesalahan (ikon, judul "Gagal memuat", dan pesan penyebabnya; belum ada tombol coba lagi).

### L-17 · Buat / Edit Post — **v1.3**
Satu layar untuk dua mode. Kolom teks, tombol **Pilih Foto** (jadi **Ganti Foto** setelah ada gambar), pratinjau gambar dengan tombol ✕ untuk membuangnya, tombol **Kirim**. Mode edit (dibuka dari menu di L-18) memakai layar yang sama, terisi data post lama. Gambar yang melewati 500 KB mentah ditolak dengan pesan "Ukuran foto terlalu besar. Pilih foto lain."

### L-18 · Detail Post — **v1.3**
Post lengkap (nama, waktu, teks, gambar), judul "Komentar (n)", daftar komentar terlama dulu (nama, teks, waktu), dan kolom tulis komentar dengan tombol kirim di bawah. Menu ⋮ (**Edit Post** / **Hapus Post**) hanya muncul untuk pemilik post; Hapus memakai dialog konfirmasi "Post dan semua komentarnya akan dihapus permanen. Lanjutkan?".

---

## 9. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function login() { return request.auth != null; }
    function pemilikDok(uid) { return login() && request.auth.uid == uid; }

    // v1.3 — gambar forum Base64 dibatasi 700.000 karakter (§12b).
    function gambarForumAman(data) {
      return data.get('gambarBase64', null) == null
        || data.gambarBase64.size() <= 700000;
    }

    match /users/{userId} {
      allow read: if pemilikDok(userId);
      allow create, update: if pemilikDok(userId);
      allow delete: if false;

      // v1.1 — favorit hanya boleh diakses pemilik akunnya sendiri
      match /favorit/{lapanganId} {
        allow read, create, delete: if pemilikDok(userId);
        allow update: if false;   // toggle = create/delete, tidak pernah update
      }
    }

    match /lapangan/{lapanganId} {
      allow read: if true;
      // Mitra boleh buat lapangan miliknya sendiri (pemilikId == uid, L-15).
      // pemilikId == null JUGA diizinkan supaya AdminSeedScreen (T-10) bisa
      // membuat lapangan non-mitra — mayoritas data seed punya pemilikId
      // null, dan null tidak akan pernah sama dengan request.auth.uid.
      // (Koreksi implementasi 18 Agustus 2026 — versi awal cuma mengizinkan
      // pemilikId == uid, yang berarti AdminSeedScreen akan gagal total
      // untuk 25 dari 30 lapangan non-mitra. Ditemukan saat T-13.)
      allow create: if login() && (
           request.resource.data.pemilikId == request.auth.uid
        || request.resource.data.pemilikId == null
      );
      allow update: if login() && (
           resource.data.pemilikId == request.auth.uid
        || request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(['ratingTotal','jumlahRating','ratingRata2'])
      );
      allow delete: if login() && resource.data.pemilikId == request.auth.uid;
    }

    match /aktivitasBermain/{aktivitasId} {
      allow read: if login();
      allow create: if login() && request.resource.data.pembuatId == request.auth.uid;
      allow update: if login();   // dibutuhkan agar peserta bisa bertambah
      allow delete: if login() && resource.data.pembuatId == request.auth.uid;

      match /permintaan/{userId} {
        allow read: if login();
        allow create: if pemilikDok(userId);
        allow update: if login();
        allow delete: if pemilikDok(userId);
      }
    }

    match /rating/{ratingId} {
      allow read: if true;

      // Ulasan baru: atas nama sendiri dan TANPA balasan (v1.5, T-66) —
      // balasan hanya boleh datang dari mitra lewat update.
      allow create: if login()
        && request.resource.data.userId == request.auth.uid
        && !request.resource.data.keys().hasAny(['balasanMitra', 'balasanPada']);

      allow update: if login() && (
        // Jalur 1 — PEMBUAT ulasan mengubah ulasannya sendiri: userId tetap,
        // dan field balasan tidak boleh disentuh.
        (
          resource.data.userId == request.auth.uid
          && request.resource.data.userId == request.auth.uid
          && !request.resource.data.diff(resource.data).affectedKeys()
               .hasAny(['balasanMitra', 'balasanPada'])
        )
        // Jalur 2 — MITRA PEMILIK lapangan: hanya field balasan, 1–500 karakter.
        || (
          request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['balasanMitra', 'balasanPada'])
          && request.resource.data.balasanMitra is string
          && request.resource.data.balasanMitra.size() >= 1
          && request.resource.data.balasanMitra.size() <= 500
          && request.resource.data.balasanPada is timestamp
          && get(/databases/$(database)/documents/lapangan/$(resource.data.lapanganId))
               .data.pemilikId == request.auth.uid
        )
      );

      allow delete: if false;
    }

    match /booking/{bookingId} {
      allow read: if login();
      allow create: if login() && request.resource.data.userId == request.auth.uid;
      allow update: if login();   // pemilik mengonfirmasi, pengguna membatalkan
      allow delete: if false;
    }

    match /slotBooking/{slotId} {
      allow read: if login();
      allow create, delete: if login();
      allow update: if false;
    }

    match /notifikasi/{notifikasiId} {
      allow read: if login() && resource.data.untukUserId == request.auth.uid;
      allow create: if login();
      allow update: if login() && resource.data.untukUserId == request.auth.uid;
      allow delete: if login() && resource.data.untukUserId == request.auth.uid;
    }

    // v1.3 — Forum (AB-13)
    match /forum_posts/{postId} {
      allow read: if login();
      allow create: if login()
        && request.resource.data.userId == request.auth.uid
        && request.resource.data.jumlahKomentar == 0
        && gambarForumAman(request.resource.data);

      allow update: if login() && (
        // Jalur 1 — siapa pun: hanya menaikkan jumlahKomentar tepat 1
        (request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['jumlahKomentar'])
          && request.resource.data.jumlahKomentar
               == resource.data.jumlahKomentar + 1)
        // Jalur 2 — hanya pemilik: teks, gambar, dan penanda waktu edit
        || (resource.data.userId == request.auth.uid
          && request.resource.data.diff(resource.data).affectedKeys()
               .hasOnly(['teks', 'gambarBase64', 'dieditPada'])
          && gambarForumAman(request.resource.data))
      );
      allow delete: if login() && resource.data.userId == request.auth.uid;

      match /komentar/{komentarId} {
        allow read: if login();
        allow create: if login()
          && request.resource.data.userId == request.auth.uid;
        allow update: if false;
        // Penulis komentar, ATAU pemilik post (saat hapusPost membersihkan komentar)
        allow delete: if login() && (
          resource.data.userId == request.auth.uid
          || get(/databases/$(database)/documents/forum_posts/$(postId))
               .data.userId == request.auth.uid
        );
      }
    }
  }
}
```

> Aturan ini sengaja longgar di beberapa titik (mis. `update` aktivitas) supaya alur gabung-aktivitas jalan tanpa Cloud Functions. Untuk skripsi ini memadai; sebutkan sebagai keterbatasan di Bab 5.
>
> Aturan `favorit` justru **ketat** — hanya pemilik akun yang bisa membaca dan menulis. Ini contoh bagus untuk ditunjukkan ke penguji saat membahas keamanan data pribadi.
>
> Aturan `forum_posts` (v1.3) punya satu titik longgar yang disengaja: Jalur 1 mengizinkan siapa pun yang login menaikkan `jumlahKomentar` tepat 1 **tanpa** memeriksa bahwa komentarnya benar-benar dibuat. Penghitung dan komentar dikirim satu `WriteBatch` dari klien. Rules sebenarnya bisa memeriksanya lewat `getAfter()`, tapi itu menambah satu pembacaan dokumen per komentar, dan versi sekarang memilih tidak memakainya. Sebutkan sebagai keterbatasan di Bab 5 kalau forum masuk skripsi.

---

## 10. Data Awal (Seeding)

Data lapangan dimuat **satu kali** sebelum aplikasi dipakai, lewat halaman tersembunyi `AdminSeedScreen` yang hanya berisi satu tombol. Setelah dijalankan sekali, rutenya dinonaktifkan.

Sumber data dan atribut `sumberData`:

| Sumber | `sumberData` | `isMitra` | Kelengkapan |
|---|---|---|---|
| Direktori pemesanan lapangan daring publik, diverifikasi manual lewat Google Maps (bukan panggilan Google Places API) | `"direktori_daring"` | `false` | nama, alamat, koordinat, jam, foto, nomor telepon, tautan Maps; harga/jam/fasilitas = **estimasi** |
| Pendaftaran mitra lewat aplikasi | `"mitra"` | `true` | lengkap + bisa direservasi |

> **Catatan 27 September 2026:** nilai string `sumberData` tetap `"places_api"` di kode (tidak diganti, supaya tidak perlu reseed ulang Firestore) — yang diperbaiki hanya deskripsi metodenya di sini, karena datanya ternyata dikumpulkan lewat cek manual satu-per-satu ke Google Maps (T-51) plus rencana konfirmasi telepon untuk harga/jam, bukan lewat pemanggilan Google Places API sungguhan. Lihat `SPRINT-PLAN.md` bagian "sumberData 'places_api'" untuk detail dan revisi Bab 1.3/Bab 3 yang masih menyusul di dokumen skripsi.
>
> **Update 8 Oktober 2026:** skripsi (`Highlight_2`) sudah menulis sumber data sebagai direktori daring + verifikasi manual Google Maps, tanpa Places API, observasi, maupun konfirmasi telepon (telepon tidak dilakukan, survei T-00e dibatalkan). Artinya **nilai `"places_api"` dan `"observasi"` sama-sama label lama yang tidak sesuai skripsi.**
>
> **Diputuskan dan dikerjakan 19 Oktober 2026:** keduanya digabung jadi **`"direktori_daring"`** di `seed_lapangan.dart` (25 entri) dan default `LapanganModel.fromFirestore()`. Tidak ada efek fungsional (tidak ada layar yang membaca `sumberData`). **25 dokumen di Firestore produksi diubah manual lewat Firebase Console** (field `sumberData` → `direktori_daring`) — **bukan reseed**, karena seed membuat ID dokumen baru (rating/booking/favorit/aktivitas putus) dan `fotoURL` di file seed masih kosong (30 foto hilang).

Format satu entri seed:

```dart
{
  'nama': 'Futsal Arena Serpong',
  'alamat': 'Jl. Raya Serpong No. 10, Tangerang Selatan',
  'latitude': -6.2884,
  'longitude': 106.6689,
  'jenisOlahraga': ['futsal', 'mini_soccer'],
  'harga': 150000,
  'hargaSlot': {'pagi': 120000, 'siang': 150000, 'malam': 200000},
  'jamBuka': '08:00',
  'jamTutup': '23:00',
  'fasilitas': ['parkir', 'toilet', 'kantin', 'ruang ganti'],
  'fotoURL': ['https://...'],
  'isMitra': false,
  'pemilikId': null,
  'sumberData': 'direktori_daring',
  'ratingTotal': 0,
  'jumlahRating': 0,
  'ratingRata2': 0.0,
}
```

**Target: 20–30 lapangan** di wilayah penelitian (Alam Sutera, BSD, Gading Serpong dan sekitarnya), dengan sebaran keempat olahraga supaya tiap filter ada isinya. Sertakan minimal 3 lapangan `isMitra: true` agar alur reservasi bisa didemokan.

Data siap pakai beserta catatan verifikasinya ada di **`SEED-DATA.md`**.

### Akun Uji (QA)

Dua akun tetap untuk pengujian manual — **pakai ini, jangan bikin akun baru tiap sesi**:

| Peran | Surel | Kata Sandi |
|---|---|---|
| Pengguna | `pengguna.uji@sportspace.test` | `Testing123` |
| Mitra | `mitra.uji@sportspace.test` | `Testing123` |

Dibuat 15 September 2026 sebagai pengganti akun-akun test lama (`qa1`, `qa2`, `*.bb`, `*.demo*`) yang sudah dihapus dari Firebase Console (Authentication + dokumen Firestore terkait) supaya data test tidak terus menumpuk. Akun asli (bukan test) milik anggota tim/teman yang mencoba aplikasi — **jangan dihapus/pakai untuk eksperimen**.

---

## 11. Kriteria Terima (sekaligus kasus uji Black Box)

Nomor BB di bawah dipakai langsung sebagai tabel pengujian Black Box di Bab 4.

| ID | Skenario | Hasil yang diharapkan |
|---|---|---|
| BB-01 | Register dengan data valid | Akun dibuat, dokumen `users` terbentuk dengan `role` sesuai pilihan |
| BB-02 | Register dengan surel sudah terpakai | Pesan kesalahan, akun tidak dibuat |
| BB-03 | Login dengan kredensial benar | Masuk ke Home |
| BB-04 | Login dengan kata sandi salah | Pesan "Surel atau kata sandi salah" |
| BB-05 | Buka Home dengan izin lokasi diberikan | Daftar lapangan tampil urut jarak terdekat |
| BB-06 | Buka Home dengan izin lokasi ditolak, tanpa lokasi default | Muncul arahan mengaktifkan lokasi, aplikasi tidak crash |
| BB-07 | Pilih filter olahraga Badminton | Hanya lapangan dengan `jenisOlahraga` memuat badminton yang tampil |
| BB-08 | Ketik nama lapangan di search bar | Daftar tersaring sesuai kata kunci |
| BB-09 | Buka tab Map | Marker posisi pengguna dan seluruh lapangan tampil di peta OSM |
| BB-10 | Tekan marker lapangan | Kartu ringkas muncul, bisa menuju detail |
| BB-11 | Buka detail lapangan non-mitra | Tombol "Ajukan Reservasi" **tidak** muncul |
| BB-12 | Buka detail lapangan mitra | Tombol "Ajukan Reservasi" muncul |
| BB-13 | Verifikasi jarak Haversine | Selisih dengan perhitungan manual < 0,1 km |
| BB-14 | Buat aktivitas bermain dengan data valid | Aktivitas tersimpan dan tampil di daftar Cari Rekan |
| BB-15 | Buat aktivitas dengan waktu di masa lalu | Ditolak dengan pesan validasi |
| BB-16 | Kirim permintaan gabung | Permintaan tersimpan, pembuat menerima notifikasi |
| BB-17 | Pembuat menerima permintaan | `peserta` bertambah, `jumlahPemainSaatIni` +1, pemohon dapat notifikasi |
| BB-18 | Terima permintaan saat slot sudah penuh | Ditolak dengan pesan "Slot penuh" |
| BB-19 | Pembuat menolak permintaan | Status `DITOLAK`, pemohon dapat notifikasi |
| BB-20 | Aktivitas mencapai jumlah pemain penuh | Status berubah `PENUH`, hilang dari daftar |
| BB-21 | Beri rating 4 bintang pada lapangan baru | `ratingRata2` = 4.0, `jumlahRating` = 1 |
| BB-22 | Ubah rating dari 4 jadi 2 | `jumlahRating` tetap 1, `ratingRata2` = 2.0 |
| BB-23 | Dua pengguna memberi rating 5 dan 3 | `ratingRata2` = 4.0, `jumlahRating` = 2 |
| BB-24 | Ajukan reservasi pada slot kosong | Booking dibuat status `MENUNGGU`, mitra dapat notifikasi |
| BB-25 | Ajukan reservasi pada slot yang sudah dipesan | Ditolak dengan pesan "Slot sudah dipesan" |
| BB-26 | Mitra mengonfirmasi booking | Status `DIKONFIRMASI`, pengguna dapat notifikasi |
| BB-27 | Mitra menolak booking | Status `DITOLAK`, dokumen `slotBooking` terhapus, slot bisa dipesan lagi |
| BB-28 | Booking lewat dari jam selesai | Status tampil `SELESAI` |
| BB-29 | Mitra menambah lapangan baru | Lapangan tampil di pencarian dengan `isMitra: true` |
| BB-30 | Logout | Kembali ke Login, sesi terhapus |
| **BB-31** | **Tekan ♡ pada lapangan** | **Dokumen `users/{uid}/favorit/{lapanganId}` dibuat, ikon jadi ♥** |
| **BB-32** | **Tekan ♥ pada lapangan yang sudah difavoritkan** | **Dokumen terhapus, ikon kembali jadi ♡, hilang dari daftar favorit di Profil** |
| **BB-33** | **Buka detail lapangan mitra (`isMitra == true`)** — *diubah 7 Oktober 2026, semula menguji badge "Terverifikasi" yang sudah dihapus* | **Badge "✅ Mitra Terdaftar" muncul** |
| **BB-34** | **Buka detail lapangan non-mitra (`sumberData == "direktori_daring"`)** | **Tidak ada badge status yang muncul** |
| **BB-35** | **Buka Home dengan izin lokasi ditolak, tapi punya `lokasiDefault`** | **Daftar tetap tampil terurut dari lokasi default, muncul spanduk pemberitahuan** |
| **BB-36** | **Buka Profil** | **Angka Booking, Aktivitas, dan Favorit cocok dengan isi Firestore** |
| **BB-37** | **Pengguna A mencoba membaca favorit pengguna B** | **Ditolak Security Rules** |
| **BB-38** | **Pengguna membatalkan booking status `MENUNGGU`/`DIKONFIRMASI`** | **Status jadi `DIBATALKAN`, `slotBooking` terhapus (slot terbuka lagi), mitra dapat notifikasi** |
| **BB-39** | **Pembuat membatalkan aktivitasnya sendiri** | **Dokumen `aktivitasBermain` terhapus, hilang dari daftar Cari Rekan, seluruh peserta (selain pembuat) dapat notifikasi** |
| **BB-40** | **Tekan tombol zoom + / − di Map berulang kali sampai batas** | **Peta memperbesar/memperkecil satu level per tekan, berhenti tepat di level 3 (zoom −) dan 18 (zoom +), tidak melewati batas** |
| **BB-41** | **Buka detail lapangan dengan `tautanMaps` terisi, tekan "Buka di Google Maps"** | **Aplikasi/browser Google Maps eksternal terbuka menuju lokasi lapangan; kalau `tautanMaps` kosong, tombolnya tidak muncul sama sekali** |
| **BB-42** | **Buka tab Forum** | **Daftar post tampil terbaru dulu (maksimal 20). Kalau belum ada post: "Belum ada post. Jadi yang pertama!"** |
| **BB-43** | **Buat post berisi teks, tekan Kirim** | **Post muncul paling atas dengan nama pembuat dan jumlah komentar 0** |
| **BB-44** | **Kirim post tanpa teks dan tanpa gambar** | **Ditolak dengan pesan "Post tidak boleh kosong.", dokumen tidak dibuat** |
| **BB-45** | **Buat post dengan gambar dari galeri** | **Gambar tampil di kartu daftar dan di Detail Post. Gambar yang melewati 500 KB mentah ditolak: "Ukuran foto terlalu besar. Pilih foto lain."** |
| **BB-46** | **Tulis komentar di Detail Post, tekan kirim** | **Komentar tampil di daftar komentar, dan angka komentar di kartu post bertambah 1** |
| **BB-47** | **Pemilik post memilih Edit Post, ubah isi, simpan** | **Isi berubah dan penanda "(diedit)" muncul. Pengguna lain tidak melihat menu Edit/Hapus di post itu** |
| **BB-48** | **Pemilik post memilih Hapus Post dan mengonfirmasi** | **Post dan seluruh komentarnya terhapus, hilang dari daftar** |
| **BB-49** | **Pengguna B mencoba mengubah isi atau menghapus post pengguna A** | **Ditolak Security Rules** |
| **BB-50** | **Buat aktivitas dengan jenis Sparring** *(T-54)* | **Dokumen tersimpan dengan `jenisAktivitas = "sparring"`; kartu di Cari Rekan dan Detail Aktivitas berlabel Sparring** |
| **BB-51** | **Pilih chip jenis "Sparring" di Cari Rekan** *(T-54)* | **Hanya aktivitas Sparring yang tampil. Aktivitas lama (tanpa field jenis) hanya muncul di "Semua" dan "Main Bareng"** |
| **BB-52** | **Buat aktivitas tanpa memilih tingkat kemampuan** *(T-55)* | **Ditolak dengan pesan validasi, dokumen tidak dibuat** |
| **BB-53** | **Pilih chip tingkat "Pemula" di Cari Rekan** *(T-55)* | **Hanya aktivitas bertingkat Pemula yang tampil. Aktivitas lama (tanpa tingkat) hanya muncul di "Semua tingkat"** |
| **BB-54** | **Buat aktivitas dengan biaya dikosongkan** *(T-56)* | **`biayaPerOrang = 0`, kartu dan Detail Aktivitas menampilkan "Gratis"** |
| **BB-55** | **Buat aktivitas dengan biaya 25000; lalu coba biaya negatif atau di atas 1.000.000** *(T-56)* | **25000 tampil "Rp 25.000 / orang". Biaya negatif, di atas batas, atau bukan angka ditolak dengan pesan validasi** |
| **BB-56** | **Buka Profil akun baru tanpa booking, aktivitas, dan favorit** *(T-58)* | **Kelima lencana tampil redup beserta syaratnya** |
| **BB-57** | **Buat booking pertama, lalu buka Profil** *(T-58)* | **Lencana "Pemesan Pertama" menyala tanpa perlu keluar-masuk akun, lencana lain tetap redup** |
| **BB-58** | **Tekan Bagikan di Detail Aktivitas** *(T-63)* | **WhatsApp terbuka dengan teks ringkasan aktivitas sudah terisi (olahraga, jenis, tingkat, lapangan, waktu, pemain, biaya)** |
| **BB-59** | **Tekan Bagikan di Detail Lapangan** *(T-63)* | **WhatsApp terbuka dengan teks nama, alamat, jam buka, dan tautan Google Maps (bila ada)** |
| **BB-60** | **Buka Detail Lapangan yang `nomorTelepon`-nya nomor seluler (mis. `081316441741`), tekan WhatsApp** *(T-61)* | **WhatsApp terbuka ke percakapan dengan nomor `6281316441741`** |
| **BB-61** | **Buka Detail Lapangan yang nomornya telepon rumah (`0217429521`) atau kosong** *(T-61)* | **Tombol WhatsApp tidak muncul sama sekali** |
| **BB-62** | **Di Home pilih urut "Rating tertinggi"** *(T-57)* | **Lapangan berurut `ratingRata2` menurun; yang belum punya ulasan di akhir; seri diurut jarak. Chip olahraga dan kata kunci tetap berlaku** |
| **BB-63** | **Di Home pilih urut "Terpopuler"** *(T-57)* | **Lapangan berurut `jumlahRating` menurun (seri: rating, lalu jarak)** |
| **BB-64** | **Nyalakan "Buka sekarang"** *(T-57)* | **Hanya lapangan yang jam operasionalnya mencakup jam sekarang yang tampil, termasuk yang tutup lewat tengah malam atau buka 24 jam** |
| **BB-65** | **Pilih fasilitas "parkir" dan "toilet"** *(T-57)* | **Hanya lapangan yang punya keduanya tampil** |
| **BB-66** | **Tekan Reset di lembar Filter & Urutkan** *(T-57)* | **Urutan kembali ke Terdekat (AB-02), saklar dan fasilitas bersih, penanda titik di ikon hilang** |
| **BB-67** | **Mitra memblokir satu jam di L-19, lalu pengguna membuka L-10 untuk tanggal itu** *(T-59)* | **Jam itu bertanda "Penuh" di L-10, dan mengajukan reservasi pada jam itu ditolak "Slot sudah dipesan"** |
| **BB-68** | **Mitra menekan jam yang diblokir di L-19** *(T-59)* | **Blokir terbuka, jam bisa dipesan lagi** |
| **BB-69** | **Mitra membuka L-19 pada tanggal yang jamnya sudah dipesan pengguna** *(T-59)* | **Jam itu bertanda "Dipesan" dan tidak bisa ditekan; slot booking tidak terhapus** |
| **BB-70** | **Mitra mengisi Diskon 20% pada lapangannya** *(T-65)* | **Badge "Diskon 20%" dan harga coret muncul di kartu Home dan Detail Lapangan; diskon 0, kosong, atau tidak ada badge** |
| **BB-71** | **Ajukan reservasi pada lapangan berdiskon** *(T-65)* | **Estimasi di L-10 merinci potongan; `booking.totalHarga` yang tersimpan adalah harga setelah diskon** |
| **BB-72** | **Isi Diskon 91 atau huruf** *(T-65)* | **Ditolak dengan pesan validasi, lapangan tidak berubah** |
| **BB-73** | **Mitra menambah produk "Sewa Bola" Rp 15.000 di form lapangan** *(T-60)* | **Tersimpan di lapangan; menambah produk keenam atau produk bernama/berharga tidak valid ditolak** |
| **BB-74** | **Pengguna memesan dengan 2 × "Sewa Bola"** *(T-60)* | **Total naik 2 × Rp 15.000 (tanpa diskon pada produk), tersimpan di `booking.produkTambahan`, dan terlihat di Riwayat Pemesanan serta Booking Masuk mitra** |
| **BB-75** | **Mitra mengubah harga produk setelah booking dibuat** *(T-60)* | **Booking lama tetap memakai harga lama** |
| **BB-76** | **Pengguna mengubah jadwal booking ke slot kosong** *(T-62)* | **Slot lama terbuka, slot baru terkunci, status jadi `MENUNGGU`, `totalHarga` dihitung ulang, mitra dapat notifikasi** |
| **BB-77** | **Pengguna mengubah jadwal ke slot yang sudah dipesan orang lain** *(T-62)* | **Ditolak "Slot sudah dipesan"; jadwal dan slot lama tidak berubah sama sekali** |
| **BB-78** | **Buka Riwayat Pemesanan pada booking `SELESAI`, `DIBATALKAN`, atau `DITOLAK`** *(T-62)* | **Tombol Ubah Jadwal tidak muncul; menggeser jadwal ke jam yang tumpang tindih dengan jadwal lamanya sendiri berhasil** |
| **BB-79** | **Buat aktivitas Privat** *(T-64)* | **Kode 6 karakter tampil untuk pembuat; aktivitas tidak muncul di daftar Cari Rekan akun lain** |
| **BB-80** | **Akun lain memasukkan kode itu lewat "Punya kode?"** *(T-64)* | **Detail Aktivitas terbuka dan permintaan gabung bisa dikirim; huruf kecil di kode tetap diterima** |
| **BB-81** | **Masukkan kode yang salah** *(T-64)* | **Pesan "Kode tidak ditemukan.", tidak ada layar yang terbuka** |
| **BB-82** | **Buka Cari Rekan dengan aktivitas lama (tanpa `visibilitas`)** *(T-64)* | **Aktivitas lama tetap tampil sebagai publik** |
| **BB-83** | **Buka "Beri Rating" pada lapangan yang sudah pernah kamu nilai** *(L-11)* | **Judul "Ubah Rating", bintang dan teks terisi nilai lama, ada keterangan bahwa ulasan akan diganti; pada lapangan yang belum pernah dinilai form kosong berjudul "Beri Rating"** |
| **BB-84** | **Ubah rating dari Detail yang dibuka lewat Home, lalu kembali ke Home tanpa menarik layar** *(L-11, L-04)* | **Kartu lapangan itu langsung menampilkan rata-rata dan jumlah ulasan yang baru; jarak dan urutan Terdekat tidak bergeser** |
| **BB-85** | **Buka "Beri Rating" saat tidak ada jaringan** *(L-11)* | **Pesan "Gagal memuat ulasanmu sebelumnya. Coba lagi." dengan tombol Coba Lagi, bukan form kosong; setelah jaringan kembali, Coba Lagi membuka form** |
| **BB-86** | **Mitra pemilik membalas ulasan di lapangannya** *(T-66)* | **Tombol "Balas" ada di setiap ulasan; setelah Kirim, blok "Balasan pemilik" (teks + tanggal) tampil di bawah ulasan itu, dan tombol berubah jadi "Ubah balasan"** |
| **BB-87** | **Pengguna biasa, dan mitra yang BUKAN pemilik lapangan itu, membuka Detail** *(T-66)* | **Balasan yang sudah ada terlihat, tetapi tombol "Balas" / "Ubah balasan" tidak ada** |
| **BB-88** | **Kirim balasan kosong atau lebih dari 500 karakter** *(T-66)* | **Ditolak dengan pesan validasi; tidak ada tulisan ke Firestore** |
| **BB-89** | **Pengguna mengubah rating-nya sendiri pada ulasan yang sudah dibalas** *(T-66, AB-05)* | **Nilai dan teks ulasan berubah, balasan mitra tetap ada; `jumlahRating` tidak bertambah** |
| **BB-90** | **Penyewa mencoba menulis `balasanMitra` langsung ke dokumen `rating`, atau mitra lain membalas ulasan di lapangan yang bukan miliknya** *(T-66)* | **Ditolak Security Rules** |
| **BB-91** | **Booking `MENUNGGU` lalu dikonfirmasi mitra; pengguna membuka aplikasi** *(T-67)* | **Saat `MENUNGGU` tidak ada pengingat; setelah `DIKONFIRMASI` terjadwal satu pengingat 60 menit sebelum jam mulai, dan notifikasi "Sebentar lagi waktunya main!" muncul dengan nama lapangan dan jam** |
| **BB-92** | **Booking dikonfirmasi yang waktu pengingatnya sudah lewat** *(T-67)* | **Tidak ada pengingat yang dijadwalkan** |
| **BB-93** | **Lebih dari 20 booking dikonfirmasi di masa depan** *(T-67)* | **Hanya 20 pengingat terdekat yang dijadwalkan** |
| **BB-94** | **Matikan lalu nyalakan saklar "Pengingat jadwal"; izin notifikasi belum diberikan** *(T-67)* | **Mati: semua pengingat dibatalkan. Nyala: dijadwalkan ulang. Saat izin belum ada, menyalakan saklar memunculkan dialog izin Android, dan selama belum diizinkan tampil petunjuk oranye** |
| **BB-95** | **Batalkan booking, atau keluar akun** *(T-67)* | **Pengingat booking itu hilang; keluar akun membatalkan semua pengingat yang belum muncul** |
| **BB-96** | **Pasang aplikasi baru (atau nilai tersimpan rusak), buka Profil → Pengaturan** *(T-68)* | **Mode tampilan terpilih "Terang"; nilai tidak dikenal dibaca Terang, tidak crash** |
| **BB-97** | **Mode Terang dibandingkan dengan tampilan sebelum T-68** *(T-68)* | **Semua layar tampil sama: warna latar, kartu, dan teks tidak berubah** |
| **BB-98** | **Pilih "Gelap"; buka Home, Map, Teman, Profil, Forum, Detail Lapangan, form reservasi, lembar rating/filter/Edit Profil, Notifikasi, Dashboard Mitra, Atur Slot, Form Lapangan, Login, Daftar** *(T-68)* | **Berganti seketika di layar yang sama tanpa kembali ke awal; tidak ada teks yang sulit dibaca, tidak ada kartu atau latar putih yang tertinggal, dialog dan pemilih tanggal ikut gelap** |
| **BB-99** | **Pilih "Gelap", tutup aplikasi sepenuhnya, buka lagi** *(T-68)* | **Tetap Gelap sejak layar pertama (tidak berkedip terang di Flutter), pilihan di Profil tetap "Gelap"** |
| **BB-100** | **Pilih "Ikuti HP", lalu ganti tema sistem HP terang ↔ gelap** *(T-68)* | **Aplikasi ikut berganti tanpa dibuka ulang** |
| **BB-101** | **Booking `MENUNGGU` lalu dikonfirmasi mitra; buka Riwayat Pemesanan** *(T-69)* | **Saat `MENUNGGU` tidak ada tombol "Cari rekan untuk jadwal ini"; setelah `DIKONFIRMASI` dan belum mulai, tombol muncul; setelah dibatalkan atau lewat jam mulai, hilang** |
| **BB-102** | **Ketuk "Cari rekan untuk jadwal ini"** *(T-69)* | **Form Buat Aktivitas terbuka dengan lapangan, olahraga (dari lapangan), tanggal, dan jam sesuai booking, plus kotak info "Dari booking di …"; tingkat dan jumlah pemain masih kosong** |
| **BB-103** | **Lengkapi tingkat dan jumlah pemain, lalu Buat Aktivitas** *(T-69)* | **Aktivitas tampil di Cari Rekan dengan lapangan, tanggal, dan jam yang sama dengan booking; layar kembali ke Profil** |
| **BB-104** | **Buka Buat Aktivitas lewat tombol + di tab Teman** *(T-69)* | **Form kosong seperti sebelumnya, tanpa kotak info** |

---

## 12. Definisi Selesai

Satu fitur dianggap selesai jika:

1. Seluruh kasus BB yang terkait lulus di perangkat Android nyata (bukan hanya emulator). — *19 Oktober 2026: dikonfirmasi tim sudah diuji dan aman di HP Android fisik.*
2. Tidak melanggar aturan lapisan MVVM di Bagian 5.
3. Tidak ada `print()` yang tersisa di kode produksi.
4. Semua teks antarmuka berbahasa Indonesia. — *19 Oktober 2026: dialog tanggal/jam bawaan Flutter yang tadinya berbahasa Inggris sudah diperbaiki (lihat "Koreksi teknis 7–19 Oktober 2026").*
5. Kondisi kosong, memuat, dan kesalahan sudah ditangani (tidak ada layar putih polos).
6. `flutter analyze` bersih tanpa error.

---

## 12b. Keputusan T-40 — SELESAI (20 Agustus 2026): Opsi A dipilih

**Firebase Storage.** Tabel 3.4 dan Bab 2.9 skripsi mencantumkan Firebase Storage sebagai teknologi yang dipakai untuk menyimpan foto lapangan dan foto profil. PRD ini melarangnya (Bagian 2.1) karena menambah kompleksitas untuk pemula.

Keduanya tidak bisa benar sekaligus. Dua opsi yang dipertimbangkan:

- **Opsi A — hapus Firebase Storage dari skripsi.** Foto lapangan memakai URL (mitra tempel link yang sudah ada, bukan upload), foto profil memakai avatar inisial. Paling hemat waktu, dan tidak menambah risiko bug menjelang deadline.
- **Opsi B — implementasikan versi minimal.** Tambah `image_picker` + `firebase_storage`, aktifkan upload foto **hanya** pada form Tambah/Edit Lapangan milik mitra (T-26). Sekitar 2–4 jam kerja tambahan, dan klaim di skripsi jadi terbukti. Membutuhkan paket Blaze.

**Keputusan: Opsi A.** Alasan: fitur upload foto tidak menjawab satu pun dari tiga rumusan masalah (pencarian lapangan berbasis lokasi, cari rekan bermain, reservasi), jadi Opsi B tidak menambah nilai ke penelitian — hanya menambah kompleksitas dan titik gagal baru untuk tim pemula Flutter. Kode T-26 (`form_lapangan_screen.dart`) sudah dibangun sesuai Opsi A: kolom "URL Foto" biasa, bukan `image_picker`.

**Diperluas v1.2 (15 September 2026, tahap 1):** foto profil pengguna sempat bisa diisi lewat URL eksternal opsional (sebelumnya selalu avatar inisial, tanpa jalan lain). Ini masih Opsi A murni — pola dan alasannya identik dengan foto lapangan (URL, bukan upload, tanpa Storage).

**Diperluas v1.2 (15 September 2026, tahap 2) — diganti lagi jadi upload asli via Base64:** URL diganti total dengan pilih foto langsung dari galeri (`image_picker`), disimpan sebagai **Base64 di dokumen Firestore `users/{uid}`** — BUKAN Firebase Storage, BUKAN URL lagi. Ini **pendekatan ketiga**, beda dari Opsi A (tempel URL) maupun Opsi B (Storage+Blaze) yang dipertimbangkan semula:

- Tetap **tanpa Firebase Storage/Blaze** — keputusan T-40 (Opsi A) soal Storage sendiri tidak berubah.
- Tapi **upload asli** (bukan tempel URL) — mengatasi masalah nyata Opsi A: kebanyakan pengguna tidak punya foto diri yang sudah ter-hosting di URL manapun untuk ditempel.
- Bergantung pada **batas 1 MB per dokumen Firestore**, jadi HANYA cocok untuk gambar yang dikompres kecil dan **satu per dokumen**: foto profil (`ubah_profil_sheet.dart`, 512 px) dan — sejak v1.3 — gambar post forum (`buat_post_screen.dart`, 1024 px). Keduanya memakai `maxWidth`/`maxHeight`/`imageQuality` bawaan `image_picker`, tanpa paket kompresi tambahan. TIDAK dipakai untuk foto lapangan (`lapangan.fotoURL` tetap URL, foto lapangan bisa lebih besar/banyak per lapangan).
- Menambah **satu paket baru** ke PRD Bagian 4: `image_picker`.

**Diperluas v1.3 (4 November 2026) — gambar post forum.** Forum (AB-13) memakai pola Base64 yang sama untuk gambar post. Sebelumnya pola ini tertulis "hanya untuk foto profil"; forum memakainya tanpa tercatat, dan hanya batas di layar yang menjaganya. Sekarang tercatat, dan dijaga **tiga lapis** dengan angka yang saling cocok:

| Lapis | Batas | Di mana |
|---|---|---|
| 1. View | gambar mentah ≤ **500 KB** (`512 × 1024` byte), sesudah kompres `image_picker` | `buat_post_screen.dart` (`_batasUkuranGambarBytes`) |
| 2. Repository | string Base64 ≤ **700.000 karakter** | `ForumRepository` (`batasPanjangGambarBase64`), ditolak sebelum dikirim: "Gambar terlalu besar. Pilih gambar yang lebih kecil." |
| 3. Security Rules | string Base64 ≤ **700.000 karakter** saat membuat dan saat pemilik mengedit | `firestore.rules` (`gambarForumAman`, §9) |

Hitungannya: 500 KB mentah = 512.000 byte → Base64 ≈ 682.668 karakter (4/3 kali lipat), di bawah 700.000, dan di bawah batas 1.048.576 byte per dokumen dengan sisa ±350 KB untuk `teks` dan field lain. Satu gambar per post, jadi dokumen tidak bisa menumpuk gambar. Batas teks post belum ada (`teks` tidak dibatasi panjangnya) — post yang sangat panjang tetap bisa mendekati 1 MB; dicatat sebagai keterbatasan.

**Sisa pekerjaan dari keputusan ini (dokumen, bukan kode):** revisi Tabel 3.4 (hapus baris Firebase Storage) dan Bab 2.9 (hapus poin yang menyebut Storage) bersama Pak Gintoro — lihat §14 daftar revisi dokumen skripsi.

**Catatan istilah — jangan tertukar saat menulis ulang Bab 2.9/Tabel 3.4:** "Firebase" adalah nama platform (payung besar), bukan nama basis datanya. Produk yang benar-benar dipakai punya nama sendiri-sendiri: **Cloud Firestore** (basis data NoSQL — ini yang disebut kalau bicara soal "database") dan **Firebase Authentication** (login). **Firebase Storage** adalah produk terpisah lagi (penyimpanan file) yang TIDAK dipakai — jangan sampai kalimat baru malah menyebut "Firebase" secara umum lalu tetap terkesan mencakup Storage.

Draf kalimat pengganti paragraf ke-2 Bab 2.9 (yang saat ini masih menyebut Storage):

> *"Layanan Firebase yang dimanfaatkan dalam penelitian ini meliputi: (1) Cloud Firestore, basis data NoSQL berbasis dokumen yang mendukung sinkronisasi data real-time, sekaligus menyimpan foto profil pengguna dalam format Base64 langsung di dalam dokumen; serta (2) Firebase Authentication, sistem autentikasi pengguna. Firebase Storage sengaja tidak digunakan dalam penelitian ini — foto lapangan disediakan mitra dalam bentuk tautan URL eksternal, bukan diunggah ke penyimpanan cloud — sehingga aplikasi tetap dapat berjalan sepenuhnya pada paket Firebase gratis (Spark), tanpa perlu upgrade ke paket Blaze."*

Tabel 3.4 baris 4 (kategori "Penyimpanan Berkas" / teknologi "Firebase Storage") — paling sederhana dihapus barisnya sekalian, karena tidak ada produk penyimpanan file terpisah yang dipakai (foto profil ikut nempel di baris Cloud Firestore, foto lapangan cukup disebut di teks sebagai URL eksternal, bukan "teknologi" tersendiri).

> **Catatan untuk masa depan:** kalau tim berubah pikiran dan ingin upload foto asli (Opsi B), ini bukan perubahan besar — cukup tambah `image_picker`+`firebase_storage` ke `pubspec.yaml`, ganti `TextFormField` URL di `form_lapangan_screen.dart` jadi pemilih gambar, dan upload ke Storage sebelum `tambahLapangan()`/`perbaruiLapangan()` dipanggil (field `fotoURL` di model sudah `List<String>`, tidak perlu berubah). Butuh paket Blaze aktif (T-00d).

**Catatan praktik (22 September 2026) — host URL mana yang boleh disarankan ke mitra.** Opsi A mengasumsikan mitra tinggal "tempel link yang sudah ada", tapi tiga layanan image-hosting anonim paling populer untuk itu — **PostImages, ImgBB, dan Imgur** — diverifikasi **diblokir di level ISP Indonesia** (kemungkinan Kominfo Trust+ Positif): dicoba dari dua jaringan berbeda, koneksi TLS ke domain-domain itu di-reset/disodori sertifikat palsu, dan baru normal begitu lewat VPN (Cloudflare WARP). DNS tetap resolve benar di semua kondisi, jadi ini pemblokiran DPI berbasis SNI, bukan DNS sinkhole — artinya kemungkinan besar berlaku luas ke pengguna ISP Indonesia lain juga, bukan cuma jaringan yang dites.

**Rekomendasi pengganti: Google Drive.** Mitra upload foto ke Drive → klik kanan file → Share → "Anyone with the link" → salin link (`.../file/d/FILE_ID/view`) → ambil `FILE_ID` → ubah jadi `https://drive.google.com/uc?export=view&id=FILE_ID` → itu yang ditempel ke field "URL Foto". Diverifikasi jalan tanpa VPN (`curl` 200 OK, `content-type: image/webp`) dan tampil benar di Home card maupun Detail Lapangan tanpa perubahan kode (keduanya sudah render `fotoURL` kalau terisi). Tidak mengubah keputusan T-40 (tetap Opsi A, tetap URL eksternal, tetap tanpa Storage) — cuma soal domain mana yang aman disarankan.

**SELESAI (23 September 2026):** seluruh 30 lapangan sudah punya `fotoURL` terisi (foto asli via Google Drive, tiap link diverifikasi `curl` 200 OK sebelum ditempel ke Firestore — status lengkap di `docs/SEED-DATA.md`). Satu bug ditemukan dan diperbaiki dalam prosesnya: `kartu_lapangan.dart` (kartu Home) tidak memberi `height` tetap ke thumbnail, sehingga `IntrinsicHeight` membaca rasio aspek asli foto dan membuat kartu dengan foto berorientasi potret (mis. Hey Beach Padel Club) jadi lebih tinggi dari kartu lain — diperbaiki dengan `height: lebar` tetap di `_Thumbnail`/`_BlokWarna` (commit `ff8e38d`), `flutter analyze`/`flutter test` tetap bersih.

---

## 12c. Rating antar-pengguna — ditunda ke Bab 5

Prototipe Figma menampilkan **"4.9★"** sebagai salah satu dari tiga kotak statistik di layar Profil, yaitu rating **untuk pengguna** — bukan untuk lapangan.

Fitur ini **tidak dibangun**, dan alasannya perlu dipahami karena empat fitur Figma lain justru diterima:

Empat fitur lain (favorit, badge terverifikasi, olahraga favorit, lokasi default) semuanya **memakai data yang sudah ada atau menambah satu field sederhana**. Rating antar-pengguna adalah subsistem baru yang utuh: koleksi baru, aturan siapa boleh menilai siapa dan kapan (hanya setelah bermain bersama? berapa lama jendelanya?), pencegahan penilaian ganda, transaction denormalisasi rata-rata ke dokumen `users`, Security Rules baru, notifikasi baru, dan kasus Black Box baru. Untuk tim tiga orang yang baru belajar Flutter, ini realistis makan 1,5–2 minggu — kira-kira setara seluruh alur reservasi (T-23 sampai T-26) yang sudah dinyatakan wajib.

Dan yang paling menentukan: fitur ini **tidak menjawab satu pun rumusan masalah**. Ketiga rumusan masalah bicara soal menemukan lapangan, menemukan rekan, dan reservasi.

Karena itu kotak statistik ketiga diganti **jumlah favorit** (AB-12), yang datanya sudah tersedia gratis.

Catat rating antar-pengguna di **Bab 5 sebagai saran pengembangan lanjutan**. Kalau ternyata Sprint 4 selesai lebih cepat dari jadwal, ini kandidat pertama untuk ditambahkan — bicarakan dulu dengan Pak Gintoro.

---

## 13. Rujukan ke Skripsi

| Bagian PRD | Sumber di skripsi |
|---|---|
| Masalah & tujuan | Bab 1.1, 1.2, 1.4 |
| Batasan | Bab 1.3 Ruang Lingkup ✅ direvisi di `Highlight_2` (7 Oktober 2026): direktori daring + verifikasi manual Google Maps, tanpa observasi/telepon — lihat §14 "Putaran revisi 2" |
| Haversine | Bab 2.3 |
| OSM & flutter_map | Bab 2.4 |
| Firebase | Bab 2.9 |
| Black Box & SUS | Bab 2.10, 2.11.3 |
| Aktor & fungsi | Bab 3.3.1, Tabel 3.3 |
| Teknologi | Tabel 3.4 |
| Model data | Bab 3.3.2 poin 6, Tabel 3.10 |
| Layar | Bab 3.3.2 poin 5 ✅ direvisi di `Highlight_2` (4 tab, subbab Map/Login/Registrasi/Dashboard Mitra) — gambar masih harus dibuat tim, lihat §14 M1–M9 |

---

## 14. Daftar revisi dokumen skripsi akibat v1.1

Kerjakan bersama Pak Gintoro sebelum Bab 4 ditulis:

| # | Bagian skripsi | Perubahan |
|---|---|---|
| 1 | Bab 3.3.2 poin 5 | Navigasi bawah 3 tab → **4 tab** (Home · Map · Teman · Profil) |
| 2 | Bab 3.3.2 poin 5 | Tambah rancangan layar Login, Register, dan Dashboard Mitra (sudah jadi PR sebelumnya) |
| 3 | Bab 3.3.2 poin 6 / Tabel 3.10 | Tambah atribut `olahragaFavorit` dan `lokasiDefault` pada entitas Users |
| 4 | ERD Bab 3 | Tambah relasi `Users` — `Favorit` — `Lapangan` (many-to-many lewat subkoleksi) |
| 5 | Bab 3 use case | Tambah use case "Simpan Lapangan Favorit" |
| 6 | Bab 4 tabel Black Box | Tambah BB-31 sampai BB-37 |
| 7 | Bab 5 saran | Tambah rating antar-pengguna sebagai pengembangan lanjutan (§12c) |
| 8 | Tabel 3.4, Bab 2.9 | Hapus Firebase Storage dari daftar teknologi — keputusan T-40 (§12b, bukan akibat v1.1, tapi tenggatnya sama: sebelum Bab 4). **Perhatikan kontrasnya dengan poin #10 di bawah:** hanya atribut foto **Users** yang berubah jadi Base64 — atribut `fotoURL` pada entitas **Lapangan** (Tabel 3.10) TIDAK berubah, tetap `List<String>` berisi URL eksternal, jangan ikut direvisi jadi Base64 |

### Tambahan akibat v1.2 (15 September 2026)

| # | Bagian skripsi | Perubahan |
|---|---|---|
| 9 | Bab 3.3.2 poin 6 / Tabel 3.10 | Tambah atribut `nomorTelepon` pada entitas Lapangan |
| 10 | Tabel 3.10 | Ganti nama atribut `fotoProfilURL` → `fotoProfilBase64` pada entitas Users — bukan "selalu null" lagi, opsional, isinya Base64 hasil pilih foto galeri (bukan URL) |
| 11 | Bab 3.3.2 poin 5 (rancangan L-04) | Tambah tombol toggle ♥ Favorit di search bar; hapus rancangan daftar Lapangan Favorit dari L-13 |
| 12 | Bab 3.3.2 poin 5 (rancangan L-05) | Tambah search bar (di luar Figma/PRD awal) |
| 13 | Bab 3 use case / Activity Diagram | Tambah alur "Batalkan Keikutsertaan Aktivitas" (AB-06 lanjutan) |

### Tambahan akibat T-46/T-47/L-01 (15–16 September 2026)

| # | Bagian skripsi | Perubahan |
|---|---|---|
| 14 | Bab 3 use case / Activity Diagram | Tambah use case "Batalkan Booking" (AB-04 lanjutan, T-46) dan "Batalkan Aktivitas oleh Pembuat" (AB-06 lanjutan, T-47) |
| 15 | Bab 4 tabel Black Box | Tambah BB-38 dan BB-39 |
| 16 | Bab 3.3.2 poin 5 (rancangan L-01 Splash Screen) | Splash sekarang **memakai tombol "Mulai Sekarang"** (menunggu ditekan), bukan auto-pindah otomatis seperti draf sebelumnya — kalau Bab 4 sudah menyertakan tangkapan layar/narasi splash auto-pindah, perlu disesuaikan |
| 17 | Bab 4 lampiran tangkapan layar (kalau ada) | Ikon aplikasi (launcher icon) dan gambar splash screen sudah pakai logo asli (`assets/images/logo.jpg`), bukan lagi ikon bawaan Flutter/emoji ⚽ |

### Tambahan akibat T-50 (21 September 2026)

| # | Bagian skripsi | Perubahan |
|---|---|---|
| 18 | Bab 3.3.2 poin 5 (rancangan L-05) | Tambah tombol zoom +/− (di luar Figma/PRD awal), dan sebutkan batas zoom 3–18 yang berlaku untuk tombol, pinch, maupun scroll mouse |
| 19 | Bab 4 tabel Black Box | Tambah BB-40 |

### Tambahan akibat T-51 (21 September 2026)

| # | Bagian skripsi | Perubahan |
|---|---|---|
| 20 | Bab 3.3.2 poin 6 / Tabel 3.10, ERD Bab 3 | Tambah atribut `tautanMaps` pada entitas Lapangan (String, opsional — link Google Maps asli) |
| 21 | Bab 3.3.2 poin 5 (rancangan L-06 Detail Lapangan) | Tambah tombol "Buka di Google Maps" (di luar Figma/PRD awal), berdampingan dengan "Lihat di peta" yang sudah ada — jelaskan bedanya (eksternal vs internal ke tab Map) |
| 22 | Tabel 3.4 (daftar package/dependensi) | Tambah `url_launcher` |
| 23 | Bab 4 tabel Black Box | Tambah BB-41 (tombol "Buka di Google Maps" membuka aplikasi/browser eksternal, hanya tampil kalau `tautanMaps` terisi) |
| 24 | Bab 5 saran / Keterbatasan Penelitian | Tambah keterbatasan: lapangan multi-olahraga (Raw Futsal & Badminton, Taruna Futsal & Badminton) memakai satu nilai harga/jam untuk seluruh jenis olahraga di venue itu — belum ada dukungan harga/jam per jenis olahraga dalam satu lapangan |

### Tambahan akibat koreksi sumber data (1 Oktober 2026)

Klaim "Google Places API" di Bab 1–3 tidak sesuai kenyataan (data dikumpulkan dari direktori booking publik, lalu diverifikasi manual lewat Google Maps di T-51; aplikasi tidak pernah memanggil Places API). Hasil pembacaan `SportSpace_Bab1-3_Revisi_Highlight_1.docx` menemukan klaim itu di 12 tempat. **Ganti semuanya dengan istilah yang sama** ("verifikasi manual melalui Google Maps"); jangan menulis "konfirmasi telepon" sebelum teleponnya benar-benar dilakukan.

| # | Bagian skripsi | Perubahan |
|---|---|---|
| 25 | **Bab 2.5 + Daftar Isi** | Ganti judul "Google Places API" → **"Google Maps sebagai Sumber Verifikasi Data Lapangan"** (jangan dihapus, supaya penomoran 2.6–2.13 dan rujukan silang seperti "Subbab 2.11.2" tidak bergeser). Isi: Google Maps dipakai manual sebagai acuan verifikasi, tanpa API, didukung data kuesioner 39,6% responden memakai Google Maps untuk mencari lapangan. Hapus kalimat "cakupan data luas sejak diluncurkan" |
| 26 | Bab 1.3 poin 1 dan poin 2 (daftar teknologi) | Ganti kalimat sumber data sekunder; hapus baris "Google Places API untuk data lapangan eksternal" dari daftar teknologi |
| 27 | Bab 1.5 poin 2 (Pengumpulan Data) | Ganti "Data sekunder diperoleh dari Google Places API" |
| 28 | **Tabel 3.1, Sprint 3** | "integrasi Google Places API" → pengumpulan, verifikasi, dan seeding data lapangan ke Firestore |
| 29 | Bab 3.1 (3 tempat: paragraf multi-sumber, dan ringkasan "Pengumpulan Data") | Ganti sumber sekunder; kalimat "tidak disediakan oleh Google Places API" juga diganti |
| 30 | Bab 3.2.3 Usulan Solusi 1 | Tertulis "dua sumber" — samakan dengan "tiga sumber" di bagian lain, dan ganti isi sumber sekunder |
| 31 | Bab 3.2.3 narasi Gambar 3.2, Tabel 3.3 fungsi 1 beserta paragraf penjelasnya | Ganti "data gabungan Google Places API, hasil observasi, mitra" dengan istilah baru |
| 32 | **Tabel 3.4 baris 7** | Hapus baris "Data Lapangan Eksternal: Google Places API" (atau ganti jadi data hasil verifikasi manual); sekaligus hapus baris Firebase Storage (lihat #8) |
| 33 | **Bab 3.3.2 poin 4 (Sequence Diagram) + Gambar 3.8** | Hapus Google Places API sebagai partisipan yang "dipanggil" — **gambar harus digambar ulang**. Periksa juga isi gambar 3.2 dan 3.5 (teks di dalam gambar tidak terbaca saat review) |
| 34 | Tabel 3.9 (elemen halaman Profile), baris Menu Pengaturan | Hapus "Bahasa" — multi-bahasa di luar ruang lingkup (§2.2) |

Catatan dari diskusi sebelumnya yang belum tercatat di tabel atas:

| # | Bagian skripsi | Perubahan |
|---|---|---|
| 35 | Tabel 3.10 (ERD) | Gabung entitas `Users` dan `PemilikLapangan` jadi satu entitas `Users` dengan atribut `role` (keputusan 15 September 2026: kode tidak dipecah, dokumen yang disesuaikan). Sesuai Catatan pemetaan ke ERD di §6 |
| 36 | Bab 3.3.2 poin 5 + Tabel 3.6 | Halaman Map ditambahkan sebagai halaman tersendiri berlabel **"Cari Lapangan"**, berbeda dari Detail Lapangan (gabungan dengan #1) |
| ~~37~~ | ~~Bab 3 use case / Activity Diagram~~ | ~~Daftar aktivitas Cari Rekan pada Detail Lapangan (T-53)~~ — **gugur 8 Oktober 2026: T-53 dibatalkan**, tidak perlu diagram baru |

### Tambahan akibat Forum (4 November 2026) — **hanya kalau forum diputuskan masuk skripsi**

> **Arah sudah condong ke (b) — 5 November 2026.** Pak Gintoro menyebut forum sebagai fitur pemanis dan hanya modul besar yang perlu masuk Bab 3 (lihat "Perubahan v1.4"). Jadi #38–#44 **tidak perlu dikerjakan**, kecuali tim memutuskan lain. Jalur (b) di bawah yang berlaku sampai ada keputusan resmi.

Dua jalur:

- **(a) Forum masuk Bab 3–4:** kerjakan #38–#44 di bawah.
- **(b) Forum tidak masuk Bab 3–4:** #38–#44 tidak dikerjakan. Tulis forum di Bab 5 sebagai pengembangan lanjutan, dan di Bab 4 sebutkan bahwa tab Forum ada di aplikasi tetapi di luar ruang lingkup pengujian. Putaran revisi 2 menuliskan **4 tab** — tangkapan layar Bab 4 akan menunjukkan 5, jadi kalimat itu tetap perlu disesuaikan.

| # | Bagian skripsi | Perubahan |
|---|---|---|
| 38 | Bab 3.3.2 poin 5 + Tabel 3.4 (narasi navigasi) | Navigasi bawah 4 tab → **5 tab** (Home · Map · Teman · Profil · Forum) — menggantikan keputusan label tab putaran revisi 2 |
| 39 | ERD Bab 3 / Tabel 3.10 | Tambah entitas `ForumPost` (`userId`, `namaUser`, `teks`, `gambarBase64`, `jumlahKomentar`, `createdAt`, `dieditPada`) dan `ForumKomentar` (subkoleksi) — ERD jadi 10 entitas. Sesuai §6.10–6.11 |
| 40 | Bab 3 use case / Activity Diagram | Tambah use case "Membuat, Mengedit, dan Menghapus Post Forum" dan "Berkomentar di Forum" |
| 41 | Bab 3.3.2 UI | Tambah subbab rancangan Forum (L-16 daftar, L-17 buat/edit, L-18 detail) beserta tabel elemennya |
| 42 | Tabel 3.4 / Bab 2.9 | Kalimat "Cloud Firestore ... menyimpan foto profil pengguna dalam format Base64" → tambah "dan gambar post forum" (§12b) |
| 43 | Bab 4 tabel Black Box | Tambah BB-42 sampai BB-49 |
| 44 | Bab 5 keterbatasan | Komentar tidak bisa diedit/dihapus satuan; Security Rules forum punya satu titik longgar (penghitung komentar, §9); teks post tidak dibatasi panjangnya; gambar forum Base64 dibatasi 500 KB per post |

### Tambahan akibat v1.4 (5 November 2026) — fitur tambahan tahap 1

Sesuai arahan Pak Gintoro (fitur pemanis tidak perlu masuk Bab 3), tidak ada use case, activity diagram, atau subbab rancangan baru. Yang perlu disesuaikan hanya yang bisa terlihat penguji:

| # | Bagian skripsi | Perubahan |
|---|---|---|
| 45 | ERD Bab 3 / Tabel 3.10, entitas `AktivitasBermain` | Tambah tiga atribut `jenisAktivitas`, `tingkatKemampuan`, `biayaPerOrang` (§6.3). **Buat ERD (M1) setelah ini final**, supaya tidak digambar dua kali. Alternatifnya, biarkan ERD dan sebutkan ketiganya di Bab 4 sebagai tambahan di luar rancangan awal |
| 46 | Bab 4 (implementasi) | Satu paragraf: fitur lencana pencapaian dan tombol WhatsApp/bagikan ada di aplikasi sebagai tambahan di luar rancangan awal. Tangkapan layar Profil dan Detail Lapangan akan menampilkannya |
| 47 | Bab 4 tabel Black Box | Tambah BB-50 sampai BB-61 bila tim ingin mengujinya di skripsi; kalau tidak, cukup tulis di Bab 4 bahwa fitur tambahan di luar ruang lingkup pengujian |
| 48 | Bab 5 saran dan keterbatasan | Fitur AYO tahap 2 dan 3 (sort/filter Home, blokir slot, reschedule, promo, aktivitas privat, pengingat) sebagai pengembangan lanjutan. Biaya per orang hanya informasi, tanpa pembayaran. Filter jenis dan tingkat di klien tidak efisien untuk daftar yang sangat besar |

### Tambahan akibat v1.5 (5 November 2026) — fitur tambahan tahap 2 dan 3

Sama seperti v1.4: fitur pemanis, tanpa use case atau diagram baru.

| # | Bagian skripsi | Perubahan |
|---|---|---|
| 49 | ERD Bab 3 / Tabel 3.10 | Entitas `Lapangan` +`diskonPersen`, +`produkTambahan` (larik). Entitas `Booking` +`produkTambahan` (larik). Entitas `AktivitasBermain` +`visibilitas`, +`kodeAkses` (selain tiga atribut v1.4). Sesuai §6.2, §6.3, §6.6. **Gambar ERD (M1) setelah semua ini final** |
| 50 | Bab 3.2 / pembahasan pengurutan hasil pencarian | AB-02 tetap benar: urutan **bawaan** murni jarak. Tambahkan satu kalimat bahwa pengguna boleh memilih urutan rating atau populer, dan itu tidak mengubah rancangan Haversine |
| 51 | Bab 4 | Tambahkan ke paragraf fitur tambahan (#46): filter dan urut Home, blokir slot, promo, produk tambahan, ubah jadwal, aktivitas privat |
| 52 | Bab 4 tabel Black Box | Tambah BB-62 sampai BB-104 bila tim ingin mengujinya di skripsi; kalau tidak, tulis bahwa fitur tambahan di luar ruang lingkup pengujian |
| 53 | Bab 5 keterbatasan dan saran | Aktivitas privat hanya disembunyikan dari daftar, bukan dilindungi Security Rules. Promo dan produk tambahan hanya informasi tanpa pembayaran. Balasan mitra (T-66, sudah dikerjakan) tidak bisa dihapus dan tidak memberi notifikasi ke pengguna. Pengingat jadwal (T-67, sudah dikerjakan) hanya terjadwal saat aplikasi terbuka dan boleh terlambat beberapa menit karena alarm tidak-tepat-waktu |
| 56 | Bab 1 batasan masalah (jika menyebut mode gelap) dan Bab 3 perancangan antarmuka | Mode gelap (T-68) kini ada; Bab 3 menyatakan tampilan mengikuti Figma yang hanya punya mode terang. Tulis bahwa mode terang = Figma dan mode gelap = turunan, dengan palet di §AB-24. Peta tetap terang (keterbatasan, Bab 5) |
| 55 | Bab 3 teknologi / Bab 4 implementasi (daftar package) | Tiga package baru: `flutter_local_notifications`, `timezone`, `shared_preferences` (§4). Notifikasi ini **lokal di HP**, bukan Firebase Cloud Messaging — penting dijelaskan karena Bab 3 menyatakan notifikasi dibuat in-app lewat Firestore listener. Konfigurasi Android (desugaring, izin, receiver) ikut berubah |
| 54 | Bab 3 ERD dan 3.3.2 (atribut `rating`) | Entitas `rating` bertambah dua atribut: `balasanMitra` dan `balasanPada` (T-66). Gambar ERD sebaiknya dibuat setelah atribut ini final, atau keduanya disebut "tambahan di luar rancangan awal". Security Rules `rating` juga berubah (dua jalur `update`, §9) |

**Draf isi Bab 2.5 baru (siap salin, sesuaikan sesuai kebutuhan):** — ⚠️ *digantikan 7 Oktober 2026: versi final di `Highlight_2` tidak lagi menyebut observasi langsung maupun konfirmasi telepon, lihat "Putaran revisi 2" di bawah.*

> Google Maps adalah layanan pemetaan dari Google yang memuat informasi tempat, antara lain nama, alamat, koordinat geografis, nomor telepon, jam operasional, foto, serta rating dan ulasan dari pengguna. Pada penelitian ini, Google Maps tidak diakses melalui Application Programming Interface (API) dan tidak dipanggil oleh aplikasi, melainkan digunakan secara manual oleh peneliti sebagai acuan verifikasi data lapangan. Pemilihan Google Maps didasarkan pada kebiasaan pengguna sasaran: berdasarkan kuesioner penelitian ini, 39,6% dari 101 responden menggunakan Google Maps untuk mencari lapangan olahraga.
>
> Data lapangan non-mitra dikumpulkan dari sumber daring publik, kemudian diverifikasi satu per satu oleh peneliti melalui Google Maps, yaitu koordinat lokasi, nomor telepon, dan tautan lokasi. Atribut yang tidak tersedia pada Google Maps, seperti harga sewa dan fasilitas, dilengkapi melalui observasi langsung peneliti [dan konfirmasi telepon ke pengelola lapangan — hapus bagian ini kalau teleponnya belum dilakukan]. Seluruh data kemudian dimuat ke Firebase Firestore melalui proses akuisisi data awal (*seeding*), sehingga saat aplikasi berjalan tidak ada ketergantungan pada layanan pihak ketiga.

Nilai string `sumberData: "places_api"` di kode sengaja belum diganti (menghindari reseed Firestore); kalau kelak diganti, usulan namanya `"google_maps_manual"`. — *Diperbarui 19 Oktober 2026: sudah diganti jadi `"direktori_daring"` (menggantikan `"places_api"` **dan** `"observasi"` sekaligus) — lihat catatan di §10.*

---

### Putaran revisi 2 — SELESAI dibuat drafnya (7 Oktober 2026)

Hasilnya: **`SportSpace_Bab1-3_Revisi_Highlight_2.docx`** (di folder Downloads pemilik proyek, di luar repo). Sekarang ini **file skripsi terbaru**; `Highlight_1` disimpan sebagai arsip, tidak diubah. Stabilo putaran 1 sudah dibersihkan, dan **semua perubahan putaran 2 diberi stabilo kuning** supaya Pak Gintoro langsung melihat bagian yang berubah.

**Keputusan yang dipakai (menggantikan catatan lama di atas kalau bertentangan):**

| Topik | Keputusan | Menggantikan |
|---|---|---|
| Sumber data lapangan | **Dua sumber**: (1) sekunder = direktori pemesanan lapangan daring publik, diverifikasi manual melalui Google Maps; (2) primer = lapangan mitra. Harga/jam/fasilitas lapangan non-mitra ditulis sebagai **estimasi**. Klaim "Google Places API" **dan** "observasi langsung peneliti" dihapus seluruhnya, karena T-00e (survei) tidak pernah dilakukan. Frasa "konfirmasi telepon" **tidak** dipakai (telepon belum dilakukan) | Draf Bab 2.5 di atas (masih menyebut observasi); catatan #30 ("tiga sumber") |
| Favorit | Favorit, olahraga favorit, dan lokasi default **tidak disebut sama sekali di Bab 3** (ERD, use case, tabel UI), karena tidak terkait rumusan masalah | #3, #4, #5, #11 — dibatalkan |
| Label tab | Mengikuti aplikasi: **Home · Map · Teman · Profil**, tanpa rename "Cari Lapangan" | Label di #36 |
| Gambar | Gambar lama tidak diedit; diberi **kotak kuning bergaris putus-putus** berisi instruksi gambar ulang | — |

**Rangkuman perubahan yang sudah masuk ke docx:**

| Bab | Perubahan |
|---|---|
| Bab 1 | 1.3: sumber data jadi dua sumber + kalimat estimasi untuk lapangan non-mitra; baris "Google Places API" dihapus dari daftar teknologi. 1.5: "Tabel 1.1" → "Tabel 2.6"; pengumpulan data tanpa observasi dan Places API |
| Bab 2 | Daftar Isi + judul/isi 2.5 → "Google Maps sebagai Sumber Verifikasi Data Lapangan" (2 paragraf). 2.9: Firebase Storage dihapus, diganti foto profil Base64 di Firestore + foto lapangan URL eksternal (paket Spark) |
| Bab 3.1–3.2 | Tabel 3.1 Sprint 3; paragraf multi-sumber; ringkasan "Pengumpulan Data"; 3.2.2 (tanpa "observasi lapangan"; ketersediaan slot hanya lapangan mitra; pembatalan pemesanan); 3.2.3 Usulan Solusi 1 dan narasi Gambar 3.2 |
| Bab 3.3.1 | Tabel 3.3 fungsi 1/3/5 (sumber data + fitur pembatalan); narasi fungsi pencarian; Tabel 3.4: hapus Firebase Storage dan Google Places API, tambah baris "Paket Pendukung Flutter" (geolocator, url_launcher, image_picker), Firestore menyimpan foto profil Base64 |
| Bab 3.3.2 diagram | Narasi Use Case (pembatalan + mitra = Users ber-role mitra); narasi Class Diagram (+PermintaanGabungModel, NotifikasiModel); narasi Sequence Diagram (partisipan View/ViewModel/Repository/LocationService, Haversine dihitung di ViewModel, ChangeNotifier) |
| Bab 3.3.2 UI | Pembuka: 6 halaman utama + 3 halaman pendukung, navigasi 4 tab. Splash pakai tombol "Mulai Sekarang". Tabel Home (hapus Logo, tambah Ikon Notifikasi, chip "Semua", 4 tab). **Subbab baru**: c. Map, g. Login, h. Registrasi, i. Dashboard Mitra (masing-masing narasi + tabel elemen). Tabel Detail Lapangan dan Profil ditulis ulang sesuai aplikasi; Tabel Cari Rekan disesuaikan istilah "aktivitas" |
| Bab 3.3.2 ERD | Tabel ERD jadi **8 entitas**: Users (gabungan Users + PemilikLapangan, atribut `role`, `nomorTelepon`, `fotoProfilBase64`), Lapangan (+`alamat`, `jenisOlahraga[]`, `nomorTelepon`, `tautanMaps`, `pemilikId`), AktivitasBermain, **PermintaanGabung**, Rating, Booking, **SlotBooking**, **Notifikasi**; paragraf penjelasan ikut diperbarui |
| Penomoran | Subbab UI jadi a–i. Gambar 3.12 (Map) baru, Detail/Cari Rekan/Profil → 3.13/3.14/3.15, Login/Registrasi/Dashboard → 3.16/3.17/3.18, ERD → 3.19. Tabel 3.7 (Map) baru, Detail/Cari Rekan/Profil → 3.8/3.9/3.10, Login/Registrasi/Dashboard → 3.11/3.12/3.13, ERD → 3.14 |
| Tata letak (bukan isi) | 10 gambar Bab 3 yang semula "mengambang" (diikat ke posisi halaman) dijadikan sejajar teks, rata tengah, tepat di atas caption-nya, supaya tidak terlepas dari caption saat teks bergeser. Judul tabel diberi *keep with next* |

**Yang masih harus dikerjakan MANUAL oleh tim** (Claude tidak bisa/tidak boleh mengerjakan):

| # | Pekerjaan | Keterangan |
|---|---|---|
| M1 | **Buat ERD sungguhan — Gambar 3.19** | **Paling penting.** Gambar 3.15 lama ternyata salinan Class Diagram, jadi skripsi belum punya ERD. Isi dan notasinya ada di kotak kuning |
| M2 | Gambar ulang Gambar 3.5 (Activity Pencarian Lapangan) | Gambar lama berisi alur cari rekan, salah isi |
| M3 | Gambar ulang Gambar 3.7 (Class Diagram) | Ikuti narasi + kode (Model/ViewModel/Repository), hapus "User extends LBSService" |
| M4 | Perbarui Gambar 3.8 (Sequence Pencarian Lapangan) | Hapus partisipan Google Places API |
| M5 | Perbarui Gambar 3.1 (Kerangka Berpikir) | "Google Places API" → direktori daring + Google Maps; "OSMDroid" → "flutter_map" |
| M6 | Perbarui Gambar 3.4 (Use Case) | Tambah Batalkan booking / Batalkan aktivitas / Batalkan keikutsertaan |
| M7 | Buat rancangan Figma: Map (3.12), Login (3.16), Registrasi (3.17), Dashboard Mitra (3.18) | Elemen sesuai tabel masing-masing |
| M8 | Perbaikan kecil: Gambar 3.2 ("Harvesine"), 3.9 ("notif push", "Buka Halaman Kerja"), 3.11 (hapus peta di Home), 3.13 (hapus "Pilih Slot", tombol "Ajukan Reservasi"), 3.15 (hapus "4.9★ Rating", menu Profil) | Instruksi rinci di tiap kotak kuning |
| M9 | Hapus 15 kotak kuning setelah gambarnya diganti | — |
| M10 | Perbarui nomor halaman **Daftar Isi** secara manual | Daftar Isi diketik manual (bukan field Word), jadi tidak bisa di-*Update Field* |
| M11 | Tambah sitasi untuk Bab 2.5 (Google Maps) kalau diminta pembimbing | Sengaja dibiarkan tanpa sitasi, jangan mengarang referensi |
| M12 | Konsultasikan seluruh revisi dengan Pak Gintoro, lalu hapus stabilo kuning setelah disetujui | — |
| M13 | Bab 4: tulis bahwa 5 lapangan mitra di data uji adalah **simulasi** (akun mitra uji); Bab 4/5: butir #6, #7, #15, #17, #19, #23, #24 di atas | Belum ada Bab 4–5 di file ini |

**Tindak lanjut di kode — SELESAI 7 Oktober 2026:** badge "🏅 Terverifikasi" dihapus dari Detail Lapangan (AB-11, BB-33/BB-34 diperbarui). Catatan asal: "🏅 Terverifikasi" (`sumberData == "observasi"`, AB-11/BB-33) tidak lagi benar setelah klaim observasi dihapus. Badge dan nilai `sumberData` perlu disesuaikan, sekaligus definisi di §6.2/§10 dan AB-11.
