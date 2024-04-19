// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/GetSurveyAnswer/getSurveyAnsRepository.dart';

abstract class GetSurveyAnsState {}

class GetSurveyAnsInitial extends GetSurveyAnsState {}

class GetSurveyAnsFetchInProgress extends GetSurveyAnsState {}

class GetSurveyAnsFetchSuccess extends GetSurveyAnsState {
  final List<NewsModel> getSurveyAns;

  GetSurveyAnsFetchSuccess({required this.getSurveyAns});
}

class GetSurveyAnsFetchFailure extends GetSurveyAnsState {
  final String errorMessage;

  GetSurveyAnsFetchFailure(this.errorMessage);
}

class GetSurveyAnsCubit extends Cubit<GetSurveyAnsState> {
  final GetSurveyAnsRepository _getSurveyAnsRepository;

  GetSurveyAnsCubit(this._getSurveyAnsRepository) : super(GetSurveyAnsInitial());

  void getSurveyAns({required String langId}) async {
    try {
      emit(GetSurveyAnsFetchInProgress());
      final result = await _getSurveyAnsRepository.getSurveyAns(langId: langId);
      emit(GetSurveyAnsFetchSuccess(getSurveyAns: result['GetSurveyAns']));
    } catch (e) {
      emit(GetSurveyAnsFetchFailure(e.toString()));
    }
  }
}
