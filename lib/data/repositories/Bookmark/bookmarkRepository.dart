// ignore_for_file: file_names

import 'package:news/data/models/NewsModel.dart';
import 'package:news/data/repositories/Bookmark/bookmarkRemoteDataSource.dart';
import 'package:news/utils/strings.dart';

class BookmarkRepository {
  static final BookmarkRepository _bookmarkRepository = BookmarkRepository._internal();
  late BookmarkRemoteDataSource _bookmarkRemoteDataSource;

  factory BookmarkRepository() {
    _bookmarkRepository._bookmarkRemoteDataSource = BookmarkRemoteDataSource();
    return _bookmarkRepository;
  }

  BookmarkRepository._internal();

  Future<Map<String, dynamic>> getBookmark({required String offset, required String limit, required String langId}) async {
    final result = await _bookmarkRemoteDataSource.getBookmark(perPage: limit, offset: offset, langId: langId);

    return {"total": result[TOTAL], "Bookmark": (result[DATA] as List).map((e) => NewsModel.fromJson(e)).toList()};
  }

  Future setBookmark({required String newsId, required String status}) async {
    final result = await _bookmarkRemoteDataSource.addBookmark(status: status, newsId: newsId);
    return result;
  }
}
