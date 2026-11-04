# Penjelasan Project Sport Space

Dokumen ini menjelaskan struktur project Sport Space, kegunaan setiap file, dan syntax dasar Dart/Flutter yang digunakan.

Project ini adalah aplikasi Android untuk mencari lapangan olahraga dan rekan bermain berbasis lokasi.

## 1. Teknologi yang Digunakan

- Flutter: framework untuk membuat tampilan aplikasi.
- Dart: bahasa pemrograman Flutter.
- Firebase Authentication: login dan register.
- Cloud Firestore: penyimpanan data.
- Provider: state management.
- Geolocator: mengambil lokasi GPS.
- Flutter Map dan OpenStreetMap: menampilkan peta.
- Intl: format tanggal dan rupiah.
- Cached Network Image: menampilkan foto dari URL.
- Image Picker: memilih foto profil dari galeri.

## 2. Arsitektur Aplikasi

Project menggunakan pola MVVM:

```text
View -> ViewModel -> Repository -> Firestore
```

### View

View adalah tampilan yang dilihat pengguna. Contohnya `home_screen.dart` dan `detail_lapangan_screen.dart`.

View bertugas untuk:

- menampilkan teks, tombol, form, dan daftar;
- membaca state dari ViewModel;
- mengirim aksi pengguna ke ViewModel;
- tidak mengakses Firestore secara langsung.

### ViewModel

ViewModel mengatur state dan logika yang berhubungan dengan tampilan.

Contoh:

- sedang memuat data;
- data berhasil dimuat;
- terjadi error;
- tombol sedang diproses;
- filter pencarian aktif.

ViewModel menggunakan `ChangeNotifier` dan `notifyListeners()`.

### Repository

Repository adalah lapisan yang mengakses Firebase.

Repository bertugas untuk:

- mengambil data;
- menambah data;
- mengubah data;
- menghapus data;
- menjalankan transaction;
- menerjemahkan error Firebase menjadi pesan bahasa Indonesia.

### Model

Model adalah bentuk data aplikasi.

Contoh model:

- `LapanganModel` untuk data lapangan;
- `UserModel` untuk data pengguna;
- `BookingModel` untuk data reservasi.

Model biasanya memiliki:

- field data;
- constructor;
- `fromFirestore()` untuk membaca data Firebase;
- `toFirestore()` untuk mengubah object menjadi data Firebase.

## 3. File Root Project

### `pubspec.yaml`

Berisi informasi project dan daftar package.

Contoh:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
```

`provider: ^6.1.2` berarti project menggunakan package Provider versi 6.1.2 atau versi kompatibel yang lebih baru.

Setelah mengubah file ini, jalankan:

```bash
flutter pub get
```

### `analysis_options.yaml`

Berisi aturan pemeriksaan kode Dart. File ini membantu menemukan error, warning, dan pelanggaran gaya penulisan.

### `firebase.json`

Konfigurasi Firebase CLI untuk project ini.

### `firestore.rules`

Berisi aturan keamanan Firestore. File ini menentukan siapa yang boleh membaca atau mengubah data.

### `firestore.indexes.json`

Berisi composite index yang diperlukan oleh query Firestore tertentu.

### `lib/main.dart`

Titik awal aplikasi Flutter. File ini:

1. menyiapkan Flutter;
2. menginisialisasi Firebase;
3. memuat format tanggal Indonesia;
4. memasang Provider;
5. membuat tema aplikasi;
6. menampilkan `SplashScreen`.

Contoh syntax:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SportSpaceApp());
}
```

Penjelasan:

- `Future<void>`: fungsi asynchronous yang tidak mengembalikan nilai.
- `main()`: fungsi pertama yang dijalankan.
- `async`: fungsi dapat menggunakan `await`.
 - `WidgetsFlutterBinding.ensureInitialized()`: menyiapkan Flutter sebelum memakai plugin.
- `await`: menunggu proses selesai.
- `runApp()`: menjalankan aplikasi Flutter.
- `const`: object tidak perlu dibuat ulang karena nilainya tetap.

### `lib/firebase_options.dart`

