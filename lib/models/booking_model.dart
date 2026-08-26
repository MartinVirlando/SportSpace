import 'package:cloud_firestore/cloud_firestore.dart';

/// Model booking — PRD Bagian 6.6.
///
/// ATURAN LAPISAN (CLAUDE.md): model hanya berisi data +
/// `fromFirestore()` / `toFirestore()`. Kunci slot untuk cegah double
/// booking (AB-04, koleksi `slotBooking`) sengaja TIDAK punya model
/// sendiri — PRD Bagian 5 hanya mendaftarkan 8 model, dan `slotBooking`
/// cuma dokumen teknis 4 field yang dibuat langsung di Repository.
class BookingModel {
  final String bookingId;
  final String userId;
  final String namaUser;
  final String lapanganId;
  final String namaLapangan;

  /// Disalin dari `lapangan.pemilikId` agar mitra bisa memfilter
  /// booking miliknya tanpa join (Firestore tidak punya join).
  final String pemilikId;

  final String tanggal; // "yyyy-MM-dd"
  final String jamMulai; // "HH:mm"
  final String jamSelesai; // "HH:mm"
  final String
      status; // MENUNGGU | DIKONFIRMASI | DITOLAK | SELESAI | DIBATALKAN
  final int totalHarga;
  final DateTime dibuatPada;

  const BookingModel({
    required this.bookingId,
    required this.userId,
    required this.namaUser,
    required this.lapanganId,
    required this.namaLapangan,
    required this.pemilikId,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.status,
    required this.totalHarga,
    required this.dibuatPada,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookingModel(
      bookingId: doc.id,
      userId: data['userId'] as String? ?? '',
      namaUser: data['namaUser'] as String? ?? '',
      lapanganId: data['lapanganId'] as String? ?? '',
      namaLapangan: data['namaLapangan'] as String? ?? '',
      pemilikId: data['pemilikId'] as String? ?? '',
      tanggal: data['tanggal'] as String? ?? '',
      jamMulai: data['jamMulai'] as String? ?? '',
      jamSelesai: data['jamSelesai'] as String? ?? '',
      status: data['status'] as String? ?? 'MENUNGGU',
      totalHarga: (data['totalHarga'] as num?)?.toInt() ?? 0,
      dibuatPada:
          (data['dibuatPada'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'bookingId': bookingId,
        'userId': userId,
        'namaUser': namaUser,
        'lapanganId': lapanganId,
        'namaLapangan': namaLapangan,
        'pemilikId': pemilikId,
        'tanggal': tanggal,
        'jamMulai': jamMulai,
        'jamSelesai': jamSelesai,
        'status': status,
        'totalHarga': totalHarga,
        'dibuatPada': Timestamp.fromDate(dibuatPada),
      };
}
