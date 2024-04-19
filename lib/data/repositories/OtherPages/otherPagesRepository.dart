// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:news/utils/strings.dart';
import 'package:news/data/models/OtherPageModel.dart';
import 'package:news/data/repositories/OtherPages/otherPageRemoteDataSorce.dart';

class OtherPageRepository {
  static final OtherPageRepository _otherPageRepository = OtherPageRepository._internal();

  late OtherPageRemoteDataSource _otherPageRemoteDataSource;

  factory OtherPageRepository() {
    _otherPageRepository._otherPageRemoteDataSource = OtherPageRemoteDataSource();
    return _otherPageRepository;
  }

  OtherPageRepository._internal();

  Future<Map<String, dynamic>> getOtherPage({required String langId}) async {
    final result = await _otherPageRemoteDataSource.getOtherPages(langId: langId);

    return {"OtherPage": (result['data'] as List).map((e) => OtherPageModel.fromJson(e)).toList()};
  }

  //get only privacy policy & Terms Conditions
  Future<Map<String, dynamic>> getPrivacyTermsPage({required String langId}) async {
    try {
      final body = {LANGUAGE_ID: langId};
      final result = await Api.sendApiRequest(body: body, url: Api.getPolicyPagesApi, isGet: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
