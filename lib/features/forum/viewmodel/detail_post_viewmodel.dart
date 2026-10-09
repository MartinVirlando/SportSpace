import 'package:flutter/foundation.dart';

import '../../../models/forum_komentar_model.dart';
import '../../../repositories/forum_repository.dart';


class DetailPostViewModel extends ChangeNotifier {
  final ForumRepository _repository;
  final String postId;

  DetailPostViewModel({
    required ForumRepository repository,
    required this.postId,
  })  : _repository = repository,
        streamKomentar = repository.streamKomentar(postId);

 
  final Stream<List<ForumKomentarModel>> streamKomentar;


  bool _sedangMengirim = false;
  bool get sedangMengirim => _sedangMengirim;


  Future<String?> kirimKomentar({
    required String userId,
    required String namaUser,
    required String teks,
  }) async {
    _sedangMengirim = true;
    notifyListeners();

    try {
      await _repository.tambahKomentar(
        postId: postId,
        userId: userId,
        namaUser: namaUser,
        teks: teks,
      );
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _sedangMengirim = false;
      notifyListeners();
    }
  }
}