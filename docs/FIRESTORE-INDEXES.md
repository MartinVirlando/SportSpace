# Composite Index Firestore — Sport Space

**Artefak utama:** `firestore.indexes.json` (11 index) · **Dokumen ini:** penjelasan kenapa tiap index ada
**Turunan dari:** PRD Bagian 6 (skema) + Bagian 8 (spesifikasi layar) · **Dipakai mulai:** T-06, wajib beres sebelum T-15

---

## Kenapa file JSON, bukan cuma markdown ini

Daftar index di markdown gampang basi — ditulis sekali, lalu kodenya berubah dan dokumennya nggak. Sedangkan `firestore.indexes.json` adalah **artefak yang bisa di-deploy**:

```bash
firebase deploy --only firestore:indexes
```

Satu perintah, 11 index langsung dibuat. Masuk git, jadi ketiganya punya index yang sama persis. Dokumen ini fungsinya beda: menjawab pertanyaan *"kenapa butuh index ini?"* — yang akan ditanya penguji, dan yang nggak bisa dijawab oleh file JSON.

Jadi keduanya perlu, tapi **JSON yang jadi sumber kebenaran.** Kalau nanti ada index baru, tambahkan ke JSON dulu, baru catat di sini.

---

## Kenapa ini perlu disiapkan sekarang, bukan nanti pas error

Firestore memang menampilkan pesan error yang berisi **tautan langsung untuk membuat index**. Kelihatannya gampang. Tiga alasan kenapa tetap harus disiapkan di depan:

1. **Pembangunan index makan waktu beberapa menit.** Kalau ketahuan pas demo di depan pembimbing atau pas sidang, kalian cuma bisa menunggu sambil ditonton.
2. **Emulator Firestore tidak menegakkan aturan index.** Kalau kalian tes di emulator, semua query jalan mulus — lalu meledak begitu ganti ke Firestore asli. Ini jebakan yang paling sering bikin bingung karena "di laptop saya jalan kok".
3. **Bikin index lewat tautan error itu bikin drift.** Index-nya cuma ada di Firebase Console milik satu orang, nggak masuk git, dan dua anggota tim lain tetap kena error yang sama.

---

## Ringkasan: 11 index

| # | Koleksi | Field (urut) | Dipakai di |
|---|---|---|---|
| 1 | `lapangan` | `pemilikId` ↑, `nama` ↑ | L-14 daftar lapangan mitra |
| 2 | `aktivitasBermain` | `status` ↑, `waktu` ↑ | L-07 filter "Semua" |
| 3 | `aktivitasBermain` | `status` ↑, `jenisOlahraga` ↑, `waktu` ↑ | L-07 filter per olahraga |
| 4 | `aktivitasBermain` | `pembuatId` ↑, `waktu` ↓ | L-13 aktivitas yang saya buat |
| 5 | `aktivitasBermain` | `peserta` (array), `waktu` ↓ | L-13 aktivitas yang saya ikuti |
| 6 | `rating` | `lapanganId` ↑, `tanggal` ↓ | L-06 daftar ulasan |
| 7 | `booking` | `userId` ↑, `dibuatPada` ↓ | L-13 riwayat pemesanan |
| 8 | `booking` | `pemilikId` ↑, `dibuatPada` ↓ | L-14 booking masuk |
| 9 | `booking` | `pemilikId` ↑, `status` ↑, `dibuatPada` ↓ | L-14 booking masuk + filter status |
| 10 | `slotBooking` | `lapanganId` ↑, `tanggal` ↑, `jam` ↑ | L-10 slot yang sudah terisi |
| 11 | `notifikasi` | `untukUserId` ↑, `dibuatPada` ↓ | L-12 daftar notifikasi |

Batas kuota Firestore adalah 200 composite index per database, jadi 11 masih sangat longgar. Biaya index yang tidak terpakai praktis nol untuk skala skripsi — **kalau ragu, bikin saja**, jauh lebih murah daripada kena error pas demo.

---

## Aturan dasarnya (ini yang perlu dipahami, bukan dihafal)

