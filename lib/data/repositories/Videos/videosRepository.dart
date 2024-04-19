// ignore_for_file: file_names

import 'package:news/data/models/NewsModel.dart';
import 'package:news/utils/strings.dart';
import 'package:news/data/repositories/Videos/videoRemoteDataSource.dart';

class VideoRepository {
  static final VideoRepository _videoRepository = VideoRepository._internal();

  late VideoRemoteDataSource _videoRemoteDataSource;

  factory VideoRepository() {
    _videoRepository._videoRemoteDataSource = VideoRemoteDataSource();
    return _videoRepository;
  }

  VideoRepository._internal();

  Future<Map<String, dynamic>> getVideo({required String offset, required String limit, required String langId, String? latitude, String? longitude}) async {
    final result = await _videoRemoteDataSource.getVideos(limit: limit, offset: offset, langId: langId, latitude: latitude, longitude: longitude);

    return {"total": result[TOTAL], "Video": (result['data'] as List).map((e) => NewsModel.fromVideos(e)).toList()};
  }
}
