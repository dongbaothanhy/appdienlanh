// ignore_for_file: file_names

import 'package:news/data/repositories/DeleteUserNotification/deleteUserNotiRemoteDataSource.dart';

class DeleteUserNotiRepository {
  static final DeleteUserNotiRepository _deleteUserNotiRepository = DeleteUserNotiRepository._internal();
  late DeleteUserNotiRemoteDataSource _deleteUserNotiRemoteDataSource;

  factory DeleteUserNotiRepository() {
    _deleteUserNotiRepository._deleteUserNotiRemoteDataSource = DeleteUserNotiRemoteDataSource();
    return _deleteUserNotiRepository;
  }

  DeleteUserNotiRepository._internal();

  Future deleteUserNotification({required String id}) async {
    final result = await _deleteUserNotiRemoteDataSource.deleteUserNotification(id: id);
    return result;
  }
}
