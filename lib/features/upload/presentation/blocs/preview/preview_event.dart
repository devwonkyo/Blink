part of 'preview_bloc.dart';

abstract class PreviewEvent {}

class InitializeVideo extends PreviewEvent {
  final String videoPath;
  InitializeVideo(this.videoPath);
}

class PlayVideo extends PreviewEvent {}

class PauseVideo extends PreviewEvent {}

class DisposeVideo extends PreviewEvent {}