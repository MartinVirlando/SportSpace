# Sisa Revisi Skripsi Bab 1–3

Disusun 16 November 2026, diperbarui 21 November 2026.

**File terbaru: `SportSpace_Revisi Bab 1-3 Highlight hijau_3.docx` (21 November 2026).** Mulai sekarang, sunting file ini.
- `_3` dibuat dari `_2`. `_2` sendiri dibuat dari file revisi Martin (`SportSpace_Revisi Bab 1-3 Highlight hijau.docx`, 11 November 2026).
- File Martin dan `_2` tidak diubah, jadi keduanya bisa dipakai sebagai pembanding.
- Semua perubahan baru di `_2` dan `_3` distabilo hijau.

**Keputusan 21 November 2026: Forum masuk skripsi (jalur a)**, sudah disetujui Pak Gintoro.

**Status:** semua teks Bab 1–3 sudah dicocokkan dengan kode aplikasi (bagian 1). Yang tersisa hanya pekerjaan manual (bagian 2) dan Bab 4–5 (bagian 3). Nomor dalam kurung merujuk ke `PRD.md` §14.

---

## Sebelum mulai (wajib dibaca, termasuk oleh asisten AI)

### Yang sengaja TIDAK diubah
Bagian berikut terlihat "kurang" bila dibandingkan dengan aplikasi, tetapi memang keputusan tim. Jangan ditambahkan atau diubah:

- **Favorit, olahraga favorit, dan lokasi default** tidak disebut di Bab 3 (ERD, use case, tabel UI). Itu sebabnya statistik Profil di Tabel 3.10 hanya menyebut pemesanan dan aktivitas, walaupun aplikasi juga menampilkan jumlah favorit.
- **Fitur pemanis tidak dijadikan use case, diagram, atau subbab baru di Bab 3** (arahan Pak Gintoro, 5 November 2026): lencana, WhatsApp dan bagikan, filter dan urutkan Home, blokir slot, promo, produk tambahan, ubah jadwal, aktivitas privat, balasan mitra, pengingat jadwal, mode gelap, cari rekan dari booking, riwayat main. Yang sudah tertulis dipertahankan, tetapi jangan ditambah lagi.
- **Pengecualian: Forum.** Sejak 21 November 2026 Forum masuk skripsi, lengkap dengan use case, rancangan layar, dan entitas ERD. Activity Diagram Forum **sengaja tidak dibuat**, karena fitur rating pun tidak punya.
- **Navigasi bawah 5 tab:** Home · Map · Teman · Profil · Forum.
- **Sumber data:** direktori pemesanan daring yang diverifikasi manual melalui Google Maps, ditambah lapangan mitra. Jangan menulis Google Places API, observasi langsung, maupun konfirmasi telepon.
- **Urutan bawaan hasil pencarian murni jarak (Haversine).** Rating hanya informasi.
- **Firebase Storage tidak dipakai.** Foto lapangan berupa URL eksternal. Foto profil dan gambar post forum disimpan sebagai Base64 di Firestore.
- **Nama atribut** ditulis persis seperti di kode (`lapanganId`, `jamBuka`, `peserta`, dan seterusnya; `createdAt` pada Forum memang berbahasa Inggris di kode).
- **Rating antar-pengguna, chat, dan payment gateway** tidak dibangun. Forum bukan chat.

### Aturan saat menyunting docx
1. Jangan mengubah atau menghapus gambar, kecuali saat menempel gambar pengganti (setelah itu hapus kotak kuningnya).
2. Jangan menghapus stabilo sebelum disetujui Pak Gintoro.
3. Jangan mengarang atau mengganti referensi tanpa membuka sumber aslinya.
4. Beri stabilo hijau pada setiap teks yang diubah atau ditambah, dan simpan sebagai file baru.

---

## 1. Sudah dikerjakan (21 November 2026)

### 1a. File `_2`: Forum dan sisa revisi teks

