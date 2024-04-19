// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/CommentModel.dart';
import 'package:news/data/repositories/NewsComment/SetComment/setComRepository.dart';
import 'package:news/utils/strings.dart';

abstract class SetCommentState {}

class SetCommentInitial extends SetCommentState {}

class SetCommentFetchInProgress extends SetCommentState {}

class SetCommentFetchSuccess extends SetCommentState {
  List<CommentModel> setComment;
  int total;

  SetCommentFetchSuccess({required this.setComment, required this.total});
}

class SetCommentFetchFailure extends SetCommentState {
  final String errorMessage;

  SetCommentFetchFailure(this.errorMessage);
}

class SetCommentCubit extends Cubit<SetCommentState> {
  final SetCommentRepository _setCommentRepository;

  SetCommentCubit(this._setCommentRepository) : super(SetCommentInitial());

  void setComment({required String parentId, required String newsId, required String message}) async {
    emit(SetCommentFetchInProgress());
    try {
      final result = await _setCommentRepository.setComment(message: message, newsId: newsId, parentId: parentId);
      emit(SetCommentFetchSuccess(setComment: result['SetComment'], total: result[TOTAL]));
    } catch (e) {
      emit(SetCommentFetchFailure(e.toString()));
    }
  }
}
