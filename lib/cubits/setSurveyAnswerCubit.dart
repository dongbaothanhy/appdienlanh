// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/repositories/SetSurveyAnswer/setSurveyAnsRepository.dart';

abstract class SetSurveyAnsState {}

class SetSurveyAnsInitial extends SetSurveyAnsState {}

class SetSurveyAnsFetchInProgress extends SetSurveyAnsState {}

class SetSurveyAnsFetchSuccess extends SetSurveyAnsState {
  var setSurveyAns;

  SetSurveyAnsFetchSuccess({required this.setSurveyAns});
}

class SetSurveyAnsFetchFailure extends SetSurveyAnsState {
  final String errorMessage;

  SetSurveyAnsFetchFailure(this.errorMessage);
}

class SetSurveyAnsCubit extends Cubit<SetSurveyAnsState> {
  final SetSurveyAnsRepository _setSurveyAnsRepository;

  SetSurveyAnsCubit(this._setSurveyAnsRepository) : super(SetSurveyAnsInitial());

  void setSurveyAns({required String queId, required String optId}) async {
    try {
      emit(SetSurveyAnsFetchInProgress());
      final result = await _setSurveyAnsRepository.setSurveyAns(queId: queId, optId: optId);

      emit(SetSurveyAnsFetchSuccess(setSurveyAns: result['SetSurveyAns']));
    } catch (e) {
      emit(SetSurveyAnsFetchFailure(e.toString()));
    }
  }
}