| Bagian | Perubahan |
|---|---|
| Bab 1.3 | Forum komunitas sebagai fitur pendukung; forum publik, bukan percakapan pribadi; foto profil dan gambar post forum sebagai Base64 |
| Bab 2.9 | Kalimat Base64 (dua tempat): foto profil dan gambar post forum |
| Tabel 3.1 | Sprint 4 ditambah forum komunitas |
| 3.2.2 | Kebutuhan fungsional ke-8: forum komunitas |
| 3.3.1 | Deskripsi jenis pengguna; "enam fungsi utama"; Tabel 3.3 baris 6 Forum Komunitas; narasi fungsi forum |
| Tabel 3.4 | Firestore dan image_picker menyebut gambar post forum; kalimat OSM dirapikan |
| Use case dan Class Diagram | Narasi dan kotak Gambar 3.4 dan 3.7 ditambah Forum |
| Rancangan UI | Paragraf pembuka, Tabel 3.6 dan 3.7, serta kotak 3.11 dan 3.12: navigasi 5 tab |
| **Subbab j (baru)** | Perancangan Halaman Forum: Gambar 3.19–3.21 (kotak "GAMBAR BELUM ADA") dan Tabel 3.14–3.16 |
| ERD | **Nomor bergeser:** Gambar 3.19 → **3.22**, Tabel 3.14 → **3.17**. Ada 10 entitas, termasuk atribut salinan nama dan `diblokirOleh`, ditambah paragraf penjelasan denormalisasi |
| Kotak gambar | Isi kotak 3.15 diganti; kotak baru di bawah Gambar 3.3, 3.6, dan 3.14 |

### 1b. File `_3`: semua teks dicocokkan dengan kode

Yang dicocokkan:
- setiap nama kelas dan metode di Bab 3;
- setiap atribut Tabel 3.17 terhadap data yang disimpan model ke Firestore;
- setiap baris Tabel 3.5–3.13 terhadap layar aplikasi;
- narasi alur, sequence, dan klaim Bab 1–2 tentang aplikasi.

Yang ternyata tidak cocok, lalu dibetulkan:

| Letak | Sebelum → sesudah |
|---|---|
| Tabel 3.6 (Header Home) | "lokasi saat ini" → "nama wilayah penelitian (Tangerang Selatan)", sesuai teks tetap di aplikasi. Kotak 3.11 ditambah keterangan header |
| Tabel 3.8 (Nama & Rating) | "jarak dari posisi pengguna" dihapus: layar Detail Lapangan tidak menampilkan jarak |
| Tabel 3.8 dan kotak 3.13 | Label tombol "Lihat di Peta" → "Lihat di peta" (sama dengan aplikasi) |
| Tabel 3.9 (Form Buat Aktivitas) | Ditambah jenis aktivitas, tingkat kemampuan, dan biaya per orang (opsional) |
| Tabel 3.10 (Menu Informasi) | "Tentang Aplikasi" → "Tentang" |
| Kotak Gambar 3.8 | Partisipan `HomeView` → `HomeScreen` (nama kelas sebenarnya) |
| Narasi Class Diagram | Haversine "pada kelas utilitas" → "fungsi utilitas tersendiri, yaitu `hitungJarakHaversine()`" |
| Narasi Gambar 3.2 | Marker membuka kartu ringkas; detail dibuka lewat tombol "Lihat" |
| Bab 2.8 dan 2.10 | Daftar data ERD dan daftar fitur yang diuji Black Box ditambah forum |
| Bab 2.12 | Nama menu persis: "Filter & Urutkan" |
| Referensi | "Puryanto et al." → "Puryanto dan Akbar (2025)" di teks dan daftar pustaka; Hermawan & Suharso ditambah halaman 1971–1981 dan DOI; Atsani et al. ditambah halaman 41–54 |

Hasil pemeriksaan: Word membuka `_3` tanpa pesan perbaikan; 93 halaman; semua gambar tidak berubah; diff teks hanya berisi perubahan di atas.

---

