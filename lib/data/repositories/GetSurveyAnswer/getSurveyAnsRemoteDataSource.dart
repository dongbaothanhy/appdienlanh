// ignore_for_file: file_names

import 'package:news/utils/strings.dart';
import 'package:news/utils/api.dart';

class GetSurveyAnsRemoteDataSource {
  Future<dynamic> getSurveyAns({required String langId}) async {
    try {
      final body = {LANGUAGE_ID: langId};
      final result = await Api.sendApiRequest(body: body, url: Api.getQueResultApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
