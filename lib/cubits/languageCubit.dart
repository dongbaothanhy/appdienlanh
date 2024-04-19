// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/appLanguageModel.dart';
import 'package:news/data/repositories/language/languageRepository.dart';

abstract class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageFetchInProgress extends LanguageState {}

class LanguageFetchSuccess extends LanguageState {
  final List<LanguageModel> language;

  LanguageFetchSuccess({required this.language});
}

class LanguageFetchFailure extends LanguageState {
  final String errorMessage;

  LanguageFetchFailure(this.errorMessage);
}

class LanguageCubit extends Cubit<LanguageState> {
  final LanguageRepository _languageRepository;

  LanguageCubit(this._languageRepository) : super(LanguageInitial());

  Future<List<LanguageModel>> getLanguage() async {
    try {
      emit(LanguageFetchInProgress());
      final result = await _languageRepository.getLanguage();
      emit(LanguageFetchSuccess(language: result['Language']));
      return result['Language'];
    } catch (e) {
      emit(LanguageFetchFailure(e.toString()));
      return [];
    }
  }

  List<LanguageModel> langList() {
    return (state is LanguageFetchSuccess) ? (state as LanguageFetchSuccess).language : [];
  }

  int getLanguageIndex({required String langName}) {
    return (state is LanguageFetchSuccess) ? (state as LanguageFetchSuccess).language.indexWhere((element) => element.language == langName) : 0;
  }
}
