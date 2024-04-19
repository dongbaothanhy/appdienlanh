// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/TagModel.dart';
import 'package:news/data/repositories/Tag/tagRepository.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';

abstract class TagState {}

class TagInitial extends TagState {}

class TagFetchInProgress extends TagState {}

class TagFetchSuccess extends TagState {
  final List<TagModel> tag;
  final int total;
  final bool hasMoreFetchError;
  final bool hasMore;

  TagFetchSuccess({required this.tag, required this.total, required this.hasMoreFetchError, required this.hasMore});
}

class TagFetchFailure extends TagState {
  final String errorMessage;

  TagFetchFailure(this.errorMessage);
}

class TagCubit extends Cubit<TagState> {
  final TagRepository _tagRepository;

  TagCubit(this._tagRepository) : super(TagInitial());

  void getTags({required String langId}) async {
    try {
      emit(TagFetchInProgress());
      final result = await _tagRepository.getTag(langId: langId, limit: limitOfAPIData.toString(), offset: "0");

      emit(TagFetchSuccess(tag: result['Tag'], total: result[TOTAL], hasMoreFetchError: false, hasMore: ((result['Tag'] as List<TagModel>).length < result[TOTAL])));
    } catch (e) {
      emit(TagFetchFailure(e.toString()));
    }
  }

  void getMoreTags({required String langId}) async {
    if (state is TagFetchSuccess) {
      try {
        await _tagRepository.getTag(langId: langId, limit: limitOfAPIData.toString(), offset: (state as TagFetchSuccess).tag.length.toString()).then((value) {
          List<TagModel> updatedResults = (state as TagFetchSuccess).tag;
          updatedResults.addAll(value['Tag']);
          emit(TagFetchSuccess(tag: updatedResults, total: value[TOTAL], hasMoreFetchError: false, hasMore: (updatedResults.length < value[TOTAL])));
        });
      } catch (e) {
        emit(TagFetchSuccess(tag: (state as TagFetchSuccess).tag, total: (state as TagFetchSuccess).total, hasMoreFetchError: true, hasMore: (state as TagFetchSuccess).hasMore));
      }
    }
  }

  bool hasMoreTags() {
    return (state is TagFetchSuccess) ? (state as TagFetchSuccess).hasMore : false;
  }
}
