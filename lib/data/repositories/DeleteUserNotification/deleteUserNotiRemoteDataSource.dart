// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class DeleteUserNotiRemoteDataSource {
  Future deleteUserNotification({required String id}) async {
    try {
      final body = {ID: id};
      final result = await Api.sendApiRequest(body: body, url: Api.deleteUserNotiApi);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
