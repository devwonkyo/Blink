part of 'share_bloc.dart';

abstract class ShareEvent extends Equatable {
  const ShareEvent();

  @override
  List<Object?> get props => [];
}

class CreateShareLink extends ShareEvent {
  final String videoId;

  const CreateShareLink(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class HandleInitialDynamicLink extends ShareEvent {}

class HandleDynamicLink extends ShareEvent {}
