// ignore_for_file: file_names

import 'package:news/utils/api.dart';

class GetUserByIdRemoteDataSource {
  Future<dynamic> getUserById() async {
    try {
      final result = await Api.sendApiRequest(body: {}, url: Api.getUserByIdApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
