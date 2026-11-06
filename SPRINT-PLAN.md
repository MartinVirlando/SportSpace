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
| T-00d | ~~Upgrade ke paket Blaze **dan pasang budget alert** di Google Cloud Console~~ — **diganti 8 Oktober 2026: tetap di paket Spark (gratis)** | 1 orang | Keputusan tercatat (lihat catatan di bawah) |
| T-00e | ~~Survei manual lapangan: konfirmasi harga, jam, dan fasilitas untuk 8 lapangan bertanda `observasi` di `SEED-DATA.md`~~ — **dibatalkan 8 Oktober 2026** | Bertiga | — |
| **T-00f** | **Verifikasi koordinat 25 lapangan lewat Google Maps** (klik kanan pin → salin koordinat) | Bertiga | Seluruh entri `seed_lapangan.dart` punya koordinat asli |

> **T-00d penting** *(catatan awal — digantikan keputusan 8 Oktober 2026 di bawah)*. Dengan pemakaian skripsi, tagihan realistis Rp 0 karena kuota gratis tidak akan tersentuh. Tapi tanpa budget alert, satu bug perulangan tak terbatas bisa jadi masalah.
>
> **Keputusan T-00d (8 Oktober 2026): project tetap di paket Spark, tidak upgrade ke Blaze.** Seluruh layanan yang dipakai (Firestore termasuk composite index, Authentication Email/Password) jalan penuh di Spark. Cloud Functions, Cloud Messaging, dan Storage yang butuh Blaze memang sengaja tidak dipakai (lihat CLAUDE.md dan PRD §12b). Di Spark tidak ada tagihan sama sekali: kalau kuota harian habis, layanan berhenti sampai kuota pulih, bukan menagih. Jadi budget alert tidak diperlukan. Ini juga sudah sejalan dengan Bab 2.9 `Highlight_2` yang menyebut paket Spark.
>
> **T-00e dibatalkan (8 Oktober 2026).** Survei lapangan tidak dilakukan. Klaim "observasi langsung peneliti" sudah dicabut dari skripsi (PRD §14 "Putaran revisi 2"), dan harga/jam/fasilitas lapangan non-mitra ditulis sebagai **estimasi**. Badge "🏅 Terverifikasi" yang bergantung pada survei ini juga sudah dihapus.
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
| T-10 | `AdminSeedScreen` + masukkan 30 lapangan ke Firestore | C | T-03, ~~T-00e~~ (dibatalkan), **T-00f** | Data tampil di Firebase Console |
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
| **T-36** | Badge status "Mitra Terdaftar" dan "Terverifikasi" di L-06 — **AB-11** *(badge "Terverifikasi" dihapus 7 Oktober 2026, BB-33/BB-34 diubah — lihat PRD AB-11)* | C | T-13 | BB-33, BB-34 lulus |
| **T-37** | Olahraga favorit + lokasi default di Profil, dan cadangan lokasi di AB-03 | A | T-27, T-09 | BB-35 lulus |
| **T-38** | Statistik profil (Booking · Aktivitas · Favorit) dengan `count()` — **AB-12** | A | T-27, T-35 | BB-36 lulus |

> **T-20, T-21, T-23 adalah tiga tugas tersulit** karena melibatkan Firestore Transaction. Kerjakan bertiga bareng kalau perlu. Baca ulang PRD AB-04, AB-05, AB-06 sebelum mulai — terutama catatan bahwa transaction **tidak bisa** menjalankan Query.
>
> **T-35 dan T-36 justru termasuk paling mudah.** T-36 murni tampilan dari data yang sudah ada (kira-kira 30 menit). T-35 tidak butuh transaction karena operasinya satu dokumen. Keduanya bagus dikerjakan sebagai selingan setelah T-23 yang melelahkan.

**Demo akhir Sprint 4:** seluruh alur berjalan ujung ke ujung — cari lapangan, simpan favorit, buat aktivitas, gabung, terima permintaan, beri rating, ajukan reservasi, mitra mengonfirmasi.

### v1.2 — lima penambahan pasca-Sprint 4 (15 September 2026)

| ID | Tugas | Bergantung | Selesai jika |
|---|---|---|---|
| **T-41** | Favorit dipindah dari L-13 ke tombol toggle ♥ di search bar L-04 — **AB-10 lanjutan** | T-35 | Toggle menyaring tanpa mengubah urutan jarak; daftar di L-13 dihapus, kotak angka tetap |
| **T-42** | Search bar + daftar saran ala Google Maps di Map (L-05) — fitur baru di luar PRD awal | T-14 | Marker tersaring nama/alamat; saran muncul selagi fokus+ada kata kunci; tap saran auto-pan + kartu ringkas; pesan kosong-hasil beda dari kosong-total |
| **T-43** | Foto profil dari galeri (opsional) di Edit Profil, disimpan Base64 di Firestore — pendekatan ketiga di luar Opsi A/B (§12b) | T-27 | Pilih foto via `image_picker`, kompres otomatis, tersimpan & tampil, jatuh balik ke inisial kalau kosong/gagal. Tanpa Firebase Storage/Blaze |
| **T-44** | Atribut `nomorTelepon` pada `lapangan` — kontak, opsional | T-03, T-26 | Field tampil di L-06 (hanya kalau terisi), bisa diisi/diubah lewat form mitra L-15 |
| **T-45** | Batalkan keikutsertaan aktivitas — **AB-06 lanjutan** | T-20 | Peserta (bukan pembuat) bisa keluar, slot & status disesuaikan via transaction, bisa gabung ulang |

> **Kelimanya sudah selesai secara kode** (15 September 2026) — diverifikasi `flutter analyze` bersih, `flutter test` hijau, pemeriksaan lapisan MVVM bersih, dan diuji manual langsung di emulator lewat `adb`/`uiautomator` untuk tiap fitur (toggle favorit, search Map, ganti foto profil, isi kontak lapangan lewat Dashboard Mitra, batalkan keikutsertaan aktivitas — semua jalur bahagia terverifikasi berfungsi). PRD.md (§6.1, §6.2, §7 AB-06/AB-10, §8 L-04/L-05/L-06/L-09/L-13/L-15, §12b, §14) dan CLAUDE.md sudah diperbarui mengikuti. **Belum masuk T-30 Black Box formal** — lima fitur ini di luar 37 kasus BB-01…BB-37 yang sudah didefinisikan PRD §11; kalau mau diuji formal, perlu kasus BB baru ditambahkan dulu.
>
> **Verifikasi menyeluruh sebelum merge (15 September 2026)** — sebelum push ke `main`: `./gradlew assembleDebug` BUILD SUCCESSFUL, lalu APK debug baru di-*install ulang dari nol* (bukan hot reload) dan seluruh alur v1.2 diuji ulang: kontak lapangan tampil & persisten lewat restart, "Lihat di peta" auto-pan dari L-06 ke L-05 tetap jalan, kotak statistik Profil termuat penuh tanpa nyangkut, foto profil persisten, dan — pengecekan khusus — Detail Aktivitas (L-09) dari sudut pandang **pembuat** dikonfirmasi TIDAK menampilkan tombol "Batalkan Keikutsertaan" (hanya peserta biasa yang punya tombol itu), sesuai batasan yang disengaja di T-45. Sempat ditemukan gejala "kotak statistik Booking/Aktivitas nyangkut di kondisi memuat" di sesi testing panjang (>1 jam, banyak switch akun) — dicek log `flutter run` penuh, tidak ada exception/error Firestore sama sekali, dan pulih total setelah restart aplikasi. Tidak terulang di seluruh pengujian fresh-install berikutnya, jadi disimpulkan kondisi sesaat terkait `Stream` Firestore yang idle lama, BUKAN regresi dari kode v1.2 — dicatat sebagai kandidat pengamatan lebih lanjut di T-30, bukan bug yang diperbaiki sesi ini.
>
> **"List teman" (sistem pertemanan) diusulkan lalu dibatalkan** — tidak menjawab rumusan masalah manapun di Bab 1 dan butuh entitas ERD baru sama sekali, beda dari kelima tugas di atas yang semuanya perluasan dari entitas yang sudah ada.

### Backlog terbuka — diusulkan 15 September 2026, belum dikerjakan

Awalnya empat saran dari audit kode setelah v1.2 selesai (T-46...T-49); T-49 (filter harga di Home) sudah dicoret dari rencana (15 September 2026) — diputuskan bukan kebutuhan aplikasi ini, bukan cuma ditunda. T-48 ternyata sudah selesai lebih dulu (lihat catatan di bawah) — backlog ini basi untuk item itu. Sisanya (T-46, T-47) sudah selesai juga. **Backlog ini sekarang kosong**, dipertahankan di sini sebagai riwayat.

| ID | Tugas | Kenapa | Bergantung | Catatan implementasi |
|---|---|---|---|---|
| **T-46** | Batalkan Booking (sisi pengguna) — AB-04 lanjutan | Security rules SUDAH punya komentar `// pemilik mengonfirmasi, pengguna membatalkan`; status `DIBATALKAN` sudah ada di enum; AB-04 sudah menyebut "saat booking ditolak atau dibatalkan: hapus `slotBooking` miliknya" — tinggal belum ada UI/method yang memanggilnya sama sekali | T-23 | `BookingRepository` baru punya `konfirmasiBooking`/`tolakBooking` (mitra)/`tandaiBookingSelesai` — tambah `batalkanBooking(booking)` (pengguna), hapus dokumen `slotBooking` terkait dalam transaction yang sama. UI: tombol di `_KartuRiwayatBooking` (Profil L-13), pola dialog konfirmasi sama seperti T-45 |
| **T-47** | Batalkan Aktivitas (sisi pembuat) — AB-06 lanjutan | `firestore.rules` SUDAH punya `allow delete: if ... pembuatId == uid`, tapi `AktivitasRepository` tidak punya method delete/batalkan sama sekali — pembuat yang berubah pikiran tidak punya jalan keluar | T-45 | Tambah `batalkanAktivitas(aktivitasId)` di `AktivitasRepository` (hapus dokumen + kirim notifikasi ke seluruh peserta). UI: tombol di Detail Aktivitas (L-09), hanya tampil kalau `apakahPembuat == true` |

> T-46 dan T-47 paling direkomendasikan duluan — fondasinya (security rules, status enum, pola kode dari T-45) sudah ada, tinggal disambung.

> **T-46 dan T-47 SELESAI (15 September 2026).** `BookingRepository.batalkanBooking()` dan `AktivitasRepository.batalkanAktivitas()` ditambahkan mengikuti pola transaction idempoten yang sudah ada (`tolakBooking`/`batalkanKeikutsertaan`). `flutter analyze` bersih, `flutter test` hijau, pemeriksaan lapisan MVVM bersih, `./gradlew assembleDebug` BUILD SUCCESSFUL, dan kedua alur diuji manual di emulator lewat `adb`/`uiautomator` dengan Firestore produksi sungguhan: booking baru dibuat lalu dibatalkan (status langsung `Dibatalkan`, tombol hilang), aktivitas dengan peserta lain dibatalkan (SnackBar sukses, kartu langsung hilang dari "Aktivitas Saya" lewat live stream). **Satu penyesuaian dari rencana awal:** subkoleksi `permintaan` pada aktivitas yang dibatalkan SENGAJA tidak ikut dihapus — dicoba, tapi `firestore.rules` cuma izinkan pemilik dokumen `permintaan/{userId}` menghapusnya sendiri, bukan pembuat aktivitas, jadi kalau dipaksakan transaction gagal `permission-denied` begitu ada peserta lain. Dokumen itu jadi yatim tapi tidak mengganggu fungsi apa pun (tidak ada kode yang membacanya tanpa aktivitas induk juga ada).

> **T-48 TERNYATA SUDAH SELESAI (ditemukan 15 September 2026, dikerjakan sebenarnya 14 September 2026 di commit `a01caa9`).** Backlog ini salah — audit kode yang menghasilkan daftar T-46...T-49 tidak mengecek riwayat commit/PRD terbaru sebelum menandai T-48 sebagai belum dikerjakan. Notifikasi `BOOKING_DIKONFIRMASI`/`BOOKING_DITOLAK` **sudah** berpindah ke tab Profil saat ditekan sejak commit itu (`ShellNavigasiState.pindahKeTab()` + `AppRoutes.kunciShell`, sudah didokumentasikan PRD.md sebagai "Koreksi #6 akhirnya ditutup"). Diverifikasi ulang 15 September dengan skenario nyata dua akun (mitra konfirmasi booking → pengguna dapat notifikasi → tap → langsung ke Profil dengan status benar) — tidak ada kerja tersisa.

