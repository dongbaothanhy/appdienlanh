// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/Bookmark/bookmarkRepository.dart';
import 'package:news/utils/api.dart';

abstract class UpdateBookmarkStatusState {}

class UpdateBookmarkStatusInitial extends UpdateBookmarkStatusState {}

class UpdateBookmarkStatusInProgress extends UpdateBookmarkStatusState {}

class UpdateBookmarkStatusSuccess extends UpdateBookmarkStatusState {
  final NewsModel news;
  final bool wasBookmarkNewsProcess; //to check that process of Bookmark done or not
  UpdateBookmarkStatusSuccess(this.news, this.wasBookmarkNewsProcess);
}

class UpdateBookmarkStatusFailure extends UpdateBookmarkStatusState {
  final String errorMessage;

  UpdateBookmarkStatusFailure(this.errorMessage);
}

class UpdateBookmarkStatusCubit extends Cubit<UpdateBookmarkStatusState> {
  final BookmarkRepository bookmarkRepository;

  UpdateBookmarkStatusCubit(this.bookmarkRepository) : super(UpdateBookmarkStatusInitial());

  void setBookmarkNews({required NewsModel news, required String status}) {
    emit(UpdateBookmarkStatusInProgress());
    bookmarkRepository.setBookmark(newsId: (news.newsId != null) ? news.newsId! : news.id!, status: status).then((value) {
      emit(UpdateBookmarkStatusSuccess(news, status == "1" ? true : false));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(UpdateBookmarkStatusFailure(apiMessageAndCodeException.errorMessage.toString()));
    });
  }
}
