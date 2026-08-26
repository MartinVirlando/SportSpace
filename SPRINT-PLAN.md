# Rencana Sprint — Sport Space

**Versi 1.1 · 17 Agustus 2026** — diselaraskan dengan PRD v1.1.

Sprint 1 dan 2 (analisis & perancangan) **sudah selesai** — hasilnya adalah Bab 3 skripsi.
Dokumen ini merinci **Sprint 3, 4, dan 5** yang berisi implementasi dan pengujian.

Asumsi: 14 minggu, 3 orang, ketiganya ngoding, mulai dari nol Flutter.

### Perubahan di v1.1

| Tugas | Perubahan |
|---|---|
| T-00f | **Baru** — verifikasi koordinat 25 lapangan (blocker BB-13) |
| T-06 | Sekarang mencakup deploy **index**, bukan hanya rules |
| T-08 | Sekarang mencakup **shell navigasi 4 tab** |
| T-10 | Merujuk `SEED-DATA.md`, dan bergantung pada T-00f |
| T-12 | Home = **daftar vertikal**; acuan kodenya sudah ada (`CONTOH-KODE-HOME.md`) |
| T-14 | Peta jadi **tab sendiri**, bukan layar yang dibuka dari Home |
| T-35…T-38 | **Baru** — favorit, badge status, olahraga favorit + lokasi default, statistik profil |
| T-39 | **Baru** — revisi dokumen skripsi sesuai PRD §14 |

---

## Cara memakai dokumen ini

Setiap tugas punya ID (`T-xx`). Saat memberi perintah ke Claude di VSCode, sebut ID-nya:

> "Kerjakan T-07 sesuai PRD."

Kerjakan **satu tugas sampai tuntas** sebelum pindah. Jangan lompat-lompat — banyak tugas bergantung pada tugas sebelumnya.

---

## Minggu 0 (Minggu 1–2) · Persiapan — belum ngoding skripsi

Jangan lewati bagian ini. Belajar Flutter *sambil* mengerjakan skripsi adalah cara paling umum kehilangan sebulan.

| ID | Tugas | Siapa | Selesai jika |
|---|---|---|---|
| T-00a | Install Flutter SDK, Android Studio, siapkan emulator + perangkat fisik | Bertiga | `flutter doctor` bersih |
| T-00b | Ikuti codelab Flutter dasar; buat satu app CRUD sederhana (catatan/todo) | Bertiga, masing-masing | Paham `StatelessWidget`, `StatefulWidget`, `setState`, `ListView`, navigasi |
| T-00c | Buat project Firebase, aktifkan Firestore + Authentication (Email/Password) | 1 orang | Console Firebase siap |
| T-00d | Upgrade ke paket Blaze **dan pasang budget alert** di Google Cloud Console | 1 orang | Budget alert aktif di angka kecil |
| T-00e | Survei manual lapangan: konfirmasi harga, jam, dan fasilitas untuk 8 lapangan bertanda `observasi` di `SEED-DATA.md` | Bertiga | Data di `seed_lapangan.dart` diperbarui |
| **T-00f** | **Verifikasi koordinat 25 lapangan lewat Google Maps** (klik kanan pin → salin koordinat) | Bertiga | Seluruh entri `seed_lapangan.dart` punya koordinat asli |

> **T-00d penting.** Dengan pemakaian skripsi, tagihan realistis Rp 0 karena kuota gratis tidak akan tersentuh. Tapi tanpa budget alert, satu bug perulangan tak terbatas bisa jadi masalah.
>
> **T-00f adalah blocker BB-13.** 25 dari 30 lapangan koordinatnya masih perkiraan tingkat kelurahan. Haversine tidak bisa dibuktikan benar di atas data yang salah, dan penguji berhak menanyakan asal koordinatnya. Sekitar 10 menit kalau dibagi bertiga — kerjakan ini **sebelum** T-10.

---

## Sprint 3 · Fondasi + Fitur Pencarian Lapangan (Minggu 3–7)

