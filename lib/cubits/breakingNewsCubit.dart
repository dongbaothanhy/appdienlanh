// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/repositories/BreakingNews/breakNewsRepository.dart';

abstract class BreakingNewsState {}

class BreakingNewsInitial extends BreakingNewsState {}

class BreakingNewsFetchInProgress extends BreakingNewsState {}

class BreakingNewsFetchSuccess extends BreakingNewsState {
  final List<BreakingNewsModel> breakingNews;

  BreakingNewsFetchSuccess({required this.breakingNews});
}

class BreakingNewsFetchFailure extends BreakingNewsState {
  final String errorMessage;

  BreakingNewsFetchFailure(this.errorMessage);
}

class BreakingNewsCubit extends Cubit<BreakingNewsState> {
  final BreakingNewsRepository _breakingNewsRepository;

  BreakingNewsCubit(this._breakingNewsRepository) : super(BreakingNewsInitial());

  Future<List<BreakingNewsModel>> getBreakingNews({required String langId}) async {
    emit(BreakingNewsFetchInProgress());
    try {
      final result = await _breakingNewsRepository.getBreakingNews(langId: langId);
      emit(BreakingNewsFetchSuccess(breakingNews: result['BreakingNews']));
      return result['BreakingNews'];
    } catch (e) {
      emit(BreakingNewsFetchFailure(e.toString()));
      return [];
    }
  }
}
