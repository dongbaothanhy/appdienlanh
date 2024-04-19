// ignore_for_file: file_names

import 'package:news/utils/api.dart';

class SystemRepository {
  Future<dynamic> fetchSettings() async {
    try {
      final result = await Api.sendApiRequest(url: Api.getSettingApi, body: {}, isGet: true);
      return result['data'];
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