> **Verifikasi ulang + fitur baru (16 September 2026).** Sebelum push commit T-46/T-47 ke GitHub, dijalankan verifikasi menyeluruh di build baru: `flutter analyze` bersih, `flutter test` hijau, aturan lapisan bersih, lalu kedua alur (batalkan booking, batalkan aktivitas) diuji ulang end-to-end di emulator memakai akun uji tetap yang baru dibuat (lihat di bawah) — **lulus, tidak ada regresi**. Di sesi yang sama juga dikerjakan: (1) ikon aplikasi diganti dari ikon bawaan Flutter jadi logo asli (`assets/images/logo.jpg`) lewat package `flutter_launcher_icons` (dev-only); (2) splash screen (L-01) diperbarui memakai logo asli + badge fitur, dan **tombol "Mulai Sekarang" dibangun** (kebalikan dari keputusan sebelumnya yang auto-pindah tanpa tombol) — pengecekan status login tetap jalan di latar belakang sejak splash dibuka, jadi begitu tombol ditekan biasanya langsung pindah tanpa jeda tambahan; (3) label aplikasi Android diperbaiki dari `sport_space` mentah jadi "Sport Space" di `AndroidManifest.xml`. `PRD.md` §4/§8 L-01/L-09/L-13/§11 (BB-38, BB-39)/§14 diperbarui mengikuti.
>
> **Firebase dibersihkan dari akun/data test yang menumpuk (16 September 2026).** 8 akun test dari sesi-sesi sebelumnya (`qa1`, `qa2`, `*.bb`, `*.demo*`) dihapus dari Firebase Console (Authentication + dokumen `users` + lapangan test "Lapangan QA Mitra"/"Lapangan Uji BB" + data terkait), termasuk satu dokumen `users/{uid}` yatim tanpa akun Auth. **Dua akun asli milik teman yang benar-benar mencoba aplikasi (`jete@gmail.com`, `andri@gmail.com`) sengaja TIDAK disentuh.** Sebagai gantinya ditetapkan **dua akun uji tetap** yang harus dipakai terus untuk testing manual ke depan — didaftarkan lewat halaman Daftar di app (bukan Console), didokumentasikan di `PRD.md` §10 "Akun Uji (QA)":
>
> | Peran | Surel | Kata Sandi |
> |---|---|---|
> | Pengguna | `pengguna.uji@sportspace.test` | `Testing123` |
> | Mitra | `mitra.uji@sportspace.test` | `Testing123` |

### Kontrol zoom di Map — T-50 (21 September 2026)

| ID | Tugas | Bergantung | Selesai jika |
|---|---|---|---|
| **T-50** | Tombol zoom +/− di Map (L-05), plus batas zoom 3–18 konsisten untuk tombol/pinch/scroll — fitur baru di luar PRD awal | T-14 | Tombol menambah/mengurangi satu level zoom per tekan; `MapOptions.minZoom`/`maxZoom` di-set 3/18 supaya pinch dan scroll mouse bawaan `flutter_map` ikut batas yang sama |

> **T-50 SELESAI (21 September 2026).** Sebelum menulis kode, dicek dulu ke source `flutter_map-7.0.2` di pub cache (`interaction.dart`, `interactive_flag.dart`) — ternyata pinch-zoom dan scroll-wheel-zoom **sudah aktif sejak awal** lewat `InteractiveFlag.all` (default `MapOptions.interactionOptions`, tidak pernah di-override kode ini), jadi tidak butuh kode tambahan untuk itu. Yang ditambahkan cuma dua tombol +/− (pola sama dengan tombol recenter T-14: murni `_mapController.move()` di View, tidak menyentuh `MapViewModel`/Firestore) dan `minZoom`/`maxZoom` di `MapOptions` supaya batas 3–18 berlaku sama untuk tombol, pinch, maupun scroll. `flutter analyze` bersih, diuji langsung di emulator (`sport_space_avd`) via `adb`: zoom in sampai level jalan, zoom out ditekan 14x berturut-turut berhenti tepat di level 3 (bukan terus turun), recenter tetap kembali ke zoom 14. PRD.md §8 L-05, §11 (BB-40), §14 diperbarui mengikuti. **Belum diuji pinch/scroll sungguhan** (emulator tidak dikendalikan lewat gesture multi-touch/mouse asli di sesi ini) dan **belum verifikasi di perangkat Android nyata** sesuai Definisi Selesai PRD §12 poin 1.

### Koreksi data lapangan + link Google Maps + kontak — T-51 (21 September 2026)

| ID | Tugas | Bergantung | Selesai jika |
|---|---|---|---|
| **T-51** | Cek manual 30 lapangan ke Google Maps, koreksi yang meleset; tambah `nomorTelepon`/`tautanMaps` ke seluruh 30 lapangan; tombol "Buka di Google Maps" (L-06) — fitur baru di luar PRD awal | T-10, T-44 | 30/30 lapangan terverifikasi manual; 3 koordinat yang meleset dikoreksi; 2 lapangan multi-olahraga namanya mencerminkan itu; tombol Maps eksternal berfungsi dan hanya tampil kalau `tautanMaps` terisi |

> **T-51 SELESAI (21 September 2026).** User cek manual satu-per-satu 30 lapangan ke Google Maps (di luar sesi ini, hasilnya diserahkan sebagai daftar link + nomor telepon + catatan revisi). Temuan: 3 koordinat meleset (MS Sport Arena, Arsa Sport Mini Soccer, Mad Padel Club BSD) — dikoreksi; Raw Futsal ternyata multi-olahraga (futsal & badminton) sama seperti Taruna Futsal yang sudah ada — `jenisOlahraga` ditambah, kedua nama diganti jadi "... & Badminton" supaya kelihatan dari daftar tanpa buka detail. Field baru `tautanMaps` ditambahkan ke `LapanganModel`/skema, package `url_launcher` ditambah (izin diberikan user), tombol "Buka di Google Maps" ditambahkan di L-06 berdampingan dengan "Lihat di peta" yang sudah ada (internal, ke tab Map — beda tujuan). Data didorong ke Firestore produksi lewat hapus-koleksi-lalu-reseed dari akun `mitra.uji` (bukan `.update()` — `firestore.rules` tidak mengizinkan untuk 25/30 lapangan non-mitra), dengan konsekuensi rating/favorit lama ter-reset (disetujui, data uji bukan data sidang). Diverifikasi di emulator: urutan jarak Home cocok hitungan ulang, "Raw Futsal & Badminton" muncul benar di pencarian, tombol Maps membuka aplikasi Google Maps asli (dicoba di Sabnani Football), Kontak tampil benar. `flutter analyze` bersih, aturan lapisan MVVM bersih, `flutter test` hijau. `PRD.md` §4/§6.2/§8 L-06/"Koreksi teknis" dan `docs/SEED-DATA.md` diperbarui mengikuti. **Belum diverifikasi di perangkat Android nyata** sesuai Definisi Selesai PRD §12 poin 1, dan baru 5/30 lapangan yang benar-benar dilihat ulang tampilannya di emulator pasca-reseed (sisanya diasumsikan benar dari data yang sama, belum dicek visual satu-satu).

### Ide masa depan (masih riset): harga/jam per jenis olahraga — 21 September 2026

Ditemukan saat verifikasi manual data lapangan (T-51 di atas): **Raw Futsal** di Google Maps ternyata juga menyediakan badminton (bukan cuma futsal), sama seperti pola **Taruna Futsal** (`['futsal', 'badminton']`, satu-satunya lapangan multi-olahraga yang sudah ada sebelum T-51). Skema `jenisOlahraga: List<String>` sudah mendukung satu lapangan dengan >1 jenis olahraga — itu bukan masalah. **Yang belum didukung:** `harga`/`hargaSlot`/`jamBuka`/`jamTutup` itu satu set nilai per dokumen lapangan, berlaku rata untuk semua jenis olahraga di venue itu — padahal di dunia nyata futsal dan badminton di venue yang sama bisa beda harga dan beda jam.

**Keputusan yang sudah dieksekusi (T-51):** untuk Raw Futsal, ikuti pola Taruna Futsal — tambahkan `'badminton'` ke `jenisOlahraga`, harga/jam tetap satu nilai (simplifikasi, ditulis sebagai keterbatasan di Bab Keterbatasan Penelitian).

