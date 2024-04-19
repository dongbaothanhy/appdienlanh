// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class TagRemoteDataSource {
  Future<dynamic> getTag({required String langId, required String offset, required String limit}) async {
    try {
      final body = {LANGUAGE_ID: langId, LIMIT: limit, OFFSET: offset};
      final result = await Api.sendApiRequest(body: body, url: Api.getTagsApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
