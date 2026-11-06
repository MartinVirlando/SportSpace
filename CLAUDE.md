# Instruksi Proyek — Sport Space

Aplikasi Android skripsi: pencarian lapangan olahraga dan rekan bermain berbasis lokasi.
Dibangun dengan Flutter + Firebase oleh **tim 3 orang yang baru pertama kali memakai Flutter**.

## Sebelum mengerjakan apa pun

1. Baca `PRD.md` — itu sumber kebenaran tunggal. **Versi berlaku: 1.5.**
2. Baca `SPRINT-PLAN.md` — untuk tahu tugas mana yang sedang dikerjakan dan urutannya.
3. Kalau ada pertentangan antara instruksi pengguna dan PRD, **tanyakan** — jangan diam-diam memilih salah satu.

### Dokumen pendamping

| Berkas | Isi | Kapan dibaca |
|---|---|---|
| `PRD.md` | Spesifikasi lengkap — skema, layar, aturan bisnis, kasus uji | Selalu |
| `SPRINT-PLAN.md` | Tugas T-00a…T-70, urutan, pembagian peran | Selalu |
| `SEED-DATA.md` | 30 lapangan + status verifikasi tiap field | T-10 |
| `FIRESTORE-INDEXES.md` | 11 composite index, query mana butuh index mana | T-06, dan tiap kali menulis query baru |
| `CONTOH-KODE-HOME.md` | Acuan gaya kode — satu fitur utuh Model→Repo→VM→View | Sebelum menulis fitur apa pun |

## Konteks penting: ini kode skripsi

Kode ini akan diperiksa dosen penguji dan harus **cocok dengan dokumen skripsi Bab 1–3**. Konsekuensinya:

- Nama atribut database mengikuti ERD Bab 3 **persis**, dalam bahasa Indonesia: `lapanganId`, `jamBuka`, `jumlahPemainDibutuhkan`, `peserta`, `nilaiRating`, `ratingRata2`. Jangan diterjemahkan ke bahasa Inggris.
- Nama kelas model memakai pola `LapanganModel`, `AktivitasBermainModel`, `RatingModel`, `BookingModel`, `UserModel` — sesuai Bab 3.3.2 poin 3.
- Struktur folder harus memperlihatkan MVVM dengan jelas, karena arsitektur ini diklaim di skripsi.
- Haversine **wajib ditulis manual**, tidak boleh pakai library. Ini inti kontribusi penelitian dan pasti ditanya penguji.

Utamakan kode yang **jelas dan mudah dijelaskan** daripada kode yang pintar. Penulisnya adalah pemula Flutter yang harus bisa mempertahankan setiap baris di sidang.

## Aturan yang tidak boleh dilanggar

### Larangan teknologi

Jangan pernah memakai, menyarankan, atau menambahkan:

