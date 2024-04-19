// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class SetFlagRemoteDataSource {
  Future<dynamic> setFlag({required String commId, required String newsId, required String message}) async {
    try {
      final body = {COMMENT_ID: commId, NEWS_ID: newsId, MESSAGE: message};
      final result = await Api.sendApiRequest(body: body, url: Api.setFlagApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
