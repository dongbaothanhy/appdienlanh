// ignore_for_file: file_names

import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/SurveyQuestion/surveyQueRemoteDataSource.dart';

class SurveyQuestionRepository {
  static final SurveyQuestionRepository _surveyQuestionRepository = SurveyQuestionRepository._internal();

  late SurveyQuestionRemoteDataSource _surveyQuestionRemoteDataSource;

  factory SurveyQuestionRepository() {
    _surveyQuestionRepository._surveyQuestionRemoteDataSource = SurveyQuestionRemoteDataSource();
    return _surveyQuestionRepository;
  }

  SurveyQuestionRepository._internal();

  Future<Map<String, dynamic>> getSurveyQuestion({required String langId}) async {
    final result = await _surveyQuestionRemoteDataSource.getSurveyQuestions(langId: langId);

    return {"SurveyQuestion": (result['data'] as List).map((e) => NewsModel.fromSurvey(e)).toList()};
  }
}
