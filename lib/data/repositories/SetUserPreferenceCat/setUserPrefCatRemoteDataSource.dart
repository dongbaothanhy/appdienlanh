// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class SetUserPrefCatRemoteDataSource {
  Future<dynamic> setUserPrefCat({required String catId}) async {
    try {
      final body = {CATEGORY_ID: catId};
      final result = await Api.sendApiRequest(body: body, url: Api.setUserCatApi);

      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
