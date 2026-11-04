import 'package:flutter/foundation.dart';

import '../../../models/forum_post_model.dart';
import '../../../repositories/forum_repository.dart';


class ForumViewModel extends ChangeNotifier {
  final ForumRepository _repository;

  ForumViewModel({required ForumRepository repository})
      : _repository = repository;

  /// Stream daftar post, dikonsumsi langsung oleh `StreamBuilder` di View.
  Stream<List<ForumPostModel>> get streamPosts => _repository.streamPosts();
}