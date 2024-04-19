// ignore_for_file: file_names

import 'package:news/data/models/LiveStreamingModel.dart';
import 'package:news/data/repositories/LiveStream/liveRemoteDataSource.dart';

class LiveStreamRepository {
  static final LiveStreamRepository _liveStreamRepository = LiveStreamRepository._internal();

  late LiveStreamRemoteDataSource _liveStreamRemoteDataSource;

  factory LiveStreamRepository() {
    _liveStreamRepository._liveStreamRemoteDataSource = LiveStreamRemoteDataSource();
    return _liveStreamRepository;
  }

  LiveStreamRepository._internal();

  Future<Map<String, dynamic>> getLiveStream({required String langId}) async {
    final result = await _liveStreamRemoteDataSource.getLiveStreams(langId: langId);

    return {"LiveStream": (result['data'] as List).map((e) => LiveStreamingModel.fromJson(e)).toList()};
  }
}
