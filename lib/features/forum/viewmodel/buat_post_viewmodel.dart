import 'package:flutter/foundation.dart';

import '../../../repositories/forum_repository.dart';

class BuatPostViewModel extends ChangeNotifier {
  final ForumRepository _repository;

  BuatPostViewModel({required ForumRepository repository})
      : _repository = repository;


  bool _sedangMengirim = false;
  bool get sedangMengirim => _sedangMengirim;

 
  Future<String?> kirimPost({
    required String userId,
    required String namaUser,
    required String teks,
    String? gambarBase64,
  }) async {
    _sedangMengirim = true;
    notifyListeners();

    try {
      await _repository.buatPost(
        userId: userId,
        namaUser: namaUser,
        teks: teks,
        gambarBase64: gambarBase64,
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