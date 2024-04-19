// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class DeleteCommRemoteDataSource {
  Future deleteComm({required String commId}) async {
    try {
      final body = {COMMENT_ID: commId};
      final result = await Api.sendApiRequest(body: body, url: Api.setCommentDeleteApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