Berisi konfigurasi Firebase yang dibuat oleh FlutterFire CLI. File ini biasanya tidak ditulis manual.

## 4. Folder `lib/core`

Folder `core` berisi kode umum yang bisa digunakan oleh banyak fitur.

### `lib/core/constants/app_colors.dart`

Menyimpan warna, ukuran, bayangan, dan style teks aplikasi.

Tujuannya agar warna tidak ditulis berulang-ulang di banyak widget.

Contoh:

```dart
class AppColors {
  AppColors._();

  static const primary = Color(0xFF...);
}
```

- `static`: bisa dipanggil melalui nama class.
- `const`: nilainya tetap.
- `AppColors._()`: constructor private agar class hanya digunakan sebagai kumpulan konstanta.

### `lib/core/constants/app_sports.dart`

Menyimpan daftar olahraga yang didukung:

- futsal;
- mini soccer;
- badminton;
- padel.

File ini juga menyimpan label dan icon olahraga.

### `lib/core/constants/app_strings.dart`

Menyimpan teks yang dilihat pengguna, misalnya:

```dart
static const cobaLagi = 'Coba Lagi';
```

Keuntungannya:

- teks mudah dicari;
- penulisan konsisten;
- perubahan teks tidak perlu mencari di semua widget.

### `lib/core/data/seed_lapangan.dart`

Berisi data awal 30 lapangan yang dimasukkan ke Firestore melalui halaman seed.

Bentuk datanya biasanya:

```dart
const List<Map<String, dynamic>> seedLapangan = [
  {
    'nama': 'Nama Lapangan',
    'harga': 100000,
  },
];
```

- `List`: kumpulan data berurutan.
- `Map`: data berbentuk pasangan key dan value.
- `dynamic`: value dapat memiliki berbagai tipe.

### `lib/core/services/location_service.dart`

Membungkus package `geolocator` agar ViewModel tidak perlu mengetahui detail package GPS.

Tanggung jawabnya:

- memeriksa izin lokasi;
- meminta izin lokasi;
- mengambil latitude dan longitude;
- menangani lokasi yang ditolak;
- memberikan fallback ke lokasi default.

### `lib/core/utils/haversine.dart`

Menghitung jarak antara dua koordinat GPS menggunakan rumus Haversine manual.

File ini sengaja dipisahkan agar fungsi perhitungan dapat diuji secara otomatis.

### `lib/core/utils/formatter.dart`

Berisi fungsi untuk memformat:

- rupiah;
- tanggal;
- waktu;
- jarak.

Contoh pemakaian:

```dart
Formatter.rupiah(lapangan.harga)
```

### `lib/core/utils/validators.dart`

Memeriksa input form seperti:

- email;
- password;
- harga;
- koordinat;
- ulasan.

Validator Flutter biasanya mengembalikan `String?`:

```dart
String? validasiNama(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Nama wajib diisi';
  }
  return null;
}
```

`null` berarti input valid. String berarti input memiliki error.

### `lib/core/utils/status_booking.dart`

Menentukan status tampilan booking berdasarkan tanggal dan jam, misalnya booking selesai atau masih aktif.

## 5. Folder `lib/models`

### `lapangan_model.dart`

Merepresentasikan data lapangan.

Field penting:

```dart
final String lapanganId;
final String nama;
final double latitude;
final double longitude;
final int harga;
final bool isMitra;
```

- `String`: teks.
- `double`: angka desimal.
- `int`: angka bulat.
- `bool`: `true` atau `false`.
- `final`: hanya dapat diisi sekali.

`fromFirestore()` membaca data Firebase:

```dart
factory LapanganModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return LapanganModel(
    lapanganId: doc.id,
    nama: data['nama'] as String? ?? '',
  );
}
```

- `factory`: constructor khusus untuk membuat object melalui proses tertentu.
- `as`: casting atau menganggap object sebagai tipe tertentu.
- `??`: jika nilai sebelah kiri `null`, gunakan nilai sebelah kanan.

Angka Firestore dibaca menggunakan pola:

```dart
(data['latitude'] as num?)?.toDouble() ?? 0.0
```

