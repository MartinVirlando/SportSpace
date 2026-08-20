import 'package:flutter/foundation.dart';

import '../../../models/notifikasi_model.dart';
import '../../../repositories/notifikasi_repository.dart';

/// ViewModel untuk halaman Notifikasi (L-12) dan badge lonceng di Home
/// (L-04).
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data lewat
/// [NotifikasiRepository].
///
/// Dibuat LOKAL di dua tempat berbeda — sekali di `home_screen.dart`
/// untuk badge, sekali lagi di `notifikasi_screen.dart` untuk daftar
/// penuh — BUKAN Provider global, karena CLAUDE.md aturan 6 hanya
/// mengizinkan status autentikasi dan posisi GPS lintas layar. Konsekuensi
/// yang disadari: badge dan daftar penuh jadi dua listener Firestore
/// terpisah, tapi query-nya murah (ter-index, `limit(50)`).
///
/// [streamNotifikasi] dipaparkan sebagai `Stream` lewat getter, dibaca
/// View lewat `StreamBuilder` (CLAUDE.md aturan 6) — daftar ini perlu
/// langsung hidup, notifikasi baru harus muncul tanpa menyegarkan.
/// Jumlah belum dibaca dihitung DI VIEW dari data stream yang sama,
/// bukan lewat query kedua (lihat FIRESTORE-INDEXES.md).
class NotifikasiViewModel extends ChangeNotifier {
  final NotifikasiRepository _repository;
  final String userId;

  NotifikasiViewModel({
    required NotifikasiRepository repository,
    required this.userId,
  }) : _repository = repository;

  Stream<List<NotifikasiModel>> get streamNotifikasi =>
      _repository.streamNotifikasi(userId);

  Future<void> tandaiSudahDibaca(String notifikasiId) {
    return _repository.tandaiSudahDibaca(notifikasiId);
  }
}