**Ide untuk nanti (kalau user memutuskan mau dikerjakan):** harga/jam per jenis olahraga, misalnya `hargaPerOlahraga: {'futsal': {...}, 'badminton': {...}}` menggantikan/mendampingi field `harga` datar. Bukan rombak arsitektur (tidak perlu package/Cloud Functions baru), tapi menyentuh 3 tempat:
1. `LapanganModel` — skema nested per jenis olahraga.
2. **Mekanisme kunci slot booking** (PRD "hal paling gampang salah" #1) — ID dokumen `slotBooking/{lapanganId}_{tanggal}_{jam}` perlu jadi `{lapanganId}_{jenisOlahraga}_{tanggal}_{jam}`, supaya booking futsal dan badminton di venue yang sama tidak saling kunci slot yang salah. Ini bagian paling sensitif — bukan cuma tambah field, harus diubah hati-hati karena ini fondasi anti-double-booking.
3. UI Home card / Detail Lapangan / alur booking (AB-04) — perlu pilih jenis olahraga dulu baru harga & jam yang relevan ditampilkan.

Hanya berdampak ke 2 dari 30 lapangan saat ini (Taruna Futsal, Raw Futsal). Tidak urgent, belum masuk PRD, tunggu keputusan eksplisit user sebelum dikerjakan.

> **Status 8 Oktober 2026: masih riset.** Tim sedang mencari tahu apakah harga/jam per jenis olahraga perlu dibuat. Belum diputuskan, belum dikoding.

### DIBATALKAN: banyak foto per lapangan (T-52) — diusulkan 22 September 2026

Muncul saat isi coba `fotoURL` pertama kali (T-40 lanjutan, pakai link eksternal Google Drive — PostImages/ImgBB/Imgur ternyata diblokir ISP Indonesia, lihat catatan di bawah). Home card dan Detail Lapangan **sudah otomatis menampilkan foto** begitu `fotoURL` terisi (`kartu_lapangan.dart`, `detail_lapangan_screen.dart` sudah `CachedNetworkImage` dari `fotoURL.first`, tidak perlu perubahan kode). Yang belum ada: dukungan **lebih dari satu** foto per lapangan.

**Update 23 September 2026:** seluruh 30 lapangan sudah selesai diisi `fotoURL` (1 foto per lapangan, via Google Drive, diverifikasi `curl` satu-satu — detail di `docs/SEED-DATA.md`). Ditemukan bug layout saat verifikasi (bukan soal T-52): kartu Home tidak punya `height` tetap di thumbnail, jadi kartu dengan foto potret (mis. Hey Beach Padel Club) jadi lebih tinggi dari kartu lain — sudah diperbaiki (commit `ff8e38d`, lihat `PRD.md` §12b). T-52 (dukung >1 foto) di bawah ini tetap backlog terpisah, belum dikerjakan.

| ID | Tugas | Bergantung | Selesai jika |
|---|---|---|---|
| **T-52** | Dukung banyak `fotoURL` per lapangan — form Tambah/Edit Lapangan bisa tambah beberapa URL, Detail Lapangan tampilkan sebagai carousel/`PageView` bergeser (bukan cuma `.first`) | T-40 | Mitra bisa simpan >1 URL foto lewat form; Detail Lapangan bisa geser antar foto dengan indikator halaman; Home card tetap 1 thumbnail (`.first`) |

**Catatan penting — pilihan host foto:** jangan sarankan PostImages/ImgBB/Imgur ke mitra. Ketiganya diverifikasi **diblokir ISP Indonesia** (TLS reset/sertifikat palsu di dua jaringan berbeda; normal begitu lewat VPN). **Google Drive** (`https://drive.google.com/uc?export=view&id=FILE_ID`, dari link share file "Anyone with the link") terverifikasi jalan tanpa VPN — pakai ini sebagai rekomendasi ke mitra selama belum didokumentasikan ulang di tempat lain.

> **T-52 dibatalkan (8 Oktober 2026).** Satu foto per lapangan (`fotoURL.first`) dianggap cukup. Tidak akan dikerjakan; bagian ini disimpan sebagai riwayat saja.

### DIBATALKAN: aktivitas cari rekan tampil di Detail Lapangan (T-53) — diusulkan 22 September 2026

> **T-53 dibatalkan (8 Oktober 2026).** Tidak pernah dikoding, tidak akan dikerjakan. Bab 3 juga tidak perlu use case/diagram baru untuk ini (PRD §14 #37 ikut gugur). Bagian di bawah disimpan sebagai riwayat saja.

Ide dari user: saat ini "cari lapangan" (Home/Map) dan "cari rekan main" (tab Teman) dua silo terpisah — padahal `AktivitasBermainModel` **sudah** punya field `lapanganId`, jadi setiap aktivitas sebenarnya sudah terikat ke lapangan tertentu, cuma belum ditampilkan di situ. Usulan: tampilkan section kecil di Detail Lapangan berisi aktivitas yang masih buka di lapangan itu (mis. "Jam 19:00 · kurang 2 orang"), supaya orang yang lihat lapangan langsung tahu ada yang bisa digabung tanpa pindah tab.

| ID | Tugas | Bergantung | Selesai jika |
|---|---|---|---|
| **T-53** | Tampilkan aktivitas cari rekan (status masih buka, `lapanganId` cocok) sebagai section di Detail Lapangan (L-06), tiap item bisa tap ke Detail Aktivitas (L-09) | T-13, T-19 | Section muncul kalau ada aktivitas terkait, tersembunyi/pesan kosong kalau tidak ada (bukan section kosong polos); tap item membuka Detail Aktivitas yang benar |

**Sudah dicek, bukan penghalang:**
- Data: `lapanganId` sudah ada di `AktivitasBermainModel`, tidak perlu ubah skema.
- Security Rules: `aktivitasBermain` sudah `allow read: if login()` untuk semua dokumen — tidak perlu ubah `firestore.rules`.

**Belum dicek, perlu sebelum mulai:**
- **Index Firestore baru** — `FIRESTORE-INDEXES.md` belum punya index dengan `lapanganId` sebagai filter untuk `aktivitasBermain` (yang ada baru `status`+`waktu`, `status`+`jenisOlahraga`+`waktu`, `pembuatId`+`waktu`, `peserta`+`waktu`). Query baru (`lapanganId` == ini + kemungkinan `status`/`waktu`) perlu index baru ditambahkan ke `firestore.indexes.json` lalu `firebase deploy`.
- **Persetujuan Pak Gintoro** — ini di luar PRD v1.1, sama seperti pola keputusan T-40/T-50/T-51: perlu didiskusikan dulu apakah ini "pengembangan dari AB-10/AB-06 yang sudah ada" atau perlu use case/activity diagram baru di Bab 3 (user sudah setuju 22 September 2026 kalau ini kemungkinan besar butuh diagram baru karena menggabungkan dua rumusan masalah sekaligus). **User baru ada waktu untuk hal-hal terkait skripsi di akhir pekan** — jangan tunggu jawaban ini di hari kerja.
- **Desain UI** — belum ada acuan Figma untuk section ini; perlu diputuskan tampilannya dulu (berapa item ditampilkan, urutan, gaya kartu) sebelum dikoding, konsisten dengan pola proyek ini (`app_colors.dart` dari Figma, bukan hex manual).
- **Kasus Black Box baru** — kalau jadi dibangun, perlu ditambahkan ke tabel BB-01...BB-37 (jadi BB-38 dst) untuk T-30/T-33.

### Catatan skripsi: `sumberData: 'places_api'` belum benar-benar dari Google Places API — diusulkan 23 September 2026

Ditemukan saat diskusi soal akurasi data seed (`docs/SEED-DATA.md`): 25 dari 30 lapangan berlabel `sumberData: 'places_api'` atau `'observasi'`, tapi datanya **sebenarnya dikumpulkan manual dari direktori booking (Gelora, Ayo Indonesia, Traveloka, portal lokal)**, bukan dari pemanggilan Google Places API sungguhan. Definisi resmi di `PRD.md` (baris 824) bilang `"places_api"` = "Google Places API, diambil manual di luar aplikasi" — jadi label yang dipakai sekarang **tidak cocok dengan definisinya sendiri di Bab 3**, dan user mengingat sudah menulis eksplisit "Google Places API" di skripsi (Bab 1-3).

**Rekomendasi yang diberikan (belum dieksekusi):** karena klaim itu sudah tertulis di skripsi, lebih aman **benar-benar memanggil Google Places API sekali secara offline** (script/manual query, di luar app — tidak melanggar larangan "Places API saat runtime") untuk cross-check nama/alamat/koordinat/jam 25 lapangan itu, lalu update `seed_lapangan.dart`, daripada melonggarkan kalimat metodologi di Bab 3. Kuota gratis bulanan Places API cukup untuk 25 lookup sekali jalan (kemungkinan Rp0, tapi setup API key di Google Cloud Console butuh kartu untuk verifikasi billing).

**Yang perlu dicek user dulu (bukan keputusan teknis):** apakah Bab 1-3 yang menyebut Google Places API itu sudah disetujui/direview Pak Gintoro (pembimbing) atau masih draft — kalau masih draft, opsi lain (revisi satu kalimat metodologi jadi "sumber daring publik") jadi lebih murah daripada setup API. **User baru ada waktu untuk hal terkait skripsi di akhir pekan** — jangan kejar jawaban ini di hari kerja, cukup dicatat di sini untuk ditindaklanjuti.

**Update 27 September 2026 — arah revisi diputuskan (masih diskusi, belum dieksekusi ke docx/kode).** Deadline pengumpulan akhir skripsi masih Januari, jadi revisi Bab 1-3 masih memungkinkan. Setelah didiskusikan, dipilih opsi yang **beneran gratis, tidak butuh kartu/API key sama sekali**: reframe klaim "Google Places API" jadi **"verifikasi manual via Google Maps + konfirmasi telepon"** — karena ini **sudah benar-benar dilakukan** di T-51 (cek satu-satu 30 lapangan ke Google Maps untuk koordinat/`nomorTelepon`/`tautanMaps`), bukan klaim baru yang perlu dikerjakan dari nol. Ini juga lebih kuat secara validitas data dibanding klaim API yang tidak bisa dibuktikan ke penguji.

**Yang masih perlu dikerjakan (pekerjaan user, bukan Claude):**
1. Revisi kalimat Ruang Lingkup §1.3 dari "Google Places API sekunder" jadi menyebut verifikasi manual Google Maps + konfirmasi telepon.
2. Update `PRD.md` §6.2 tabel definisi `sumberData` dan nilai string di `seed_lapangan.dart` (`'places_api'` → nama baru, mis. `'google_maps_manual'`) — kode ini bisa dibantu Claude begitu wording final disepakati.
3. **Harga/jam masih perlu dikonfirmasi manual lewat telepon** ke 17-25 venue (nomor telepon sudah ada dari T-51) — Google Maps biasanya tidak menampilkan tarif, jadi cek Maps saja tidak cukup untuk field ini. Ini pekerjaan telepon manual, tidak bisa dieksekusi Claude.

Detail lengkap ada di memory `project_skripsi_bab1-3_revisi` (item #7) dan `project_sumberdata_places_api`. Sama seperti item lain di atas: **akhir pekan saja**, jangan dikejar hari kerja.

> **Update 8 Oktober 2026.** Skripsi (`Highlight_2`) sudah tidak menyebut Google Places API maupun konfirmasi telepon. Sumber datanya: direktori pemesanan daring yang diverifikasi manual lewat Google Maps, harga/jam lapangan non-mitra ditulis sebagai **estimasi**. Butir 1 di atas selesai. Butir 3 (telepon) dibatalkan. **Butir 2 selesai 19 Oktober 2026:** `'places_api'` dan `'observasi'` digabung jadi `'direktori_daring'` di kode; 25 dokumen produksi diubah manual lewat Firebase Console.

### Forum — cabang `secondary` (Martin) di-merge ke `main` — 4 November 2026

Martin menggabungkan PR #1 (`secondary` → `main`, commit `fd8ef3c`): fitur Forum (post, komentar, edit, hapus, gambar), tab kelima "Forum" di `ShellNavigasi`, koleksi `forum_posts` + subkoleksi `komentar`, dan `docs/PENJELASAN-PROJECT.md`. **Forum bukan bagian dari PRD v1.1** — belum tercantum di PRD, dan PRD masih menyebut 4 tab.

**Hasil pengecekan pasca-merge (4 November 2026):** `flutter analyze` tanpa error (1 info trailing comma), `flutter test` 7/7 hijau, pemeriksaan lapisan MVVM bersih (tidak ada View/ViewModel yang mengimpor `cloud_firestore`), `firestore.rules` baru lolos `firebase deploy --only firestore:rules --dry-run`, `pubspec.yaml` dan `firestore.indexes.json` tidak berubah (query forum hanya satu `orderBy`, tanpa composite index). `detail_lapangan_screen.dart` tidak tersentuh, jadi tombol "Buka di Google Maps" (T-51) aman.

**Uji manual di emulator (4 November 2026, `sportspace_pixel`, Android 36, Firestore produksi, akun uji tetap PRD §10, build debug dari cabang `fix/forum-merge-rapikan`):** login Pengguna dan Mitra; Home (30 lapangan, urutan jarak naik benar: 1,0 → 1,9 → 3,5 → 3,6 → 3,9 → 4,3 km dari Alam Sutera) dan filter Futsal; Detail Lapangan lengkap termasuk "Buka di Google Maps" dan "Lihat di peta"; Map (tile OSM, titik lokasi, marker, tombol zoom/recenter); Teman (kondisi kosong); Profil (statistik, riwayat pemesanan); Notifikasi; Dashboard Mitra (5 lapangan, Booking Masuk); keluar akun. **Forum:** daftar post terbaca, buat post, komentar (hitungan 0 → 1), dan hapus post beserta komentarnya semuanya berhasil — post uji sudah dihapus sendiri, data forum kembali seperti semula. Logcat seluruh sesi: tidak ada `permission-denied`, `FirebaseException`, atau exception tak tertangani. **Uji lanjutan forum (setelah PRD v1.3 dan pengaman gambar, build baru):** BB-44 (post kosong ditolak "Post tidak boleh kosong."), BB-45 (gambar kecil tampil di kartu; gambar noise 7,9 MB tetap lolos karena `image_picker` mengompresnya ke 1024 px — jalur "Ukuran foto terlalu besar" tidak bisa dipicu di emulator), BB-47 (edit memunculkan "(diedit)"; menu Edit/Hapus tidak muncul di post milik orang lain), BB-48 (hapus post). Semua post uji sudah dihapus kembali, forum produksi seperti semula, logcat tanpa error. **Belum diuji:** BB-42 (kondisi forum kosong — butuh forum tanpa satu pun post), BB-49 (post orang lain ditolak Security Rules — tidak bisa dipicu lewat UI), batas 700.000 karakter di rules (belum di-deploy), alur tulis di luar forum (booking baru, buat aktivitas, rating — kodenya tidak tersentuh merge), dan HP fisik. Catatan: forum **tidak punya** edit/hapus komentar satuan, jadi tidak ada yang perlu diuji di sana.

**Dirapikan di cabang `fix/forum-merge-rapikan`:** `FavoritRepository` yang terdaftar dua kali di `main.dart`, satu baris kosong berlebih, trailing comma di `buat_post_screen.dart`, dan label tab `'Forum'` yang ditulis langsung (sekarang `AppStrings.forum`). Ditambah: **PRD v1.3** mencatat forum (ringkasan perubahan, §2, §5, §6.10–6.11, AB-13, L-16–L-18, §9, BB-42–BB-49, §12b, §14); `CLAUDE.md` mengizinkan Base64 untuk gambar forum dengan tiga lapis batas; pengaman `batasPanjangGambarBase64` di `ForumRepository` dan `gambarForumAman` di `firestore.rules`; `docs/FIRESTORE-INDEXES.md` mencatat bahwa query forum tidak butuh index.

**Masih terbuka:**
1. **Rules forum di Firestore produksi: kemungkinan besar sudah ter-deploy, tapi isinya belum dibandingkan dengan `firestore.rules` di repo.** Dugaan awal (4 November 2026) bahwa belum ter-deploy ternyata salah: akun uji Pengguna berhasil membaca post forum asli di emulator, padahal rules sebelum merge tidak punya aturan untuk `forum_posts`. Sebelum `firebase deploy --only firestore` berikutnya, pastikan file di repo sama dengan yang aktif di Firebase Console (Firestore → Rules) supaya tidak menimpa perubahan Martin. **`firestore.rules` di repo sekarang punya `gambarForumAman` yang belum ada di produksi** — batas gambar di rules baru aktif setelah `firebase deploy --only firestore:rules`.
2. **Forum sudah dicatat di PRD v1.3 (4 November 2026), tapi keputusan untuk skripsi belum diambil:** masuk Bab 3–4 (tab jadi 5, ERD 10 entitas, BB-42–BB-49; PRD §14 #38–#44) atau jadi pengembangan lanjutan di Bab 5. Konsultasikan dengan Pak Gintoro. Teks post juga belum dibatasi panjangnya.
3. ~~Gambar forum Base64 belum tercatat dan berisiko melewati 1 MB~~ — **selesai:** tercatat di PRD §12b dan `CLAUDE.md`, dijaga tiga lapis (500 KB mentah di View, 700.000 karakter di Repository dan rules). Dugaan awal bahwa gambar bisa melewati 1 MB ternyata tidak tepat: batas 500 KB di View memang sudah ada sejak awal (≈ 683.000 karakter Base64, di bawah 1.048.576 byte); yang kurang hanyalah pencatatannya.
4. Jalur 1 rules `update` post mengizinkan siapa pun menaikkan `jumlahKomentar` +1 tanpa harus membuat komentar. Tidak berbahaya untuk skripsi, tapi tercatat.

### Backlog v1.3 — usulan dari riset aplikasi AYO — dicatat 4 November 2026

Rincian, cara, dan alasan tiap usulan ada di `docs/IDE-FITUR-V1.3.md` (riset 19 Oktober 2026). **Status per 6 November 2026: seluruh 14 usulan (T-54…T-67) sudah masuk `main`**, ditambah T-68 (mode gelap, permintaan pemilik produk) serta T-69 dan T-70 (tahap 4, usulan AYO nomor 1 dan 5). Catatan asli per 4 November 2026: belum ada satu pun yang masuk. Semuanya di luar PRD v1.1 — sama pola T-40/T-50/T-51: butuh persetujuan Pak Gintoro dan kasus BB baru sebelum dikoding. Hanya T-67 yang butuh package baru (`CLAUDE.md`: minta izin dulu). Nomor tugas di bawah mengikuti nomor usulan di dokumen ide (T-53 + nomor usulan).

| ID | Usulan | Skala | Tahap | Status |
|---|---|---|---|---|
| T-54 | Jenis aktivitas: Main Bareng / Sparring (`jenisAktivitas`, chip filter di tab Teman) | Kecil | 1 | Kode selesai 5 Nov 2026 (analyze, 13 tes hijau); BB-50–51 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-55 | Tingkat kemampuan Pemula / Menengah / Mahir (field + filter Cari Rekan) | Kecil | 1 | Kode selesai 5 Nov 2026 (analyze, 19 tes hijau); BB-52–53 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-56 | Biaya per orang di aktivitas (informasi saja, bayar di lokasi) | Kecil | 1 | Kode selesai 5 Nov 2026 (analyze, 28 tes hijau); BB-54–55 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-57 | Sort dan filter lanjutan di Home (rating, Populer, fasilitas, "Buka sekarang"; sort harga perlu keputusan ulang karena T-49) | Kecil | 2 | Kode selesai 5 Nov 2026 (analyze, 78 tes hijau); BB-62–66 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-58 | Lencana pencapaian di Profil (dihitung dari statistik AB-12) | Kecil | 1 | Kode selesai 5 Nov 2026 (analyze, 36 tes hijau); BB-56–57 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-59 | Mitra: blokir slot manual (pakai kunci `slotBooking`) | Sedang | 2 | Kode selesai 5 Nov 2026 (analyze, 91 tes hijau); BB-67–69 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-60 | Produk tambahan saat booking (sewa bola, rompi) | Sedang–besar | 3 | Kode selesai 5 Nov 2026 (analyze, 133 tes hijau); BB-73–75 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-61 | Tombol WhatsApp di Detail Lapangan (`url_launcher` + `nomorTelepon`) | Kecil | 1 | Kode selesai 5 Nov 2026 (analyze, 55 tes hijau); BB-60–61 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-62 | Ubah jadwal booking / reschedule (satu transaction) | Sedang | 2 | Kode selesai 5 Nov 2026 (analyze, 147 tes hijau); BB-76–78 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-63 | Bagikan aktivitas atau lapangan ke WhatsApp (`wa.me`, tanpa package baru) | Kecil | 1 | Kode selesai 5 Nov 2026 (analyze, 46 tes hijau); BB-58–59 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-64 | Aktivitas publik atau privat (`visibilitas`, akses lewat kode) | Sedang | 3 | Kode selesai 5 Nov 2026 (analyze, 170 tes hijau); BB-79–82 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-65 | Promo atau diskon dari mitra | Kecil–sedang | 2 | Kode selesai 5 Nov 2026 (analyze, 111 tes hijau); BB-70–72 diuji di emulator 5 Nov 2026 (lihat catatan) |
| T-66 | Mitra membalas ulasan *(ide di luar AYO; disetujui pemilik produk 5 Nov 2026)* | Kecil | 3 | Selesai 5 Nov 2026; **mengubah Security Rules** — rules baru lulus 35 skenario di emulator Firestore lokal, di-deploy pengguna 6 Nov 2026, lalu **BB-86, 87, 88, 89 terbukti di perangkat** (BB-90 hanya lewat emulator rules; lihat catatan T-66) |
| T-67 | Pengingat jadwal booking, notifikasi lokal *(ide di luar AYO; disetujui pemilik produk beserta 3 package gratis, 5 Nov 2026)* | Sedang | 3 | Selesai 5 Nov 2026 (analyze bersih, 216 tes hijau); BB-91–95 diuji di emulator (lihat catatan T-67) |
| T-68 | Mode gelap (Terang / Gelap / Ikuti HP) dengan pemilih di Profil *(permintaan pemilik produk, bukan dari AYO; sebelumnya ditolak di §2.2)* | Besar | 3 | Selesai 5 Nov 2026 (analyze bersih, 238 tes hijau); BB-96–100 diuji di emulator (lihat catatan T-68) |
| T-69 | Cari rekan dari booking: tombol di Riwayat Pemesanan membuka Buat Aktivitas yang terisi dari booking *(usulan AYO nomor 1, dipilih pemilik produk 6 Nov 2026)* | Kecil | 3 | Selesai 6 Nov 2026 (analyze bersih, 254 tes hijau); BB-101–103 diuji di emulator (lihat catatan T-69) |
| T-70 | Riwayat main: aktivitas Profil dipisah mendatang vs sudah lewat *(usulan AYO nomor 5, dipilih pemilik produk 6 Nov 2026)* | Kecil | 3 | Selesai 6 Nov 2026 (analyze bersih, 269 tes hijau); BB-105 dan BB-107 diuji di emulator, BB-106 lewat tes otomatis (lihat catatan T-70) |

**Keputusan 5 November 2026:** Pak Gintoro menilai forum dan fitur terinspirasi AYO hanyalah **pemanis**; hanya modul besar yang perlu masuk Bab 3. Tim memutuskan mengerjakan **tahap 1 saja** (T-54, T-55, T-56, T-58, T-63, T-61) dan tidak menunggu persetujuan per fitur. Spesifikasinya ada di **PRD v1.4** ("Perubahan v1.4", AB-14, AB-15, BB-50…BB-61). T-31…T-34 (SUS, Bab 4–5) dan revisi gambar T-39 **menunggu fitur tahap 1 selesai**, supaya SUS menguji aplikasi versi akhir dan ERD digambar sekali saja. Tahap 2 dan 3 tidak dikerjakan sebelum tim konfirmasi lagi. **(Diperbarui 5–6 November 2026: tim lalu mengonfirmasi tahap 2 dan 3, T-66, T-67, mode gelap, dan dua usulan tahap 4 — semuanya sudah selesai; lihat tabel di atas.)**

**Hasil uji emulator 5 November 2026** (`sportspace_pixel`, Android 36, Firestore produksi, akun uji tetap PRD §10, build debug dari `main`). Seluruh fitur tahap 1, 2, dan 3 dijalankan lewat UI sungguhan:

| Terbukti di perangkat | Catatan |
|---|---|
| BB-50, 51, 52, 53, 54 | Aktivitas Sparring/Mahir/privat dan Main Bareng/Pemula/gratis dibuat; semua kombinasi chip filter jenis, tingkat, dan olahraga benar |
| BB-55 | Biaya 25000 tampil "Rp 25.000 / orang". Penolakan biaya negatif/di atas batas hanya diuji otomatis |
| BB-56, 57 | Akun baru 0/5; akun dengan 5 booking 2/5 dengan kartu menyala |
| BB-58, 59, 60, 61 | Teks bagikan aktivitas (memuat kode untuk pembuat) dan lapangan terbaca benar di `wa.me`; `081806507575` → chat `+62 818-0650-7575`; `0217429521` tanpa tombol |
| BB-62 | Setelah tim memberi rating ke lima lapangan: Rating tertinggi menampilkan Powerhouse 5,0 → Hey Beach 5,0 → Stadiums 5,0 → The Good Padel 3,0 → Sabnani 1,0, lalu seluruh lapangan tanpa ulasan di belakang dan berurut jarak (16,3 → 16,4 → 16,5 → 16,7 → 17,7 km); sesuai aturan seri-menurut-jarak. Reset kembali ke urutan jarak |
| BB-63 | Ulasan kedua ditambahkan dari akun `pengguna.uji` ke The Good Padel Club (sebelumnya 3,0 dari 1 ulasan milik `mitra.uji`; menjadi **4,0 dari 2 ulasan**). Terpopuler: The Good Padel (2 ulasan) **di posisi pertama**, di depan Powerhouse 5,0 yang hanya 1 ulasan; sisanya seri jumlah ulasan sehingga berurut rating lalu jarak. Rating tertinggi sebagai pembanding: The Good Padel (4,0) di belakang tiga lapangan 5,0. Reset kembali ke jarak |
| BB-64, 65, 66 | "Buka sekarang" diuji dengan mengubah jam emulator: pukul 23:30 tepat 8 lapangan (yang tutup `00:00`), pukul 03:00 pesan kosong. Fasilitas "shower" tepat 5 lapangan. Reset kembali ke bawaan |
| BB-67, 68, 69 | Blokir, buka blokir, dan jam yang dipesan tidak bisa disentuh |
| BB-70, 71, 72 | Badge dan harga coret di kartu dan Detail; estimasi Rp 350.000 − 70.000 + 30.000 = Rp 310.000 tersimpan di booking; diskon 91 ditolak |
| BB-73, 74 | Maksimal 5 produk; produk 2 × Sewa Raket tampil di Riwayat Pemesanan dan Booking Masuk, tidak ikut didiskon |
| BB-76, 78 | Ubah jadwal 20:00–22:00 → 21:00–23:00 (tumpang tindih): slot 20 terlepas, 21 dipertahankan, 22 dikunci; status kembali Menunggu; notifikasi sampai ke mitra; setelah dibatalkan tombol Ubah Jadwal hilang dan seluruh slot kosong |
| BB-79, 80, 81 | Kode `LGRCNK` (6 karakter), privat tidak tampil di daftar, huruf kecil diterima, kode salah "Kode tidak ditemukan.", dan **kode tidak terlihat oleh pengguna yang bukan pembuat/peserta** |
| BB-83, 84, 85 | **Perbaikan rating (5 November 2026, sore).** BB-83: pada The Good Padel (sudah dinilai `pengguna.uji`) lembar berjudul "Ubah Rating", 5 bintang terisi, keterangan "akan mengganti"; pada Beyond Padel (belum dinilai) form kosong berjudul "Beri Rating". BB-84: rating diubah 5 → 4 dari Detail yang dibuka lewat Home, kembali ke Home **tanpa menarik layar** → kartu langsung 3,5 (2); dikembalikan ke 5 → 4,0 (2), lembar saat itu terisi 4 bintang. BB-85: jaringan dimatikan lalu lembar dibuka pada lapangan yang belum pernah dibuka → "Gagal memuat ulasanmu sebelumnya. Coba lagi." + tombol Coba Lagi (bukan form kosong); jaringan dinyalakan, Coba Lagi membuka form |

**Belum terbukti di perangkat:**
- **BB-75** (harga produk berubah setelah booking), **BB-77** (rebutan slot saat ubah jadwal — butuh dua perangkat bersamaan), dan **BB-82** (aktivitas lama tanpa `visibilitas` — tidak ada aktivitas lama di data produksi): hanya diuji otomatis.
- WhatsApp sungguhan tidak terpasang di emulator; tautan `wa.me` terbuka di Chrome dan isinya diperiksa, tetapi membuka aplikasi WhatsApp belum.
- HP fisik belum.

**Bug yang ditemukan lewat uji emulator dan sudah diperbaiki (5 November 2026):**
1. **Spinner "Aktivitas Saya" di Profil tidak pernah selesai.** Stream siaran Firestore tidak mengulang event lama untuk pelanggan yang terlambat; `ListView` membangun bagian bawah secara malas, dan Lencana (T-58) mendorong bagian itu lebih jauh sehingga bug laten ini muncul. Perbaikan: `core/utils/stream_terakhir.dart` (satu langganan, nilai terakhir diulang ke tiap pelanggan baru), dipakai `ProfilViewModel`. Terverifikasi: tampil "Belum ada aktivitas yang kamu buat atau ikuti."
2. Pesan kosong di Cari Rekan menyalahkan "filter" padahal tidak ada filter dipilih (satu-satunya aktivitas privat). Sekarang memakai pesan biasa kalau filter jenis dan tingkat tidak aktif.
3. Tinggi kartu Lencana tidak seragam dan isinya tidak rata.

**Uji ulang menyeluruh (5 November 2026, sore, build debug dari `main`):** seluruh alur AYO dijalankan ulang di emulator sebagai pengguna uji dan mitra uji, dari login sampai pembersihan. Hasilnya sama dengan di atas, dan satu temuan baru:
4. Teks `kosongAktivitas` masih berbunyi "Belum ada aktivitas untuk filter ini." walau semua filter berstatus "Semua" (perbaikan nomor 2 hanya membetulkan logikanya, bukan kalimatnya). Sekarang "Belum ada aktivitas yang bisa diikuti." — terverifikasi di perangkat setelah build ulang.

Yang terbukti pada uji ulang: filter dan urutan Home (kombinasi Terpopuler + Buka sekarang + parkir + mushola, lalu Reset kembali berurut jarak); blokir dan buka blokir slot oleh mitra; jam yang diblokir tampil "Penuh" di form reservasi, dan durasi 2 jam di 09:00 ikut "Penuh" karena menabrak 10:00; diskon 20% (harga coret, lencana, rincian estimasi); produk tambahan (validasi harga kosong, 2 × Rp 30.000); total Rp 350.000 − 70.000 + 60.000 = Rp 340.000 tersimpan di booking; Ubah Jadwal 20:00 → 21:00 (jam 20 bebas, jam 22 terkunci, mitra dapat notifikasi, status Menunggu); Atur Slot menampilkan "Dipesan" yang tidak bisa diubah; Tolak booking; aktivitas Publik (kartu, filter jenis, validasi 2–30 pemain) dan Privat (kode 6 karakter, tersembunyi dari daftar, terbuka lewat "Punya kode?" dengan huruf kecil); Batalkan Aktivitas; Bagikan ke WhatsApp (membuka `api.whatsapp.com` di Chrome); Profil tanpa spinner menggantung.

Catatan desain yang ditemukan saat uji ulang (bukan bug kode, perlu keputusan tim):
- ~~**Lencana "Langganan Lapangan" ikut menghitung booking `DIBATALKAN`.**~~ **Sudah diperbaiki (6 November 2026, T-28).** Dipilih opsi "hitung hanya `DIKONFIRMASI`/`SELESAI`": `hitungLencana` menerima angka tambahan `jumlahBookingTerkonfirmasi`; Pemesan Pertama tetap menghitung semua status. Syarat di layar: "Dapat 5 booking terkonfirmasi". PRD AB-14 disesuaikan.
- ~~Tanggal di kartu riwayat dan teks notifikasi tampil sebagai `2026-11-27`.~~ **Sudah diperbaiki (6 November 2026, T-28)** lewat `Formatter.tanggalDariTeks()` di kartu Riwayat (Profil), kartu Booking Masuk (Dashboard Mitra), dan teks notifikasi ubah jadwal. Notifikasi yang sudah tersimpan sebelumnya tetap berformat lama (teksnya disimpan jadi di Firestore).
- ~~Kartu lapangan di Dashboard Mitra tidak menandai diskon yang sedang aktif.~~ **Sudah diperbaiki (6 November 2026, T-28):** pil "Diskon X%" (`LabelDiskon`) tampil di bawah harga.
- ~~Setelah lembar Filter & Urutkan ditutup, keyboard bisa muncul lagi.~~ **Sudah diperbaiki (6 November 2026, T-28)** dan terbukti di emulator. Percobaan pertama memakai `FocusScope.of(context).unfocus()` **gagal** (setelah lembar ditutup, kursor dan keyboard kembali): perintah itu hanya membersihkan riwayat fokus scope induk, sedangkan scope layar Home masih mengingat kolom pencarian. Yang benar `FocusManager.instance.primaryFocus?.unfocus()`. Diukur lewat `dumpsys input_method` (`mInputShown`): fokus → true, lembar terbuka → false, lembar ditutup → false, tanpa kursor.
- ~~Pesan galat harga produk di form mitra terpotong.~~ **Sudah diperbaiki (6 November 2026, T-28):** kolom harga diberi `errorMaxLines: 3` dan dilebarkan.

**Catatan T-28 (rapikan akhir, 6 November 2026):** enam perubahan di atas ditambah satu perubahan tampilan atas permintaan pemilik produk — **filter Cari Rekan (L-07) dipadatkan**. Jenis aktivitas dan tingkat kemampuan dipindah dari dua baris chip ke lembar bawah "Filter Aktivitas" (`lembar_filter_aktivitas.dart`) yang dibuka ikon Filter di ujung kanan baris chip olahraga, sehingga layar memakai satu baris, bukan tiga. Titik hijau pada ikon menandai filter aktif, dan baris ringkasan "Filter: Sparring · Pemula" muncul hanya saat ada filter aktif. Reset hanya mengembalikan jenis dan tingkat. `BarisChipFilter` dihapus karena tidak terpakai. Murni tampilan: `saringAktivitas`, query, index, dan Security Rules tidak berubah. `AktivitasViewModel` dipasang di dalam tab Teman, bukan global, jadi lembar bawah menerimanya lewat `ChangeNotifierProvider.value`.
- **Status verifikasi:** `flutter analyze` bersih, 272 tes hijau (tes baru: `formatter_tanggal_test.dart`, dan `lencana_test.dart` diperluas), pemeriksaan lapisan MVVM bersih. **Dilihat di emulator (6 November 2026, `pengguna.uji` dan `mitra.uji`, mode terang dan gelap):**
  - *Cari Rekan:* satu baris dengan ikon Filter di kanan; lembar Filter Aktivitas terbuka; Reset nonaktif saat belum ada filter dan aktif sesudah memilih; titik hijau dan ringkasan "Filter: …" muncul hanya saat filter aktif dan hilang setelah Reset; layar terbaca baik di mode gelap.
  - *BB-51 dan BB-53 (lewat lembar filter):* satu aktivitas uji (Futsal, Sparring, Pemula, Gratis) dibuat dari `mitra.uji`, lalu: Main Bareng → kosong dengan pesan "Tidak ada aktivitas yang cocok dengan filter."; Sparring → kartu tampil; Sparring + Menengah → kosong; Sparring + Pemula → kartu tampil. Aktivitas uji sudah dibatalkan lewat "Batalkan Aktivitas".
  - *Tanggal:* Riwayat Pemesanan dan Booking Masuk menampilkan "Min, 8 Nov 2026" / "Jum, 6 Nov 2026".
  - *Lencana:* Langganan Lapangan tetap redup pada akun dengan 10 booking yang sebagian besar `DIBATALKAN`/`DITOLAK` (hanya Pemesan Pertama menyala, 1/5); teks syarat "Dapat 5 booking terkonfirmasi"; terbaca di mode gelap.
  - *Dashboard Mitra:* pil "Diskon 20%" muncul di bawah harga setelah diskon disetel 20% pada Candra Wijaya, lalu hilang setelah dikembalikan ke kosong (0). Data produksi dikembalikan seperti semula.
  - *Form lapangan:* pesan "Harga produk wajib diisi." tampil utuh, kolom nama dan harga produk sama lebar.
  - *Keyboard Home:* lihat butir di atas (terbukti setelah percobaan kedua).
  - *Mode gelap:* pemilih mode di Profil, Cari Rekan, lembar filter, Lencana, Dashboard Mitra, dan form lapangan terbaca baik.
  **Belum dilihat:** HP fisik, WhatsApp sungguhan, dan pengingat jadwal di perangkat. Peta tetap terang (keterbatasan yang sudah dicatat).
- **Temuan saat uji (6 November 2026):** `FloatingActionButton` di Cari Rekan dan Forum memakai tag Hero bawaan yang sama. Karena kedua tab hidup bersamaan di shell navigasi, mode debug melempar assertion "multiple heroes that share the same tag" saat layar baru dibuka (ada sejak Forum masuk, 9 Oktober; tidak muncul di build rilis). Diperbaiki dengan `heroTag: null` pada kedua FAB; setelah itu log bersih pada alur buka-tutup layar lewat FAB.
- **T-28 belum tuntas:** pengujian ulang T-54…T-70 di HP fisik (Definisi Selesai §12 poin 1) masih terbuka.
- ~~**Lembar "Beri Rating" tidak menampilkan ulasan lama milik pengguna itu sendiri.**~~ **Sudah diperbaiki (5 November 2026, BB-83, BB-85).** Sebelumnya pengguna yang sudah pernah menilai melihat bintang kosong dan mengirim ulang diam-diam **menimpa** nilai lama (terjadi saat uji BB-63: ulasan 3 bintang `mitra.uji` tertimpa 5 bintang, lalu dikembalikan ke 3 bintang; teks ulasan lama, kalau ada, tidak bisa dipastikan ikut kembali). Sekarang lembar memuat ulasan lama lewat `RatingRepository.ambilRatingSaya`: judul "Ubah Rating", bintang dan teks terisi, ada keterangan "akan mengganti"; kalau gagal dimuat tampil Coba Lagi, bukan form kosong.
- ~~Kartu lapangan di Home tidak ikut berubah setelah rating baru.~~ **Sudah diperbaiki (5 November 2026, BB-84).** Detail yang dibuka dari Home kini memanggil `HomeViewModel.perbaruiSatuLapangan` setelah rating terkirim (satu baca dokumen); fungsi penggantinya `gantiLapanganDalamDaftar` diuji otomatis (10 tes). Detail yang dibuka dari Peta belum memicu penyegaran ini (kartu Peta tidak menampilkan rating).

**Data uji yang tertinggal di Firestore produksi** (tidak bisa dihapus lewat aplikasi karena Security Rules): 2 dokumen `booking` (Candra Wijaya, 20 November `DIBATALKAN` dan 27 November `DITOLAK`) dan beberapa dokumen `notifikasi` untuk akun mitra uji. Aktivitas uji tidak meninggalkan sisa (Batalkan Aktivitas menghapus dokumennya). **Ulasan uji permanen:** `pengguna.uji` memberi 5 bintang ke The Good Padel Club (rata-rata kini 4,0 dari 2 ulasan; rating tidak bisa dihapus lewat aplikasi) — ini lapangan sungguhan, jadi hapus dokumen `rating`-nya di Firebase Console dan kembalikan `ratingTotal`/`jumlahRating` (3 dan 1) kalau angka itu tidak diinginkan. Slot, diskon, dan produk uji sudah dibersihkan; lapangan Candra Wijaya kini punya `diskonPersen: 0` dan `produkTambahan: []` (sebelumnya tidak ada, tidak berpengaruh). Bisa dihapus manual lewat Firebase Console bila diinginkan.

**Catatan T-66 (mitra membalas ulasan, 5 November 2026):** satu-satunya tugas v1.5 yang **mengubah Security Rules**. Isi: dua atribut baru `balasanMitra` dan `balasanPada` di `rating`; `RatingRepository.balasUlasan`; bottom sheet balasan; blok "Balasan pemilik" di Detail; tombol Balas hanya untuk mitra pemilik lapangan. `beriRating` kini memakai `update` (bukan `set`) pada dokumen yang sudah ada supaya balasan tidak terhapus saat pengguna mengubah ratingnya.
- **Rules diuji di emulator Firestore lokal** (proyek tiruan `demo-sportspace`, bukan produksi) dengan 35 skenario: semua jalur sah lolos (buat ulasan, ubah ulasan sendiri, mitra pemilik membalas dan mengganti balasan, aplikasi lama tetap bisa menulis ulang ulasan yang belum dibalas) dan semua jalur serangan ditolak (memalsukan balasan saat membuat atau mengubah ulasan, mitra lain atau penyewa membalas, balasan kosong/501 karakter/tipe salah, mengubah nilai ulasan lewat jalur balasan, lapangan tanpa pemilik, membajak dokumen rating orang lain, menghapus). Skrip ujinya sementara dan tidak masuk repo.
- **Aturan baru lebih ketat dari yang lama:** rules lama tidak memeriksa pemilik dokumen yang diubah, sehingga pengguna lain bisa menimpa dokumen rating orang dengan `userId` dirinya. Itu kini ditolak (skenario G1).
- **Diuji di perangkat setelah deploy rules (6 November 2026, produksi, akun `mitra.uji` pemilik Hey Beach Padel Club dan `pengguna.uji`):** BB-86 — tombol Balas ada di ulasan lapangan milik sendiri, balasan tersimpan dan tampil sebagai "Balasan pemilik" dengan tombol "Ubah balasan"; BB-88 — balasan kosong ditolak "Balasan wajib diisi."; BB-89 — rating diubah 5 → 4 bintang, jumlah ulasan tetap 1 dan balasan **tetap ada**, lalu dikembalikan ke 5; BB-87 — `pengguna.uji` melihat balasan tetapi tidak ada tombol Balas/Ubah balasan. **BB-90** (menulis `balasanMitra` langsung ke Firestore sebagai penyewa atau mitra lain) tidak bisa dipicu lewat UI dan hanya terbukti lewat 35 skenario emulator rules. Data uji permanen: satu balasan "Terima kasih atas ulasannya!" di Hey Beach Padel Club (lapangan uji milik `mitra.uji`; balasan tidak bisa dihapus, hanya diganti).
- **Perilaku untuk aplikasi versi lama setelah deploy:** menulis ulang rating yang belum punya balasan tetap berhasil; pada rating yang SUDAH dibalas, aplikasi lama (yang memakai `set`) akan mendapat "Tidak punya izin memberi rating." karena `set` akan menghapus balasan. Pastikan Martin memakai `main` terbaru.

**Catatan T-70 (riwayat main, 6 November 2026):** tanpa package, field, query, atau Security Rules baru. Fungsi murni `pisahkanAktivitasSaya` (`core/utils/riwayat_aktivitas.dart`) memisahkan stream `streamAktivitasSaya` yang sudah ada; dua bagian di Profil memakai satu langganan.
- **Diuji di emulator:** aktivitas mendatang tampil di "Aktivitas Saya" dan "Riwayat Main" menampilkan pesan kosong; setelah jam emulator dimajukan melewati 20:00 dan aplikasi dimulai ulang, "Aktivitas Saya" berubah menjadi "Belum ada aktivitas mendatang." dan aktivitas yang sama pindah ke "Riwayat Main" dengan kartu redup; setelah jam dikembalikan ia kembali ke "Aktivitas Saya"; setelah dibatalkan kedua bagian menampilkan pesan kosong yang benar. **BB-106** (batas 10 dan "Menampilkan 10 dari N") tidak diuji di perangkat karena butuh lebih dari 10 aktivitas lampau; hanya lewat 15 tes otomatis (`test/riwayat_aktivitas_test.dart`).
- **Efek samping pengujian (data uji tertinggal):** memajukan jam emulator ke 21:30 membuat aplikasi menulis balik status `SELESAI` (aturan AB-07) pada booking uji Candra Wijaya 6 November 2026 20:00–21:00, padahal jam sebenarnya baru 10:00. Booking itu kini `SELESAI` di Firestore dan tidak bisa dibatalkan lewat aplikasi, sehingga kunci `slotBooking` untuk Candra Wijaya 6 November jam 20 ikut tertahan. Bersihkan lewat Firebase Console: hapus dokumen `booking` itu dan dokumen `slotBooking` berID `{lapanganId Candra}_2026-11-06_20`.
- **Batas yang diakui:** daftar dihitung saat layar digambar, bukan dengan pewaktu (lihat PRD AB-26).

**Catatan T-69 (cari rekan dari booking, 6 November 2026):** tanpa package baru, tanpa field baru, tanpa query baru, tanpa Security Rules — ERD tidak berubah (alasan dipilih; usulan AYO nomor 2, 3, 4, dan 6 yang mengubah skema dialihkan ke saran pengembangan lanjutan Bab 5).
- **Diuji di emulator (BB-101–103):** booking `MENUNGGU` tidak punya tombol; setelah `mitra.uji` mengonfirmasi, tombol "Cari rekan untuk jadwal ini" muncul di baris tersendiri; diketuk, form Buat Aktivitas terbuka dengan Badminton (dari lapangan), Candra Wijaya, Jum 6 Nov 2026, jam 20:00, dan kotak info "Dari booking di …"; setelah tingkat Pemula dan 3 pemain dilengkapi, aktivitas tampil di Cari Rekan dengan lapangan dan jam yang sama.
- `waktuMulaiBooking` dipindah dari `pengingat_jadwal.dart` (privat) ke `core/utils/waktu_booking.dart` agar dipakai bersama; tes pengingat jadwal tetap hijau. 16 tes baru (`test/cari_rekan_booking_test.dart`).
- **Pengaman tambahan di form:** dropdown lapangan tidak lagi bisa memicu galat bawaan Flutter bila nilai awal tidak ada di daftar, dan `_submit` memakai `firstOrNull` (pesan, bukan crash).
- **Keterbatasan:** aktivitas tidak terhubung ke booking-nya, jadi bisa dibuat lebih dari satu aktivitas dari satu booking dan aktivitas tidak ikut berubah bila booking dibatalkan.

**Catatan T-68 (mode gelap, 5 November 2026):** tanpa package baru (memakai `shared_preferences` dari T-67), tanpa Firestore, tanpa Security Rules, tanpa index.
- **Cara:** token warna yang berbeda per mode (latar, permukaan, teks, peta, bayangan) dipindah dari `AppColors` ke `AppPalette` (`ThemeExtension`) dan dibaca lewat `context.warna`; `AppTextStyles` berwarna menjadi fungsi `AppTextStyles.x(context)`. Konstanta lama di `AppColors` **dihapus** sehingga setiap pemakaian yang terlewat menjadi galat kompilasi — diperbaiki di 33 berkas (178 pemakaian warna dan 196 pemakaian gaya teks; 109 kata `const` pembungkus dibuang dengan skrip sementara yang digerakkan oleh galat analyzer, lalu sisanya manual). Mode terang diverifikasi tidak berubah (nilai warna dijaga tes, dan tampilan Profil dibandingkan sebelum/sesudah).
- **Diuji di emulator (BB-96–100):** pemilih Terang/Gelap/Ikuti HP di Profil; mode berganti seketika di layar yang sama; pilihan bertahan setelah aplikasi ditutup dan dibuka lagi; "Ikuti HP" mengikuti pergantian tema sistem terang ↔ gelap. Layar yang dilihat di mode gelap: Home, Map, Teman, Forum, Detail Post, Buat Post, Profil, Detail Lapangan (beserta ulasan), form reservasi dan pemilih tanggal, lembar rating, filter, Edit Profil, Notifikasi, Buat Aktivitas, Detail Aktivitas, Login, Daftar, Dashboard Mitra, Atur Slot, Form Edit Lapangan, halaman statis.
- **Temuan saat uji dan sudah diperbaiki:** AppBar tampak abu kehijauan saat isi layar tergulung di bawahnya (tint Material 3); tint dimatikan hanya di tema gelap.
- **Keterbatasan:** peta OpenStreetMap tetap terang (tidak ada ubin gelap); layar sambut native Android putih sesaat di awal; Detail Aktivitas (L-09), dialog konfirmasi, dan halaman statis (Tentang) juga sudah dilihat di mode gelap dan terbaca baik. Satu catatan kecil: teks lencana hijau (Main Bareng/Pemula/Gratis) di atas latar hijau gelap kontrasnya sekitar 4:1, lebih rendah dari teks lain tetapi masih terbaca; belum dibuat versi lebih terang.
- 22 tes baru (`test/mode_gelap_test.dart`), termasuk perhitungan kontras WCAG untuk palet gelap.

**Catatan T-67 (pengingat jadwal booking, 5 November 2026):** package baru gratis `flutter_local_notifications` 22, `timezone`, `shared_preferences`. Konfigurasi Android: desugaring di `build.gradle.kts`, izin `RECEIVE_BOOT_COMPLETED`, dua receiver di manifest — **build debug tetap berhasil di AGP 9.1 / Gradle 9.3.1**. Tanpa Firestore, tanpa Security Rules baru, tanpa index baru.
- **Diuji di emulator (BB-91–95):** izin dicabut → saklar menyala menampilkan petunjuk oranye; saklar mati-lalu-nyala memunculkan dialog izin Android dan kanal "Pengingat Jadwal" terdaftar; booking `MENUNGGU` tidak memicu alarm; setelah mitra mengonfirmasi dan pengguna login, tepat satu alarm terjadwal pukul 17:00 untuk booking 18:00; jam emulator dimajukan ke 16:58 dan notifikasi "Sebentar lagi waktunya main!" muncul 17:02:47 dengan isi benar; saklar mati = 0 alarm, nyala = 1 alarm; keluar akun = 0 alarm; membatalkan booking = 0 alarm.
- **Temuan jujur:** alarm tidak-tepat-waktu (`inexactAllowWhileIdle`) tiba 2 menit 47 detik terlambat di emulator, dan Android menandainya dengan jendela hingga 1 jam. Karena itu teks berbunyi "mulai **sekitar** 1 jam lagi". Kalau tim ingin tepat waktu, opsinya `USE_EXACT_ALARM` (otomatis diberikan untuk APK yang dibagikan langsung, tetapi kebijakan Google Play hanya mengizinkannya untuk aplikasi alarm/kalender) — keputusan ada di tim.
- **Keterbatasan:** pengingat baru terjadwal saat aplikasi terbuka dan melihat booking sudah dikonfirmasi; mengatasinya butuh FCM yang dilarang. Belum diuji: restart HP (penjadwalan ulang lewat `ScheduledNotificationBootReceiver`) dan HP fisik dengan mode hemat daya.
- Saat menguji, `dumpsys alarm` mencetak tag satu alarm di dua bagian; menghitung baris `tag=` menghasilkan angka ganda. Hitung baris `Alarm{…id.ac.binus.sport_space}` yang diikuti `flutterlocalnotifications`.

**Urutan yang direkomendasikan:** tahap 1 = T-54, T-55, T-56, T-58, T-63, lalu T-61; tahap 2 = T-57, T-59, T-62, T-65; tahap 3 = T-60, T-64, T-66, T-67. Dokumen ide tadinya menahan T-59, T-60, T-61, T-62, T-65 sampai cabang forum di-merge karena konflik di `detail_lapangan_screen.dart`, `booking`/`lapangan`, rules, dan model — forum sudah masuk `main`, jadi blokir itu tidak berlaku lagi. Aturan tetap: satu cabang per fitur dari `main` terbaru, perubahan `models/` hanya oleh integrator. Fitur "venue tersedia hari ini" milik AYO sengaja tidak ditiru (boros pembacaan Firestore).

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
| **T-39** | Revisi Bab 1–3 sesuai **PRD §14** (7 butir, termasuk navigasi 3 tab → 4 tab) | Bertiga + Pak Gintoro | **Sebelum Bab 4 ditulis** | Bab 3 cocok dengan aplikasi yang dibangun — **teks selesai 7 Oktober 2026** (`SportSpace_Bab1-3_Revisi_Highlight_2.docx`); sisa pekerjaan manual (gambar ulang, Daftar Isi, konsultasi Pak Gintoro) di PRD §14 "Putaran revisi 2" M1–M13 |
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
Minggu 1–2   [x] T-00a  [x] T-00b  [x] T-00c  [x] T-00d (tetap Spark)  [-] T-00e (dibatalkan)  [x] T-00f
Minggu 3     [x] T-01  [x] T-02  [x] T-03  [x] T-04  [x] T-05  [x] T-06
Minggu 4     [x] T-07  [x] T-08  [x] T-09  [x] T-10
Minggu 5–6   [x] T-11  [x] T-12  [x] T-13
Minggu 7     [x] T-14                                    [x] T-40 (Opsi A, tanpa Storage)
Minggu 8     [x] T-15  [x] T-16  [x] T-17
Minggu 9     [x] T-18  [x] T-19  [x] T-20
Minggu 10    [x] T-21  [x] T-22  [x] T-23  [x] T-36
Minggu 11    [x] T-24  [x] T-25  [x] T-26  [x] T-27  [x] T-35  [x] T-37  [x] T-38
Minggu 12    [x] T-28  [x] T-29 (diuji di HP Android, 19 Okt)  [~] T-39 (revisi Bab 1–3 — teks selesai 7 Okt, gambar masih manual)
Minggu 13    [x] T-30 (41/41 emulator + HP Android, 19 Okt)  [ ] T-31
Minggu 14    [ ] T-32 (kalkulator SUS siap)  [ ] T-33  [ ] T-34
Dibatalkan   [-] T-00e  [-] T-49  [-] T-52  [-] T-53
```

> **Sisa pekerjaan per 19 Oktober 2026** (ringkasan terbaru — catatan bertanggal di bawahnya adalah riwayat):
>
> 1. ~~**Uji di HP Android fisik** — T-28, T-29, T-30~~ — **selesai**, dikonfirmasi tim 19 Oktober 2026 (aplikasi sudah dicoba dan aman di HP Android). Catat merek/tipe HP dan hasil per kasus BB untuk tabel Bab 4.
> 2. **T-31** sebar APK + kuesioner SUS ke 20–30 responden → **T-32** hitung skor (kalkulator `Kalkulator_SUS_SportSpace.xlsx` sudah siap, di folder Downloads, di luar repo).
> 3. **T-33 / T-34** tulis Bab 4 dan Bab 5. Bab 4 wajib menyebut 5 lapangan mitra sebagai simulasi (PRD §14 M13).
> 4. **T-39 pekerjaan manual tim** — PRD §14 "Putaran revisi 2" M1–M13 (gambar ERD dan diagram ulang, mockup Figma, Daftar Isi, konsultasi Pak Gintoro).
> 5. **Ubah manual 25 dokumen `lapangan` di Firebase Console**: field `sumberData` → `direktori_daring` (kode sudah diganti 19 Oktober 2026 — lihat PRD §10).
> 6. **Keputusan terbuka:** harga/jam per jenis olahraga — masih riset.
> 7. **Forum (merge 4 November 2026):** cocokkan rules forum di Firebase Console dengan `firestore.rules` di repo; putuskan dengan Pak Gintoro apakah forum masuk Bab 3–4 (PRD v1.3 sudah mencatatnya, §14 #38–#44) — lihat bagian "Forum" di atas.
> 8. **Backlog v1.3 dari AYO (T-54…T-67):** **seluruh T-54…T-67, ditambah T-68 (mode gelap), T-69, dan T-70, selesai di kode dan diuji di emulator (5–6 November 2026)** — `flutter analyze` bersih, 269 tes otomatis hijau. Rinciannya, bug yang ditemukan dan diperbaiki, serta BB yang belum terbukti di perangkat ada di "Hasil uji emulator" pada bagian Backlog v1.3. T-66 dan T-67 kemudian disetujui dan selesai (T-66 mengubah Security Rules dan sudah di-deploy). Usulan AYO lain yang mengubah skema (daftar tunggu, co-host, level pemain) sengaja dialihkan ke saran pengembangan lanjutan Bab 5. **Sisa pekerjaan:** uji di HP fisik (aplikasi WhatsApp asli, mode hemat daya untuk pengingat, BB-77 butuh dua perangkat), SUS (T-31–T-32), Bab 4–5 (T-33–T-34), dan revisi ERD (T-39, setelah atribut final).
>
> **Uji end-to-end 6 November 2026 (emulator, akun Pengguna Uji dan Mitra Uji): tidak ditemukan bug.** Dicakup: Home/pencarian/favorit; Detail Lapangan, WhatsApp, popup peta; booking (ajukan → ubah jadwal → batalkan; mitra konfirmasi; pembatalan menghapus pengingat); aktivitas (buat, gabung dengan persetujuan, terima lewat notifikasi, batal ikut, batalkan); Dashboard Mitra (tambah/edit lapangan, konfirmasi); Forum (post, komentar, hapus); Notifikasi (ketuk membuka layar yang tepat); Edit Profil, Olahraga Favorit, Lokasi Default (validasi nama kosong dan nama lokasi kosong berfungsi); mode offline (Home/Teman/Forum tampil dari cache, banner "Memakai lokasi default"); restart aplikasi. **Smoke test `flutter build apk --release` (60,4 MB) lulus**: aplikasi berjalan, login berhasil, dan pengingat jadwal terjadwal di build rilis (R8 tidak merusak `flutter_local_notifications`), lalu terhapus saat booking dibatalkan. `flutter analyze` bersih, 269 tes hijau, pemeriksaan lapisan MVVM kosong. Belum terbukti: HP fisik, mode hemat daya, BB-77 (dua perangkat).
>
> **Keputusan 8 Oktober 2026:** T-00a–T-00c dicentang selesai; T-00d diganti jadi "tetap paket Spark"; T-00e, T-52, T-53 dibatalkan (T-49 sudah dibatalkan sejak 15 September).

> **Catatan status per 26 Agustus 2026:** Seluruh alur reservasi + dashboard mitra (T-23–T-27), keputusan T-40 (Opsi A, tanpa Firebase Storage — lihat PRD §12b), dan seluruh empat tugas v1.1 (T-35 favorit, T-36 badge, T-37 olahraga favorit + lokasi default, T-38 statistik profil) sudah selesai. **Sprint 3 dan 4 lengkap secara kode, T-10 (seeding) sudah dijalankan di project Firestore produksi, dan T-06 (index + rules) sudah terverifikasi Enabled dan ter-deploy.** T-28 (audit kode + perbaikan bug) sudah jalan signifikan — lihat catatan di bawah. Sisa pekerjaan: T-00a–T-00e (proses tim, sedang berjalan paralel), lalu T-29/T-30 dan seterusnya (build APK, Black Box di perangkat nyata, SUS, penulisan Bab 4–5).
>
> **T-06 SELESAI (26 Agustus 2026).** `firebase firestore:indexes` mengonfirmasi 11 index di server cocok persis dengan `firestore.indexes.json`/`FIRESTORE-INDEXES.md`, dan cek manual di Firebase Console → Firestore → Indexes menunjukkan seluruh 11 baris berstatus **Enabled** (bukan Building). Kriteria "Selesai jika" T-06 terpenuhi.
>
> T-00a–T-00e juga belum ditandai — tugas persiapan tim (instalasi, survei manual) yang tidak bisa diverifikasi lewat kode, dan sedang dikerjakan. *(8 Oktober 2026: T-00a–T-00d selesai/diputuskan, T-00e dibatalkan.)*
>
> **Catatan sampingan dari cek T-06:** tangkapan layar Firebase Console menunjukkan project masih di paket **Spark** (gratis), bukan **Blaze** seperti disebut T-00d. Ini kemungkinan bukan masalah — Firestore (termasuk composite index) dan Authentication jalan penuh di Spark, dan proyek ini sengaja tidak memakai Cloud Functions/Storage yang butuh Blaze. Tapi karena T-00d eksplisit meminta upgrade ke Blaze + budget alert, sebaiknya dipastikan lagi saat T-00d benar-benar dikerjakan: kalau ternyata tetap di Spark, catat alasannya (semua fitur yang dipakai gratis) supaya tidak jadi pertanyaan penguji soal kesesuaian dengan dokumen. *(Diputuskan 8 Oktober 2026: tetap Spark — lihat catatan T-00d di Minggu 0.)*
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
> **Catatan kualitas data yang masih menunggu T-00e** *(8 Oktober 2026: T-00e dibatalkan — harga/jam/fasilitas resmi ditulis sebagai estimasi di skripsi, tidak perlu reseed)*: koordinat sudah benar untuk semua 30 lapangan, tapi harga/jam/fasilitas 8 lapangan `sumberData: 'observasi'` masih perkiraan pasaran, bukan hasil survei langsung — belum layak jadi bahan skripsi sampai T-00e selesai. Kalau datanya diperbarui nanti: hapus seluruh dokumen `lapangan` di Firebase Console, lalu jalankan ulang tombol "Isi Data Awal". Tile dan file `admin_seed_screen.dart` tetap WAJIB dihapus setelah dipakai di project produksi — jangan sampai ikut ke APK yang dibagikan ke responden SUS (T-31).
>
> **Testing manual pertama (20 Agustus 2026):** dijalankan di emulator Android sungguhan lewat jembatan lama (`seedPrototipe`, 7 lapangan). Home, Detail Lapangan (badge T-36, rating, favorit ♡), pencarian, dan alur reservasi dicoba langsung. Ketemu satu bug nyata — dicatat di `PRD.md` "Koreksi teknis" #8: lapangan yang tutup jam `00:00` (tengah malam) tidak pernah punya jam tersedia di form Ajukan Reservasi (L-10), karena jam tutup dibaca literal sebagai `0` alih-alih tengah malam. Sudah diperbaiki dan diverifikasi ulang (submit reservasi berhasil, notifikasi masuk ke mitra).
>
> **Testing manual kedua (21 Agustus 2026):** setelah T-10 sungguhan (30 lapangan) dijalankan, alur reservasi diuji ujung-ujung dengan dua akun baru — `pengguna.demo@sportspace.test` (role `pengguna`) mengajukan reservasi, `mitra.demo2@sportspace.test` (role `mitra`) menerimanya lewat Dashboard Mitra. **Berhasil, tanpa bug baru.** Diingatkan lagi (bukan bug, sudah tercatat di PRD "Koreksi teknis" #6): notifikasi `BOOKING_DIKONFIRMASI`/`BOOKING_DITOLAK` yang diterima pemesan belum berpindah layar kalau ditekan — pemesan harus cek manual lewat Profil → Riwayat Pemesanan. Kandidat perbaikan kecil untuk T-28 kalau ada waktu lebih; kalau tidak, aman dicatat sebagai keterbatasan di Bab 5.
>
> **Catatan infrastruktur — bukan bug kode, tapi sempat menghabiskan waktu banyak saat testing:** VPN/Cloudflare WARP yang aktif di komputer host memutus koneksi internet emulator Android ke Firebase, meski status jaringan di emulator terlihat normal ("VALIDATED"). Gejalanya menyesatkan — mirip bug: transaction Firestore native crash tiba-tiba (`AssertionError: transaction object cannot be used after update callback`), Home menampilkan data lama yang seharusnya sudah terhapus, registrasi akun baru macet tanpa pesan error. **Kalau ketemu gejala serupa saat testing di emulator, matikan dulu VPN/WARP sebelum curiga ke kode.** Setelah WARP dinonaktifkan dan emulator di-cold-boot ulang, semuanya jalan normal.
>
> Ini sinyal bagus untuk mulai T-30 (Black Box) begitu T-06 dan T-00e beres — kemungkinan ada bug serupa lain yang baru ketemu lewat testing sungguhan, bukan cuma `flutter analyze`.

> **Testing manual ketiga (26 Agustus 2026)** — dijalankan di emulator (`sport_space_avd`, Android 14), kali ini lewat build Gradle langsung (`./gradlew assembleDebug` lalu `installDebug`, bukan `flutter run`) untuk verifikasi terpisah bahwa APK-nya sungguh bisa dibangun dan berjalan sebelum lanjut ke T-29 — hasilnya `BUILD SUCCESSFUL`, app terpasang dan terbuka normal. Alur reservasi penuh (AB-04) diuji ujung-ujung dengan dua akun baru yang dibuat khusus untuk pengujian ini dan **dihapus lagi setelah selesai** (tidak menyentuh data 5 mitra/30 lapangan asli): daftar akun mitra → Tambah Lapangan (L-15, termasuk tombol "Ambil Lokasi Saat Ini") → daftar akun pengguna → lapangan baru muncul di Home dengan jarak 0.0 km (Haversine benar) → Ajukan Reservasi (L-10) → notifikasi `BOOKING_BARU` masuk ke mitra (badge lonceng) → Dashboard Mitra → Konfirmasi → status berubah `MENUNGGU` → `DIKONFIRMASI` tersimpan benar, tombol Konfirmasi/Tolak hilang setelahnya. **Tidak ada bug baru ditemukan** — AB-04 (kunci slot), AB-08 (estimasi harga + label "Estimasi, dibayar di lokasi"), dan notifikasi in-app semuanya jalan sesuai PRD. Penghapusan akun & lapangan test diverifikasi ulang: login dengan kredensial lama gagal ("Surel atau kata sandi salah"), dan lapangan tidak lagi muncul di Home dari akun lain.
>
> Satu gejala infrastruktur berulang sempat muncul lagi di sesi ini (bukan bug kode — sudah tercatat sebagai catatan infrastruktur di testing 20 Agustus di atas): Cloudflare WARP di host memutus internet emulator, sampai tab Map (tile OpenStreetMap) kosong abu-abu dan penulisan Firestore (mis. ubah Olahraga Favorit) gagal dengan pesan "Tidak ada koneksi internet". Kali ini sekadar menghentikan service `CloudflareWARP` di Windows Services **tidak cukup** — perlu **cold-boot emulator** (`adb emu kill` lalu jalankan ulang `emulator -avd ... -no-snapshot-load`, bukan cuma restart app) supaya adapter jaringan virtualnya benar-benar pulih. Setelah cold-boot, DNS emulator resolve normal dan tile Map serta seluruh baca/tulis Firestore kembali jalan.

> Minggu 11 semula terlihat padat karena empat tugas v1.1 menumpuk di sana (T-35, T-36, T-37, T-38) — semuanya sudah selesai.

> **Testing manual keempat (12 September 2026)** — seluruh **37 kasus Black Box (BB-01 sampai BB-37) di PRD §11** dijalankan satu per satu di emulator (`sport_space_avd`) lewat `adb`/`uiautomator` (tidak ada tool automasi mobile khusus tersedia), pakai tiga akun QA baru (`mitra.qa1`, `pengguna.qa1`, `pengguna.qa2`, password `Testing123`, dibuat khusus untuk sesi ini). **35 kasus lulus.** Dua bug nyata ditemukan — keduanya langsung diperbaiki di sesi yang sama, lihat `PRD.md` "Koreksi teknis pasca-v1.1 (12 September 2026)" #11–12 untuk detail teknis:
>
> - **BB-06** (izin lokasi ditolak, tanpa lokasi default) — Home macet selamanya di kondisi "memuat" karena `Geolocator.requestPermission()` tidak pernah selesai saat plugin `geolocator_android` menemui bug (`grantResults` kosong dari Android). Diperbaiki dengan timeout 10 detik. Diverifikasi ulang dengan mereproduksi pemicu yang sama persis (`pm clear` supaya dialog izin muncul segar, lalu tekan "Tolak") — sebelumnya macet permanen, sekarang langsung tampil layar cadangan lokasi default dengan benar.
> - **BB-36** (kotak statistik Profil) — angka Booking/Aktivitas/Favorit basi sampai logout/login karena diambil sekali lewat `count()` saat tab dibuat, padahal tab Profil tetap hidup di `IndexedStack`. Diperbaiki dengan menghitung dari `Stream` yang sama dipakai daftar di bawahnya (bukan `count()` terpisah) — sekaligus mengurangi baca Firestore yang tadinya dobel. Diverifikasi ulang: favorit lapangan dari Home lalu pindah ke Profil tanpa logout, angka langsung berubah.
>
> BB-18 (terima permintaan gabung saat penuh) dan BB-37 (Security Rules `favorit` menolak akses silang antar-pengguna) tidak bisa diamati langsung dari UI (masing-masing snackbar transien dan tidak ada layar yang memang query data pengguna lain) — diverifikasi lewat cara lain: BB-18 lewat kode (`throw Exception('Slot penuh')` di `aktivitas_repository.dart`, pesan sesuai PRD) plus perilaku tidak berubah setelah tap; BB-37 lewat panggilan langsung ke Firebase Auth REST API + Firestore REST API (login sungguhan sebagai dua akun QA, lalu coba baca `favorit` milik satu sama lain) — pengguna A dapat `403 PERMISSION_DENIED` membaca favorit pengguna B, `200 OK` membaca miliknya sendiri.
>
> Kedua perbaikan diverifikasi `flutter analyze` bersih, `flutter test` hijau, aturan lapisan MVVM bersih, dan diuji ulang langsung di build Gradle baru. Gejala infrastruktur WARP/jaringan emulator (lihat catatan testing sebelumnya) muncul berulang kali lagi sesi ini — cold-boot emulator tetap jadi solusi tercepat tiap kali terjadi.
>
> **T-28 dan T-30 BELUM dicentang selesai** — Definisi Selesai PRD §12 poin 1 mensyaratkan seluruh kasus BB lulus di **perangkat Android nyata**, bukan emulator. Sesi ini adalah pondasi lengkap sebelum itu (37/37 kasus tercoba, 2 bug ditutup), bukan pengganti pengujian perangkat fisik.

> **T-29 SEBAGIAN JALAN (13 September 2026).** Tile "Seed Data Awal" disembunyikan dari menu Profil (`_TileMenu`-nya di-comment di `profil_screen.dart`, bukan dihapus — `AdminSeedScreen`/`seedSemuaLapangan()` tetap ada di kode untuk reseed nanti setelah T-00e selesai) supaya tidak ikut ke APK yang dibagikan. `flutter build apk --release` berhasil (`app-release.apk`, 56.1MB, ditandatangani pakai debug key seperti default `flutter run --release` — belum ada signing config produksi terpisah, di luar cakupan PRD). Dipasang dan dicoba di emulator: splash, login, Home, dan navigasi ke Profil semua normal, tile Seed Data Awal terkonfirmasi hilang. **Belum dicentang selesai** — "Selesai jika: APK terpasang dan jalan" di tabel tugas mengacu ke **minimal 3 perangkat Android berbeda**, dan itu perlu perangkat fisik yang tidak tersedia untuk sesi ini.

> **T-29: APK release dibangun ulang (1 Oktober 2026).** `app-release.apk` sebelumnya (13 dan 21 September) belum memuat perbaikan tinggi kartu Home dari commit `ff8e38d` (23 September, `kartu_lapangan.dart`), padahal 30 foto lapangan di Firestore sudah terisi sehingga bug rasio aspek itu paling kelihatan di APK lama. Perubahan sesudahnya (`3c01043`, `5cbbdd2`) hanya dokumen, jadi tidak perlu build lagi. `flutter analyze` bersih (No issues found), `flutter build apk --release` berhasil: `build/app/outputs/flutter-apk/app-release.apk`, 56,7MB, ditandatangani debug key seperti sebelumnya. Tile "Seed Data Awal" masih disembunyikan (di-comment di `profil_screen.dart`). **Belum dipasang/diuji ulang di perangkat atau emulator pada build ini**, dan syarat T-29 "minimal 3 perangkat Android berbeda" tetap belum terpenuhi. APK-nya tidak ikut ke git (`build/` di-ignore) — bagikan lewat salinan berkas langsung.

> **T-30: BB-38 sampai BB-41 lulus di emulator (1 Oktober 2026)**, memakai `app-release.apk` yang baru dibangun hari itu dan akun uji tetap. **BB-38** (batalkan booking): status MENUNGGU → DIBATALKAN lewat dialog konfirmasi, slot terbuka lagi (diverifikasi dengan mengajukan ulang slot yang sama dan diterima), mitra menerima notifikasi "Reservasi baru" dan "Reservasi dibatalkan". **BB-39** (pembuat batalkan aktivitas): peserta yang sudah diterima mendapat notifikasi "Aktivitas dibatalkan", aktivitas hilang dari Cari Rekan. **BB-40** (zoom): berhenti tepat di batas bawah (tampilan dunia) dan batas atas (tingkat bangunan), tanpa error. **BB-41** (Buka di Google Maps): membuka aplikasi Google Maps ke halaman lapangan; sisi negatif (tombol hilang kalau `tautanMaps` kosong) hanya diverifikasi lewat kode karena ke-30 lapangan seed sudah punya tautan. Seluruh 41 kasus BB kini sudah dijalankan di emulator; **yang tersisa hanya putaran di perangkat Android fisik** (syarat PRD §12 poin 1). Catatan: emulator butuh Cloudflare WARP dimatikan agar jaringannya jalan.

> **Uji regresi sebelum merge (19 Oktober 2026)** — setelah badge "Terverifikasi" dihapus dan `sumberData` diganti jadi `direktori_daring`. `flutter analyze` bersih, `flutter test` 7/7 hijau, cek aturan lapisan bersih, `flutter build apk --debug` (Gradle `assembleDebug`) berhasil. Diuji di emulator dengan akun `pengguna.uji`: splash → Home (30 lapangan terurut jarak, foto tampil), Detail Lapangan non-mitra tanpa badge (BB-34, termasuk Stadiums Futsal yang dulu `observasi`), lapangan mitra dengan "✅ Mitra Terdaftar" (BB-33), tab Map/Teman/Profil, filter Badminton, favorit ♡→♥→♡ dan angka Favorit di Profil ikut berubah (BB-31/32/36), ajukan reservasi Hey Beach 30 Okt 10:00 (estimasi Rp 220.000 = tarif pagi `hargaSlot`, benar) → Batalkan → status Dibatalkan dan slot 10:00 terbuka lagi (BB-38). **Tidak ada bug baru, tidak ada error di logcat.** Catatan infrastruktur: kali ini WARP sudah terputus tapi DNS emulator tetap gagal; solusinya cold-boot dengan `emulator -avd sport_space_avd -no-snapshot-load -dns-server 8.8.8.8,1.1.1.1`. Temuan kecil yang sudah ada sebelumnya (bukan regresi): dialog pilih tanggal masih berbahasa Inggris ("Select date", "Cancel", "OK"). *(Diperbaiki hari yang sama — lihat catatan di bawah.)*

> **Perbaikan Definisi Selesai (19 Oktober 2026)** — dua kekurangan dari pencocokan kode dengan PRD §12 dan CLAUDE.md, keduanya disetujui user: (1) `flutter_localizations` ditambahkan dan `MaterialApp` dikunci ke bahasa Indonesia, sehingga dialog tanggal/jam di Buat Aktivitas, Ajukan Reservasi, dan Form Lapangan kini tampil "Pilih tanggal", "Batal", "OKE" (`intl` ikut naik ke 0.20.3); jam yang dipilih tetap ditampilkan "HH:mm" lewat `Formatter.jamDariPilihan()`; (2) sekitar 65 teks yang ditulis langsung di widget/ViewModel/`validators.dart` dipindah ke `AppStrings`. Diverifikasi `flutter analyze` bersih, `flutter test` hijau, lapisan bersih, build Gradle berhasil, dan dicek di emulator. Detail: PRD "Koreksi teknis (7–19 Oktober 2026)".
