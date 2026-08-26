import 'package:cloud_firestore/cloud_firestore.dart';

/// Model notifikasi — PRD Bagian 6.8.
///
/// Notifikasi in-app lewat koleksi ini + Firestore listener — pengganti
/// Firebase Cloud Messaging yang dilarang (PRD Bagian 2.1).
///
/// ATURAN LAPISAN (CLAUDE.md): model hanya berisi data +
/// `fromFirestore()` / `toFirestore()`. Tanpa logika bisnis.
class NotifikasiModel {
  final String notifikasiId;
  final String untukUserId;

  /// PERMINTAAN_GABUNG | PERMINTAAN_DITERIMA | PERMINTAAN_DITOLAK |
  /// BOOKING_BARU | BOOKING_DIKONFIRMASI | BOOKING_DITOLAK
  final String tipe;

  final String judul;
  final String pesan;

  /// `aktivitasId` atau `bookingId`, tergantung `tipe` — dipakai untuk
  /// membuka objek terkait saat notifikasi ditekan (L-12).
  final String refId;

  final bool sudahDibaca;
  final DateTime dibuatPada;

  const NotifikasiModel({
    required this.notifikasiId,
    required this.untukUserId,
    required this.tipe,
    required this.judul,
    required this.pesan,
    required this.refId,
    this.sudahDibaca = false,
    required this.dibuatPada,
  });

  factory NotifikasiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotifikasiModel(
      notifikasiId: doc.id,
      untukUserId: data['untukUserId'] as String? ?? '',
      tipe: data['tipe'] as String? ?? '',
      judul: data['judul'] as String? ?? '',
      pesan: data['pesan'] as String? ?? '',
      refId: data['refId'] as String? ?? '',
      sudahDibaca: data['sudahDibaca'] as bool? ?? false,
      dibuatPada:
          (data['dibuatPada'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'notifikasiId': notifikasiId,
        'untukUserId': untukUserId,
        'tipe': tipe,
        'judul': judul,
        'pesan': pesan,
        'refId': refId,
        'sudahDibaca': sudahDibaca,
        'dibuatPada': Timestamp.fromDate(dibuatPada),
      };
}
