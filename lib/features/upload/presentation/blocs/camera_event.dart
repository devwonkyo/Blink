part of 'camera_bloc.dart';

// camera_event.dart
abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCamera extends CameraEvent {}

class StartRecording extends CameraEvent {}

class StopRecording extends CameraEvent {}

class DisposeCamera extends CameraEvent {}
