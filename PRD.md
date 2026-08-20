# PRD — Sport Space

**Aplikasi Android pencarian lapangan olahraga dan rekan bermain berbasis lokasi**

Versi 1.1 · 17 Agustus 2026 · Diturunkan dari Pre-Thesis Bab 1–3 (revisi)

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
| **Firebase Storage** | Butuh paket Blaze. Foto lapangan pakai URL eksternal dari hasil seeding; foto profil pakai avatar inisial |
| **Riverpod, BLoC, GetX** | State management sudah dikunci: **Provider** |
| **Google Maps SDK** | Sudah dikunci: **OpenStreetMap + flutter_map** |
| **Payment gateway apa pun** | Di luar ruang lingkup penelitian. Pembayaran dilakukan di lokasi |
| **Panggilan Google Places API saat runtime** | Data lapangan sudah di-*seed* ke Firestore lebih dulu. Aplikasi hanya baca Firestore |
| **Geohash / geoflutterfire** | Kalkulasi jarak dilakukan di klien pakai Haversine manual |
| **Package `latlong2` untuk hitung jarak** | Haversine **wajib ditulis manual** — ini inti kontribusi skripsi dan akan diperiksa penguji |

### 2.2 Yang TIDAK dibangun

Fitur di bawah ini terdengar masuk akal tapi **di luar ruang lingkup**. Jangan bangun meski terlihat mudah:

- Aplikasi iOS atau web
- Chat / pesan antar pengguna
- Mode gelap, multi-bahasa (i18n), onboarding slider
- Statistik atau grafik di dashboard mitra
- Upload foto oleh pengguna
- Lupa password / verifikasi email
- Halaman pengaturan yang fungsional (Bahasa, Kebijakan Privasi, Bantuan, Tentang) — **cukup halaman statis**
- Laporan keuangan lapangan
- **Rating antar-pengguna** — lihat §12c

### 2.3 Yang WAJIB ada

- Haversine ditulis manual di `lib/core/utils/haversine.dart`
- Arsitektur MVVM terlihat jelas dari struktur folder
- Semua teks antarmuka berbahasa Indonesia
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
  intl: ^0.19.x              # format tanggal dan rupiah
  cached_network_image: ^3.x # foto lapangan
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
      app_strings.dart         # teks antarmuka berbahasa Indonesia
    data/
      seed_lapangan.dart       # data awal untuk AdminSeedScreen
    utils/
      haversine.dart           # WAJIB manual
      formatter.dart           # format rupiah, tanggal, jam
      validators.dart          # validasi form
    services/
      location_service.dart    # bungkus geolocator

  models/
    user_model.dart
    lapangan_model.dart
    aktivitas_bermain_model.dart
    permintaan_gabung_model.dart
    rating_model.dart
    booking_model.dart
    notifikasi_model.dart
    favorit_model.dart

  repositories/
    auth_repository.dart
    lapangan_repository.dart
    aktivitas_repository.dart
    rating_repository.dart
    booking_repository.dart
    notifikasi_repository.dart
    favorit_repository.dart

  features/
    auth/         { view/, viewmodel/ }
    lapangan/     { view/, viewmodel/ }
    aktivitas/    { view/, viewmodel/ }
    rating/       { view/, viewmodel/ }
    booking/      { view/, viewmodel/ }
    profil/       { view/, viewmodel/ }
    notifikasi/   { view/, viewmodel/ }
    favorit/      { view/, viewmodel/ }
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
| `fotoProfilURL` | String? | | selalu `null` — avatar dibuat dari inisial nama |
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
| `jamTutup` | String | ✓ | format `"HH:mm"` |
| `fasilitas` | List\<String\> | ✓ | mis. `["parkir","toilet","kantin","ruang ganti"]` |
| `fotoURL` | List\<String\> | ✓ | boleh larik kosong |
| `isMitra` | bool | ✓ | menentukan apakah tombol reservasi muncul |
| `pemilikId` | String? | | hanya terisi jika `isMitra == true` |
| `sumberData` | String | ✓ | `"places_api"` \| `"observasi"` \| `"mitra"` |
| `ratingTotal` | int | ✓ | jumlah seluruh nilai rating, awal `0` |
| `jumlahRating` | int | ✓ | banyak rating, awal `0` |
| `ratingRata2` | double | ✓ | atribut turunan, awal `0.0` |

