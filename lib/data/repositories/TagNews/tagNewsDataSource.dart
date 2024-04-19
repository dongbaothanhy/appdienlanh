// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class TagNewsRemoteDataSource {
  Future<dynamic> getTagNews({required String tagId, required String langId, String? latitude, String? longitude}) async {
    try {
      final body = {TAG_ID: tagId, LANGUAGE_ID: langId};
      if (latitude != null && latitude != "null") body[LATITUDE] = latitude;
      if (longitude != null && longitude != "null") body[LONGITUDE] = longitude;

      final result = await Api.sendApiRequest(body: body, url: Api.getNewsApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
