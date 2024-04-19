// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/SubCatNews/subCatRepository.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';

abstract class SubCatNewsState {}

class SubCatNewsInitial extends SubCatNewsState {}

class SubCatNewsFetchInProgress extends SubCatNewsState {}

class SubCatNewsFetchSuccess extends SubCatNewsState {
  final List<NewsModel> subCatNews;
  final int totalSubCatNewsCount;
  final bool hasMoreFetchError;
  final bool hasMore;
  final bool isFirst;

  SubCatNewsFetchSuccess({required this.subCatNews, required this.totalSubCatNewsCount, required this.hasMoreFetchError, required this.hasMore, required this.isFirst});
}

class SubCatNewsFetchFailure extends SubCatNewsState {
  final String errorMessage;

  SubCatNewsFetchFailure(this.errorMessage);
}

class SubCatNewsCubit extends Cubit<SubCatNewsState> {
  final SubCatNewsRepository _subCatNewsRepository;

  SubCatNewsCubit(this._subCatNewsRepository) : super(SubCatNewsInitial());

  void getSubCatNews({String? catId, String? subCatId, String? latitude, String? longitude, required String langId}) async {
    try {
      emit(SubCatNewsFetchInProgress());
      final result =
          await _subCatNewsRepository.getSubCatNews(limit: limitOfAPIData.toString(), offset: "0", subCatId: subCatId, langId: langId, catId: catId, latitude: latitude, longitude: longitude);
      (result["total"] > 0)
          ? emit(SubCatNewsFetchSuccess(
              subCatNews: result['SubCatNews'],
              totalSubCatNewsCount: result[TOTAL],
              hasMoreFetchError: false,
              hasMore: (result['SubCatNews'] as List<NewsModel>).length < result[TOTAL],
              isFirst: true))
          : emit(SubCatNewsFetchFailure(ErrorMessageKeys.noDataMessage));
    } catch (e) {
      if (!isClosed) emit(SubCatNewsFetchFailure(e.toString()));
    }
  }

  bool hasMoreSubCatNews() {
    return (state is SubCatNewsFetchSuccess) ? (state as SubCatNewsFetchSuccess).hasMore : false;
  }

  void getMoreSubCatNews({String? catId, String? subCatId, String? latitude, String? longitude, required String langId}) async {
    if (state is SubCatNewsFetchSuccess) {
      try {
        final result = await _subCatNewsRepository.getSubCatNews(
            limit: limitOfAPIData.toString(),
            offset: (state as SubCatNewsFetchSuccess).subCatNews.length.toString(),
            langId: langId,
            catId: catId,
            subCatId: subCatId,
            latitude: latitude,
            longitude: longitude);
        List<NewsModel> updatedResults = (state as SubCatNewsFetchSuccess).subCatNews;
        updatedResults.addAll(result['SubCatNews'] as List<NewsModel>);
        emit(SubCatNewsFetchSuccess(subCatNews: updatedResults, totalSubCatNewsCount: result[TOTAL], hasMoreFetchError: false, hasMore: updatedResults.length < result[TOTAL], isFirst: false));
      } catch (e) {
        emit(SubCatNewsFetchSuccess(
            subCatNews: (state as SubCatNewsFetchSuccess).subCatNews,
            hasMoreFetchError: true,
            totalSubCatNewsCount: (state as SubCatNewsFetchSuccess).totalSubCatNewsCount,
            hasMore: (state as SubCatNewsFetchSuccess).hasMore,
            isFirst: false));
      }
    }
  }
}
