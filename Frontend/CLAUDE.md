# Instruksi Proyek — Sport Space

Aplikasi Android skripsi: pencarian lapangan olahraga dan rekan bermain berbasis lokasi.
Dibangun dengan Flutter + Firebase oleh **tim 3 orang yang baru pertama kali memakai Flutter**.

## Sebelum mengerjakan apa pun

1. Baca `PRD.md` — itu sumber kebenaran tunggal. **Versi berlaku: 1.1.**
2. Baca `SPRINT-PLAN.md` — untuk tahu tugas mana yang sedang dikerjakan dan urutannya.
3. Kalau ada pertentangan antara instruksi pengguna dan PRD, **tanyakan** — jangan diam-diam memilih salah satu.

### Dokumen pendamping

| Berkas | Isi | Kapan dibaca |
|---|---|---|
| `PRD.md` | Spesifikasi lengkap — skema, layar, aturan bisnis, kasus uji | Selalu |
| `SPRINT-PLAN.md` | Tugas T-00a…T-40, urutan, pembagian peran | Selalu |
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
- **Firebase Cloud Messaging** — notifikasi dibuat in-app lewat koleksi `notifikasi` + Firestore listener.
- **Firebase Storage** — tidak ada upload foto. Foto lapangan pakai URL eksternal, foto profil pakai avatar inisial. (Keputusan PRD §12b masih terbuka — sampai diputuskan, larangan ini berlaku.)
- **Riverpod, BLoC, GetX** — state management sudah dikunci: **Provider**.
- **Google Maps SDK** — peta sudah dikunci: **flutter_map + OpenStreetMap**.
- **`Distance()` dari `latlong2`** untuk menghitung jarak — pakai `hitungJarakHaversine()` buatan sendiri. `latlong2` hanya boleh dipakai untuk tipe `LatLng`.
- **geohash / geoflutterfire** — jarak dihitung di klien.
- **Google Places API saat runtime** — data sudah di-*seed* ke Firestore lebih dulu.
- **Payment gateway** — di luar ruang lingkup.

### Batas ruang lingkup

Jangan membangun fitur yang tidak ada di PRD, meski terlihat sepele atau "sekalian saja". Yang sering muncul sebagai godaan dan **harus ditolak**: chat antar pengguna, mode gelap, multi-bahasa, lupa password, verifikasi email, statistik/grafik dashboard mitra, onboarding slider, upload foto, **rating antar-pengguna** (lihat PRD §12c).

Kalau menurutmu ada fitur yang benar-benar perlu tapi tidak ada di PRD: **sampaikan sebagai saran, jangan langsung dibuat.**

**Sudah masuk ruang lingkup sejak v1.1** (jangan tolak lagi): favorit lapangan (AB-10), badge status lapangan (AB-11), olahraga favorit dan lokasi default pada `users`, statistik profil (AB-12).

### Aturan arsitektur

```
View  →  ViewModel  →  Repository  →  Firestore
```

1. **View** tidak boleh `import cloud_firestore`. Titik.
2. **ViewModel** tidak boleh `import cloud_firestore`. Selalu lewat Repository.
3. **Repository** satu-satunya lapisan yang berbicara dengan Firestore.
4. **Model** hanya data + `fromFirestore()` / `toFirestore()`. Tanpa logika bisnis, tanpa akses jaringan. (Boleh `import cloud_firestore` karena butuh tipe `DocumentSnapshot` dan `Timestamp` — itu tipe data, bukan akses jaringan.)
5. ViewModel memakai `ChangeNotifier` dan `notifyListeners()`.
6. Provider dipasang hanya untuk state lintas layar: **status autentikasi** dan **posisi GPS**. Untuk daftar data yang perlu langsung hidup (notifikasi, permintaan gabung), pakai `StreamBuilder` di dalam View yang membaca stream dari ViewModel. Untuk daftar yang diambil sekali lalu diolah di klien (Home, AB-02), pakai `ChangeNotifier` dengan state eksplisit — lihat `CONTOH-KODE-HOME.md`.

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
- Warna, ukuran, dan gaya teks lewat `core/constants/app_colors.dart` — nilainya diambil dari Figma, jangan tulis hex langsung di widget.
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
