# Sport Space — Panduan Memulai

Paket ini adalah **lapisan yang ditempelkan di atas project Flutter baru**, bukan project Flutter yang sudah lengkap. Folder `android/`, `ios/`, dan berkas Gradle harus dibuat oleh `flutter create` karena isinya bergantung pada versi SDK di komputer masing-masing.

Ikuti urutannya. Sekitar 30–45 menit sampai `flutter run` berhasil.

---

## Isi paket

| Berkas | Guna |
|---|---|
| `CLAUDE.md` | Instruksi proyek — dibaca otomatis oleh Claude di VSCode |
| `PRD.md` | Spesifikasi v1.1 — sumber kebenaran tunggal |
| `SPRINT-PLAN.md` | Tugas T-00a…T-40 dan papan pantau |
| `docs/SEED-DATA.md` | 30 lapangan + status verifikasi tiap field |
| `docs/FIRESTORE-INDEXES.md` | 11 composite index dan alasannya |
| `docs/CONTOH-KODE-HOME.md` | Acuan gaya kode |
| `pubspec.yaml` | Dependency sesuai PRD Bagian 4 |
| `firebase.json`, `firestore.rules`, `firestore.indexes.json` | Konfigurasi Firebase siap deploy |
| `analysis_options.yaml` | Aturan `flutter analyze` |
| `lib/` | Fitur Home lengkap + kerangka folder MVVM |
| `test/haversine_test.dart` | Uji otomatis BB-13 |

---

## Langkah 1 · Buat project Flutter (T-01)

```bash
flutter create --org id.ac.binus --project-name sport_space sport_space
cd sport_space
```

Lalu **salin seluruh isi paket ini ke dalamnya**, timpa `pubspec.yaml` dan `lib/main.dart` yang dibuat `flutter create`:

```bash
cp -r /path/ke/sport-space/. .
flutter pub get
```

## Langkah 2 · Atur Android

Buka `android/app/build.gradle.kts` (atau `build.gradle`), pastikan:

```kotlin
minSdk = 21          // PRD Bagian 4
```

Buka `android/app/src/main/AndroidManifest.xml`, tambahkan **di atas** tag `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

> Tanpa dua izin lokasi itu, `geolocator` akan selalu mengembalikan izin ditolak dan kalian akan mengira ada bug di `location_service.dart`.

## Langkah 3 · Sambungkan Firebase (T-01)

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Perintah itu menghasilkan `lib/firebase_options.dart`. Setelah ada, buka `lib/main.dart` dan:

1. Buka komentar baris `import 'firebase_options.dart';`
2. Ganti `await Firebase.initializeApp();` menjadi:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Langkah 4 · Deploy rules dan index (T-06)

```bash
npm install -g firebase-tools
firebase login
firebase use --add          # pilih project yang sama dengan langkah 3
firebase deploy --only firestore
```

Cek di Firebase Console → Firestore → Indexes. **Tunggu semua berstatus *Enabled*, bukan *Building*.**

> Jangan lewati langkah ini karena "toh belum ada query-nya". Emulator Firestore tidak menegakkan aturan index, jadi kalau ditunda, semuanya kelihatan jalan sampai kalian pindah ke Firestore asli di Sprint 4 — dan saat itu error-nya muncul di banyak layar sekaligus.

## Langkah 5 · Perbaiki koordinat (T-00f) — **jangan dilewati**

Buka `lib/core/data/seed_lapangan.dart`. Hanya 5 dari 30 lapangan yang koordinatnya terverifikasi (bertanda `// KOORDINAT TERVERIFIKASI`). Sisanya perkiraan tingkat kelurahan.

Untuk tiap lapangan tanpa tanda itu: Google Maps → cari namanya → klik kanan di pin → salin koordinat → tempel.

Sekitar 10 menit kalau dibagi bertiga. **BB-13 tidak akan lulus tanpa ini**, dan penguji berhak menanyakan asal koordinatnya.

## Langkah 6 · Jalankan

```bash
flutter analyze     # harus bersih
flutter test        # BB-13 harus hijau, 7 uji
flutter run
```

Layar Home akan menampilkan "Belum ada lapangan" sampai T-10 (seeding) dijalankan. Itu normal — dan sekaligus bukti bahwa kondisi kosong sudah ditangani.

---

## Setelah berhasil jalan

Urutannya ada di `SPRINT-PLAN.md`. Ringkasnya:

1. **T-00b — belajar Flutter dulu, bertiga, masing-masing.** Ini bagian yang paling sering dilewati dan paling mahal akibatnya. Kode acuan di `lib/` cuma berguna kalau kalian paham kenapa `context.watch` beda dari `context.read` — dan itu pertanyaan yang wajar muncul di sidang.
2. T-03 — tulis 7 model sisanya mengikuti pola `lapangan_model.dart`.
3. T-07 — Login & Register.
4. T-10 — seeding data.

## Perintah harian

```bash
flutter pub get
flutter analyze
flutter test
flutter run

firebase deploy --only firestore    # setelah mengubah rules atau index
```

## Sebelum merge ke `main`

```bash
flutter analyze                                   # harus bersih
flutter test                                      # harus hijau
grep -rl "package:cloud_firestore" lib/ | grep -Ev "^lib/(repositories|models)/"
```

Perintah ketiga harus **tidak mengeluarkan apa pun**. Kalau ada isinya, berarti ada View atau ViewModel yang menyentuh Firestore langsung — itu melanggar MVVM yang diklaim di skripsi, dan lebih mudah diperbaiki sekarang daripada seminggu sebelum sidang.
