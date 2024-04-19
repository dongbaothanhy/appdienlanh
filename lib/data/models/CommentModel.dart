// ignore_for_file: unnecessary_null_comparison, file_names

import 'package:news/data/models/AuthModel.dart';
import 'package:news/utils/strings.dart';

class CommentModel {
  String? id, message, profile, date, name, status, like, dislike, totalLikes, totalDislikes, userId;
  List<ReplyModel>? replyComList;

  CommentModel({this.id, this.message, this.profile, this.date, this.name, this.replyComList, this.status, this.like, this.dislike, this.totalLikes, this.totalDislikes, this.userId});

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    var replyList = (json[REPLY] as List);
    List<ReplyModel> replyData = [];
    if (replyList == null || replyList.isEmpty) {
      replyList = [];
    } else {
      replyData = replyList.map((data) => ReplyModel.fromJson(data)).toList();
    }

    var userDetails = AuthModel.fromJson(json[USER]);

    return CommentModel(
        id: json[ID].toString(),
        message: json[MESSAGE],
        profile: userDetails.profile,
        name: userDetails.name,
        date: json[DATE],
        status: json[STATUS].toString(),
        replyComList: replyData,
        like: json[LIKE].toString(),
        dislike: json[DISLIKE].toString(),
        totalDislikes: json[TOTAL_DISLIKE].toString(),
        totalLikes: json[TOTAL_LIKE].toString(),
        userId: json[USER_ID].toString());
  }
}

class ReplyModel {
  String? id, message, profile, date, name, userId, parentId, newsId, status, like, dislike, totalLikes, totalDislikes;

  ReplyModel({this.id, this.message, this.profile, this.date, this.name, this.userId, this.parentId, this.status, this.newsId, this.like, this.dislike, this.totalLikes, this.totalDislikes});

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    var userDetails = AuthModel.fromJson(json[USER]);

    return ReplyModel(
        id: json[ID].toString(),
        message: json[MESSAGE],
        profile: userDetails.profile,
        name: userDetails.name,
        date: json[DATE],
        userId: json[USER_ID].toString(),
        parentId: json[PARENT_ID].toString(),
        newsId: json[NEWS_ID].toString(),
        status: json[STATUS].toString(),
        like: json[LIKE].toString(),
        dislike: json[DISLIKE].toString(),
        totalDislikes: json[TOTAL_DISLIKE].toString(),
        totalLikes: json[TOTAL_LIKE].toString());
  }
}
