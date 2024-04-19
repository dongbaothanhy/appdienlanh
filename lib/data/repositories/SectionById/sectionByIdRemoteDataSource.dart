// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class SectionByIdRemoteDataSource {
  Future<dynamic> getSectionById({required String langId, required String sectionId, String? latitude, String? longitude}) async {
    try {
      final body = {LANGUAGE_ID: langId, SECTION_ID: sectionId};
      if (latitude != null && latitude != "null") body[LATITUDE] = latitude;
      if (longitude != null && longitude != "null") body[LONGITUDE] = longitude;

      final result = await Api.sendApiRequest(body: body, url: Api.getFeatureSectionByIdApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
