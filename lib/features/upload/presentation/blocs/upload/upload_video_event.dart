part of 'upload_video_bloc.dart';

abstract class UploadVideoEvent extends Equatable {
  const UploadVideoEvent();

  @override
  List<Object?> get props => [];
}

class UploadVideo extends UploadVideoEvent {
  final String videoPath;
  final String description;
  final String thumbnailImage;
  final String videoTitle;

  const UploadVideo({
    required this.videoPath,
    required this.description,
    required this.thumbnailImage,
    required this.videoTitle,
  });

  @override
  List<Object?> get props => [videoPath, description, thumbnailImage, videoTitle];
}

class SaveVideoAsDraft extends UploadVideoEvent {
  final String videoPath;
  final String description;

  const SaveVideoAsDraft({
    required this.videoPath,
    required this.description,
  });

  @override
  List<Object?> get props => [videoPath, description];
}

class InitializeVideo extends UploadVideoEvent {
  final String videoPath;

  const InitializeVideo({required this.videoPath});

  @override
  List<Object?> get props => [videoPath];
}