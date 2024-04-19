// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/FeatureSectionModel.dart';
import 'package:news/data/repositories/FeatureSection/sectionRepository.dart';

abstract class SectionState {}

class SectionInitial extends SectionState {}

class SectionFetchInProgress extends SectionState {}

class SectionFetchSuccess extends SectionState {
  final List<FeatureSectionModel> section;

  SectionFetchSuccess({required this.section});
}

class SectionFetchFailure extends SectionState {
  final String errorMessage;

  SectionFetchFailure(this.errorMessage);
}

class SectionCubit extends Cubit<SectionState> {
  final SectionRepository _sectionRepository;

  SectionCubit(this._sectionRepository) : super(SectionInitial());

  void getSection({required String langId, String? latitude, String? longitude}) async {
    try {
      emit(SectionFetchInProgress());
      final result = await _sectionRepository.getSection(langId: langId, latitude: latitude, longitude: longitude);
      emit(SectionFetchSuccess(section: result['Section']));
    } catch (e) {
      emit(SectionFetchFailure(e.toString()));
    }
  }
}
