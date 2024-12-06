part of 'share_bloc.dart';

abstract class ShareState extends Equatable {
  const ShareState();

  @override
  List<Object?> get props => [];
}

class ShareInitial extends ShareState {}

class ShareLinkCreating extends ShareState {}

class ShareLinkCreated extends ShareState {
  final String link;

  const ShareLinkCreated(this.link);

  @override
  List<Object?> get props => [link];
}

class ShareLinkError extends ShareState {
  final String message;

  const ShareLinkError(this.message);

  @override
  List<Object?> get props => [message];
}

class VideoIdReceived extends ShareState {
  final String videoId;

  const VideoIdReceived(this.videoId);

  @override
  List<Object?> get props => [videoId];
}
