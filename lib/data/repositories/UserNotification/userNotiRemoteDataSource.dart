// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class UserNotificationRemoteDataSource {
  Future<dynamic> getUserNotifications({required String limit, required String offset}) async {
    try {
      final body = {LIMIT: limit, OFFSET: offset};
      final result = await Api.sendApiRequest(body: body, url: Api.getUserNotificationApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
