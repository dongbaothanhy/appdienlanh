// ignore_for_file: file_names, non_constant_identifier_names

import 'package:news/data/models/NotificationModel.dart';
import 'package:news/utils/strings.dart';
import 'package:news/data/repositories/UserNotification/userNotiRemoteDataSource.dart';

class UserNotificationRepository {
  static final UserNotificationRepository _UserNotificationRepository = UserNotificationRepository._internal();

  late UserNotificationRemoteDataSource _UserNotificationRemoteDataSource;

  factory UserNotificationRepository() {
    _UserNotificationRepository._UserNotificationRemoteDataSource = UserNotificationRemoteDataSource();
    return _UserNotificationRepository;
  }

  UserNotificationRepository._internal();

  Future<Map<String, dynamic>> getUserNotification({required String offset, required String limit}) async {
    final result = await _UserNotificationRemoteDataSource.getUserNotifications(limit: limit, offset: offset);

    return {"total": result[TOTAL], "UserNotification": (result['data'] as List).map((e) => NotificationModel.fromJson(e)).toList()};
  }
}
