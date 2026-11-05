/// Produk tambahan saat booking — PRD 6.2 dan 6.6, v1.5 (T-60).
///
/// Dua kelas kecil dalam satu berkas karena keduanya bukan dokumen Firestore
/// sendiri, melainkan elemen larik (`List<Map>`) di dalam dokumen `lapangan`
/// dan `booking`:
/// - [ProdukTambahanModel] — katalog milik lapangan: nama + harga satuan.
/// - [ProdukPesananModel] — salinan yang dipilih pada satu booking: nama,
///   harga, dan jumlah.
///
/// ATURAN LAPISAN (CLAUDE.md): hanya data + konversi ke/dari `Map`. Tanpa
/// logika bisnis dan tanpa akses jaringan — perhitungan total ada di
/// `core/utils/produk_tambahan.dart`. Berkas ini sengaja tidak mengimpor
/// `cloud_firestore`: yang dibaca hanya `Map`, bukan `DocumentSnapshot`.
///
/// Angka dibaca `as num` lalu `.toInt()` (jebakan #3 di CLAUDE.md): Firestore
/// bisa mengembalikan int ataupun double.
class ProdukTambahanModel {
  final String nama;

  /// Rupiah per satuan.
  final int harga;

  const ProdukTambahanModel({required this.nama, required this.harga});

  factory ProdukTambahanModel.fromMap(Map<String, dynamic> map) {
    return ProdukTambahanModel(
      nama: map['nama'] as String? ?? '',
      harga: (map['harga'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'nama': nama, 'harga': harga};
}

/// Satu baris produk pada satu booking. DISALIN dari katalog saat booking
/// dibuat — bukan rujukan — supaya mitra yang kemudian mengubah atau
/// menghapus produk tidak mengubah booking lama (BB-75).
class ProdukPesananModel {
  final String nama;

  /// Rupiah per satuan, pada saat dipesan.
  final int harga;

  final int jumlah;

  const ProdukPesananModel({
    required this.nama,
    required this.harga,
    required this.jumlah,
  });

  factory ProdukPesananModel.fromMap(Map<String, dynamic> map) {
    return ProdukPesananModel(
      nama: map['nama'] as String? ?? '',
      harga: (map['harga'] as num?)?.toInt() ?? 0,
      jumlah: (map['jumlah'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'nama': nama,
        'harga': harga,
        'jumlah': jumlah,
      };
}
