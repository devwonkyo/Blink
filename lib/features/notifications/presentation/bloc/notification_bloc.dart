import 'dart:async';

import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:blink/features/notifications/data/notification_model.dart';
import 'package:blink/features/notifications/domain/notification_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc(this.notificationRepository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
  }

  Future<void> _onLoadNotifications(
      LoadNotifications event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      final userId = await BlinkSharedPreference().getCurrentUserId();
      await emit.forEach<List<NotificationModel>>(
        notificationRepository.getNotificationStream(userId),
        onData: (notifications) {
          print('notification : $notifications');
          final followNotifications = notifications
              .where((notification) => notification.type == 'follow')
              .toList();

          final activeNotifications = notifications
              .where((notification) => notification.type == 'activity')
              .toList();

          final unreadFollowCount = followNotifications
              .where((notification) => !notification.isRead)
              .length;

          final unreadActivityCount = activeNotifications
              .where((notification) => !notification.isRead)
              .length;

          return NotificationLoaded(
            followNotifications: followNotifications,
            activeNotifications: activeNotifications,
            unreadFollowCount: unreadFollowCount,
            unreadActivityCount: unreadActivityCount,
          );
        },
        onError: (error, stackTrace) => NotificationError(error.toString()),
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
      MarkNotificationAsRead event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      await notificationRepository.markAsRead(event.notificationId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}