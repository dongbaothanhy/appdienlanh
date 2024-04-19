// ignore_for_file: file_names

import 'package:news/data/models/NotificationModel.dart';
import 'package:news/utils/strings.dart';
import 'package:news/data/repositories/Notification/notiRemoteDataSource.dart';

class NotificationRepository {
  static final NotificationRepository _notificationRepository = NotificationRepository._internal();

  late NotificationRemoteDataSource _notificationRemoteDataSource;

  factory NotificationRepository() {
    _notificationRepository._notificationRemoteDataSource = NotificationRemoteDataSource();
    return _notificationRepository;
  }

  NotificationRepository._internal();

  Future<Map<String, dynamic>> getNotification({required String langId, required String offset, required String limit}) async {
    final result = await _notificationRemoteDataSource.getNotifications(limit: limit, offset: offset, langId: langId);

    return {"total": result[TOTAL], "Notification": (result['data'] as List).map((e) => NotificationModel.fromJson(e)).toList()};
  }
}
