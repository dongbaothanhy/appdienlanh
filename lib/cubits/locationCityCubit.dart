// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/locationCityModel.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';

abstract class LocationCityState {}

class LocationCityInitial extends LocationCityState {}

class LocationCityFetchInProgress extends LocationCityState {}

class LocationCityFetchSuccess extends LocationCityState {
  final List<LocationCityModel> locationCity;
  final String totalLocations;
  final bool hasMoreFetchError;
  final bool hasMore;

  LocationCityFetchSuccess({required this.locationCity, required this.totalLocations, required this.hasMoreFetchError, required this.hasMore});
}

class LocationCityFetchFailure extends LocationCityState {
  final String errorMessage;

  LocationCityFetchFailure(this.errorMessage);
}

class LocationCityCubit extends Cubit<LocationCityState> {
  LocationCityCubit() : super(LocationCityInitial());

  void getLocationCity() async {
    try {
      final result = await Api.sendApiRequest(body: {LIMIT: limitOfAPIData, OFFSET: 0}, url: Api.getLocationCityApi, isGet: true);
      emit(LocationCityFetchSuccess(
          totalLocations: result[TOTAL].toString(),
          locationCity: (result['data'] as List).map((e) => LocationCityModel.fromJson(e)).toList(),
          hasMore: (result['data'] as List).map((e) => LocationCityModel.fromJson(e)).toList().length < result[TOTAL],
          hasMoreFetchError: false));
    } catch (e) {
      emit(LocationCityFetchFailure(e.toString()));
    }
  }

  void getMoreLocationCity() async {
    if (state is LocationCityFetchSuccess) {
      try {
        await Api.sendApiRequest(isGet: true, body: {LIMIT: limitOfAPIData, OFFSET: (state as LocationCityFetchSuccess).locationCity.length.toString()}, url: Api.getLocationCityApi).then((value) {
          List<LocationCityModel> updatedResults = (state as LocationCityFetchSuccess).locationCity;
          updatedResults.addAll((value['data'] as List).map((e) => LocationCityModel.fromJson(e)).toList());
          emit(LocationCityFetchSuccess(locationCity: updatedResults, totalLocations: value[TOTAL].toString(), hasMoreFetchError: false, hasMore: updatedResults.length < value[TOTAL]));
        });
      } catch (e) {
        emit(LocationCityFetchSuccess(
            locationCity: (state as LocationCityFetchSuccess).locationCity,
            totalLocations: (state as LocationCityFetchSuccess).totalLocations,
            hasMoreFetchError: true,
            hasMore: (state as LocationCityFetchSuccess).hasMore));
      }
    }
  }

  bool hasMoreLocation() {
    return (state is LocationCityFetchSuccess) ? (state as LocationCityFetchSuccess).hasMore : false;
  }

  List<LocationCityModel> getLocationCityList() {
    return (state is LocationCityFetchSuccess) ? (state as LocationCityFetchSuccess).locationCity : [];
  }

  int getLocationIndex({required String locationName}) {
    return (state is LocationCityFetchSuccess) ? (state as LocationCityFetchSuccess).locationCity.indexWhere((element) => element.locationName == locationName) : 0;
  }
}
