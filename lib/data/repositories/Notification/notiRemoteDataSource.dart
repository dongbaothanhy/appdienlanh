// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';

class NotificationRemoteDataSource {
  Future<dynamic> getNotifications({required String limit, required String offset, required String langId}) async {
    try {
      final body = {LIMIT: limit, OFFSET: offset, LANGUAGE_ID: langId};
      final result = await Api.sendApiRequest(body: body, url: Api.getNotificationApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
