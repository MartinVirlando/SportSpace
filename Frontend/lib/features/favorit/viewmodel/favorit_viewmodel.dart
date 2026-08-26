import 'package:flutter/foundation.dart';

import '../../../models/favorit_model.dart';
import '../../../repositories/favorit_repository.dart';

/// ViewModel untuk ikon favorit ♡/♥ di L-04 dan L-06, dan daftar favorit
/// di L-13 — PRD AB-10, T-35.
///
/// ATURAN LAPISAN: TIDAK `import cloud_firestore`. Data lewat
/// [FavoritRepository].
///
/// Dibuat LOKAL di tiap layar yang membutuhkannya (`home_screen.dart`,
/// `detail_lapangan_screen.dart`) — BUKAN Provider global, karena
/// CLAUDE.md aturan 6 hanya mengizinkan status autentikasi dan posisi GPS
/// lintas layar. Pola yang sama dengan `NotifikasiViewModel`.
///
/// [streamIdFavorit] dipaparkan sebagai `Stream` (CLAUDE.md aturan 6) —
/// status favorit perlu langsung hidup begitu ditekan, tanpa menyegarkan
/// layar.
class FavoritViewModel extends ChangeNotifier {
  final FavoritRepository _repository;
  final String userId;

  FavoritViewModel({
    required FavoritRepository repository,
    required this.userId,
  }) : _repository = repository;

  Stream<Set<String>> get streamIdFavorit =>
      _repository.streamIdFavorit(userId);

  Stream<List<FavoritModel>> get streamDaftarFavorit =>
      _repository.streamDaftarFavorit(userId);

  Future<void> toggle(String lapanganId, String namaLapangan) {
    return _repository.toggleFavorit(
      userId: userId,
      lapanganId: lapanganId,
      namaLapangan: namaLapangan,
    );
  }
}