> **`slotTersedia[]` TIDAK disimpan.** Di ERD ia atribut turunan, dihitung dari koleksi `slotBooking`. Jangan bikin fieldnya.
>
> **Badge "Verified" TIDAK menambah field.** Lihat AB-11 — badge diturunkan dari `sumberData`.

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
| `totalHarga` | int | estimasi, dibayar di lokasi |
| `dibuatPada` | Timestamp | |

### 6.7 `slotBooking/{lapanganId}_{tanggal}_{jam}` — kunci slot

Koleksi teknis untuk mencegah double booking. **Bukan entitas di ERD** — ini mekanisme implementasi dari atribut turunan `slotTersedia[]`.

ID dokumen contoh: `abc123_2026-09-01_19` (lapangan abc123, 1 Sept 2026, jam 19:00–20:00).

| Atribut | Tipe |
|---|---|
| `bookingId` | String |
| `lapanganId` | String |
| `tanggal` | String |
| `jam` | int (0–23) |

### 6.8 `notifikasi/{notifikasiId}`

| Atribut | Tipe | Keterangan |
|---|---|---|
| `notifikasiId` | String | |
| `untukUserId` | String | penerima |
| `tipe` | String | `PERMINTAAN_GABUNG` \| `PERMINTAAN_DITERIMA` \| `PERMINTAAN_DITOLAK` \| `BOOKING_BARU` \| `BOOKING_DIKONFIRMASI` \| `BOOKING_DITOLAK` |
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
```

Aturan tambahan: pembuat aktivitas **tidak bisa** mengirim permintaan gabung ke aktivitasnya sendiri; pengguna yang sudah jadi peserta tidak bisa mengirim permintaan lagi.

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
- Daftar favorit muncul di L-13 Profil.
- **Tidak memengaruhi pengurutan di L-04.** AB-02 tetap murni jarak.

### AB-11 · Badge status lapangan — **v1.1**

Badge di L-06 diturunkan dari data yang **sudah ada**, tanpa field baru:

| Badge | Syarat | Arti |
|---|---|---|
| ✅ Mitra Terdaftar | `isMitra == true` | Bisa direservasi lewat aplikasi |
| 🏅 Terverifikasi | `sumberData == "observasi"` | Data dikonfirmasi langsung oleh peneliti di lokasi |

Kalau keduanya terpenuhi, tampilkan dua-duanya. Kalau tidak ada yang terpenuhi (`sumberData == "places_api"`), jangan tampilkan badge apa pun.

> Pemetaan ini disengaja: model tiga sumber data di Bab 3 jadi **terlihat di antarmuka**, bukan cuma tertulis di dokumen. Ini bahan jawaban yang bagus kalau penguji bertanya soal validitas data.
>
> Label memakai "Terverifikasi", bukan "Verified", karena §2.3 mewajibkan seluruh teks antarmuka berbahasa Indonesia.

### AB-12 · Statistik profil — **v1.1**

Tiga angka di L-13 dihitung dengan **agregasi `count()`**, bukan dengan mengambil seluruh dokumen:

```dart
// count() hanya menagih 1 baca per 1000 dokumen — jauh lebih murah
// daripada .get() lalu .length, dan tidak butuh index tambahan.
final jumlahBooking = (await _db.collection('booking')
    .where('userId', isEqualTo: uid).count().get()).count;

final jumlahAktivitas = (await _db.collection('aktivitasBermain')
    .where('peserta', arrayContains: uid).count().get()).count;

final jumlahFavorit = (await _db.collection('users').doc(uid)
    .collection('favorit').count().get()).count;