Firestore membuat index otomatis untuk **satu field**. Untuk **kombinasi field**, index harus dibuat manual — dokumentasinya menyebut alasannya: jumlah kombinasi yang mungkin terlalu banyak untuk dibuat otomatis semua.

Aturan praktis yang menutup hampir semua kasus di aplikasi ini:

| Bentuk query | Butuh composite index? |
|---|---|
| `where(a == x)` saja | ❌ otomatis |
| `where(a == x).orderBy(a)` | ❌ otomatis |
| **`where(a == x).orderBy(b)`** | ✅ **ya** — ini penyebab 9 dari 11 index di atas |
| `where(a == x).where(b > y)` | ✅ ya |
| `where(a arrayContains x).orderBy(b)` | ✅ ya |
| `.limit(n)` tanpa where/orderBy | ❌ otomatis |

**Urutan field di dalam index wajib mengikuti aturan:** semua field equality (`==`) dulu, baru field range/inequality (`>`, `<`) atau `orderBy`. Kalau urutannya salah, index-nya ada tapi tidak dipakai — dan errornya tetap muncul.

---

## Rincian per koleksi

### `lapangan` — 1 index

Query utama di Home (L-04) **tidak butuh index sama sekali**, dan ini penting untuk dipahami:

```dart
// AB-02: ambil semua, hitung Haversine di klien, urutkan di klien
final snap = await _db.collection('lapangan').limit(500).get();
```

Search bar dan filter chip olahraga juga diproses di sisi klien (PRD L-04). Jadi jangan tergoda menambah `.where()` di sini — selain butuh index baru, itu melanggar AB-02.

Yang butuh index cuma Dashboard Mitra:

```dart
// Index #1 — (pemilikId ASC, nama ASC)
_db.collection('lapangan')
   .where('pemilikId', isEqualTo: uid)
   .orderBy('nama')
   .snapshots();
```

> Kalau kalian tidak pakai `.orderBy('nama')`, index #1 tidak dibutuhkan (equality satu field itu otomatis). Saya tetap sertakan karena daftar lapangan yang urutannya berubah-ubah tiap refresh kelihatan seperti bug di depan penguji.

---

### `aktivitasBermain` — 4 index

Halaman Cari Rekan (L-07) menyaring aktivitas yang `TERBUKA` **dan** waktunya belum lewat:

```dart
// Index #2 — (status ASC, waktu ASC) — filter "Semua"
_db.collection('aktivitasBermain')
   .where('status', isEqualTo: 'TERBUKA')
   .where('waktu', isGreaterThan: Timestamp.now())
   .orderBy('waktu')
   .snapshots();

// Index #3 — (status ASC, jenisOlahraga ASC, waktu ASC) — filter per olahraga
_db.collection('aktivitasBermain')
   .where('status', isEqualTo: 'TERBUKA')
   .where('jenisOlahraga', isEqualTo: 'badminton')
   .where('waktu', isGreaterThan: Timestamp.now())
   .orderBy('waktu')
   .snapshots();
```

⚠️ **Jebakan yang pasti kalian temui di sini:** kalau sebuah query punya filter pertidaksamaan (`isGreaterThan`), maka `orderBy` yang pertama **wajib** field yang sama. Jadi `.orderBy('dibuatPada')` setelah `.where('waktu', isGreaterThan: ...)` akan ditolak Firestore, dan pesan errornya tidak menyebut hal ini dengan jelas.

Untuk "Aktivitas Saya" di Profil (L-13), ada dua daftar berbeda:

```dart
// Index #4 — (pembuatId ASC, waktu DESC) — aktivitas yang saya buat
_db.collection('aktivitasBermain')
   .where('pembuatId', isEqualTo: uid)
   .orderBy('waktu', descending: true)
   .snapshots();

// Index #5 — (peserta CONTAINS, waktu DESC) — aktivitas yang saya ikuti
_db.collection('aktivitasBermain')
   .where('peserta', arrayContains: uid)
   .orderBy('waktu', descending: true)
   .snapshots();
```

