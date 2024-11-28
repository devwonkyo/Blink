part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadVideos extends VideoEvent {}

class ChangeVideo extends VideoEvent {
  final int index;

  ChangeVideo({required this.index});

  @override
  List<Object?> get props => [index];
}
