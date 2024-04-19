// ignore_for_file: file_names
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/TagModel.dart';
import 'package:news/data/models/appLanguageModel.dart';
import 'package:news/data/models/locationCityModel.dart';

// Define the events for your bottom sheet Cubit
abstract class BottomSheetEvent {}

class UpdateBottomSheetContent extends BottomSheetEvent {
  final List<LocationCityModel> newData;
  final List<TagModel> newTagsData;
  final List<TagModel> newLanguagesData;

  UpdateBottomSheetContent(this.newData, this.newTagsData, this.newLanguagesData);
}

// Define the state for your bottom sheet Cubit
class BottomSheetState {
  final List<LocationCityModel> locationData;
  final List<TagModel> tagsData;
  final List<LanguageModel> languageData;

  BottomSheetState(this.locationData, this.tagsData, this.languageData);
}

// Define the Cubit itself
class BottomSheetCubit extends Cubit<BottomSheetState> {
  BottomSheetCubit() : super(BottomSheetState([], [], []));
  // Access the data field within the cubit

  List<LocationCityModel> currentLocationData = [];
  List<TagModel> currentTagData = [];
  List<LanguageModel> currentLanguageData = [];

  getAllLatestContent({required bool isTag, required bool isLocation, required bool isLanguage}) {
    if (!isLocation) currentLocationData = state.locationData;
    if (!isTag) currentTagData = state.tagsData;
    if (!isLanguage) currentLanguageData = state.languageData;
  }

  void updateLocationContent(List<LocationCityModel> newData) {
    getAllLatestContent(isTag: false, isLocation: true, isLanguage: false);
    emit(BottomSheetState(newData, currentTagData, currentLanguageData));
  }

  void updateTagsContent(List<TagModel> newTagsData) {
    getAllLatestContent(isTag: true, isLocation: false, isLanguage: false);
    emit(BottomSheetState(currentLocationData, newTagsData, currentLanguageData));
  }

  void updateLanguageContent(List<LanguageModel> newLanguagesData) {
    getAllLatestContent(isTag: false, isLocation: false, isLanguage: true);
    emit(BottomSheetState(currentLocationData, currentTagData, newLanguagesData));
  }
}
