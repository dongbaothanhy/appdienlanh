// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class LikeAndDislikeCommRemoteDataSource {
  Future likeAndDislikeComm({required String langId, required String commId, required String status}) async {
    try {
      final body = {LANGUAGE_ID: langId, COMMENT_ID: commId, STATUS: status};
      final result = await Api.sendApiRequest(body: body, url: Api.setLikeDislikeComApi);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
