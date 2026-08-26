import 'package:cloud_firestore/cloud_firestore.dart';

/// Model favorit — PRD Bagian 6.9 (v1.1).
///
/// Subkoleksi `users/{userId}/favorit/{lapanganId}`. ID dokumen =
/// `lapanganId`, pola yang sama dengan `permintaan` (6.4): ID
/// deterministik membuat "sudah difavoritkan atau belum" cukup dibaca
/// satu dokumen (AB-10), dan mustahil dobel.
///
/// ATURAN LAPISAN (CLAUDE.md): model hanya berisi data +
/// `fromFirestore()` / `toFirestore()`. Tanpa logika bisnis.
class FavoritModel {
  final String lapanganId;
  final String namaLapangan;
  final DateTime dibuatPada;

  const FavoritModel({
    required this.lapanganId,
    required this.namaLapangan,
    required this.dibuatPada,
  });

  factory FavoritModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FavoritModel(
      // doc.id = lapanganId (lihat catatan di atas).
      lapanganId: doc.id,
      namaLapangan: data['namaLapangan'] as String? ?? '',
      dibuatPada:
          (data['dibuatPada'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'lapanganId': lapanganId,
        'namaLapangan': namaLapangan,
        'dibuatPada': Timestamp.fromDate(dibuatPada),
      };
}