**Sasaran:** pengguna bisa login dan melihat daftar lapangan terdekat beserta jaraknya, di daftar maupun peta.

### Fase A — dikerjakan BERTIGA BARENG (Minggu 3)

Jangan dibagi dulu. Tujuannya memastikan ketiganya paham arsitektur yang sama. Kalau dibagi sejak awal, di minggu ke-6 akan ada tiga gaya kode berbeda yang tidak bisa disatukan.

| ID | Tugas | Bergantung pada | Selesai jika |
|---|---|---|---|
| T-01 | Buat project Flutter, pasang seluruh dependency PRD Bagian 4, hubungkan ke Firebase | T-00c | `flutter run` jalan, Firebase terinisialisasi |
| T-02 | Buat struktur folder sesuai PRD Bagian 5 (folder kosong + file placeholder) | T-01 | Struktur cocok dengan PRD |
| T-03 | Tulis seluruh model di `models/` beserta `fromFirestore()` / `toFirestore()` | T-02 | 8 model sesuai PRD Bagian 6 |
| T-04 | Tulis `core/utils/haversine.dart` **manual** + uji dengan 3 koordinat yang jaraknya sudah diketahui | T-02 | BB-13 lulus, `flutter test` hijau |
| T-05 | Tulis `core/constants/` (warna, 4 olahraga, teks Indonesia) dan `core/utils/formatter.dart` | T-02 | — |
| T-06 | Deploy Firestore **Security Rules dan composite index** | T-00c | `firebase deploy --only firestore` sukses, 11 index berstatus *Enabled* |

> **T-03 mengunci nama atribut.** Setelah tugas ini selesai, folder `models/` hanya boleh diubah oleh integrator. Ini yang mencegah merge conflict paling menyakitkan.
>
> **T-04, T-05, dan sebagian T-03 sudah ada acuannya.** Paket `contoh-kode-home` berisi `haversine.dart`, `formatter.dart`, `app_colors.dart`, `app_sports.dart`, dan `lapangan_model.dart` yang sudah jadi. Bukan untuk disalin buta — baca dulu `CONTOH-KODE-HOME.md`, pahami polanya, lalu lanjutkan dengan pola yang sama untuk 7 model sisanya.
>
> **T-06 jangan ditunda.** Emulator Firestore tidak menegakkan aturan index, jadi kalau index belum di-deploy semuanya kelihatan jalan sampai kalian pindah ke Firestore asli di Sprint 4. Lihat `FIRESTORE-INDEXES.md`.

### Fase B — mulai dibagi (Minggu 4–7)

Mulai sini pakai satu cabang git per fitur.

| ID | Tugas | Siapa | Bergantung | Selesai jika |
|---|---|---|---|---|
| T-07 | `auth_repository.dart` + AuthViewModel + layar Login & Register (L-02, L-03) | A | T-03 | BB-01…BB-04 lulus |
| T-08 | Splash + routing + cek status login + **shell navigasi 4 tab** (L-01) | A | T-07 | Buka app langsung ke layar yang tepat, 4 tab bisa berpindah |
| T-09 | `location_service.dart` — izin lokasi, ambil koordinat, tangani penolakan | B | T-05 | AB-03 terpenuhi, BB-06 lulus |
| T-10 | `AdminSeedScreen` + masukkan 30 lapangan ke Firestore | C | T-03, T-00e, **T-00f** | Data tampil di Firebase Console |
| T-11 | `lapangan_repository.dart` — ambil semua lapangan, hitung Haversine, urutkan jarak | B | T-04, T-10 | Daftar terurut benar |
| T-12 | Home: **daftar vertikal** kartu lapangan, search bar, filter chip, ikon lonceng (L-04) | B | T-11 | BB-05, BB-07, BB-08 lulus |
| T-13 | Halaman Detail Lapangan (L-06) — tanpa tombol rating & reservasi dulu | C | T-11 | BB-11, BB-12 lulus |
| T-14 | **Tab Map** dengan `flutter_map` + marker + kartu ringkas (L-05) | B | T-11 | BB-09, BB-10 lulus |

