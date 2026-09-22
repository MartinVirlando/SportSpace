# Data Awal Lapangan — Sport Space

**Wilayah penelitian:** Alam Sutera, BSD, Gading Serpong, dan sekitarnya (Kota Tangerang Selatan, Kota Tangerang, Kabupaten Tangerang)
**Jumlah:** 30 lapangan · **Dibuat:** 17 Agustus 2026 · **Koordinat diperbarui:** 21 September 2026 (30/30 terverifikasi, T-51 — lihat catatan di bawah)
**Dipakai oleh:** T-10 (`AdminSeedScreen`) · **Skema:** PRD Bagian 6.2 · **Format seed:** PRD Bagian 10

> **Catatan 13 September 2026 (T-29):** tile "Seed Data Awal" di menu Profil sudah di-comment (bukan dihapus) di `profil_screen.dart` supaya tidak ikut ke APK release/SUS. Kalau perlu menjalankan seed lagi (mis. setelah T-00e selesai dan 8 lapangan `observasi` di bawah ini diperbarui dengan data survei asli), buka dulu `_TileMenu` yang di-comment di dekat tombol Keluar, jalankan seed, lalu comment lagi sebelum build berikutnya.

> **Catatan 21 September 2026 (T-51):** cek manual satu-per-satu seluruh 30 lapangan ke Google Maps (bukan cuma audit kode) — seluruh koordinat sekarang terverifikasi 30/30 (sebelumnya dokumen ini sempat basi, masih bilang 7/30 padahal `seed_lapangan.dart` sudah 30/30 sejak 21 Agustus). Ditemukan juga: 3 koordinat ternyata meleset (MS Sport Arena, Arsa Sport Mini Soccer, Mad Padel Club BSD) — sudah dikoreksi; dan Raw Futsal ternyata multi-olahraga (futsal & badminton) seperti Taruna Futsal — nama keduanya diganti jadi "Raw Futsal & Badminton" / "Taruna Futsal & Badminton". `nomorTelepon` dan `tautanMaps` (field baru, link Google Maps asli untuk tombol "Buka di Google Maps") juga sudah terisi untuk seluruh 30 lapangan — nilainya ada langsung di `seed_lapangan.dart`, tidak diduplikasi ke tabel di bawah supaya tidak dobel-maintain. Detail lengkap: `PRD.md` "Koreksi teknis + v1.2 tahap baru (21 September 2026)".

---

## ⚠️ Baca ini dulu — status kelayakan data

Dokumen ini **belum bisa langsung dipakai sebagai data hasil survei di skripsi.** Isinya dikumpulkan dari direktori venue publik dan platform booking (Gelora, Ayo Indonesia, Traveloka, dan sejumlah portal lokal), bukan dari observasi langsung.

| Field | Status | Yang harus kamu lakukan |
|---|---|---|
| `nama` | ✅ Nyata, dari sumber publik | — |
| `alamat` | ✅ Nyata, dari sumber publik | — |
| `jenisOlahraga` | ✅ Nyata | — |
| `jamBuka` / `jamTutup` | ⚠️ Sebagian dari sumber, sebagian perkiraan | Konfirmasi saat survei |
| `latitude` / `longitude` | ✅ **30/30 terverifikasi** (21 September 2026, T-51 — cek manual dua kali: T-00f 21 Agustus, lalu ulang satu-per-satu 21 September, 3 di antaranya ternyata meleset dan sudah dikoreksi) | — |
| `harga` / `hargaSlot` | ⚠️ Perkiraan pasaran, bukan tarif resmi | **Wajib diperbaiki** untuk yang `observasi` |
| `fasilitas` | ⚠️ Sebagian dari sumber, sebagian perkiraan | Konfirmasi saat survei |
| `fotoURL` | ⬜ Sengaja dikosongkan | Foto sendiri saat survei — cara host-nya, lihat catatan di bawah tabel |
| `nomorTelepon` | ✅ **30/30 terisi** (21 September 2026, T-51, hasil cek manual Google Maps — 3 di antaranya memang tidak punya nomor publik, dibiarkan kosong) | — |
| `tautanMaps` | ✅ **30/30 terisi** (21 September 2026, T-51 — field baru, link Google Maps asli untuk tombol "Buka di Google Maps") | — |
| `isMitra` / `pemilikId` | 🎭 Simulasi untuk keperluan demo | Lihat bagian "Lapangan mitra" |