```

Kotak statistik ketiga di Figma berlabel "4.9★ Rating" — itu **diganti** menjadi **jumlah favorit**. Alasannya di §12c.

---

## 8. Spesifikasi Layar

Navigasi bawah punya **4 tab: Home · Map · Teman · Profil** (v1.1, mengikuti prototipe Figma).

> ⚠️ Bab 3.3.2 poin 5 masih menuliskan 3 tab. **Wajib direvisi** sebelum Bab 4 ditulis.

Tab **Map** langsung membuka L-05. Tab **Teman** membuka L-07.

### L-01 · Splash Screen
Logo + nama "Sport Space" di tengah, tagline di bawah logo, indikator loading, latar warna utama. Tampil ~2 detik, lalu cek status login: sudah login → Home; belum → Login.

> Figma menampilkan tombol "Mulai Sekarang" di layar ini. Tombol itu **tidak dibangun** — splash berpindah otomatis. Hapus tombolnya dari Figma agar tangkapan layar Bab 4 konsisten.

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
| Filter chip olahraga | Semua / Futsal / Mini Soccer / Badminton / Padel — **lima chip, termasuk "Semua"** |
| Daftar kartu lapangan | **Daftar vertikal**, satu kartu per baris. Isi: foto, nama, alamat, **jarak (km, 1 desimal)**, harga per jam, rating rata-rata + jumlah ulasan, ikon ♡ favorit |
| Bottom navigation | Home · Map · Teman · Profil |

**Peta tidak tertanam di Home.** Peta punya tab sendiri (L-05). Frame Figma menampilkan peta 220px di dalam Home — bagian itu dihapus, digantikan daftar vertikal penuh.

Kondisi kosong: "Belum ada lapangan di sekitar kamu." Kondisi izin lokasi ditolak: sesuai AB-03.

### L-05 · Peta Lapangan
Dibuka dari tab **Map**. `FlutterMap` dengan tile OpenStreetMap, marker posisi pengguna + marker tiap lapangan. Menekan marker menampilkan kartu ringkas (nama, jarak, harga) dengan tombol menuju L-06. Tombol kecil "kembali ke posisi saya" (ikon target, pojok kanan bawah peta) menggeser peta balik ke posisi pengguna — ditambahkan saat implementasi (T-14) karena marker posisi bisa keluar layar setelah peta digeser untuk melihat lapangan lain, dan Figma/PRD sebelumnya tidak menyediakan jalan kembali selain geser manual.

Tile URL: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
`userAgentPackageName` wajib diisi sesuai package aplikasi.

### L-06 · Detail Lapangan — **diperbarui v1.1**
Foto (satu gambar cukup), **ikon ♡ favorit di pojok kanan atas foto** (AB-10), nama + jenis olahraga + rating rata-rata, **badge status** (AB-11), alamat + tombol lihat di peta, jam operasional, daftar fasilitas (ikon + label), harga sewa, daftar ulasan pengguna, tombol **"Beri Rating"**, dan tombol **"Ajukan Reservasi"** — muncul hanya bila `isMitra == true`.

> Figma menampilkan pemilihan slot jam langsung di layar ini. Pemilihan slot tetap di **L-10** sesuai PRD, karena butuh pemilihan tanggal dan perhitungan estimasi harga yang tidak muat di layar detail. Tombol "Booking Sekarang" di Figma = tombol "Ajukan Reservasi" yang membuka L-10.
>
> Figma juga menampilkan bottom navigation di dalam kartu detail. Itu keliru — layar detail dibuka di atas tab, tanpa bottom nav.

### L-07 · Cari Rekan
Dibuka dari tab **Teman**. Tab filter olahraga — **lima chip termasuk "Semua", dan Mini Soccer wajib ada** (Figma baru punya tiga). Daftar kartu aktivitas berisi nama pembuat, olahraga, nama lapangan, tanggal & jam, dan `jumlahPemainSaatIni/jumlahPemainDibutuhkan` dengan progress bar; tombol **Gabung** per kartu; FAB untuk membuat aktivitas baru (L-08). Aktivitas yang sudah `PENUH` atau waktunya lewat tidak ditampilkan.

### L-08 · Buat Aktivitas (form)
Pilih olahraga, pilih lapangan (dari daftar lapangan), tanggal & jam, jumlah pemain dibutuhkan, catatan opsional. Validasi: semua wajib kecuali catatan; waktu harus di masa depan; jumlah pemain 2–30.

### L-09 · Detail Aktivitas
Info lengkap aktivitas, daftar peserta. Jika pengguna adalah pembuat: tampilkan daftar permintaan gabung dengan tombol **Terima** / **Tolak**. Jika bukan: tombol **Gabung** atau label status permintaannya.

### L-10 · Ajukan Reservasi (form)
Pilih tanggal, jam mulai, durasi (jam). Tampilkan slot yang sudah terisi agar tidak dipilih (chip jam bertanda "Penuh", mengikuti gaya Figma). Tampilkan estimasi total harga. Tombol **Ajukan Reservasi** menjalankan AB-04.

### L-11 · Beri Rating (form/modal)
Pilih bintang 1–5, isi ulasan opsional, tombol Kirim → menjalankan AB-05.

### L-12 · Notifikasi
Daftar dari koleksi `notifikasi` yang `untukUserId == uid`, urut terbaru. Menekan item membuka objek terkait dan menandai `sudahDibaca = true`.

### L-13 · Profil — **diperbarui v1.1**

Dibuka dari tab **Profil**.

| Bagian | Isi |
|---|---|
| Header | Avatar inisial + nama + surel + nomor telepon, tombol Edit Profil |
| Kotak statistik | **Booking** · **Aktivitas** · **Favorit** — dihitung dengan AB-12 |
| Olahraga Favorit | Menampilkan `olahragaFavorit`, bisa diubah (pilih dari 4 olahraga) |
| Lokasi Default | Menampilkan `lokasiDefault.nama`, bisa diubah — dipakai AB-03 |
| Lapangan Favorit | Daftar dari subkoleksi `favorit` (AB-10) |
| Riwayat Pemesanan | Daftar booking pengguna dengan 5 status |
| Aktivitas Saya | Aktivitas yang dibuat dan yang diikuti |
| Menu statis | Bantuan, Kebijakan Privasi, Tentang — halaman statis saja |
| Dashboard Mitra | Hanya muncul jika `role == "mitra"` |
| Keluar | Logout |

> Figma menampilkan menu "Notifikasi: Aktif" yang bisa diatur. Itu **tidak dibangun** — §2.2 mengunci pengaturan sebagai halaman statis, dan aplikasi tidak memakai FCM sehingga tidak ada yang bisa dimatikan.

### L-14 · Dashboard Mitra
Daftar lapangan milik mitra + tombol tambah lapangan; daftar booking masuk dengan tombol **Konfirmasi** / **Tolak**.

### L-15 · Tambah/Edit Lapangan (form mitra)
Nama, alamat, koordinat (latitude & longitude diisi manual atau ambil dari lokasi saat ini), jenis olahraga (multi-pilih), harga, jam buka & tutup, fasilitas (multi-pilih), URL foto. Saat disimpan: `isMitra = true`, `pemilikId = uid`, `sumberData = "mitra"`.

---

## 9. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function login() { return request.auth != null; }
    function pemilikDok(uid) { return login() && request.auth.uid == uid; }

    match /users/{userId} {
      allow read: if login();
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
      allow create, update: if login() && request.resource.data.userId == request.auth.uid;
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
  }
}
```

