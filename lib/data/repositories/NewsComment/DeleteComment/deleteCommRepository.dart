// ignore_for_file: file_names

import 'package:news/data/repositories/NewsComment/DeleteComment/deleteCommDataSource.dart';

class DeleteCommRepository {
  static final DeleteCommRepository _deleteCommRepository = DeleteCommRepository._internal();
  late DeleteCommRemoteDataSource _deleteCommRemoteDataSource;

  factory DeleteCommRepository() {
    _deleteCommRepository._deleteCommRemoteDataSource = DeleteCommRemoteDataSource();
    return _deleteCommRepository;
  }

  DeleteCommRepository._internal();

  Future setDeleteComm({required String commId}) async {
    final result = await _deleteCommRemoteDataSource.deleteComm(commId: commId);
    return result;
  }
}
