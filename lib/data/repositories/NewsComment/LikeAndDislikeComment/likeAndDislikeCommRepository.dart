// ignore_for_file: file_names
import 'package:news/data/repositories/NewsComment/LikeAndDislikeComment/likeAndDislikeCommDataSource.dart';

class LikeAndDislikeCommRepository {
  static final LikeAndDislikeCommRepository _likeAndDislikeCommRepository = LikeAndDislikeCommRepository._internal();
  late LikeAndDislikeCommRemoteDataSource _likeAndDislikeCommRemoteDataSource;

  factory LikeAndDislikeCommRepository() {
    _likeAndDislikeCommRepository._likeAndDislikeCommRemoteDataSource = LikeAndDislikeCommRemoteDataSource();
    return _likeAndDislikeCommRepository;
  }

  LikeAndDislikeCommRepository._internal();

  Future setLikeAndDislikeComm({required String langId, required String commId, required String status}) async {
    final result = await _likeAndDislikeCommRemoteDataSource.likeAndDislikeComm(langId: langId, commId: commId, status: status);
    return result;
  }
}
