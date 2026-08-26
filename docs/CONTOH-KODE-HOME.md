# Contoh Kode Vertikal — Fitur Home (L-04)

Ini bukan potongan kode. Ini **satu fitur utuh dari atas ke bawah**, dipakai
sebagai acuan gaya kode bertiga. Setiap fitur berikutnya ditulis mengikuti
pola yang sama.

## Alur data — baca dari bawah ke atas

```
Firestore
   ▲
   │  hanya lapisan ini yang tahu Firestore ada
LapanganRepository        lib/repositories/lapangan_repository.dart
   ▲
   │  hitung Haversine, urutkan, saring
HomeViewModel             lib/features/lapangan/viewmodel/home_viewmodel.dart
   ▲
   │  context.watch / context.read
HomeScreen                lib/features/lapangan/view/home_screen.dart
```

## Isi paket

| Berkas | Lapisan | Isi |
|---|---|---|
| `core/utils/haversine.dart` | util | Rumus Haversine manual (AB-01) |
| `core/utils/formatter.dart` | util | Format rupiah, tanggal, jarak |
| `core/constants/app_colors.dart` | konstanta | Warna & ukuran dari Figma |
| `core/constants/app_sports.dart` | konstanta | 4 olahraga + label + ikon |
| `core/services/location_service.dart` | service | Bungkus geolocator (AB-03) |
| `models/lapangan_model.dart` | model | Data + fromFirestore/toFirestore |
| `repositories/lapangan_repository.dart` | repository | **Satu-satunya** yang impor cloud_firestore |
| `features/lapangan/viewmodel/home_viewmodel.dart` | viewmodel | Seluruh logika tampilan |
| `features/lapangan/view/home_screen.dart` | view | Hanya menggambar |
| `widgets/kartu_lapangan.dart` | widget | Kartu satu lapangan |
| `widgets/chip_olahraga.dart` | widget | Baris chip filter |

## Cara memasang

Salin isi `lib/` ke project kamu, lalu pasang ViewModel-nya di `main.dart`:

```dart
ChangeNotifierProvider(
  create: (_) => HomeViewModel(
    repository: LapanganRepository(),
    locationService: LocationService(),
  ),
  child: const HomeScreen(),
)
```

## Cara cepat memeriksa apakah aturan lapisan dilanggar

```bash
# Harus mengembalikan TEPAT SATU baris: lapangan_repository.dart
grep -rl "package:cloud_firestore" lib/ | grep -v "^lib/repositories/"
```

Kalau perintah itu mengeluarkan berkas selain di `lib/repositories/` dan
`lib/models/`, berarti ada logika yang salah tempat. Jalankan ini sebelum
setiap merge ke `main`.

> `models/` boleh mengimpor `cloud_firestore` karena butuh tipe
> `DocumentSnapshot` dan `Timestamp` — itu tipe data, bukan akses jaringan.

## Empat hal yang paling layak ditiru dari contoh ini

**1. Lima kondisi ditangani eksplisit, bukan dua.** Lihat `enum KondisiHome`.
Bukan cuma "memuat" dan "berhasil" — ada gagal, kosong, dan lokasi ditolak.
Bahkan ada *dua* jenis kosong: tidak ada data sama sekali, versus filter tidak
menyisakan hasil. Pesannya beda karena jalan keluarnya beda.

**2. Repository menerjemahkan kesalahan.** Kode Firebase seperti
`permission-denied` diubah jadi kalimat Indonesia yang siap tampil. View
tinggal menampilkan apa adanya, tidak perlu tahu Firebase.

**3. Model tidak menyimpan hasil hitungan.** `jarakKm` ada di model tapi
tidak ikut `toFirestore()`. Nilainya diisi ViewModel lewat
`salinDenganJarak()`. Ini menjaga model tetap murni data.

**4. `as num` lalu `.toDouble()`, bukan `as double`.** Firestore menyimpan
angka bulat sebagai int. Kalau `latitude` kebetulan bernilai `-6` (bukan
`-6.2`), `as double` akan crash. Jebakan ini akan kalian temui cepat atau
lambat — lebih baik dihindari sejak awal.

## Yang sengaja dibiarkan sebagai TODO

Ada empat `TODO` di `home_screen.dart` — nama pengguna, halaman detail,
favorit, dan notifikasi. Semuanya menunggu tugas lain di SPRINT-PLAN
(T-07, T-13, T-15). Sengaja tidak diisi supaya batas tugasnya jelas.
