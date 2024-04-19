// ignore_for_file: file_names

import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/repositories/BreakingNews/breakNewsRemoteDataSource.dart';

class BreakingNewsRepository {
  static final BreakingNewsRepository _breakingNewsRepository = BreakingNewsRepository._internal();

  late BreakingNewsRemoteDataSource _breakingNewsRemoteDataSource;

  factory BreakingNewsRepository() {
    _breakingNewsRepository._breakingNewsRemoteDataSource = BreakingNewsRemoteDataSource();
    return _breakingNewsRepository;
  }

  BreakingNewsRepository._internal();

  Future<Map<String, dynamic>> getBreakingNews({required String langId}) async {
    final result = await _breakingNewsRemoteDataSource.getBreakingNews(langId: langId);

    return {"BreakingNews": (result['data'] as List).map((e) => BreakingNewsModel.fromJson(e)).toList()};
  }
}
