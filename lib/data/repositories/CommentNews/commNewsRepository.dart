// ignore_for_file: file_names
import 'package:news/data/models/CommentModel.dart';
import 'package:news/data/repositories/CommentNews/commNewsRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class CommentNewsRepository {
  static final CommentNewsRepository _commentNewsRepository = CommentNewsRepository._internal();

  late CommentNewsRemoteDataSource _commentNewsRemoteDataSource;

  factory CommentNewsRepository() {
    _commentNewsRepository._commentNewsRemoteDataSource = CommentNewsRemoteDataSource();
    return _commentNewsRepository;
  }

  CommentNewsRepository._internal();

  Future<Map<String, dynamic>> getCommentNews({required String offset, required String limit, required String newsId}) async {
    final result = await _commentNewsRemoteDataSource.getCommentNews(limit: limit, offset: offset, newsId: newsId);
    final List<CommentModel> commentsList = (result['data'] as List).map((e) => CommentModel.fromJson(e)).toList();
    final List<ReplyModel> replyList = [];
    for (var i in commentsList) {
      replyList.addAll(i.replyComList as List<ReplyModel>);
    }
    return {"total": result[TOTAL], "CommentNews": commentsList};
  }
}
