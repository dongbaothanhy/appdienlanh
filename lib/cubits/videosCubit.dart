// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/Videos/videosRepository.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';

abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoFetchInProgress extends VideoState {}

class VideoFetchSuccess extends VideoState {
  final List<NewsModel> video;
  final int totalVideoCount;
  final bool hasMoreFetchError;
  final bool hasMore;

  VideoFetchSuccess({required this.video, required this.totalVideoCount, required this.hasMoreFetchError, required this.hasMore});
}

class VideoFetchFailure extends VideoState {
  final String errorMessage;

  VideoFetchFailure(this.errorMessage);
}

class VideoCubit extends Cubit<VideoState> {
  final VideoRepository _videoRepository;

  VideoCubit(this._videoRepository) : super(VideoInitial());

  void getVideo({required String langId, String? latitude, String? longitude}) async {
    try {
      emit(VideoFetchInProgress());
      final result = await _videoRepository.getVideo(limit: limitOfAPIData.toString(), offset: "0", langId: langId, latitude: latitude, longitude: longitude);
      emit(VideoFetchSuccess(video: result['Video'], totalVideoCount: result[TOTAL], hasMoreFetchError: false, hasMore: (result['Video'] as List<NewsModel>).length < result[TOTAL]));
    } catch (e) {
      emit(VideoFetchFailure(e.toString()));
    }
  }

  bool hasMoreVideo() {
    return (state is VideoFetchSuccess) ? (state as VideoFetchSuccess).hasMore : false;
  }

  void getMoreVideo({required String langId, String? latitude, String? longitude}) async {
    if (state is VideoFetchSuccess) {
      try {
        final result =
            await _videoRepository.getVideo(langId: langId, limit: limitOfAPIData.toString(), offset: (state as VideoFetchSuccess).video.length.toString(), latitude: latitude, longitude: longitude);
        List<NewsModel> updatedResults = (state as VideoFetchSuccess).video;
        updatedResults.addAll(result['Video'] as List<NewsModel>);
        emit(VideoFetchSuccess(video: updatedResults, totalVideoCount: result[TOTAL], hasMoreFetchError: false, hasMore: updatedResults.length < result[TOTAL]));
      } catch (e) {
        emit(VideoFetchSuccess(
            video: (state as VideoFetchSuccess).video, hasMoreFetchError: true, totalVideoCount: (state as VideoFetchSuccess).totalVideoCount, hasMore: (state as VideoFetchSuccess).hasMore));
      }
    }
  }
}
