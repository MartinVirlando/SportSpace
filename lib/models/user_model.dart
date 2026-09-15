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

  /// Opsional — foto profil, diisi pengguna dari galeri (JPG) lewat
  /// `image_picker`, disimpan sebagai **Base64** langsung di dokumen ini
  /// (T-43 lanjutan). BUKAN Firebase Storage/URL — lihat PRD §12b: batas
  /// 1 MB per dokumen Firestore cukup untuk foto profil yang sudah
  /// dikompres kecil (`maxWidth`/`maxHeight`/`imageQuality` di
  /// `ubah_profil_sheet.dart`). `null`/kosong berarti avatar ditampilkan
  /// dari inisial nama.
  final String? fotoProfilBase64;

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
    this.fotoProfilBase64,
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
      fotoProfilBase64: data['fotoProfilBase64'] as String?,
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
        'fotoProfilBase64': fotoProfilBase64,
        'role': role,
        'tanggalDaftar': Timestamp.fromDate(tanggalDaftar),
        'olahragaFavorit': olahragaFavorit,
        'lokasiDefault': lokasiDefault,
      };

  /// Menyalin objek sambil mengganti `olahragaFavorit` dan/atau
  /// `lokasiDefault` — dipakai AuthViewModel setelah T-37 berhasil
  /// menulis perubahan ke Firestore, supaya salinan lokal (`AuthViewModel.user`)
  /// ikut terbarui tanpa perlu `ambilUser()` ulang. Objeknya immutable
  /// (semua field `final`), sama seperti `LapanganModel.salinDenganJarak`.
  UserModel salinDengan({
    String? nama,
    String? nomorTelepon,
    String? fotoProfilBase64,
    List<String>? olahragaFavorit,
    Map<String, dynamic>? lokasiDefault,
  }) =>
      UserModel(
        userId: userId,
        nama: nama ?? this.nama,
        surel: surel,
        nomorTelepon: nomorTelepon ?? this.nomorTelepon,
        fotoProfilBase64: fotoProfilBase64 ?? this.fotoProfilBase64,
        role: role,
        tanggalDaftar: tanggalDaftar,
        olahragaFavorit: olahragaFavorit ?? this.olahragaFavorit,
        lokasiDefault: lokasiDefault ?? this.lokasiDefault,
      );
}