> Aturan ini sengaja longgar di beberapa titik (mis. `update` aktivitas) supaya alur gabung-aktivitas jalan tanpa Cloud Functions. Untuk skripsi ini memadai; sebutkan sebagai keterbatasan di Bab 5.
>
> Aturan `favorit` justru **ketat** — hanya pemilik akun yang bisa membaca dan menulis. Ini contoh bagus untuk ditunjukkan ke penguji saat membahas keamanan data pribadi.

---

## 10. Data Awal (Seeding)

Data lapangan dimuat **satu kali** sebelum aplikasi dipakai, lewat halaman tersembunyi `AdminSeedScreen` yang hanya berisi satu tombol. Setelah dijalankan sekali, rutenya dinonaktifkan.

Sumber data dan atribut `sumberData`:

| Sumber | `sumberData` | `isMitra` | Kelengkapan |
|---|---|---|---|
| Google Places API (diambil manual di luar aplikasi) | `"places_api"` | `false` | nama, alamat, koordinat, jam, foto |
| Observasi langsung peneliti | `"observasi"` | `false` | lengkap termasuk harga & fasilitas |
| Pendaftaran mitra lewat aplikasi | `"mitra"` | `true` | lengkap + bisa direservasi |

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
  'sumberData': 'observasi',
  'ratingTotal': 0,
  'jumlahRating': 0,
  'ratingRata2': 0.0,
}
```

**Target: 20–30 lapangan** di wilayah penelitian (Alam Sutera, BSD, Gading Serpong dan sekitarnya), dengan sebaran keempat olahraga supaya tiap filter ada isinya. Sertakan minimal 3 lapangan `isMitra: true` agar alur reservasi bisa didemokan.

Data siap pakai beserta catatan verifikasinya ada di **`SEED-DATA.md`**.

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
| **BB-33** | **Buka detail lapangan `sumberData == "observasi"`** | **Badge "🏅 Terverifikasi" muncul** |
| **BB-34** | **Buka detail lapangan `sumberData == "places_api"`** | **Tidak ada badge status yang muncul** |
| **BB-35** | **Buka Home dengan izin lokasi ditolak, tapi punya `lokasiDefault`** | **Daftar tetap tampil terurut dari lokasi default, muncul spanduk pemberitahuan** |
| **BB-36** | **Buka Profil** | **Angka Booking, Aktivitas, dan Favorit cocok dengan isi Firestore** |
| **BB-37** | **Pengguna A mencoba membaca favorit pengguna B** | **Ditolak Security Rules** |

---

## 12. Definisi Selesai

Satu fitur dianggap selesai jika:

1. Seluruh kasus BB yang terkait lulus di perangkat Android nyata (bukan hanya emulator).
2. Tidak melanggar aturan lapisan MVVM di Bagian 5.
3. Tidak ada `print()` yang tersisa di kode produksi.
4. Semua teks antarmuka berbahasa Indonesia.
5. Kondisi kosong, memuat, dan kesalahan sudah ditangani (tidak ada layar putih polos).
6. `flutter analyze` bersih tanpa error.

---

## 12b. Keputusan Terbuka — perlu disepakati sebelum Sprint 4

**Firebase Storage.** Tabel 3.4 dan Bab 2.9 skripsi mencantumkan Firebase Storage sebagai teknologi yang dipakai untuk menyimpan foto lapangan dan foto profil. PRD ini melarangnya (Bagian 2.1) karena menambah kompleksitas untuk pemula.

Keduanya tidak bisa benar sekaligus. Pilih salah satu sebelum masuk Sprint 4:

- **Opsi A — hapus Firebase Storage dari skripsi.** Revisi Tabel 3.4 (hapus baris 4) dan Bab 2.9 (hapus poin 3). Foto lapangan memakai URL hasil seeding, foto profil memakai avatar inisial. Paling hemat waktu.
- **Opsi B — implementasikan versi minimal.** Tambah `image_picker` + `firebase_storage`, aktifkan upload foto **hanya** pada form Tambah/Edit Lapangan milik mitra (T-26). Sekitar 2–4 jam kerja tambahan, dan klaim di skripsi jadi terbukti. Membutuhkan paket Blaze — yang memang sudah disiapkan di T-00d.

Selama belum diputuskan, ikuti larangan di Bagian 2.1.

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
| Batasan | Bab 1.3 Ruang Lingkup |
| Haversine | Bab 2.3 |
| OSM & flutter_map | Bab 2.4 |
| Firebase | Bab 2.9 |
| Black Box & SUS | Bab 2.10, 2.11.3 |
| Aktor & fungsi | Bab 3.3.1, Tabel 3.3 |
| Teknologi | Tabel 3.4 |
| Model data | Bab 3.3.2 poin 6, Tabel 3.10 |
| Layar | Bab 3.3.2 poin 5 ⚠️ **perlu revisi: 3 tab → 4 tab** |

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
