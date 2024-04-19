// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class SetCommentRemoteDataSource {
  Future<dynamic> setComment({required String parentId, required String newsId, required String message}) async {
    try {
      final body = {PARENT_ID: parentId, NEWS_ID: newsId, MESSAGE: message};
      final result = await Api.sendApiRequest(body: body, url: Api.setCommentApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