> **Kenapa peta (T-14) tetap dikerjakan setelah daftar (T-12), padahal sekarang jadi tab utama?** Alasannya tidak berubah: peta itu memikat sehingga sering dikerjakan duluan — lalu habis 5 hari berkelahi dengan tile provider dan marker, sementara belum ada satu pun data yang tampil. Daftar terurut membuktikan hal yang sama (GPS terbaca, Haversine benar, data mengalir) dan jauh lebih cepat jadi. Tab Map boleh diisi placeholder "Segera hadir" sampai T-14 dikerjakan.
>
> **T-12 punya acuan lengkap.** Seluruh rantai Model → Repository → ViewModel → View untuk layar ini ada di paket `contoh-kode-home`. T-11 dan T-12 harusnya jadi tugas tercepat di sprint ini.

**Demo akhir Sprint 3:** buka aplikasi → login → lihat daftar lapangan terdekat lengkap dengan jaraknya → pindah ke tab Map → buka detail lapangan.

---

## Sprint 4 · Rekan Bermain, Rating, Reservasi, dan Favorit (Minggu 8–11)

**Sasaran:** seluruh fitur utama berfungsi.

| ID | Tugas | Siapa | Bergantung | Selesai jika |
|---|---|---|---|---|
| T-15 | `notifikasi_repository.dart` + NotifikasiViewModel + halaman Notifikasi + badge (L-12) | A | T-03 | Notifikasi masuk secara langsung tanpa refresh |
| T-16 | `aktivitas_repository.dart` — buat, ambil daftar, filter olahraga | B | T-03 | — |
| T-17 | Tab Teman: daftar aktivitas + kartu + FAB (L-07), **5 chip termasuk Mini Soccer** | B | T-16 | Daftar aktivitas tampil & tersaring |
| T-18 | Form Buat Aktivitas + validasi (L-08) | B | T-16 | BB-14, BB-15 lulus |
| T-19 | Halaman Detail Aktivitas + kirim permintaan gabung (L-09) | B | T-17 | BB-16 lulus |
| T-20 | Terima/tolak permintaan gabung dengan transaction — **AB-06** | B | T-19, T-15 | BB-17, BB-18, BB-19, BB-20 lulus |
| T-21 | `rating_repository.dart` + form Beri Rating dengan transaction — **AB-05** | C | T-13 | BB-21, BB-22, BB-23 lulus |
| T-22 | Tampilkan daftar ulasan di halaman Detail Lapangan | C | T-21 | Ulasan tampil |
| T-23 | `booking_repository.dart` + kunci slot dengan transaction — **AB-04** | C | T-03 | BB-24, BB-25 lulus |
| T-24 | Form Ajukan Reservasi + tampilkan slot terisi + estimasi harga (L-10) | C | T-23 | Slot terisi tidak bisa dipilih |
| T-25 | Dashboard Mitra: daftar lapangan, konfirmasi/tolak booking (L-14) | A | T-23 | BB-26, BB-27 lulus |
| T-26 | Form Tambah/Edit Lapangan untuk mitra (L-15) | A | T-25 | BB-29 lulus |
| T-27 | Tab Profil: riwayat booking, aktivitas saya, menu statis, logout (L-13) | A | T-23 | BB-28, BB-30 lulus |
| **T-35** | `favorit_repository.dart` + FavoritViewModel + ikon ♡ di L-04 dan L-06 — **AB-10** | C | T-13 | BB-31, BB-32, BB-37 lulus |
| **T-36** | Badge status "Mitra Terdaftar" dan "Terverifikasi" di L-06 — **AB-11** | C | T-13 | BB-33, BB-34 lulus |
| **T-37** | Olahraga favorit + lokasi default di Profil, dan cadangan lokasi di AB-03 | A | T-27, T-09 | BB-35 lulus |
| **T-38** | Statistik profil (Booking · Aktivitas · Favorit) dengan `count()` — **AB-12** | A | T-27, T-35 | BB-36 lulus |