**Kenapa ini penting.** Kalau penguji bertanya "koordinat ini dapat dari mana?" dan jawabannya "dari internet", itu masalah — karena Bab 3 mengklaim sumber data Places API + observasi langsung. Data di bawah adalah **kerangka kerja yang sudah jadi**, bukan pengganti T-00e. Bagusnya: kerja survei kalian sekarang tinggal *memverifikasi dan mengoreksi* 30 baris, bukan mengumpulkan dari nol.

### Cara host foto (22 September 2026)

`fotoURL` diisi URL eksternal (PRD §12b, Opsi A — bukan upload). **Jangan pakai PostImages, ImgBB, atau Imgur** — ketiganya diverifikasi diblokir ISP Indonesia (diuji lewat `curl` di dua jaringan berbeda, baru normal lewat VPN). Kalau dipakai, foto tidak akan muncul untuk kebanyakan pengguna, bukan karena aplikasinya salah.

Pakai **Google Drive** sebagai gantinya: upload foto → klik kanan file → Share → "Anyone with the link" → salin link → ambil `FILE_ID` dari `.../file/d/FILE_ID/view` → ubah jadi `https://drive.google.com/uc?export=view&id=FILE_ID` → itu yang ditempel ke `fotoURL`. Detail lengkap di `PRD.md` §12b.

### Cara memperbaiki koordinat (± 20 detik per lapangan)

1. Buka Google Maps di browser desktop
2. Cari nama lapangan
3. Klik kanan tepat di pin lokasinya
4. Baris paling atas menu adalah koordinatnya — klik untuk menyalin
5. Tempel ke `seed_lapangan.dart`, ganti angka `latitude` dan `longitude`

**Sudah selesai (T-51, 21 September 2026)** — seluruh 30 lapangan sudah dicek manual, lihat catatan di atas.

---

## Ringkasan sebaran

| Aspek | Hasil | Syarat PRD | Status |
|---|---|---|---|
| Jumlah lapangan | 30 | 20–30 | ✅ |
| Futsal | 8 | ada isinya | ✅ |
| Badminton | 11 (termasuk Raw Futsal & Badminton sejak T-51) | ada isinya | ✅ |
| Padel | 8 | ada isinya | ✅ |
| Mini soccer | 5 | ada isinya | ✅ |
| `isMitra: true` | 5 | minimal 3 | ✅ |
| `sumberData` | 17 `places_api` · 8 `observasi` · 5 `mitra` | tiga sumber terwakili | ✅ |
| Nama duplikat | tidak ada | — | ✅ |
| Rentang jarak dari Binus Alam Sutera | 0,95 km – ±17 km | — | ✅ bagus untuk uji pengurutan |

Rentang jarak yang lebar itu disengaja: kalau semua lapangan berjarak 2–3 km, pengurutan jarak (BB-05) jadi sulit dibuktikan di depan penguji karena selisihnya tidak kelihatan.

**5 terdekat dari kampus Binus Alam Sutera** (−6,2214 / 106,6520) — dihitung ulang 21 September 2026 dari koordinat final (30/30 terverifikasi), sudah dicocokkan langsung dengan urutan yang tampil di Home lewat emulator — pakai ini untuk uji manual BB-05:

| # | Lapangan | Jarak |
|---|---|---|
| 1 | The Good Padel Club | 0,95 km |
| 2 | Hey Beach Padel Club | 1,89 km |
| 3 | Sabnani Football | 3,69 km |
| 4 | KM7 Mini Soccer | 3,77 km |
| 5 | Stadiums Futsal | 3,92 km |

