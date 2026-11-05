import 'dart:async';

/// Membungkus sebuah [Stream] supaya pelanggan yang TERLAMBAT tetap menerima
/// nilai terakhirnya.
///
/// **Masalah yang dipecahkan.** `Query.snapshots()` dari Firestore adalah
/// stream siaran (broadcast): event yang sudah lewat tidak diulang untuk
/// pelanggan baru. Di layar Profil satu stream dipakai beberapa
/// `StreamBuilder` (kotak statistik, daftar, lencana). `ListView` hanya
/// membangun bagian yang dekat dengan layar, jadi `StreamBuilder` yang ada di
/// bawah baru berlangganan SETELAH event pertama lewat, dan menunggu
/// selamanya (spinner tidak pernah selesai). Selain itu `StreamBuilder` yang
/// terbuang lalu dibangun lagi saat digulir juga kehilangan datanya.
///
/// **Cara kerja.** Kelas ini berlangganan ke [sumber] SATU kali, menyimpan
/// nilai (atau galat) terakhir, lalu membagikannya lewat [stream]. Setiap
/// pelanggan baru langsung menerima nilai terakhir itu, kemudian event
/// berikutnya. Karena hanya satu langganan ke sumber, tidak ada listener
/// Firestore tambahan dan tidak ada baca tambahan.
///
/// Panggil [dispose] saat pemiliknya dibuang, supaya langganan ke sumber
/// berhenti.
///
/// Tanpa package tambahan (mis. `rxdart`): memakai `Stream.multi`, yang
/// menjalankan blok `onListen` untuk tiap pelanggan secara sinkron — jadi
/// tidak ada celah di antara "terima nilai terakhir" dan "mulai mendengar
/// event baru".
class StreamTerakhir<T> {
  final StreamController<T> _siaran = StreamController<T>.broadcast();
  late final StreamSubscription<T> _langganan;

  T? _nilaiTerakhir;
  bool _adaNilai = false;
  Object? _galatTerakhir;
  StackTrace? _jejakGalat;

  StreamTerakhir(Stream<T> sumber) {
    _langganan = sumber.listen(
      (nilai) {
        _nilaiTerakhir = nilai;
        _adaNilai = true;
        _galatTerakhir = null;
        _siaran.add(nilai);
      },
      onError: (Object galat, StackTrace jejak) {
        _galatTerakhir = galat;
        _jejakGalat = jejak;
        _siaran.addError(galat, jejak);
      },
    );
  }

  /// Stream yang bisa didengar kapan saja oleh banyak pelanggan; masing-masing
  /// langsung menerima nilai terakhir (kalau sudah ada), atau galat terakhir
  /// (kalau sumber sedang dalam keadaan galat), baru kemudian event berikutnya.
  ///
  /// Objeknya SATU dan tetap (`late final`), bukan dibuat ulang tiap dibaca:
  /// `StreamBuilder` berlangganan ulang kalau objek `stream`-nya berubah di
  /// `didUpdateWidget`, jadi getter yang membuat objek baru akan memicu
  /// langganan ulang di setiap rebuild.
  late final Stream<T> stream = Stream<T>.multi((pengendali) {
    if (_adaNilai) {
      pengendali.add(_nilaiTerakhir as T);
    } else if (_galatTerakhir != null) {
      pengendali.addError(_galatTerakhir!, _jejakGalat);
    }

    final langgananSiaran = _siaran.stream.listen(
      pengendali.add,
      onError: pengendali.addError,
    );
    pengendali.onCancel = langgananSiaran.cancel;
  });

  Future<void> dispose() async {
    await _langganan.cancel();
    await _siaran.close();
  }
}