Pola ini aman jika Firestore mengembalikan `int` atau `double`.

### Model lainnya

- `user_model.dart`: profil pengguna, role, olahraga favorit, lokasi default, foto profil.
- `aktivitas_bermain_model.dart`: aktivitas bermain.
- `booking_model.dart`: reservasi.
- `favorit_model.dart`: lapangan favorit.
- `rating_model.dart`: rating dan ulasan.
- `notifikasi_model.dart`: notifikasi aplikasi.
- `permintaan_gabung_model.dart`: permintaan bergabung ke aktivitas.

Semua model mengikuti pola data + `fromFirestore()` + `toFirestore()`.

## 6. Folder `lib/repositories`

### `lapangan_repository.dart`

Mengakses koleksi `lapangan` di Firestore.

Fungsi utamanya:

- mengambil semua lapangan;
- mengambil satu lapangan;
- seed data lapangan;
- mengambil lapangan milik mitra;
- menambah lapangan;
- mengubah lapangan.

Contoh query:

```dart
final snapshot = await _db
    .collection('lapangan')
    .limit(500)
    .get();
```

- `_db`: variable private.
- `.collection()`: memilih koleksi.
- `.limit()`: membatasi jumlah dokumen.
- `.get()`: mengambil data sekali.

### `auth_repository.dart`

Mengelola Firebase Authentication dan koleksi `users`.

Fungsi:

- login;
- register;
- logout;
- membaca profil;
- memperbarui profil.

### `aktivitas_repository.dart`

Mengelola aktivitas bermain dan permintaan bergabung. Menggunakan stream, batch, dan transaction.

### `booking_repository.dart`

Mengelola reservasi, slot booking, riwayat, konfirmasi, dan penolakan booking.

Transaction dipakai agar dua pengguna tidak dapat mengambil slot yang sama secara bersamaan.

### `rating_repository.dart`

Menyimpan rating dan memperbarui rata-rata rating secara atomic menggunakan transaction.

### `favorit_repository.dart`

Menyimpan dan menghapus favorit pengguna.

### `notifikasi_repository.dart`

Membaca notifikasi secara real-time dan menandai notifikasi sebagai sudah dibaca.

## 7. Folder `lib/routes`

### `app_routes.dart`

Berisi nama rute dan navigasi utama empat tab:

1. Home;
2. Map;
3. Teman;
4. Profil.

`ShellNavigasi` menggunakan `StatefulWidget` karena tab yang aktif dapat berubah.

`IndexedStack` menjaga state tab agar tidak dibuat ulang saat pengguna berpindah tab.

### `splash_screen.dart`

Menentukan halaman awal berdasarkan status login:

- pengguna belum login -> Login;
- pengguna sudah login -> shell aplikasi.

### `admin_seed_screen.dart`

Halaman khusus untuk memasukkan data awal lapangan ke Firestore.

## 8. Folder `lib/widgets`

### `kartu_lapangan.dart`

Widget reusable untuk menampilkan satu lapangan.

Dapat dipakai di Home atau daftar lain tanpa menulis ulang tampilan kartu.

### `chip_olahraga.dart`

Widget reusable untuk filter olahraga.

## 9. Folder `features/auth`

### `auth_viewmodel.dart`

Mengatur status login, register, logout, dan user yang sedang aktif.

Class ini menggunakan `ChangeNotifier`:

```dart
class AuthViewModel extends ChangeNotifier {
  void ubahState() {
    notifyListeners();
  }
}
```

`notifyListeners()` memberi tahu widget yang memakai ViewModel agar melakukan rebuild.

### `login_screen.dart`

Menampilkan form email dan password.

Konsep yang digunakan:

- `StatefulWidget`;
- `TextEditingController`;
- `Form`;
- validasi;
- tombol asynchronous;
- navigasi.

### `register_screen.dart`

Menampilkan form registrasi dan pemilihan role pengguna atau mitra.

## 10. Folder `features/lapangan`

### `home_viewmodel.dart`

Mengatur data Home:

- mengambil lokasi;
- mengambil lapangan;
- menghitung jarak Haversine;
- mengurutkan lapangan berdasarkan jarak;
- mencari lapangan;
- menyaring olahraga;
- menyaring favorit.

