// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/BreakingNewsModel.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/SectionById/sectionByIdRepository.dart';

abstract class SectionByIdState {}

class SectionByIdInitial extends SectionByIdState {}

class SectionByIdFetchInProgress extends SectionByIdState {}

class SectionByIdFetchSuccess extends SectionByIdState {
  final List<NewsModel> newsModel;
  final List<BreakingNewsModel> breakNewsModel;
  final int totalCount;
  final String type;

  SectionByIdFetchSuccess({required this.newsModel, required this.breakNewsModel, required this.totalCount, required this.type});
}

class SectionByIdFetchFailure extends SectionByIdState {
  final String errorMessage;

  SectionByIdFetchFailure(this.errorMessage);
}

class SectionByIdCubit extends Cubit<SectionByIdState> {
  final SectionByIdRepository _sectionByIdRepository;

  SectionByIdCubit(this._sectionByIdRepository) : super(SectionByIdInitial());

  void getSectionById({required String langId, required String sectionId, String? latitude, String? longitude}) async {
    try {
      emit(SectionByIdFetchInProgress());
      final result = await _sectionByIdRepository.getSectionById(langId: langId, sectionId: sectionId, latitude: latitude, longitude: longitude);

      emit(SectionByIdFetchSuccess(
          newsModel: (result[0].newsType == "news" || result[0].newsType == "user_choice")
              ? result[0].news!
              : result[0].videosType == "news"
                  ? result[0].videos!
                  : [],
          breakNewsModel: result[0].newsType == "breaking_news"
              ? result[0].breakNews!
              : result[0].videosType == "breaking_news"
                  ? result[0].breakVideos!
                  : [],
          totalCount: (result[0].newsType == "news" || result[0].newsType == "user_choice")
              ? result[0].newsTotal!
              : result[0].newsType == "breaking_news"
                  ? result[0].breakNewsTotal!
                  : result[0].videosTotal!,
          type: result[0].newsType!));
    } catch (e) {
      if (!isClosed) emit(SectionByIdFetchFailure(e.toString())); //isClosed checked to resolve Bad state issue of Bloc
    }
  }
}