> **T-20, T-21, T-23 adalah tiga tugas tersulit** karena melibatkan Firestore Transaction. Kerjakan bertiga bareng kalau perlu. Baca ulang PRD AB-04, AB-05, AB-06 sebelum mulai — terutama catatan bahwa transaction **tidak bisa** menjalankan Query.
>
> **T-35 dan T-36 justru termasuk paling mudah.** T-36 murni tampilan dari data yang sudah ada (kira-kira 30 menit). T-35 tidak butuh transaction karena operasinya satu dokumen. Keduanya bagus dikerjakan sebagai selingan setelah T-23 yang melelahkan.

**Demo akhir Sprint 4:** seluruh alur berjalan ujung ke ujung — cari lapangan, simpan favorit, buat aktivitas, gabung, terima permintaan, beri rating, ajukan reservasi, mitra mengonfirmasi.

---

## Sprint 5 · Pengujian dan Evaluasi (Minggu 12–14)

| ID | Tugas | Siapa | Selesai jika |
|---|---|---|---|
| T-28 | Perbaikan bug + rapikan tampilan + pastikan kondisi kosong/memuat/error tertangani | Bertiga | Definisi Selesai PRD Bagian 12 terpenuhi |
| T-29 | Build APK release, uji di minimal 3 perangkat Android berbeda | 1 orang | APK terpasang dan jalan |
| T-30 | Jalankan seluruh **37** kasus BB-01…BB-37, catat hasil ke tabel | Bertiga | Tabel Black Box siap untuk Bab 4 |
| T-31 | Sebar APK + kuesioner SUS ke 20–30 responden (purposive sampling) | Bertiga | Data SUS terkumpul |
| T-32 | Hitung skor SUS, buat tabel dan interpretasi (rujuk Bangor et al. 2009) | 1 orang | Skor SUS siap untuk Bab 4 |
| T-33 | Tulis Bab 4 (implementasi, tangkapan layar, hasil Black Box, hasil SUS) | Bertiga | Draf Bab 4 |
| T-34 | Tulis Bab 5 (kesimpulan + saran pengembangan) | Bertiga | Draf Bab 5 |

**Saran isi Bab 5** — keterbatasan yang sebaiknya diakui sendiri, karena penguji kemungkinan menemukannya:

- Kalkulasi jarak dilakukan di klien sehingga tidak efisien untuk jumlah lapangan yang sangat besar; geohash disarankan untuk pengembangan lanjutan.
- Notifikasi bersifat in-app, belum push notification, karena keterbatasan paket layanan.
- Ketersediaan slot hanya akurat untuk lapangan mitra.
- Security Rules masih longgar di beberapa titik karena tidak memakai Cloud Functions.
- Rating antar-pengguna belum diimplementasikan — lihat PRD §12c.

---

## Tugas dokumen skripsi (paralel, bukan ngoding)

| ID | Tugas | Siapa | Tenggat | Selesai jika |
|---|---|---|---|---|
| **T-39** | Revisi Bab 1–3 sesuai **PRD §14** (7 butir, termasuk navigasi 3 tab → 4 tab) | Bertiga + Pak Gintoro | **Sebelum Bab 4 ditulis** | Bab 3 cocok dengan aplikasi yang dibangun |
| T-40 | Putuskan PRD §12b (Firebase Storage): Opsi A atau B | Bertiga + Pak Gintoro | Sebelum Sprint 4 | Keputusan tercatat di PRD |

> **T-39 jangan ditunda sampai Bab 4.** Kalau tangkapan layar di Bab 4 menampilkan 4 tab sementara Bab 3 menuliskan 3 tab, itu jenis ketidakcocokan yang paling gampang ditemukan penguji karena tidak perlu membaca kode sama sekali.

---

## Kalau waktu ternyata cuma 8 minggu

Urutan pemotongan, dari yang paling ringan konsekuensinya:

