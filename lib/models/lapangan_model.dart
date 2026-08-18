import 'package:cloud_firestore/cloud_firestore.dart';

/// Model lapangan — PRD Bagian 6.2.
///
/// ATURAN LAPISAN (CLAUDE.md): model hanya berisi data +
/// `fromFirestore()` / `toFirestore()`. Tidak boleh ada logika bisnis,
/// tidak boleh ada akses jaringan. Perhitungan Haversine TIDAK di sini —
/// itu tugas ViewModel.
///
/// Nama atribut mengikuti ERD Bab 3 persis, dalam bahasa Indonesia.
/// Jangan diterjemahkan ke bahasa Inggris.
class LapanganModel {
  final String lapanganId;
  final String nama;
  final String alamat;
  final double latitude;
  final double longitude;
  final List<String> jenisOlahraga;
  final int harga;
  final Map<String, int>? hargaSlot;
  final String jamBuka;
  final String jamTutup;
  final List<String> fasilitas;
  final List<String> fotoURL;
  final bool isMitra;
  final String? pemilikId;
  final String sumberData;
  final int ratingTotal;
  final int jumlahRating;
  final double ratingRata2;

  /// Jarak dari pengguna dalam km.
  ///
  /// TIDAK disimpan di Firestore — nilainya diisi ViewModel setelah
  /// menghitung Haversine (PRD AB-02). Bernilai `null` selama posisi
  /// pengguna belum diketahui.
  final double? jarakKm;

  const LapanganModel({
    required this.lapanganId,
    required this.nama,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.jenisOlahraga,
    required this.harga,
    this.hargaSlot,
    required this.jamBuka,
    required this.jamTutup,
    required this.fasilitas,
    required this.fotoURL,
    required this.isMitra,
    this.pemilikId,
    required this.sumberData,
    required this.ratingTotal,
    required this.jumlahRating,
    required this.ratingRata2,
    this.jarakKm,
  });

  factory LapanganModel.fromFirestore(DocumentSnapshot doc) {
    // `data()` bertipe Object?, jadi dicast dulu ke Map supaya bisa dibaca.
    final data = doc.data() as Map<String, dynamic>;

    return LapanganModel(
      // Selalu pakai doc.id sebagai sumber kebenaran, bukan field
      // 'lapanganId' di dalam dokumen — kalau seeding pernah keliru,
      // doc.id tetap benar.
      lapanganId: doc.id,
      nama: data['nama'] as String? ?? '',
      alamat: data['alamat'] as String? ?? '',

      // Firestore menyimpan angka sebagai int ATAU double tergantung cara
      // menulisnya. `as num` lalu `.toDouble()` aman untuk keduanya —
      // langsung `as double` akan crash kalau nilainya kebetulan bulat.
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,

      jenisOlahraga: List<String>.from(data['jenisOlahraga'] ?? const []),
      harga: (data['harga'] as num?)?.toInt() ?? 0,
      hargaSlot: data['hargaSlot'] == null
          ? null
          : Map<String, int>.from(data['hargaSlot'] as Map),
      jamBuka: data['jamBuka'] as String? ?? '00:00',
      jamTutup: data['jamTutup'] as String? ?? '23:59',
      fasilitas: List<String>.from(data['fasilitas'] ?? const []),
      fotoURL: List<String>.from(data['fotoURL'] ?? const []),
      isMitra: data['isMitra'] as bool? ?? false,
      pemilikId: data['pemilikId'] as String?,
      sumberData: data['sumberData'] as String? ?? 'places_api',
      ratingTotal: (data['ratingTotal'] as num?)?.toInt() ?? 0,
      jumlahRating: (data['jumlahRating'] as num?)?.toInt() ?? 0,
      ratingRata2: (data['ratingRata2'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'lapanganId': lapanganId,
        'nama': nama,
        'alamat': alamat,
        'latitude': latitude,
        'longitude': longitude,
        'jenisOlahraga': jenisOlahraga,
        'harga': harga,
        'hargaSlot': hargaSlot,
        'jamBuka': jamBuka,
        'jamTutup': jamTutup,
        'fasilitas': fasilitas,
        'fotoURL': fotoURL,
        'isMitra': isMitra,
        'pemilikId': pemilikId,
        'sumberData': sumberData,
        'ratingTotal': ratingTotal,
        'jumlahRating': jumlahRating,
        'ratingRata2': ratingRata2,
        // `jarakKm` sengaja TIDAK ikut ditulis — dia hasil hitungan,
        // bukan data yang disimpan.
      };

  /// Menyalin objek sambil mengisi `jarakKm`.
  ///
  /// Dipakai ViewModel setelah menghitung Haversine. Objeknya immutable
  /// (semua field `final`), jadi cara mengubahnya adalah membuat salinan
  /// baru — ini pola standar di Dart dan mencegah data berubah diam-diam.
  LapanganModel salinDenganJarak(double jarak) => LapanganModel(
        lapanganId: lapanganId,
        nama: nama,
        alamat: alamat,
        latitude: latitude,
        longitude: longitude,
        jenisOlahraga: jenisOlahraga,
        harga: harga,
        hargaSlot: hargaSlot,
        jamBuka: jamBuka,
        jamTutup: jamTutup,
        fasilitas: fasilitas,
        fotoURL: fotoURL,
        isMitra: isMitra,
        pemilikId: pemilikId,
        sumberData: sumberData,
        ratingTotal: ratingTotal,
        jumlahRating: jumlahRating,
        ratingRata2: ratingRata2,
        jarakKm: jarak,
      );
}