### `home_screen.dart`

Menampilkan daftar lapangan dan beberapa kondisi:

- memuat;
- berhasil;
- kosong;
- error;
- hasil pencarian kosong.

### `map_viewmodel.dart`

Mengatur data untuk peta:

- posisi pengguna;
- marker lapangan;
- lapangan yang dipilih;
- pencarian pada peta;
- fokus kamera.

### `map_screen.dart`

Menampilkan OpenStreetMap, marker, search bar, saran pencarian, dan kartu lapangan terpilih.

### `detail_lapangan_viewmodel.dart`

Mengambil satu lapangan dan menyediakan stream ulasan.

Contoh state:

```dart
enum KondisiDetail { memuat, berhasil, gagal }
```

`enum` digunakan untuk daftar kondisi yang terbatas.

### `detail_lapangan_screen.dart`

Menampilkan:

- foto lapangan;
- nama dan alamat;
- rating;
- badge mitra atau terverifikasi;
- jam buka;
- harga;
- fasilitas;
- jenis olahraga;
- nomor telepon;
- tombol reservasi untuk lapangan mitra;
- daftar ulasan;
- tombol beri rating.

## 11. Bedah Syntax `detail_lapangan_screen.dart`

### Membuat StatelessWidget

```dart
class DetailLapanganScreen extends StatelessWidget {
  final String lapanganId;

  const DetailLapanganScreen({
    super.key,
    required this.lapanganId,
  });
}
```

Penjelasan:

- `class`: membuat class.
- `extends`: mewarisi class lain.
- `StatelessWidget`: widget tanpa state internal yang berubah.
- `final String lapanganId`: property wajib bertipe String.
- `const`: constructor dapat dibuat sebagai object konstan.
- `super.key`: meneruskan key ke parent Flutter.
- `required`: parameter wajib dikirim.

### Method `build`

```dart
@override
Widget build(BuildContext context) {
  return Scaffold();
}
```

- `@override`: menggantikan method dari `StatelessWidget`.
- `Widget`: nilai yang dikembalikan berupa widget.
- `BuildContext`: posisi widget dalam widget tree.
- `Scaffold`: kerangka halaman Flutter.

### Membaca ViewModel dengan Provider

```dart
final vm = context.watch<DetailLapanganViewModel>();
```

`watch` membaca ViewModel dan membuat widget rebuild ketika ViewModel memanggil `notifyListeners()`.

```dart
context.read<DetailLapanganViewModel>().muatUlang();
```

`read` membaca ViewModel tanpa otomatis rebuild ketika data berubah. Cocok untuk memanggil method.

### Provider lokal

```dart
ChangeNotifierProvider(
  create: (context) => DetailLapanganViewModel(
    repository: context.read<LapanganRepository>(),
  )..muatDetail(lapanganId),
  child: const _DetailLapanganBody(),
)
```

- `ChangeNotifierProvider`: menyediakan ViewModel ke widget anak.
- `create`: fungsi untuk membuat object.
- `=>`: arrow function.
- `..muatDetail(lapanganId)`: cascade operator; setelah object dibuat, method langsung dipanggil.
- `_DetailLapanganBody`: awalan `_` berarti private dalam file tersebut.

### Switch expression

```dart
body: switch (vm.kondisi) {
  KondisiDetail.memuat => const _Pemuatan(),
  KondisiDetail.gagal => _Kesalahan(pesan: vm.pesanError ?? 'Error'),
  KondisiDetail.berhasil => _Isi(lapangan: vm.lapangan!),
},
```

Kode memilih tampilan berdasarkan kondisi ViewModel.

- `memuat`: tampilkan loading.
- `gagal`: tampilkan pesan error.
- `berhasil`: tampilkan isi halaman.
- `!`: programmer menyatakan value tidak null.
- `??`: gunakan nilai cadangan jika null.

### Conditional widget

```dart
if (lapangan.isMitra) ...[
  ElevatedButton(
    onPressed: () {},
    child: const Text('Reservasi'),
  ),
],
```

