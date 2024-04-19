// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/GetUserNews/getUserNewsRepository.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';

abstract class GetUserNewsState {}

class GetUserNewsInitial extends GetUserNewsState {}

class GetUserNewsFetchInProgress extends GetUserNewsState {}

class GetUserNewsFetchSuccess extends GetUserNewsState {
  final List<NewsModel> getUserNews;
  final int totalGetUserNewsCount;
  final bool hasMoreFetchError;
  final bool hasMore;

  GetUserNewsFetchSuccess({required this.getUserNews, required this.totalGetUserNewsCount, required this.hasMoreFetchError, required this.hasMore});
}

class GetUserNewsFetchFailure extends GetUserNewsState {
  final String errorMessage;

  GetUserNewsFetchFailure(this.errorMessage);
}

class GetUserNewsCubit extends Cubit<GetUserNewsState> {
  final GetUserNewsRepository _getUserNewsRepository;

  GetUserNewsCubit(this._getUserNewsRepository) : super(GetUserNewsInitial());

  void getGetUserNews({required String langId, String? latitude, String? longitude}) async {
    try {
      emit(GetUserNewsFetchInProgress());
      final result = await _getUserNewsRepository.getGetUserNews(limit: limitOfAPIData.toString(), offset: "0", langId: langId, latitude: latitude, longitude: longitude);
      (result[TOTAL] > 0)
          ? emit(GetUserNewsFetchSuccess(
              getUserNews: result['GetUserNews'], totalGetUserNewsCount: result[TOTAL], hasMoreFetchError: false, hasMore: (result['GetUserNews'] as List<NewsModel>).length < result[TOTAL]))
          : emit(GetUserNewsFetchFailure(ErrorMessageKeys.noDataMessage));
    } catch (e) {
      emit(GetUserNewsFetchFailure(e.toString()));
    }
  }

  bool hasMoreGetUserNews() {
    return (state is GetUserNewsFetchSuccess) ? (state as GetUserNewsFetchSuccess).hasMore : false;
  }

  void getMoreGetUserNews({required String langId, String? latitude, String? longitude}) async {
    if (state is GetUserNewsFetchSuccess) {
      try {
        final result = await _getUserNewsRepository.getGetUserNews(
            limit: limitOfAPIData.toString(), offset: (state as GetUserNewsFetchSuccess).getUserNews.length.toString(), langId: langId, latitude: latitude, longitude: longitude);
        List<NewsModel> updatedResults = (state as GetUserNewsFetchSuccess).getUserNews;
        updatedResults.addAll(result['GetUserNews'] as List<NewsModel>);
        emit(GetUserNewsFetchSuccess(getUserNews: updatedResults, totalGetUserNewsCount: result[TOTAL], hasMoreFetchError: false, hasMore: updatedResults.length < result[TOTAL]));
      } catch (e) {
        emit(GetUserNewsFetchSuccess(
            getUserNews: (state as GetUserNewsFetchSuccess).getUserNews,
            hasMoreFetchError: true,
            totalGetUserNewsCount: (state as GetUserNewsFetchSuccess).totalGetUserNewsCount,
            hasMore: (state as GetUserNewsFetchSuccess).hasMore));
      }
    }
  }

  void deleteNews(int index) {
    if (state is GetUserNewsFetchSuccess) {
      List<NewsModel> newsList = List.from((state as GetUserNewsFetchSuccess).getUserNews)..removeAt(index);

      emit(GetUserNewsFetchSuccess(
          getUserNews: newsList, hasMore: (state as GetUserNewsFetchSuccess).hasMore, hasMoreFetchError: false, totalGetUserNewsCount: (state as GetUserNewsFetchSuccess).totalGetUserNewsCount - 1));
    }
  }

  void deleteImageId(int index) {
    if (state is GetUserNewsFetchSuccess) {
      List<NewsModel> newsList = (state as GetUserNewsFetchSuccess).getUserNews;

      newsList[index].imageDataList!.removeAt(index);

      emit(GetUserNewsFetchSuccess(
          getUserNews: newsList, hasMore: (state as GetUserNewsFetchSuccess).hasMore, hasMoreFetchError: false, totalGetUserNewsCount: (state as GetUserNewsFetchSuccess).totalGetUserNewsCount));
    }
  }
}
