// ignore_for_file: file_names

import 'package:news/data/models/TagModel.dart';
import 'package:news/utils/strings.dart';
import 'package:news/data/repositories/Tag/tagRemoteDataSource.dart';

class TagRepository {
  static final TagRepository _tagRepository = TagRepository._internal();

  late TagRemoteDataSource _tagRemoteDataSource;

  factory TagRepository() {
    _tagRepository._tagRemoteDataSource = TagRemoteDataSource();
    return _tagRepository;
  }

  TagRepository._internal();

  Future<Map<String, dynamic>> getTag({required String langId, required String offset, required String limit}) async {
    final result = await _tagRemoteDataSource.getTag(langId: langId, limit: limit, offset: offset);

    return {"Tag": (result['data'] as List).map((e) => TagModel.fromJson(e)).toList(), "total": result[TOTAL]};
  }
}