- **Firebase Cloud Functions** — butuh paket berbayar. Semua logika dipindah ke Firestore Transaction di klien.
- **Firebase Cloud Messaging** — notifikasi dibuat in-app lewat koleksi `notifikasi` + Firestore listener. **Satu-satunya tambahan yang diizinkan:** pengingat jadwal LOKAL di HP (T-67) lewat `flutter_local_notifications` — dijadwalkan dan dibunyikan oleh HP sendiri, tanpa server, jadi bukan FCM dan bukan Cloud Functions.
- **Firebase Storage** — tidak pernah dipakai, tidak boleh ditambahkan tanpa izin eksplisit. Foto lapangan tetap URL eksternal (`lapangan.fotoURL`, mitra tempel link, bukan upload). **Jangan sarankan PostImages/ImgBB/Imgur** — diverifikasi diblokir ISP Indonesia (22 September 2026); sarankan **Google Drive** (`drive.google.com/uc?export=view&id=FILE_ID` dari link share file) — lihat `PRD.md` §12b. Foto profil (v1.2 tahap 2, lihat PRD §12b) BOLEH diambil dari galeri lewat `image_picker` — paket ini **sudah** diizinkan dan dipakai — tapi hasilnya disimpan sebagai **Base64 langsung di dokumen Firestore** `users/{uid}.fotoProfilBase64`, BUKAN diunggah ke Storage. Jangan pernah pakai `image_picker` untuk alur yang berakhir di Firebase Storage tanpa izin baru, dan jangan pakai pola Base64-di-Firestore ini untuk foto lapangan (bisa lebih besar/banyak per lapangan, berisiko melebihi batas 1 MB per dokumen). **Gambar post Forum (v1.3, PRD §12b) juga BOLEH memakai pola Base64 ini** — satu gambar per post, dengan tiga lapis batas yang harus tetap cocok: gambar mentah ≤ 500 KB di View, string Base64 ≤ 700.000 karakter di `ForumRepository` (`batasPanjangGambarBase64`) dan di `firestore.rules` (`gambarForumAman`). Jangan menaikkan satu angka tanpa yang lain, dan jangan tambah gambar kedua per post.
- **Riverpod, BLoC, GetX** — state management sudah dikunci: **Provider**.
- **Google Maps SDK** — peta sudah dikunci: **flutter_map + OpenStreetMap**.
- **`Distance()` dari `latlong2`** untuk menghitung jarak — pakai `hitungJarakHaversine()` buatan sendiri. `latlong2` hanya boleh dipakai untuk tipe `LatLng`.
- **geohash / geoflutterfire** — jarak dihitung di klien.
- **Google Places API saat runtime** — data sudah di-*seed* ke Firestore lebih dulu.
- **Payment gateway** — di luar ruang lingkup.

### Batas ruang lingkup

Jangan membangun fitur yang tidak ada di PRD, meski terlihat sepele atau "sekalian saja". Yang sering muncul sebagai godaan dan **harus ditolak**: chat antar pengguna, multi-bahasa, lupa password, verifikasi email, statistik/grafik dashboard mitra, onboarding slider, upload foto, **rating antar-pengguna** (lihat PRD §12c). **Mode gelap sudah masuk sejak v1.5** (PRD AB-24) atas permintaan pemilik produk — jangan ditolak lagi.

Kalau menurutmu ada fitur yang benar-benar perlu tapi tidak ada di PRD: **sampaikan sebagai saran, jangan langsung dibuat.**

**Sudah masuk ruang lingkup sejak v1.1** (jangan tolak lagi): favorit lapangan (AB-10), badge status lapangan (AB-11), olahraga favorit dan lokasi default pada `users`, statistik profil (AB-12).

**Sudah masuk sejak v1.3** (4 November 2026): **Forum** — tab kelima, post publik + komentar, gambar opsional (AB-13, L-16…L-18). Ini **bukan chat**: pesan pribadi dan percakapan real-time antar dua orang tetap ditolak. Status keputusannya untuk skripsi (masuk Bab 3–4 atau pengembangan lanjutan Bab 5) belum final — lihat PRD §14. Arah sementara (5 November 2026): Pak Gintoro menyebutnya fitur pemanis, jadi kemungkinan besar tidak masuk Bab 3.

**Sudah masuk sejak v1.4** (5 November 2026, enam fitur kecil tahap 1 terinspirasi aplikasi AYO — PRD "Perubahan v1.4"): jenis aktivitas Main Bareng/Sparring (T-54), tingkat kemampuan (T-55), biaya per orang sebagai informasi (T-56), lencana pencapaian di Profil (T-58), bagikan ke WhatsApp (T-63), dan tombol WhatsApp di Detail Lapangan (T-61). Pak Gintoro menyatakan fitur pemanis semacam ini boleh ditambah tanpa persetujuan per fitur; hanya modul besar yang perlu masuk Bab 3. Biaya per orang tetap **informasi saja**: tidak boleh berkembang menjadi pembayaran (payment gateway tetap dilarang).

