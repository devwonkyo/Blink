part of 'notification_bloc.dart';

// State
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> followNotifications;
  final List<NotificationModel> activeNotifications;

  const NotificationLoaded({
    required this.followNotifications,
    required this.activeNotifications,
  });

  @override
  List<Object?> get props => [followNotifications, activeNotifications];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}