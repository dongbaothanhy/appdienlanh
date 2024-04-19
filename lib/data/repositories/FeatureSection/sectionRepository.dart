// ignore_for_file: file_names

import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/repositories/FeatureSection/sectionRemoteDataSource.dart';

class SectionRepository {
  static final SectionRepository _sectionRepository = SectionRepository._internal();

  late SectionRemoteDataSource _sectionRemoteDataSource;

  factory SectionRepository() {
    _sectionRepository._sectionRemoteDataSource = SectionRemoteDataSource();
    return _sectionRepository;
  }

  SectionRepository._internal();

  Future<Map<String, dynamic>> getSection({required String langId, String? latitude, String? longitude}) async {
    final result = await _sectionRemoteDataSource.getSections(langId: langId, latitude: latitude, longitude: longitude);
    return {"Section": (result['data'] as List).map((e) => FeatureSectionModel.fromJson(e)).toList()};
  }
}