Catatan: `peserta` selalu berisi `pembuatId` (PRD 6.3), jadi index #5 sebenarnya sudah mencakup aktivitas yang dia buat sendiri. Index #4 tetap saya sertakan kalau kalian mau memisahkan dua tab. Kalau tidak, hapus saja index #4 dari JSON.

⚠️ Satu query hanya boleh punya **satu** `arrayContains`. Jadi kalian tidak bisa menggabungkan `peserta arrayContains uid` dengan `jenisOlahraga arrayContains ...` — untungnya di PRD `jenisOlahraga` pada aktivitas bertipe String tunggal, bukan array.

---

### `rating` — 1 index

```dart
// Index #6 — (lapanganId ASC, tanggal DESC)
_db.collection('rating')
   .where('lapanganId', isEqualTo: lapanganId)
   .orderBy('tanggal', descending: true)
   .limit(20)
   .snapshots();
```

Ini untuk **menampilkan** ulasan di L-06. Perhitungan rata-rata rating **tidak** lewat sini — itu pakai `ratingTotal` / `jumlahRating` yang didenormalisasi (AB-05). Jangan pernah menghitung rata-rata dengan membaca seluruh koleksi ini.

---

### `booking` — 3 index

```dart
// Index #7 — (userId ASC, dibuatPada DESC) — riwayat pemesanan pengguna, L-13
_db.collection('booking')
   .where('userId', isEqualTo: uid)
   .orderBy('dibuatPada', descending: true)
   .snapshots();

// Index #8 — (pemilikId ASC, dibuatPada DESC) — booking masuk ke mitra, L-14
_db.collection('booking')
   .where('pemilikId', isEqualTo: uid)
   .orderBy('dibuatPada', descending: true)
   .snapshots();

// Index #9 — (pemilikId ASC, status ASC, dibuatPada DESC) — tab "Menunggu" di L-14
_db.collection('booking')
   .where('pemilikId', isEqualTo: uid)
   .where('status', isEqualTo: 'MENUNGGU')
   .orderBy('dibuatPada', descending: true)
   .snapshots();
```

Perhatikan: index #8 **tidak** bisa melayani query #9. Menambah satu filter equality di tengah berarti index baru. Ini sumber kebingungan klasik — "kan sudah ada indexnya?" — padahal beda query, beda index.

AB-07 (status `SELESAI` dihitung di klien) tidak butuh query tambahan: statusnya diperiksa dari daftar yang sudah dimuat, lalu ditulis balik satu per satu.

---

### `slotBooking` — 1 index

Dipakai L-10 untuk menandai jam yang sudah terisi supaya tidak bisa dipilih:

```dart
// Index #10 — (lapanganId ASC, tanggal ASC, jam ASC)
final snap = await _db.collection('slotBooking')
   .where('lapanganId', isEqualTo: lapanganId)
   .where('tanggal', isEqualTo: '2026-09-01')
   .orderBy('jam')
   .get();
final jamTerisi = snap.docs.map((d) => d['jam'] as int).toSet();
```

Ini query **baca** untuk menampilkan UI. Jangan dicampur dengan pengecekan bentrok di AB-04 — yang itu pakai `transaction.get()` pada `DocumentReference` dengan ID deterministik, dan **tidak boleh** pakai query (transaction Firestore tidak bisa menjalankan Query). Dua-duanya perlu: query ini supaya slot terisi tampak abu-abu, transaction supaya dua orang yang menekan tombol bersamaan tidak sama-sama berhasil.

---

### `notifikasi` — 1 index

```dart
// Index #11 — (untukUserId ASC, dibuatPada DESC)
_db.collection('notifikasi')
   .where('untukUserId', isEqualTo: uid)
   .orderBy('dibuatPada', descending: true)
   .limit(50)
   .snapshots();
```

**Badge jumlah belum dibaca sengaja tidak diberi index sendiri.** Godaannya adalah membuat query kedua `where('sudahDibaca', isEqualTo: false)`, tapi itu berarti listener kedua, biaya baca dobel, dan satu index lagi. Lebih baik hitung dari stream yang sama:

