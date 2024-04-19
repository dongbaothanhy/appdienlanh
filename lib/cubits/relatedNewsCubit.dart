// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/RelatedNews/relatedNewsRepository.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';

abstract class RelatedNewsState {}

class RelatedNewsInitial extends RelatedNewsState {}

class RelatedNewsFetchInProgress extends RelatedNewsState {}

class RelatedNewsFetchSuccess extends RelatedNewsState {
  final List<NewsModel> relatedNews;
  final int totalRelatedNewsCount;
  final bool hasMoreFetchError;
  final bool hasMore;

  RelatedNewsFetchSuccess({required this.relatedNews, required this.totalRelatedNewsCount, required this.hasMoreFetchError, required this.hasMore});
}

class RelatedNewsFetchFailure extends RelatedNewsState {
  final String errorMessage;

  RelatedNewsFetchFailure(this.errorMessage);
}

class RelatedNewsCubit extends Cubit<RelatedNewsState> {
  final RelatedNewsRepository _relatedNewsRepository;

  RelatedNewsCubit(this._relatedNewsRepository) : super(RelatedNewsInitial());

  void getRelatedNews({required String langId, String? catId, String? subCatId}) async {
    try {
      emit(RelatedNewsFetchInProgress());
      final result = await _relatedNewsRepository.getRelatedNews(perPage: limitOfAPIData.toString(), offset: "0", langId: langId, catId: catId, subCatId: subCatId);
      emit(RelatedNewsFetchSuccess(
          relatedNews: result['RelatedNews'], totalRelatedNewsCount: result[TOTAL], hasMoreFetchError: false, hasMore: (result['RelatedNews'] as List<NewsModel>).length < result[TOTAL]));
    } catch (e) {
      emit(RelatedNewsFetchFailure(e.toString()));
    }
  }

  bool hasMoreRelatedNews() {
    return (state is RelatedNewsFetchSuccess) ? (state as RelatedNewsFetchSuccess).hasMore : false;
  }

  void getMoreRelatedNews({required String langId, String? catId, String? subCatId, String? latitude, String? longitude}) async {
    if (state is RelatedNewsFetchSuccess) {
      try {
        final result = await _relatedNewsRepository.getRelatedNews(
            perPage: limitOfAPIData.toString(),
            offset: (state as RelatedNewsFetchSuccess).relatedNews.length.toString(),
            langId: langId,
            subCatId: subCatId,
            catId: catId,
            latitude: latitude,
            longitude: longitude);
        List<NewsModel> updatedResults = (state as RelatedNewsFetchSuccess).relatedNews;
        updatedResults.addAll(result['RelatedNews'] as List<NewsModel>);
        emit(RelatedNewsFetchSuccess(
          relatedNews: updatedResults,
          totalRelatedNewsCount: result[TOTAL],
          hasMoreFetchError: false,
          hasMore: updatedResults.length < result[TOTAL],
        ));
      } catch (e) {
        emit(RelatedNewsFetchSuccess(
          relatedNews: (state as RelatedNewsFetchSuccess).relatedNews,
          hasMoreFetchError: true,
          totalRelatedNewsCount: (state as RelatedNewsFetchSuccess).totalRelatedNewsCount,
          hasMore: (state as RelatedNewsFetchSuccess).hasMore,
        ));
      }
    }
  }
}