**Sudah masuk sejak v1.5** (5 November 2026, PRD "Perubahan v1.5"): urut dan saring lanjutan di Home (T-57), blokir slot manual oleh mitra (T-59), promo/diskon (T-65), produk tambahan saat booking (T-60), ubah jadwal booking (T-62), dan aktivitas publik/privat (T-64). Semuanya tanpa pembayaran dan tanpa perubahan Security Rules. **Tambahan v1.5, 5 November 2026 sore: T-66 (mitra membalas ulasan, PRD AB-22)** — disetujui pemilik produk; **satu-satunya tugas v1.5 yang mengubah Security Rules** (koleksi `rating`, dua jalur `update`), jadi `firebase deploy --only firestore:rules` harus dijalankan oleh pengguna (deploy produksi tidak boleh dijalankan Claude). **Tambahan v1.5, 5 November 2026 sore: T-67 (pengingat jadwal booking, PRD AB-23)** — disetujui pemilik produk beserta tiga package gratis (`flutter_local_notifications`, `timezone`, `shared_preferences`) dan perubahan konfigurasi Android (desugaring, receiver). **Semua tugas T-54…T-67 kini masuk.** **Mode gelap (T-68, PRD AB-24)** juga masuk atas permintaan pemilik produk, dengan pengaturannya di Profil. **Tahap 4 usulan AYO (6 November 2026): hanya dua yang tanpa skema baru, T-69 (cari rekan dari booking, AB-25) dan T-70 (riwayat main, AB-26).** Usulan lain yang mengubah skema (daftar tunggu, co-host, level pemain) sengaja dialihkan ke saran pengembangan lanjutan Bab 5 supaya ERD tidak berubah lagi. **AB-02 tetap berlaku:** urutan bawaan Home murni jarak; urutan lain hanya pilihan pengguna dan tidak boleh jadi bawaan. Urut/filter berdasarkan **harga** tetap ditolak (T-49).

### Aturan arsitektur

```
View  →  ViewModel  →  Repository  →  Firestore
```

1. **View** tidak boleh `import cloud_firestore`. Titik.
2. **ViewModel** tidak boleh `import cloud_firestore`. Selalu lewat Repository.
3. **Repository** satu-satunya lapisan yang berbicara dengan Firestore.
4. **Model** hanya data + `fromFirestore()` / `toFirestore()`. Tanpa logika bisnis, tanpa akses jaringan. (Boleh `import cloud_firestore` karena butuh tipe `DocumentSnapshot` dan `Timestamp` — itu tipe data, bukan akses jaringan.)
5. ViewModel memakai `ChangeNotifier` dan `notifyListeners()`.
6. Provider dipasang hanya untuk state lintas layar: **status autentikasi**, **posisi GPS**, dan (sejak v1.5) **pengaturan di HP** (`PengaturanViewModel`: pengingat jadwal dan mode tampilan). Untuk daftar data yang perlu langsung hidup (notifikasi, permintaan gabung), pakai `StreamBuilder` di dalam View yang membaca stream dari ViewModel. Untuk daftar yang diambil sekali lalu diolah di klien (Home, AB-02), pakai `ChangeNotifier` dengan state eksplisit — lihat `CONTOH-KODE-HOME.md`.

Kalau sebuah perubahan memaksa melanggar salah satu aturan di atas, berhenti dan jelaskan masalahnya.

**Cara memeriksanya:**

```bash
grep -rl "package:cloud_firestore" lib/ | grep -Ev "^lib/(repositories|models)/"
```

Harus tidak mengeluarkan apa pun. Jalankan sebelum setiap merge ke `main`.

## Konvensi kode