```dart
final jumlahBelumDibaca = daftarNotifikasi.where((n) => !n.sudahDibaca).length;
```

Lebih murah, lebih sederhana, dan badge-nya dijamin sinkron dengan daftarnya.

---

## Yang TIDAK butuh index (biar nggak over-engineering)

| Operasi | Kenapa aman |
|---|---|
| Home: ambil 500 lapangan, urut jarak | Tanpa `where`/`orderBy` — AB-02 memproses di klien |
| Search bar & filter chip olahraga di Home | Disaring di klien (PRD L-04) |
| Baca satu dokumen (`.doc(id).get()`) | Bukan query |
| Semua `transaction.get()` di AB-04/05/06 | `DocumentReference`, bukan query |
| Subkoleksi `permintaan` di L-09 | Ambil seluruh subkoleksi, tanpa filter |
| Profil pengguna `users/{uid}` | Baca dokumen langsung |

---

## Cara deploy

Kalau folder Flutter kalian belum di-`firebase init`:

```bash
npm install -g firebase-tools
firebase login
firebase init firestore     # pilih project yang sama dengan T-00c
```

Pastikan `firebase.json` menunjuk ke kedua file:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  }
}
```

Taruh `firestore.indexes.json` di **root project** (sejajar `pubspec.yaml`), lalu:

```bash
firebase deploy --only firestore:indexes
```

Cek statusnya di Firebase Console → Firestore Database → Indexes. Tunggu semua berstatus **Enabled** (bukan *Building*) sebelum menguji — biasanya beberapa menit.

Sekalian deploy Security Rules dari PRD Bagian 9 (T-06):

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

---

## Kalau tetap kena error index

Pesan errornya begini:

```
[cloud_firestore/failed-precondition] The query requires an index.
You can create it here: https://console.firebase.google.com/...
```

**Jangan langsung klik tautannya.** Urutan yang benar:

1. Baca query mana yang gagal, lalu cocokkan dengan tabel di atas
2. Kalau memang index baru, **tambahkan ke `firestore.indexes.json`**, lalu `firebase deploy`
3. Catat di dokumen ini supaya anggota tim lain tahu

Kalau langsung klik tautan, index-nya jadi hanya ada di Console dan tidak ikut ke git — dua anggota tim lain akan kena error yang sama, dan waktu build APK release nanti nggak ada yang ingat index apa saja yang pernah dibuat manual.

**Kalau errornya bukan soal index tapi query ditolak:** kemungkinan besar aturan "field pertidaksamaan harus jadi `orderBy` pertama" yang dilanggar. Lihat catatan di bagian `aktivitasBermain`.

---

## Catatan untuk Bab 4 dan Bab 5

**Bab 4.** Composite index layak disinggung singkat di bagian implementasi sebagai konsekuensi nyata dari pemilihan Firestore: model NoSQL menukar fleksibilitas kueri dengan keharusan mendeklarasikan index di depan. Satu paragraf plus tabel 11 index sudah cukup, dan itu memperlihatkan kalian paham konsekuensi arsitektur yang dipilih — bukan cuma memakainya.

**Bab 5 (keterbatasan).** Satu keterbatasan yang jujur dan sebaiknya kalian sebut sendiri sebelum penguji menemukannya: pendekatan "ambil 500 lapangan lalu hitung Haversine di klien" (AB-02) sengaja menghindari index sama sekali, tapi konsekuensinya biaya baca tumbuh linier terhadap jumlah lapangan. Ini sudah selaras dengan saran geohash yang ada di SPRINT-PLAN Sprint 5 — tinggal dihubungkan.

---

## Sumber

- [Firestore — Index overview](https://firebase.google.com/docs/firestore/query-data/index-overview)
- [Firestore — Query with range and inequality filters on multiple fields](https://firebase.google.com/docs/firestore/query-data/multiple-range-fields)
- [Firestore — Optimize queries with range and inequality filters](https://firebase.google.com/docs/firestore/query-data/multiple-range-optimize-indexes)
