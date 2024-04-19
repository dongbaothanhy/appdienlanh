// ignore_for_file: file_names

import 'package:news/utils/strings.dart';
import 'package:news/utils/api.dart';

class BookmarkRemoteDataSource {
  Future<dynamic> getBookmark({required String langId, required String offset, required String perPage}) async {
    try {
      final body = {LANGUAGE_ID: langId, OFFSET: offset, LIMIT: perPage};
      final result = await Api.sendApiRequest(body: body, url: Api.getBookmarkApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future addBookmark({required String newsId, required String status}) async {
    try {
      final body = {NEWS_ID: newsId, STATUS: status};
      final result = await Api.sendApiRequest(body: body, url: Api.setBookmarkApi);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