Tombol hanya dimasukkan jika `lapangan.isMitra` bernilai `true`.

### Spread operator

```dart
children: [
  if (kondisi) ...[
    widgetSatu,
    widgetDua,
  ],
]
```

`...` memasukkan isi list ke list lain.

### Async dan await

```dart
Future<void> _bukaFormRating() async {
  final berhasil = await showBeriRatingSheet(context);
}
```

- `Future<void>`: hasil fungsi tersedia nanti dan tidak mengembalikan nilai.
- `async`: fungsi dapat memakai `await`.
- `await`: menunggu proses asynchronous selesai.

### `StreamBuilder`

```dart
StreamBuilder<List<RatingModel>>(
  stream: viewModel.streamUlasan(lapanganId),
  builder: (context, snapshot) {
    return Text('Daftar ulasan');
  },
)
```

`StreamBuilder` cocok untuk data real-time. Ketika data Firestore berubah, builder dapat membangun ulang tampilan.

## 12. Konsep Dart yang Sering Muncul

### Tipe data

```dart
String nama = 'Budi';
int umur = 20;
double jarak = 2.5;
bool aktif = true;
List<String> olahraga = ['futsal', 'padel'];
Map<String, dynamic> data = {'nama': 'Budi'};
```

### Null safety

```dart
String? nama;
```

Tanda `?` berarti `nama` boleh bernilai null.

```dart
nama ?? 'Tidak ada nama'
```

Menggunakan nilai cadangan jika `nama` null.

```dart
nama!
```

Menyatakan bahwa programmer yakin `nama` tidak null.

### Getter

```dart
String get namaTampilan => '$nama - $alamat';
```

Getter terlihat seperti property tetapi nilainya dihitung saat dipanggil.

### Constructor

```dart
class User {
  final String nama;

  const User({required this.nama});
}
```

Object dibuat dengan:

```dart
const User(nama: 'Budi');
```

### Anonymous function

```dart
items.map((item) => item.nama).toList();
```

`(item) => item.nama` adalah fungsi singkat tanpa nama.

### `try-catch`

```dart
try {
  await ambilData();
} catch (e) {
  pesanError = e.toString();
}
```

- `try`: kode yang berpotensi error.
- `catch`: menangkap error.
- `e`: object error.

### `for`

```dart
for (final olahraga in daftarOlahraga) {
  print(olahraga);
}
```

Mengulang semua item dalam list.

## 13. Urutan Belajar yang Disarankan

1. [main.dart](../lib/main.dart)
2. [app_colors.dart](../lib/core/constants/app_colors.dart)
3. [app_strings.dart](../lib/core/constants/app_strings.dart)
4. [app_sports.dart](../lib/core/constants/app_sports.dart)
5. [formatter.dart](../lib/core/utils/formatter.dart)
6. [validators.dart](../lib/core/utils/validators.dart)
7. [haversine.dart](../lib/core/utils/haversine.dart)
8. [favorit_model.dart](../lib/models/favorit_model.dart)
9. [lapangan_model.dart](../lib/models/lapangan_model.dart)
10. [lapangan_repository.dart](../lib/repositories/lapangan_repository.dart)
11. [home_viewmodel.dart](../lib/features/lapangan/viewmodel/home_viewmodel.dart)
12. [home_screen.dart](../lib/features/lapangan/view/home_screen.dart)
13. [detail_lapangan_screen.dart](../lib/features/lapangan/view/detail_lapangan_screen.dart)
14. File login dan register
15. File aktivitas
16. File booking
17. File rating
18. File notifikasi
19. File profil
20. File mitra

## 14. Perintah Penting

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

- `flutter pub get`: mengambil dependency.
- `flutter analyze`: memeriksa error dan warning.
- `flutter test`: menjalankan automated test.
- `flutter run`: menjalankan aplikasi.

Pemeriksaan aturan arsitektur:

```bash
grep -rl "package:cloud_firestore" lib/ | grep -Ev "^lib/(repositories|models)/"
```

Perintah tersebut seharusnya tidak mengeluarkan file View atau ViewModel, karena hanya Repository dan Model yang boleh mengimpor Firestore.
