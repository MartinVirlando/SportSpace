import 'package:cloud_firestore/cloud_firestore.dart';

/// Model permintaan gabung — PRD Bagian 6.4.
///
/// Subkoleksi `aktivitasBermain/{aktivitasId}/permintaan/{userId}`.
/// ID dokumen sengaja = `userId` pemohon, supaya satu orang tidak bisa
/// mengirim permintaan ganda ke aktivitas yang sama (AB-06).
///
/// ATURAN LAPISAN (CLAUDE.md): model hanya berisi data +
/// `fromFirestore()` / `toFirestore()`. Tanpa logika bisnis.
class PermintaanGabungModel {
  final String userId;
  final String namaUser;
  final String status; // MENUNGGU | DITERIMA | DITOLAK
  final DateTime dibuatPada;

  const PermintaanGabungModel({
    required this.userId,
    required this.namaUser,
    required this.status,
    required this.dibuatPada,
  });

  factory PermintaanGabungModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PermintaanGabungModel(
      // doc.id = userId pemohon (lihat catatan di atas), konsisten
      // dengan pola lapanganId di LapanganModel.
      userId: doc.id,
      namaUser: data['namaUser'] as String? ?? '',
      status: data['status'] as String? ?? 'MENUNGGU',
      dibuatPada:
          (data['dibuatPada'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'namaUser': namaUser,
        'status': status,
        'dibuatPada': Timestamp.fromDate(dibuatPada),
      };
}
