// ignore_for_file: file_names

import 'package:news/data/repositories/RelatedNews/relatedNewsDataSource.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/utils/strings.dart';

class RelatedNewsRepository {
  static final RelatedNewsRepository _relatedNewsRepository = RelatedNewsRepository._internal();

  late RelatedNewsRemoteDataSource _relatedNewsRemoteDataSource;

  factory RelatedNewsRepository() {
    _relatedNewsRepository._relatedNewsRemoteDataSource = RelatedNewsRemoteDataSource();
    return _relatedNewsRepository;
  }

  RelatedNewsRepository._internal();

  Future<Map<String, dynamic>> getRelatedNews({required String langId, required String offset, required String perPage, String? catId, String? subCatId, String? latitude, String? longitude}) async {
    final result = await _relatedNewsRemoteDataSource.getRelatedNews(langId: langId, catId: catId, subCatId: subCatId, latitude: latitude, longitude: longitude, offset: offset, perPage: perPage);

    return {"RelatedNews": (result['data'] as List).map((e) => NewsModel.fromJson(e)).toList(), "total": result[TOTAL]};
  }
}