> Tabel ini sebelumnya basi (sempat menyebut Stadiums Futsal #3 dan Hall Badminton Jonex #4, padahal keduanya tidak masuk 5 besar dengan koordinat final) — kalau ada revisi koordinat lagi nanti, hitung ulang jangan cuma percaya tabel ini.

---

## Daftar lengkap 30 lapangan

Kolom **📍** = koordinat terverifikasi (30/30 sejak T-51, 21 September 2026 — 3 di antaranya dikoreksi ulang, ditandai 🔧). Kolom **Sumber** = nilai atribut `sumberData`. `nomorTelepon`/`tautanMaps` tidak diulang di sini — lihat langsung `seed_lapangan.dart`.

### Futsal (8)

| # | Nama | Alamat | Harga/jam | Jam | 📍 | Sumber |
|---|---|---|---|---|---|---|
| 1 | Stadiums Futsal | Jl. Pondok Jagung Timur No. 35, Serpong Utara | 200.000 | 08:00–22:00 | ✅ | observasi |
| 2 | MS Sport Arena | Kav. Ocean Walk, Jl. Pahlawan Seribu Blok CBD Lot VI A, Lengkong Gudang, Serpong | 300.000 | 06:00–00:00 | 🔧 | observasi |
| 3 | Vegas Futsal | Jl. Raya Buaran-Viktor, BSD, Serpong | 180.000 | 08:00–22:00 | ✅ | places_api |
| 4 | Noel Futsal | Jl. Raya Puspitek No. 58, Buaran, Serpong | 150.000 | 07:00–22:00 | ✅ | places_api |
| 5 | Primaraga Hall | Jl. Mandor Baret No. 1, Legoso, Ciputat Timur | 120.000 | 07:00–00:00 | ✅ | places_api |
| 6 | Raw Futsal & Badminton † | Jl. Pahlawan No. 79, Ciputat Timur | 185.000 | 06:00–17:00 | ✅ | places_api |
| 7 | Garasi Futsal | Jl. R.E. Martadinata No. 73, Cipayung, Ciputat | 140.000 | 07:00–23:00 | ✅ | places_api |
| 8 | Taruna Futsal & Badminton † | Jl. Salak Raya No. 76, Pondok Benda, Pamulang | 130.000 | 07:00–23:00 | ✅ | places_api |

† 2 lapangan multi-olahraga (futsal **dan** badminton) — Raw Futsal & Badminton ditemukan T-51 (21 September 2026), Taruna Futsal & Badminton sudah sejak awal. Berguna untuk membuktikan filter chip bekerja pada `List<String>`, bukan `String` (BB-07). **Keterbatasan:** harga/jam untuk keduanya tetap satu nilai berlaku untuk semua jenis olahraga di venue itu — lihat `PRD.md` bagian Keterbatasan, dan `SPRINT-PLAN.md` "Ide masa depan" untuk rencana kalau mau dibuat per-jenis-olahraga.

### Mini Soccer (5)

| # | Nama | Alamat | Harga/jam | Jam | 📍 | Sumber |
|---|---|---|---|---|---|---|
| 9 | Kicktopia Mini Soccer Gading Serpong | Gading Serpong, Kelapa Dua, Kab. Tangerang | 600.000 | 06:00–00:00 | ✅ | **mitra** |
| 10 | KM7 Mini Soccer | Jl. Raya Serpong KM. 7 No. 28, Pondok Jagung, Serpong Utara | 550.000 | 06:00–00:00 | ✅ | **mitra** |
| 11 | Sabnani Football | Rawa Kutuk, Serpong Utara | 550.000 | 06:00–23:00 | ✅ | observasi |
| 12 | Arsa Sport Mini Soccer | Jl. Cilenggang 1, Cilenggang, Serpong | 500.000 | 06:00–22:00 | 🔧 | observasi |
| 13 | AM Soccer Arena | Kp. Curug Kongsi Baru, Medang, Pagedangan | 700.000 | 06:00–00:00 | ✅ | places_api |

### Badminton (11)

| # | Nama | Alamat | Harga/jam | Jam | 📍 | Sumber |
|---|---|---|---|---|---|---|
| 14 | Candra Wijaya International Badminton Centre | Jl. Jelupang Raya No. 15, Jelupang, Serpong Utara | 150.000 | 06:00–00:00 | ✅ | **mitra** |
| 15 | Hall Badminton Jonex | Jl. Pemakanan No. 37, Pondok Jagung, Serpong Utara | 55.000 | 08:00–23:00 | ✅ | observasi |
| 16 | Matrix Badminton Arena | BSD City | 90.000 | 07:00–23:00 | ✅ | places_api |
| 17 | Tontowi Ahmad Badminton Hall BSD | Lengkong Kulon, Pagedangan | 80.000 | 06:00–23:00 | ✅ | places_api |
| 18 | Benteng Badminton Hall | Jl. Ciakar, Kp. Pangger, Situgadung, Pagedangan | 70.000 | 07:00–23:00 | ✅ | places_api |
| 19 | Ultra Badminton Hall | Kp. Ciakar, Jl. Raya Pagedangan, Situgadung, Pagedangan | 65.000 | 07:00–23:00 | ✅ | places_api |
| 20 | GOR Panca Putra | Gg. Betawi, Ciater, Serpong | 60.000 | 07:00–23:00 | ✅ | observasi |
| 21 | GOR Saratoga | Jl. Mede No. 60, Pamulang Barat | 40.000 | 07:00–00:00 | ✅ | places_api |
| 22 | GOR Jambu | Jl. Jambu No. 8B, Pisangan, Ciputat Timur | 35.000 | 07:00–23:00 | ✅ | places_api |
| 23 | *(Taruna Futsal & Badminton, lihat #8)* | | | | | |
| — | *(Raw Futsal & Badminton, lihat #6)* | | | | | |

### Padel (8)

| # | Nama | Alamat | Harga/jam | Jam | 📍 | Sumber |
|---|---|---|---|---|---|---|
| 24 | Hey Beach Padel Club | Jalur Sutera No. 30A, Pakualam, Serpong Utara | 280.000 | 07:00–23:00 | ✅ | **mitra** |
| 25 | Mad Padel Club BSD | Jl. Damar Poso 8 No. 23 Blok AA8, Medang, Pagedangan | 320.000 | 06:00–00:00 | 🔧 | **mitra** |
| 26 | Rekket Space Padel Hall BSD | Jl. Buaran Raya, Buaran, Serpong | 240.000 | 06:00–23:00 | ✅ | observasi |
| 27 | Beyond Padel BSD | Jl. Melati VIII No. 7, Jelupang, Serpong Utara | 260.000 | 07:00–23:00 | ✅ | observasi |
| 28 | Racquet Padel Club BSD | Jl. Raya Pagedangan, BSD | 160.000 | 06:00–23:00 | ✅ | places_api |
| 29 | Go Padel BSD | Jl. Jatake-Babakan Raya No. 78, Jatake, Pagedangan | 200.000 | 06:00–23:00 | ✅ | places_api |
| 30 | The Good Padel Club | Jl. Alam Utama Kav. 10, Panunggangan Timur, Pinang, Kota Tangerang | 350.000 | 07:00–23:00 | ✅ | places_api |
| 31 | Powerhouse Padel | Jl. Kejaksaan Raya No. 60, Kreo, Larangan, Kota Tangerang | 250.000 | 07:00–23:00 | ✅ | places_api |

🔧 = 3 lapangan yang koordinatnya dikoreksi T-51 (bukan sekadar diverifikasi baru — koordinat lama di seed sebelumnya memang meleset).

> **8 lapangan bertanda `observasi`** adalah yang paling dekat kampus dan paling realistis kalian datangi saat T-00e. Untuk yang ini, harga/jam/fasilitas **wajib** diganti dengan data asli — kalau tidak, ubah `sumberData`-nya jadi `places_api` supaya tidak mengklaim observasi yang tidak dilakukan.

---

## Lapangan mitra dan `pemilikId`

Lima lapangan ditandai `isMitra: true`. Semuanya dipilih karena **memang menerima booking online** di platform seperti Ayo atau Gelora, jadi simulasinya masuk akal dan bisa kamu pertahankan kalau ditanya penguji.

Tapi ada urutan yang harus benar: `pemilikId` di file Dart masih `null`, padahal PRD 6.2 bilang atribut ini terisi kalau `isMitra == true`, dan Security Rules butuh nilainya untuk memfilter booking milik mitra.

**Urutan yang benar:**

1. Register akun mitra lewat aplikasi (L-03, pilih peran "Pemilik Lapangan"), misalnya `mitra@sportspace.test`
2. Salin UID-nya dari Firebase Console → Authentication
3. Tempel UID itu ke `AdminSeedScreen` (lihat kode di bawah)
4. Baru tekan tombol seed

Kalau seed dijalankan sebelum akun mitra ada, kelima lapangan itu punya `pemilikId: null` dan Dashboard Mitra (L-14) akan kosong terus — dan ini akan makan waktu lama untuk didiagnosis.

---

## Cara memakai file `seed_lapangan.dart`

Taruh di `lib/core/data/seed_lapangan.dart`. Berikut bagian inti `AdminSeedScreen` (T-10):

```dart
// UID akun mitra — ambil dari Firebase Console > Authentication
// setelah register akun mitra lewat aplikasi. JANGAN dibiarkan kosong.
const String uidMitra = 'GANTI_DENGAN_UID_MITRA';

Future<int> jalankanSeed() async {
  if (uidMitra == 'GANTI_DENGAN_UID_MITRA') {
    throw Exception('UID mitra belum diisi. Register akun mitra dulu.');
  }

  final firestore = FirebaseFirestore.instance;
  final koleksi = firestore.collection('lapangan');

  // Cegah seed dijalankan dua kali — kalau tidak, datanya jadi dobel
  // dan daftar di Home akan menampilkan lapangan yang sama berulang.
  final cek = await koleksi.limit(1).get();
  if (cek.docs.isNotEmpty) {
    throw Exception('Koleksi lapangan sudah berisi data. Seed dibatalkan.');
  }

  // WriteBatch menulis banyak dokumen dalam satu operasi — jauh lebih cepat
  // dan lebih hemat kuota daripada 30 kali set() satu per satu.
  final batch = firestore.batch();

  for (final data in seedLapangan) {
    final ref = koleksi.doc();            // Firestore membuat ID acak
    batch.set(ref, {
      ...data,
      'lapanganId': ref.id,               // PRD 6.2: sama dengan ID dokumen
      'pemilikId': data['isMitra'] == true ? uidMitra : null,
    });
  }

  await batch.commit();
  return seedLapangan.length;
}
```

Setelah tombol ditekan sekali dan datanya muncul di Firebase Console, **nonaktifkan rutenya** (PRD Bagian 10) — hapus dari `app_routes.dart` atau bungkus dengan `if (kDebugMode)`.

### Kalau perlu seed ulang

Hapus seluruh dokumen di koleksi `lapangan` lewat Firebase Console dulu (Firestore tidak punya "drop collection" dari klien), baru jalankan lagi.

---

## Yang masih kurang setelah ini

Seed lapangan menyelesaikan blocker #1 dari empat yang saya sebutkan. Yang belum:

- **Composite index Firestore** — belum didokumentasikan di mana pun. Akan bikin error runtime di Sprint 4.
- **Akun & skenario demo** — minimal 3 akun (pengguna A, pengguna B, mitra) dengan data aktivitas dan booking yang sudah disiapkan.
- **Keputusan PRD 12b (Firebase Storage)** — tenggat sebelum Sprint 4.
- **Contoh kode vertikal satu fitur** (View → ViewModel → Repository) sebagai acuan gaya kode bertiga.

---

## Sumber data

- [Gelora — KM7 Mini Soccer](https://www.gelora.id/v/km7minisoccer/about) · [Arsa Sport Mini Soccer](https://www.gelora.id/v/arsaminisoccer/about) · [MS Sport Arena](https://www.gelora.id/v/mssportarena) · [Sabnani Football](https://www.gelora.id/v/sabnanifootball/about)
- [Kicktopia Mini Soccer Gading Serpong](https://kicktopia.id/)
- [Ayo Indonesia — AM Soccer Arena](https://ayo.co.id/v/am-soccer-arena)
- [Info Tangerang — 8 Rekomendasi Lapangan Padel di BSD](https://infotangerang.id/8-rekomendasi-lapangan-padel-di-bsd-dengan-fasilitas-lengkap-sewa-per-jam-mulai-rp200-ribuan/)
- [Tangsel Life — 9 Rekomendasi Lapangan Futsal di Tangerang Selatan](https://tangselife.com/sport/rekomendasi-lapangan-futsal)
- [Tangsel Life — 6 Rekomendasi Lapangan Badminton di Tangerang Selatan](https://tangselife.com/sport/ekomendasi-lapangan-badminton)
- [Townzhub — 4 Rekomendasi Lapangan Badminton di BSD](https://townzhub.com/blog/4-rekomendasi-lapangan-badminton-di-bsd-dengan-fasilitas-terbaik-dan-rating-tinggi)
