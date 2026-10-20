import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPostModel {
  final String id;
  final String userId;
  final String namaUser;
  final String teks;
  final String? gambarBase64;
  final int jumlahKomentar;
  final DateTime createdAt;

  
  final DateTime? dieditPada;

  const ForumPostModel({
    required this.id,
    required this.userId,
    required this.namaUser,
    required this.teks,
    this.gambarBase64,
    this.jumlahKomentar = 0,
    required this.createdAt,
    this.dieditPada,
  });

  /// Mengubah dokumen Firestore menjadi objek Dart.
  factory ForumPostModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ForumPostModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      namaUser: data['namaUser'] as String? ?? 'Pengguna',
      teks: data['teks'] as String? ?? '',
      gambarBase64: data['gambarBase64'] as String?,
      jumlahKomentar: data['jumlahKomentar'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dieditPada: (data['dieditPada'] as Timestamp?)?.toDate(),
    );
  }

  /// Mengubah objek Dart menjadi Map untuk disimpan ke Firestore.
  /// `id` tidak dimasukkan karena id sudah jadi nama dokumennya.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'namaUser': namaUser,
      'teks': teks,
      'gambarBase64': gambarBase64,
      'jumlahKomentar': jumlahKomentar,
      'createdAt': Timestamp.fromDate(createdAt),
      'dieditPada':
          dieditPada == null ? null : Timestamp.fromDate(dieditPada!),
    };
  }
}