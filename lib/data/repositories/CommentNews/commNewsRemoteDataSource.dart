// ignore_for_file: file_names
import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class CommentNewsRemoteDataSource {
  Future<dynamic> getCommentNews({required String limit, required String offset, required String newsId}) async {
    try {
      final body = {LIMIT: limit, OFFSET: offset, NEWS_ID: newsId};
      final result = await Api.sendApiRequest(body: body, url: Api.getCommentByNewsApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
