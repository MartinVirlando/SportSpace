import 'package:cloud_firestore/cloud_firestore.dart';

/// Model pengguna — PRD Bagian 6.1.
///
/// ATURAN LAPISAN (CLAUDE.md): model hanya berisi data +
/// `fromFirestore()` / `toFirestore()`. Tidak boleh ada logika bisnis,
/// tidak boleh ada akses jaringan.
///
/// Nama atribut mengikuti ERD Bab 3 persis, dalam bahasa Indonesia.
/// Menyatukan entitas `Users` dan `PemilikLapangan` dari ERD — dibedakan
/// lewat `role` (lihat PRD Bagian 3, catatan pemetaan ke ERD).
class UserModel {
  final String userId;
  final String nama;
  final String surel;
  final String nomorTelepon;

  /// Selalu `null` — foto profil pakai avatar inisial, bukan upload
  /// (PRD Bagian 2.1, Firebase Storage dilarang).
  final String? fotoProfilURL;

  final String role; // "pengguna" | "mitra"
  final DateTime tanggalDaftar;

  /// v1.1 — subset dari 4 olahraga, boleh larik kosong.
  final List<String> olahragaFavorit;

  /// v1.1 — cadangan lokasi saat GPS ditolak (AB-03).
  /// Bentuk: {"nama": ..., "latitude": ..., "longitude": ...}.
  final Map<String, dynamic>? lokasiDefault;

  const UserModel({
    required this.userId,
    required this.nama,
    required this.surel,
    this.nomorTelepon = '',
    this.fotoProfilURL,
    required this.role,
    required this.tanggalDaftar,
    this.olahragaFavorit = const [],
    this.lokasiDefault,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      userId: doc.id,
      nama: data['nama'] as String? ?? '',
      surel: data['surel'] as String? ?? '',
      nomorTelepon: data['nomorTelepon'] as String? ?? '',
      fotoProfilURL: data['fotoProfilURL'] as String?,
      role: data['role'] as String? ?? 'pengguna',
      // Firestore Timestamp -> DateTime supaya lapisan atas tidak perlu
      // tahu tipe Firestore sama sekali.
      tanggalDaftar:
          (data['tanggalDaftar'] as Timestamp?)?.toDate() ?? DateTime.now(),
      olahragaFavorit: List<String>.from(data['olahragaFavorit'] ?? const []),
      lokasiDefault: data['lokasiDefault'] == null
          ? null
          : Map<String, dynamic>.from(data['lokasiDefault'] as Map),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'nama': nama,
        'surel': surel,
        'nomorTelepon': nomorTelepon,
        'fotoProfilURL': fotoProfilURL,
        'role': role,
        'tanggalDaftar': Timestamp.fromDate(tanggalDaftar),
        'olahragaFavorit': olahragaFavorit,
        'lokasiDefault': lokasiDefault,
      };
}