- Nama file: `snake_case.dart`. Nama kelas: `PascalCase`. Variabel/fungsi: `camelCase`.
- Nama fungsi dan komentar boleh bahasa Indonesia — ini justru membantu penulisnya.
- Semua teks yang dilihat pengguna **wajib bahasa Indonesia**. Taruh di `core/constants/app_strings.dart`.
- Format rupiah dan tanggal lewat `core/utils/formatter.dart`, jangan diformat manual di widget.
- Warna, ukuran, dan gaya teks lewat `core/constants/app_colors.dart` — nilainya diambil dari Figma, jangan tulis hex langsung di widget. **Sejak mode gelap (v1.5):** warna yang berbeda per mode (latar, permukaan, teks) dibaca lewat `context.warna.surface` dst. (`core/theme/app_palette.dart`), dan gaya teks berwarna berupa fungsi: `AppTextStyles.judulSeksi(context)`. `AppColors` hanya memuat warna yang sama di kedua mode (hijau merek, pastel olahraga). Layar yang baru wajib dilihat di kedua mode.
- Setiap layar wajib menangani tiga kondisi: **memuat**, **kosong**, dan **kesalahan**. Tidak boleh ada layar putih polos.
- Jangan tinggalkan `print()` di kode produksi.
- Jangan buat abstraksi yang belum dibutuhkan. Tidak perlu dependency injection framework, tidak perlu generic repository.

## Saat menulis kode

- Kerjakan satu tugas dari `SPRINT-PLAN.md` sampai tuntas sebelum pindah ke tugas berikutnya.
- Setelah membuat fitur, jalankan `flutter analyze` dan bereskan seluruh error.
- Jelaskan konsep Flutter yang baru dipakai secara singkat saat pertama kali muncul — penulisnya sedang belajar.
- Kalau butuh menambah package baru di luar daftar PRD Bagian 4, **minta izin dulu**.
- **Setiap query Firestore baru**, cek dulu `FIRESTORE-INDEXES.md`. Kalau butuh index baru, tambahkan ke `firestore.indexes.json` lalu `firebase deploy` — jangan klik tautan "create index" di pesan error, karena index-nya tidak akan masuk git.

## Menangani kesalahan

Repository melempar `Exception` dengan pesan berbahasa Indonesia yang siap ditampilkan. ViewModel menangkapnya dan menyimpannya ke field `pesanError`. View menampilkan lewat `SnackBar` atau widget kesalahan.

Jangan menelan kesalahan diam-diam dengan `try { } catch (e) { }` kosong.

## Tiga hal yang paling gampang salah

**1. Firestore Transaction tidak bisa menjalankan Query.** `transaction.get()` hanya menerima `DocumentReference`. Karena itu pencegahan double booking memakai kunci slot dengan ID dokumen deterministik (`slotBooking/{lapanganId}_{tanggal}_{jam}`), bukan kueri cek-bentrok. Lihat PRD AB-04. Jangan mencoba mengakalinya dengan kueri di dalam transaction — itu tidak akan jalan.

**2. Rata-rata rating jangan dihitung dengan membaca seluruh koleksi.** Pakai denormalisasi `ratingTotal` + `jumlahRating` yang diperbarui dalam transaction. Lihat PRD AB-05.

**3. Angka dari Firestore dibaca dengan `as num` lalu `.toDouble()`.** Firestore menyimpan angka bulat sebagai `int`. Kalau `latitude` kebetulan bernilai `-6` dan bukan `-6.2`, `as double` akan crash saat runtime. Ini jebakan yang pasti ditemui cepat atau lambat.

## Perintah yang sering dipakai

```bash
flutter pub get
flutter analyze
flutter test                     # BB-13 diuji otomatis di sini
flutter run
flutter build apk --release      # untuk dibagikan ke responden SUS

firebase deploy --only firestore  # rules + index sekaligus
```

## Git

- Satu cabang per fitur: `fitur/pencarian-lapangan`, `fitur/cari-rekan`.
- Hanya **integrator** yang boleh merge ke `main` dan mengubah isi `models/`.
- Pesan commit bahasa Indonesia, ringkas: `tambah filter olahraga di halaman Home`.
- Sebelum merge: `flutter analyze` bersih, `flutter test` hijau, dan pemeriksaan aturan lapisan di atas tidak mengeluarkan apa pun.
