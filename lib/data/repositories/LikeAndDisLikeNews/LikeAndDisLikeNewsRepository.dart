// ignore_for_file: file_names, non_constant_identifier_names

import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/LikeAndDisLikeNews/LikeAndDisLikeNewsDataSource.dart';
import 'package:news/utils/strings.dart';

class LikeAndDisLikeRepository {
  static final LikeAndDisLikeRepository _LikeAndDisLikeRepository = LikeAndDisLikeRepository._internal();
  late LikeAndDisLikeRemoteDataSource _LikeAndDisLikeRemoteDataSource;

  factory LikeAndDisLikeRepository() {
    _LikeAndDisLikeRepository._LikeAndDisLikeRemoteDataSource = LikeAndDisLikeRemoteDataSource();
    return _LikeAndDisLikeRepository;
  }

  LikeAndDisLikeRepository._internal();

  Future<Map<String, dynamic>> getLikeAndDisLike({required String offset, required String limit, required String langId}) async {
    final result = await _LikeAndDisLikeRemoteDataSource.getLikeAndDisLike(perPage: limit, offset: offset, langId: langId);

    return {"total": result[TOTAL], "LikeAndDisLike": (result[DATA] as List).map((e) => NewsModel.fromJson(e)).toList()};
  }

  Future setLikeAndDisLike({required String newsId, required String status}) async {
    final result = await _LikeAndDisLikeRemoteDataSource.addAndRemoveLikeAndDisLike(status: status, newsId: newsId);
    return result;
  }
}
