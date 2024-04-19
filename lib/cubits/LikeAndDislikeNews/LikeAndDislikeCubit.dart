// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/LikeAndDisLikeNews/LikeAndDisLikeNewsRepository.dart';
import 'package:news/utils/strings.dart';

abstract class LikeAndDisLikeState {}

class LikeAndDisLikeInitial extends LikeAndDisLikeState {}

class LikeAndDisLikeFetchInProgress extends LikeAndDisLikeState {}

class LikeAndDisLikeFetchSuccess extends LikeAndDisLikeState {
  final List<NewsModel> likeAndDisLike;
  final int totalLikeAndDisLikeCount;
  final bool hasMoreFetchError;
  final bool hasMore;

  LikeAndDisLikeFetchSuccess({required this.likeAndDisLike, required this.totalLikeAndDisLikeCount, required this.hasMoreFetchError, required this.hasMore});
}

class LikeAndDisLikeFetchFailure extends LikeAndDisLikeState {
  final String errorMessage;

  LikeAndDisLikeFetchFailure(this.errorMessage);
}

class LikeAndDisLikeCubit extends Cubit<LikeAndDisLikeState> {
  final LikeAndDisLikeRepository likeAndDisLikeRepository;
  int perPageLimit = 25;

  LikeAndDisLikeCubit(this.likeAndDisLikeRepository) : super(LikeAndDisLikeInitial());

  void getLikeAndDisLike({required String langId}) async {
    try {
      emit(LikeAndDisLikeFetchInProgress());
      final result = await likeAndDisLikeRepository.getLikeAndDisLike(limit: perPageLimit.toString(), offset: "0", langId: langId);
      emit(LikeAndDisLikeFetchSuccess(
          likeAndDisLike: result['LikeAndDisLike'], totalLikeAndDisLikeCount: result[TOTAL], hasMoreFetchError: false, hasMore: (result['LikeAndDisLike'] as List<NewsModel>).length < result[TOTAL]));
    } catch (e) {
      emit(LikeAndDisLikeFetchFailure(e.toString()));
    }
  }

  bool hasMoreLikeAndDisLike() {
    return (state is LikeAndDisLikeFetchSuccess) ? (state as LikeAndDisLikeFetchSuccess).hasMore : false;
  }

  void getMoreLikeAndDisLike({required String langId}) async {
    if (state is LikeAndDisLikeFetchSuccess) {
      try {
        final result = await likeAndDisLikeRepository.getLikeAndDisLike(limit: perPageLimit.toString(), offset: (state as LikeAndDisLikeFetchSuccess).likeAndDisLike.length.toString(), langId: langId);
        List<NewsModel> updatedResults = (state as LikeAndDisLikeFetchSuccess).likeAndDisLike;
        updatedResults.addAll(result['LikeAndDisLike'] as List<NewsModel>);
        emit(LikeAndDisLikeFetchSuccess(likeAndDisLike: updatedResults, totalLikeAndDisLikeCount: result[TOTAL], hasMoreFetchError: false, hasMore: updatedResults.length < result[TOTAL]));
      } catch (e) {
        emit(LikeAndDisLikeFetchSuccess(
            likeAndDisLike: (state as LikeAndDisLikeFetchSuccess).likeAndDisLike,
            hasMoreFetchError: true,
            totalLikeAndDisLikeCount: (state as LikeAndDisLikeFetchSuccess).totalLikeAndDisLikeCount,
            hasMore: (state as LikeAndDisLikeFetchSuccess).hasMore));
      }
    }
  }

  bool isNewsLikeAndDisLike(String newsId) {
    if (state is LikeAndDisLikeFetchSuccess) {
      final likeAndDisLike = (state as LikeAndDisLikeFetchSuccess).likeAndDisLike;
      return likeAndDisLike.indexWhere((element) => (element.id == newsId || element.newsId == newsId)) != -1;
    }
    return false;
  }

  void resetState() {
    emit(LikeAndDisLikeFetchInProgress());
  }
}
