// ignore_for_file: file_names

import 'package:news/utils/strings.dart';
import 'package:news/utils/api.dart';

class LikeAndDisLikeRemoteDataSource {
  Future<dynamic> getLikeAndDisLike({required String langId, required String offset, required String perPage}) async {
    try {
      final body = {LANGUAGE_ID: langId, OFFSET: offset, LIMIT: perPage};

      final result = await Api.sendApiRequest(body: body, url: Api.getLikeNewsApi, isGet: true);

      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future addAndRemoveLikeAndDisLike({required String newsId, required String status}) async {
    try {
      final body = {NEWS_ID: newsId, STATUS: status};
      final result = await Api.sendApiRequest(body: body, url: Api.setLikesDislikesApi);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
