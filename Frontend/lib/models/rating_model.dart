import 'package:cloud_firestore/cloud_firestore.dart';

/// Model rating — PRD Bagian 6.5.
///
/// ID dokumen = `"{userId}_{lapanganId}"` — satu pengguna hanya punya
/// satu rating per lapangan, dan boleh memperbaruinya (AB-05, AB-09).
///
/// ATURAN LAPISAN (CLAUDE.md): model hanya berisi data +
/// `fromFirestore()` / `toFirestore()`. Perhitungan rata-rata
/// (`ratingRata2` di LapanganModel) TIDAK di sini — itu tugas
/// Repository lewat Firestore Transaction.
class RatingModel {
  final String ratingId;
  final String userId;
  final String namaUser;
  final String lapanganId;
  final int nilaiRating; // 1-5
  final String? ulasanTeks;
  final DateTime tanggal;

  const RatingModel({
    required this.ratingId,
    required this.userId,
    required this.namaUser,
    required this.lapanganId,
    required this.nilaiRating,
    this.ulasanTeks,
    required this.tanggal,
  });

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RatingModel(
      ratingId: doc.id,
      userId: data['userId'] as String? ?? '',
      namaUser: data['namaUser'] as String? ?? '',
      lapanganId: data['lapanganId'] as String? ?? '',
      nilaiRating: (data['nilaiRating'] as num?)?.toInt() ?? 0,
      ulasanTeks: data['ulasanTeks'] as String?,
      tanggal: (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ratingId': ratingId,
        'userId': userId,
        'namaUser': namaUser,
        'lapanganId': lapanganId,
        'nilaiRating': nilaiRating,
        'ulasanTeks': ulasanTeks,
        'tanggal': Timestamp.fromDate(tanggal),
      };
}