1. **T-35 sampai T-38** (favorit, badge, olahraga favorit, statistik). Ini fitur v1.1 yang bukan jawaban rumusan masalah. Buang duluan, pindahkan ke Bab 5. Kalau dipotong, PRD §6.1, §6.9, dan BB-31…BB-37 ikut dicabut.
2. **T-23 sampai T-26** (seluruh alur reservasi dan dashboard mitra).

**Konsekuensi memotong nomor 2 harus disadari:** Rumusan Masalah #3 menyebut reservasi, jadi rumusan itu perlu direvisi ulang bersama pembimbing. Karena kamu sudah memutuskan booking wajib, jalur ini adalah rencana cadangan terakhir — bukan pilihan pertama.

Yang **tidak boleh** dipotong dalam kondisi apa pun, karena langsung menjawab rumusan masalah: pencarian lapangan berbasis LBS (T-11, T-12), peta (T-14), rekan bermain (T-16…T-20), dan rating (T-21).

---

## Pembagian peran

| Orang | Fokus | Catatan |
|---|---|---|
| **A** — integrator | Auth, routing & shell 4 tab, notifikasi, profil, dashboard mitra | Satu-satunya yang merge ke `main` dan mengubah `models/` |
| **B** | Lapangan, peta, aktivitas bermain | Bagian paling berat, dapat porsi terbesar |
| **C** | Seeding data, detail lapangan, rating, booking, favorit | Banyak menyentuh Firestore Transaction |

Minggu 3 dikerjakan bertiga bareng. Pembagian di atas baru berlaku mulai minggu 4.

**Jangan bagi kerja per-lapisan** ("A pegang UI, B pegang logic, C pegang database"). Itu bikin semua orang saling menunggu dan tidak ada yang bisa menyelesaikan satu fitur utuh.

**Sebelum setiap merge ke `main`**, jalankan pemeriksaan aturan lapisan:

```bash
flutter analyze
flutter test
grep -rl "package:cloud_firestore" lib/ | grep -Ev "^lib/(repositories|models)/"
```

Perintah ketiga harus tidak mengeluarkan apa pun. Kalau ada, berarti ada View atau ViewModel yang menyentuh Firestore langsung — itu melanggar arsitektur MVVM yang diklaim di skripsi.

---

## Papan pantau

Salin ke Notion/Trello/spreadsheet dan perbarui tiap minggu.

```
Minggu 1–2   [ ] T-00a  [ ] T-00b  [ ] T-00c  [ ] T-00d  [ ] T-00e  [x] T-00f
Minggu 3     [x] T-01  [x] T-02  [x] T-03  [x] T-04  [x] T-05  [x] T-06
Minggu 4     [x] T-07  [x] T-08  [x] T-09  [x] T-10
Minggu 5–6   [x] T-11  [x] T-12  [x] T-13
Minggu 7     [x] T-14                                    [x] T-40 (Opsi A, tanpa Storage)
Minggu 8     [x] T-15  [x] T-16  [x] T-17
Minggu 9     [x] T-18  [x] T-19  [x] T-20
Minggu 10    [x] T-21  [x] T-22  [x] T-23  [x] T-36
Minggu 11    [x] T-24  [x] T-25  [x] T-26  [x] T-27  [x] T-35  [x] T-37  [x] T-38
Minggu 12    [ ] T-28  [ ] T-29                          [ ] T-39 (revisi Bab 1–3)
Minggu 13    [ ] T-30  [ ] T-31
Minggu 14    [ ] T-32  [ ] T-33  [ ] T-34
```

