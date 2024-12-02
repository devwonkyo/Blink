part of 'preview_bloc.dart';

abstract class PreviewState {}

class VideoPlayerInitial extends PreviewState {}

class VideoPlayerLoading extends PreviewState {}

class VideoPlayerReady extends PreviewState {
  final VideoPlayerController controller;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  VideoPlayerReady({
    required this.controller,
    required this.isPlaying,
    required this.position,
    required this.duration,
  });

  VideoPlayerReady copyWith({
    VideoPlayerController? controller,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return VideoPlayerReady(
      controller: controller ?? this.controller,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class VideoPlayerError extends PreviewState {
  final String message;
  VideoPlayerError(this.message);
}