## 2. Pekerjaan manual yang tersisa (Bab 1–3)

### 2.1 Gambar: diagram dan rancangan Figma
Instruksi rinci ada di kotak kuning masing-masing gambar (21 kotak).

| Prioritas | Gambar | Pekerjaan | PRD |
|---|---|---|---|
| 1 | **3.22 ERD** (dulu 3.19) | **Buat ERD sungguhan, 10 entitas sesuai Tabel 3.17.** Gambar sekarang salinan Class Diagram | M1, #39 |
| 2 | 3.5 Activity Pencarian Lapangan | Ganti total (isinya alur cari rekan) | M2 |
| 2 | 3.7 Class Diagram | Gambar ulang sesuai Model/ViewModel/Repository, termasuk kelas Forum | M3 |
| 2 | 3.8 Sequence Pencarian Lapangan | Hapus Google Places API; partisipan `HomeScreen`, `HomeViewModel`, `LocationService`, `LapanganRepository` | M4 |
| 2 | 3.14 Rancangan Cari Rekan | Chip, FAB, isi kartu, navigasi 5 tab | #58 |
| 2 | **3.19 Forum, 3.20 Buat/Edit Post, 3.21 Detail Post** | Buat rancangan Figma baru | #41 |
| 3 | 3.1 Kerangka Berpikir | Sumber data dan "OSMDroid" → "flutter_map" | M5 |
| 3 | 3.4 Use Case | Tiga use case pembatalan + dua use case Forum | M6, #40 |
| 3 | 3.9 Sequence Pencarian Rekan | Ganti "Buka Halaman Kerja" dan "notif push" | M8 |
| 3 | 3.2 Flowchart Pencarian Lapangan | Ejaan "Harvesine" (2 tempat) | M8 |
| 3 | 3.11 Home, 3.13 Detail Lapangan, 3.15 Profile | Perbaikan rancangan Figma; header Home dan navigasi 5 tab | M8 |
| 3 | 3.12 Map, 3.16 Login, 3.17 Registrasi, 3.18 Dashboard Mitra | Buat rancangan Figma baru | M7 |
| 4 | 3.3 Flowchart dan 3.6 Activity Pencarian Rekan | Disarankan, lihat kotaknya | — |

### 2.2 Klaim tentang Anantha Sekoh et al. (2025), dulu tertulis "Mutia et al."
**Sudah dikerjakan di `_3` (21 November 2026):** nama penulis diganti di keenam tempat:
- Bab 1.1;
- Bab 2.13.1;
- Tabel 2.6;
- Tabel 3.2;
- Bab 3.2.2;
- daftar pustaka.

Entri daftar pustaka dipindah ke urutan abjad (setelah Alkodri) dan dilengkapi volume 269, halaman 1220–1228, serta DOI 10.1016/j.procs.2025.09.063. Data penulisnya dari Crossref dan OpenAlex. Para penulis berasal dari BINUS Online.

**Masih perlu dicek manual.** Teks lengkap artikel tidak bisa dibuka otomatis (ScienceDirect menolak akses), jadi pengecekan baru berdasarkan abstrak. Silakan unduh PDF-nya dari ScienceDirect (terbuka, CC BY-NC-ND) lalu cek:

| Letak | Klaim di skripsi | Hasil cek ke abstrak | Usulan bila tidak didukung teks lengkap |
|---|---|---|---|
| Bab 1.1 dan Bab 3.2.2 | Kesulitan menghubungi venue menurunkan minat berolahraga | **Didukung** | — |
| Bab 2.13.1 | "membuktikan bahwa … secara signifikan meningkatkan partisipasi olahraga pengguna dan mengurangi kendala akses ke fasilitas" | **Sebagian didukung.** Kata "signifikan" di abstrak dipakai untuk efisiensi pengelolaan jadwal, bukan partisipasi. Temuan partisipasi berasal dari wawancara 20 responden | "… melalui wawancara terhadap 20 responden menemukan bahwa aplikasi booking lapangan meningkatkan efisiensi pengelolaan jadwal, dan kemudahan akses mendorong partisipasi olahraga, …" |
| Tabel 2.6 kolom Metode/Teknologi | "Mobile App, LBS, Cloud Backend" | **Belum terbukti.** Abstrak hanya menyebut aplikasi mobile, metode agile, dan wawancara | "Mobile App, Agile, wawancara 20 responden" |
| Tabel 2.6 kolom Keterbatasan | "tidak multiolahraga" | **Belum terbukti.** Abstrak menyebut "sports field" secara umum | Hapus "tidak multiolahraga" kalau teks lengkap ternyata mendukung banyak olahraga |
| Tabel 3.2 kolom Anantha Sekoh et al. | LBS ✓, Informasi terpusat ✓, Rating ✗ | **Belum terbukti** dari abstrak | Sesuaikan tanda ✓/✗ dengan isi artikel |

Opsional: tautan Google Cloud (n.d.) dialihkan ke https://docs.cloud.google.com/firestore/quotas.

### 2.3 Daftar Isi dan judul Bab 5
- Perbarui nomor halaman Daftar Isi secara manual (M10). Dokumen bertambah dari 88 ke 93 halaman. Daftar Isi hanya sampai 3.3.2, jadi subbab j tidak perlu ditambahkan, tetapi nomor halaman 3.3.2 dan Daftar Pustaka berubah.
- Di Bab 1.6 (Sistematika Penulisan), ganti "BAB 5 KESIMPULAN DAN SARAN" menjadi **"BAB 5 SIMPULAN DAN SARAN"** supaya sesuai template kampus.

### 2.4 Konsultasi, lalu hapus kotak dan stabilo
1. Konsultasikan semua revisi ke Pak Gintoro (M12). Kirim file `_3` yang masih berstabilo, supaya beliau bisa melihat apa saja yang berubah.
2. Hapus setiap kotak kuning setelah gambar penggantinya ditempel (M9).
3. **Hapus stabilo kuning dan hijau setelah disetujui** (M12). Di Word: pilih semua (Ctrl+A), lalu Home → Text Highlight Color → **No Color**.
4. Bila pembimbing meminta: sitasi untuk definisi Google Maps di paragraf pertama 2.5 (M11). Jangan mengarang referensi.

### 2.5 Perbaikan kode: atribusi OpenStreetMap di peta
**Sudah dikerjakan (21 November 2026), belum di-commit.**
- `map_screen.dart` kini menampilkan "flutter_map | © OpenStreetMap contributors" di pojok kiri bawah peta.
- Atribusi ikut naik saat kartu ringkas muncul, supaya tidak tertutup.
- Mengetuknya membuka `openstreetmap.org/copyright`.
- Teks atribusi ada di `AppStrings.atribusiOsm`.
- `flutter analyze` bersih dan `flutter test` lulus (272 tes).

Sudah dicek di emulator (21 November 2026):
- Atribusi tampil di mode terang dan mode gelap.
- Saat kartu ringkas muncul, atribusi ikut naik dan tidak tertutup.
- Ketukan pada atribusi membuka `openstreetmap.org/copyright` di Chrome.

Sisa langkah manual:
- Commit di cabang tersendiri, misalnya `fitur/atribusi-osm`.
- Bila tangkapan layar Map untuk Bab 4 sudah diambil sebelumnya, ambil ulang supaya atribusinya ikut terlihat.

---

## 3. Bab 4–5

Panduan lengkap Bab 4–5 ada di **`docs/PANDUAN-BAB-4-5.md`**. Isinya:
- kerangka sesuai template kampus;
- spesifikasi sistem;
- daftar tangkapan layar;
- pemetaan delapan aturan emas;
- kasus Black Box yang dimasukkan;
- prosedur SUS;
- bukti untuk simpulan;
- daftar keterbatasan dan saran.

Daftar Bab 4–5 yang dulu ada di bagian ini sudah dipindah ke panduan itu.