> **Catatan status per 26 Agustus 2026:** Seluruh alur reservasi + dashboard mitra (T-23–T-27), keputusan T-40 (Opsi A, tanpa Firebase Storage — lihat PRD §12b), dan seluruh empat tugas v1.1 (T-35 favorit, T-36 badge, T-37 olahraga favorit + lokasi default, T-38 statistik profil) sudah selesai. **Sprint 3 dan 4 lengkap secara kode, T-10 (seeding) sudah dijalankan di project Firestore produksi, dan T-06 (index + rules) sudah terverifikasi Enabled dan ter-deploy.** T-28 (audit kode + perbaikan bug) sudah jalan signifikan — lihat catatan di bawah. Sisa pekerjaan: T-00a–T-00e (proses tim, sedang berjalan paralel), lalu T-29/T-30 dan seterusnya (build APK, Black Box di perangkat nyata, SUS, penulisan Bab 4–5).
>
> **T-06 SELESAI (26 Agustus 2026).** `firebase firestore:indexes` mengonfirmasi 11 index di server cocok persis dengan `firestore.indexes.json`/`FIRESTORE-INDEXES.md`, dan cek manual di Firebase Console → Firestore → Indexes menunjukkan seluruh 11 baris berstatus **Enabled** (bukan Building). Kriteria "Selesai jika" T-06 terpenuhi.
>
> T-00a–T-00e juga belum ditandai — tugas persiapan tim (instalasi, survei manual) yang tidak bisa diverifikasi lewat kode, dan sedang dikerjakan.
>
> **Catatan sampingan dari cek T-06:** tangkapan layar Firebase Console menunjukkan project masih di paket **Spark** (gratis), bukan **Blaze** seperti disebut T-00d. Ini kemungkinan bukan masalah — Firestore (termasuk composite index) dan Authentication jalan penuh di Spark, dan proyek ini sengaja tidak memakai Cloud Functions/Storage yang butuh Blaze. Tapi karena T-00d eksplisit meminta upgrade ke Blaze + budget alert, sebaiknya dipastikan lagi saat T-00d benar-benar dikerjakan: kalau ternyata tetap di Spark, catat alasannya (semua fitur yang dipakai gratis) supaya tidak jadi pertanyaan penguji soal kesesuaian dengan dokumen.
>
> **T-28 SEBAGIAN JALAN (26 Agustus 2026) — audit kode menyeluruh, 18 bug ditemukan & diperbaiki.** Sebelum testing sungguhan di perangkat (T-30) dimulai, dilakukan audit sistematis ke seluruh lapisan kode (dibantu Claude, bukan Black Box formal) untuk menutup bug sebanyak mungkin lebih awal. Belum dicentang selesai karena Definisi Selesai PRD §12 poin 1 ("seluruh kasus BB lulus di **perangkat Android nyata**") baru bisa dipastikan lewat T-30 — ini pondasi sebelum itu. Ringkasan per area (detail lengkap ada di riwayat commit hari ini):
>
> - **Kondisi UI (memuat/kosong/kesalahan)** — 14 layar diperiksa satu-satu. Ditemukan tombol "Coba Lagi" di Detail Lapangan yang salah mengulang `lapanganId` kosong (selalu gagal lagi); Map tidak punya pesan "belum ada lapangan" saat kosong; Profil bisa sekejap blank putih saat logout. Ketiganya diperbaiki. 5 titik `user!.userId` (null-assertion) di Home/Notifikasi/Dashboard Mitra/Detail Lapangan/Profil diganti jadi pengaman spinner, bukan crash.
> - **Transaksi inti (AB-04/05/06/07)** — `terimaPermintaan` (gabung aktivitas) tidak cek status permintaan dulu, jadi dua tap "Terima" cepat pada permintaan yang sama bisa menaikkan `jumlahPemainSaatIni` dua kali; `konfirmasiBooking`/`tolakBooking` punya celah serupa (double-tap) — keduanya diperbaiki jadi transaction dengan cek status dulu. Status `SELESAI` (AB-07) sebelumnya hanya dihitung ulang di Profil, sekarang dipakai bersama Dashboard Mitra lewat `core/utils/status_booking.dart` supaya mitra tidak melihat status basi.
> - **Validasi form** — bug fungsional nyata: form Tambah/Edit Lapangan (L-15) menolak jam tutup `"00:00"` (tengah malam) sebagai tidak valid, padahal 14/30 lapangan seed tutup tengah malam — mitra sama sekali tidak bisa mendaftar/mengedit lapangan itu. Diperbaiki. Pengaman berlapis ditambahkan di lapisan Repository untuk rating (1-5, ulasan ≤500 karakter) dan aktivitas (jumlah pemain 2-30, waktu masa depan) — sebelumnya cuma dicek di UI.
> - **Auth/Register** — race condition nyata: setelah login/daftar, navigasi ke `ShellNavigasi` terjadi sebelum `AuthViewModel.user` benar-benar terisi (diisi lewat stream terpisah `authStateChanges`), jadi di jaringan lambat tab **Profil bisa macet permanen di spinner**. Diperbaiki dengan mengisi `user` langsung dari hasil login/daftar. Akun "yatim" (Auth berhasil dibuat tapi dokumen `users` gagal ditulis) sekarang di-rollback otomatis.
> - **Data lapangan & favorit** — edit lapangan mitra (L-15) memakai `.set()` penuh yang diam-diam **menghapus `hargaSlot`** setiap kali diedit (form tidak punya kolomnya) dan berisiko menimpa balik rating yang baru masuk dari pengguna lain (lost update) — diperbaiki jadi `.update()` parsial, field itu tidak pernah disentuh lagi. Toggle favorit ♡/♥ dibungkus transaction (sebelumnya race pada double-tap cepat). Cast `hargaSlot` yang rawan crash kalau valuenya `double` diperbaiki.
> - **Lokasi (AB-03)** — `LocationService.ambilPosisi()` tidak menangkap timeout GPS, sehingga **melewati fallback lokasi default** dan menampilkan pesan teknis bahasa Inggris alih-alih tetap mencoba `lokasiDefault` — diperbaiki. `HomeViewModel`/`MapViewModel` juga ditambah penjaga (nomor urut permintaan) supaya panggilan yang tumpang tindih (mis. "Coba Lagi" ditekan dua kali) tidak saling menimpa hasil.
> - **Keamanan — SUDAH di-deploy ke produksi.** `firestore.rules`: `users/{userId}` semula `allow read: if login()` — siapa pun yang login bisa membaca nomor telepon dan lokasi default (koordinat rumah/kantor) pengguna LAIN mana pun, padahal tidak ada kode yang membutuhkannya. Dipersempit jadi `pemilikDok(userId)` dan sudah `firebase deploy --only firestore` ke `app-skripsi-f8340`.
>
> Seluruh perbaikan di atas diverifikasi `flutter analyze` bersih, `flutter test` (7 kasus Haversine) hijau, dan pemeriksaan aturan lapisan MVVM bersih di tiap langkah. PRD.md juga sudah diperbarui (§9 rules block + "Koreksi teknis pasca-v1.1 26 Agustus 2026") untuk dua perubahan yang mengubah kontrak dokumen (rules, `hargaSlot`).
>
> **T-00f SELESAI (21 Agustus 2026).** Seluruh 30 entri di `seed_lapangan.dart` sekarang bertanda `// KOORDINAT TERVERIFIKASI`, hasil verifikasi Google Maps (tim mengirimkan 23 koordinat yang tadinya perkiraan kelurahan; 7 sebelumnya sudah terverifikasi). "Selesai jika: Seluruh entri `seed_lapangan.dart` punya koordinat asli" — kriteria terpenuhi.
>
> **T-10 SELESAI (21 Agustus 2026).** `lapangan_repository.dart` punya `seedSemuaLapangan()` — menulis seluruh 30 lapangan dari `seed_lapangan.dart` (termasuk 5 mitra, bukan 3) dalam satu batch, `pemilikId` otomatis diisi ke akun yang sedang login untuk entri mitra. `admin_seed_screen.dart` (tile di menu Profil) memanggil method ini; method lama `seedPrototipe()` (bridge 7 lapangan) sudah dihapus. Seed **sudah dijalankan** di project Firestore produksi (`app-skripsi-f8340`) dan diverifikasi dua arah: 30 dokumen tampil di Firebase Console, dan Home menampilkan ke-30 lapangan terurut jarak di dua akun uji berbeda. Data lama sisa testing (7 dokumen prototipe + 2 data uji manual "Lapangan Uji Non-Mitra"/"Mitra") dihapus lebih dulu dari koleksi `lapangan` supaya tidak dobel.
>
> **Catatan kualitas data yang masih menunggu T-00e:** koordinat sudah benar untuk semua 30 lapangan, tapi harga/jam/fasilitas 8 lapangan `sumberData: 'observasi'` masih perkiraan pasaran, bukan hasil survei langsung — belum layak jadi bahan skripsi sampai T-00e selesai. Kalau datanya diperbarui nanti: hapus seluruh dokumen `lapangan` di Firebase Console, lalu jalankan ulang tombol "Isi Data Awal". Tile dan file `admin_seed_screen.dart` tetap WAJIB dihapus setelah dipakai di project produksi — jangan sampai ikut ke APK yang dibagikan ke responden SUS (T-31).
>
> **Testing manual pertama (20 Agustus 2026):** dijalankan di emulator Android sungguhan lewat jembatan lama (`seedPrototipe`, 7 lapangan). Home, Detail Lapangan (badge T-36, rating, favorit ♡), pencarian, dan alur reservasi dicoba langsung. Ketemu satu bug nyata — dicatat di `PRD.md` "Koreksi teknis" #8: lapangan yang tutup jam `00:00` (tengah malam) tidak pernah punya jam tersedia di form Ajukan Reservasi (L-10), karena jam tutup dibaca literal sebagai `0` alih-alih tengah malam. Sudah diperbaiki dan diverifikasi ulang (submit reservasi berhasil, notifikasi masuk ke mitra).
>
> **Testing manual kedua (21 Agustus 2026):** setelah T-10 sungguhan (30 lapangan) dijalankan, alur reservasi diuji ujung-ujung dengan dua akun baru — `pengguna.demo@sportspace.test` (role `pengguna`) mengajukan reservasi, `mitra.demo2@sportspace.test` (role `mitra`) menerimanya lewat Dashboard Mitra. **Berhasil, tanpa bug baru.** Diingatkan lagi (bukan bug, sudah tercatat di PRD "Koreksi teknis" #6): notifikasi `BOOKING_DIKONFIRMASI`/`BOOKING_DITOLAK` yang diterima pemesan belum berpindah layar kalau ditekan — pemesan harus cek manual lewat Profil → Riwayat Pemesanan. Kandidat perbaikan kecil untuk T-28 kalau ada waktu lebih; kalau tidak, aman dicatat sebagai keterbatasan di Bab 5.
>
> **Catatan infrastruktur — bukan bug kode, tapi sempat menghabiskan waktu banyak saat testing:** VPN/Cloudflare WARP yang aktif di komputer host memutus koneksi internet emulator Android ke Firebase, meski status jaringan di emulator terlihat normal ("VALIDATED"). Gejalanya menyesatkan — mirip bug: transaction Firestore native crash tiba-tiba (`AssertionError: transaction object cannot be used after update callback`), Home menampilkan data lama yang seharusnya sudah terhapus, registrasi akun baru macet tanpa pesan error. **Kalau ketemu gejala serupa saat testing di emulator, matikan dulu VPN/WARP sebelum curiga ke kode.** Setelah WARP dinonaktifkan dan emulator di-cold-boot ulang, semuanya jalan normal.
>
> Ini sinyal bagus untuk mulai T-30 (Black Box) begitu T-06 dan T-00e beres — kemungkinan ada bug serupa lain yang baru ketemu lewat testing sungguhan, bukan cuma `flutter analyze`.

> Minggu 11 semula terlihat padat karena empat tugas v1.1 menumpuk di sana (T-35, T-36, T-37, T-38) — semuanya sudah selesai.
