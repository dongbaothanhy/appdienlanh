// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class RelatedNewsRemoteDataSource {
  Future<dynamic> getRelatedNews({required String langId, String? catId, String? subCatId, String? latitude, String? longitude, required String offset, required String perPage}) async {
    try {
      final body = {LANGUAGE_ID: langId, OFFSET: offset, LIMIT: perPage};
      (subCatId != "0" && subCatId != '') ? body[SUBCAT_ID] = subCatId! : body[CATEGORY_ID] = catId!;
      if (latitude != null && latitude != "null") body[LATITUDE] = latitude;
      if (longitude != null && longitude != "null") body[LONGITUDE] = longitude;

      final result = await Api.sendApiRequest(body: body, url: Api.getNewsApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
