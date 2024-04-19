// ignore_for_file: file_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/data/models/NotificationModel.dart';
import 'package:news/data/repositories/UserNotification/userNotiRepository.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';

abstract class UserNotificationState {}

class UserNotificationInitial extends UserNotificationState {}

class UserNotificationFetchInProgress extends UserNotificationState {}

class UserNotificationFetchSuccess extends UserNotificationState {
  final List<NotificationModel> userUserNotification;
  final int totalUserNotificationCount;
  final bool hasMoreFetchError;
  final bool hasMore;

  UserNotificationFetchSuccess({required this.userUserNotification, required this.totalUserNotificationCount, required this.hasMoreFetchError, required this.hasMore});
}

class UserNotificationFetchFailure extends UserNotificationState {
  final String errorMessage;

  UserNotificationFetchFailure(this.errorMessage);
}

class UserNotificationCubit extends Cubit<UserNotificationState> {
  final UserNotificationRepository _userUserNotificationRepository;

  UserNotificationCubit(this._userUserNotificationRepository) : super(UserNotificationInitial());

  void getUserNotification() async {
    try {
      emit(UserNotificationFetchInProgress());
      final result = await _userUserNotificationRepository.getUserNotification(limit: limitOfAPIData.toString(), offset: "0");

      if (result[TOTAL] > 0) {
        emit(UserNotificationFetchSuccess(
            userUserNotification: result['UserNotification'],
            totalUserNotificationCount: result[TOTAL],
            hasMoreFetchError: false,
            hasMore: (result['UserNotification'] as List<NotificationModel>).length < result[TOTAL]));
      } else {
        emit(UserNotificationFetchFailure(ErrorMessageKeys.noDataMessage));
      }
    } catch (e) {
      emit(UserNotificationFetchFailure(e.toString()));
    }
  }

  bool hasMoreUserNotification() {
    return (state is UserNotificationFetchSuccess) ? (state as UserNotificationFetchSuccess).hasMore : false;
  }

  void getMoreUserNotification() async {
    if (state is UserNotificationFetchSuccess) {
      try {
        final result =
            await _userUserNotificationRepository.getUserNotification(limit: limitOfAPIData.toString(), offset: (state as UserNotificationFetchSuccess).userUserNotification.length.toString());
        List<NotificationModel> updatedResults = (state as UserNotificationFetchSuccess).userUserNotification;
        updatedResults.addAll(result['UserNotification'] as List<NotificationModel>);
        emit(UserNotificationFetchSuccess(userUserNotification: updatedResults, totalUserNotificationCount: result[TOTAL], hasMoreFetchError: false, hasMore: updatedResults.length < result[TOTAL]));
      } catch (e) {
        emit(UserNotificationFetchSuccess(
            userUserNotification: (state as UserNotificationFetchSuccess).userUserNotification,
            hasMoreFetchError: true,
            totalUserNotificationCount: (state as UserNotificationFetchSuccess).totalUserNotificationCount,
            hasMore: (state as UserNotificationFetchSuccess).hasMore));
      }
    }
  }

  void deleteUserNoti(String id) {
    if (state is UserNotificationFetchSuccess) {
      List<NotificationModel> userNotiList = (state as UserNotificationFetchSuccess).userUserNotification;
      var delItem = [];
      for (int i = 0; i < userNotiList.length; i++) {
        if (id.contains(",") && id.contains(userNotiList[i].id!)) {
          delItem.add(i);
        } else {
          if (userNotiList[i].id == id) {
            userNotiList.removeAt(i);
          }
        }
      }

      for (int j = 0; j < delItem.length; j++) {
        userNotiList.removeAt(delItem[j]);
      }

      emit(UserNotificationFetchSuccess(
          userUserNotification: userNotiList,
          hasMore: (state as UserNotificationFetchSuccess).hasMore,
          hasMoreFetchError: false,
          totalUserNotificationCount: (state as UserNotificationFetchSuccess).totalUserNotificationCount - (delItem.isEmpty ? 1 : delItem.length)));
    }
  }
}
