// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/data/models/NotificationModel.dart';
import 'package:news/data/repositories/Notification/notificationRepository.dart';
import 'package:news/utils/ErrorMessageKeys.dart';
import 'package:news/utils/constant.dart';
import 'package:news/utils/strings.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationFetchInProgress extends NotificationState {}

class NotificationFetchSuccess extends NotificationState {
  final List<NotificationModel> notification;
  final int totalNotificationCount;
  final bool hasMoreFetchError;
  final bool hasMore;

  NotificationFetchSuccess({required this.notification, required this.totalNotificationCount, required this.hasMoreFetchError, required this.hasMore});
}

class NotificationFetchFailure extends NotificationState {
  final String errorMessage;

  NotificationFetchFailure(this.errorMessage);
}

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationCubit(this._notificationRepository) : super(NotificationInitial());

  void getNotification({required BuildContext context}) async {
    try {
      emit(NotificationFetchInProgress());
      final result = await _notificationRepository.getNotification(langId: context.read<AppLocalizationCubit>().state.id, limit: limitOfAPIData.toString(), offset: "0");
      (result[TOTAL] > 0)
          ? emit(NotificationFetchSuccess(
              notification: result['Notification'],
              totalNotificationCount: result[TOTAL],
              hasMoreFetchError: false,
              hasMore: (result['Notification'] as List<NotificationModel>).length < result[TOTAL]))
          : emit(NotificationFetchFailure(ErrorMessageKeys.noDataMessage));
    } catch (e) {
      emit(NotificationFetchFailure(e.toString()));
    }
  }

  bool hasMoreNotification() {
    return (state is NotificationFetchSuccess) ? (state as NotificationFetchSuccess).hasMore : false;
  }

  void getMoreNotification({required BuildContext context}) async {
    if (state is NotificationFetchSuccess) {
      try {
        final result = await _notificationRepository.getNotification(
            langId: context.read<AppLocalizationCubit>().state.id, limit: limitOfAPIData.toString(), offset: (state as NotificationFetchSuccess).notification.length.toString());
        List<NotificationModel> updatedResults = (state as NotificationFetchSuccess).notification;
        updatedResults.addAll(result['Notification'] as List<NotificationModel>);
        emit(NotificationFetchSuccess(notification: updatedResults, totalNotificationCount: result[TOTAL], hasMoreFetchError: false, hasMore: updatedResults.length < result[TOTAL]));
      } catch (e) {
        emit(NotificationFetchSuccess(
            notification: (state as NotificationFetchSuccess).notification,
            hasMoreFetchError: true,
            totalNotificationCount: (state as NotificationFetchSuccess).totalNotificationCount,
            hasMore: (state as NotificationFetchSuccess).hasMore));
      }
    }
  }
}
