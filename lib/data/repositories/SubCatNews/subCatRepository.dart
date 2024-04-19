// ignore_for_file: file_names
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/SubCatNews/subCatNewsRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class SubCatNewsRepository {
  static final SubCatNewsRepository _subCatNewsRepository = SubCatNewsRepository._internal();

  late SubCatNewsRemoteDataSource _subCatNewsRemoteDataSource;

  factory SubCatNewsRepository() {
    _subCatNewsRepository._subCatNewsRemoteDataSource = SubCatNewsRemoteDataSource();
    return _subCatNewsRepository;
  }

  SubCatNewsRepository._internal();

  Future<Map<String, dynamic>> getSubCatNews({required String offset, required String limit, String? catId, String? subCatId, String? latitude, String? longitude, required String langId}) async {
    final result = await _subCatNewsRemoteDataSource.getSubCatNews(limit: limit, offset: offset, langId: langId, subCatId: subCatId, catId: catId, latitude: latitude, longitude: longitude);

    return {"total": result[TOTAL], "SubCatNews": (result['data'] as List).map((e) => NewsModel.fromJson(e)).toList()};
  }
}
