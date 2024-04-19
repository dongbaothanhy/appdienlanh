// ignore_for_file: file_names

import 'package:news/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';

abstract class SlugCheckState {}

class SlugCheckInitial extends SlugCheckState {}

class SlugCheckFetchInProgress extends SlugCheckState {}

class SlugCheckFetchSuccess extends SlugCheckState {
  String message;
  SlugCheckFetchSuccess({required this.message});
}

class SlugCheckFetchFailure extends SlugCheckState {
  final String errorMessage;

  SlugCheckFetchFailure(this.errorMessage);
}

class SlugCheckCubit extends Cubit<SlugCheckState> {
  SlugCheckCubit() : super(SlugCheckInitial());

  Future<void> checkSlugAvailability({required String slug, required String langId}) async {
    try {
      final result = await Api.sendApiRequest(body: {SLUG: slug, LANGUAGE_ID: langId, LIMIT: limitOfAPIData, OFFSET: 0}, url: Api.slugCheckApi, isGet: true);
      if (result[ERROR] == true) {
        emit(SlugCheckFetchFailure(result[MESSAGE].toString()));
      } else {
        emit(SlugCheckFetchSuccess(message: result[MESSAGE]));
      }
    } catch (e) {
      emit(SlugCheckFetchFailure(e.toString()));
    }
  }
}
