import 'package:cloud_firestore/cloud_firestore.dart';

/// Model aktivitas bermain — PRD Bagian 6.3.
///
/// ATURAN LAPISAN (CLAUDE.md): model hanya berisi data +
/// `fromFirestore()` / `toFirestore()`. Tidak boleh ada logika bisnis
/// (mis. cek slot penuh) — itu tugas Repository/ViewModel lewat
/// Firestore Transaction (AB-06).
///
/// Nama atribut mengikuti ERD Bab 3 persis, dalam bahasa Indonesia.
class AktivitasBermainModel {
  final String aktivitasId;

  /// Satu nilai dari 4 olahraga — beda dengan `lapangan.jenisOlahraga`
  /// yang berupa List, karena satu aktivitas hanya untuk satu cabang.
  final String jenisOlahraga;

  final int jumlahPemainDibutuhkan;
  final int jumlahPemainSaatIni;
  final DateTime waktu;
  final String lapanganId;
  final String namaLapangan;
  final String pembuatId;
  final String namaPembuat;
  final String status; // TERBUKA | PENUH | SELESAI | DIBATALKAN
  final List<String> peserta;
  final String? catatan;
  final DateTime dibuatPada;

  const AktivitasBermainModel({
    required this.aktivitasId,
    required this.jenisOlahraga,
    required this.jumlahPemainDibutuhkan,
    required this.jumlahPemainSaatIni,
    required this.waktu,
    required this.lapanganId,
    required this.namaLapangan,
    required this.pembuatId,
    required this.namaPembuat,
    required this.status,
    required this.peserta,
    this.catatan,
    required this.dibuatPada,
  });

  factory AktivitasBermainModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AktivitasBermainModel(
      aktivitasId: doc.id,
      jenisOlahraga: data['jenisOlahraga'] as String? ?? '',
      jumlahPemainDibutuhkan:
          (data['jumlahPemainDibutuhkan'] as num?)?.toInt() ?? 0,
      jumlahPemainSaatIni: (data['jumlahPemainSaatIni'] as num?)?.toInt() ?? 1,
      waktu: (data['waktu'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lapanganId: data['lapanganId'] as String? ?? '',
      namaLapangan: data['namaLapangan'] as String? ?? '',
      pembuatId: data['pembuatId'] as String? ?? '',
      namaPembuat: data['namaPembuat'] as String? ?? '',
      status: data['status'] as String? ?? 'TERBUKA',
      peserta: List<String>.from(data['peserta'] ?? const []),
      catatan: data['catatan'] as String?,
      dibuatPada:
          (data['dibuatPada'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'aktivitasId': aktivitasId,
        'jenisOlahraga': jenisOlahraga,
        'jumlahPemainDibutuhkan': jumlahPemainDibutuhkan,
        'jumlahPemainSaatIni': jumlahPemainSaatIni,
        'waktu': Timestamp.fromDate(waktu),
        'lapanganId': lapanganId,
        'namaLapangan': namaLapangan,
        'pembuatId': pembuatId,
        'namaPembuat': namaPembuat,
        'status': status,
        'peserta': peserta,
        'catatan': catatan,
        'dibuatPada': Timestamp.fromDate(dibuatPada),
      };
}
