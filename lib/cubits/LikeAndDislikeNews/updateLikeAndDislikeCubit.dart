// ignore_for_file: file_names

import 'package:news/data/repositories/LikeAndDisLikeNews/LikeAndDisLikeNewsRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NewsModel.dart';
import 'package:news/utils/api.dart';

abstract class UpdateLikeAndDisLikeStatusState {}

class UpdateLikeAndDisLikeStatusInitial extends UpdateLikeAndDisLikeStatusState {}

class UpdateLikeAndDisLikeStatusInProgress extends UpdateLikeAndDisLikeStatusState {}

class UpdateLikeAndDisLikeStatusSuccess extends UpdateLikeAndDisLikeStatusState {
  final NewsModel news;
  final bool wasLikeAndDisLikeNewsProcess; //to check that process of favorite done or not
  UpdateLikeAndDisLikeStatusSuccess(this.news, this.wasLikeAndDisLikeNewsProcess);
}

class UpdateLikeAndDisLikeStatusFailure extends UpdateLikeAndDisLikeStatusState {
  final String errorMessage;

  UpdateLikeAndDisLikeStatusFailure(this.errorMessage);
}

class UpdateLikeAndDisLikeStatusCubit extends Cubit<UpdateLikeAndDisLikeStatusState> {
  final LikeAndDisLikeRepository likeAndDisLikeRepository;

  UpdateLikeAndDisLikeStatusCubit(this.likeAndDisLikeRepository) : super(UpdateLikeAndDisLikeStatusInitial());

  void setLikeAndDisLikeNews({required NewsModel news, required String status}) {
    emit(UpdateLikeAndDisLikeStatusInProgress());
    likeAndDisLikeRepository.setLikeAndDisLike(newsId: (news.newsId != null) ? news.newsId! : news.id!, status: status).then((value) {
      emit(UpdateLikeAndDisLikeStatusSuccess(news, status == "1" ? true : false));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(UpdateLikeAndDisLikeStatusFailure(apiMessageAndCodeException.errorMessage.toString()));
    });
  }
}
