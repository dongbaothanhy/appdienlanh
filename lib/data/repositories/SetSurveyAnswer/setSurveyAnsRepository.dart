// ignore_for_file: file_names

import 'package:news/data/repositories/SetSurveyAnswer/setSurveyAnsDataRemoteSource.dart';

class SetSurveyAnsRepository {
  static final SetSurveyAnsRepository _setSurveyAnsRepository = SetSurveyAnsRepository._internal();

  late SetSurveyAnsRemoteDataSource _setSurveyAnsRemoteDataSource;

  factory SetSurveyAnsRepository() {
    _setSurveyAnsRepository._setSurveyAnsRemoteDataSource = SetSurveyAnsRemoteDataSource();
    return _setSurveyAnsRepository;
  }

  SetSurveyAnsRepository._internal();

  Future<Map<String, dynamic>> setSurveyAns({required String queId, required String optId}) async {
    final result = await _setSurveyAnsRemoteDataSource.setSurveyAns(optId: optId, queId: queId);

    return {"SetSurveyAns": result['data']};
  }
}
