import 'package:cloud_firestore/cloud_firestore.dart';

class ForumKomentarModel {
  final String id;
  final String userId;
  final String namaUser;
  final String teks;
  final DateTime createdAt;

  const ForumKomentarModel({
    required this.id,
    required this.userId,
    required this.namaUser,
    required this.teks,
    required this.createdAt,
  });

  factory ForumKomentarModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ForumKomentarModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      namaUser: data['namaUser'] as String? ?? 'Pengguna',
      teks: data['teks'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'namaUser': namaUser,
      'teks': teks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
