import 'dart:io';

import 'package:blink/features/upload/domain/repositories/upload_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraController? _cameraController;
  UploadRepository uploadRepository = UploadRepository();

  CameraBloc() : super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<DisposeCamera>(_onDisposeCamera);
  }

  Future<void> _onInitializeCamera(
      InitializeCamera event,
      Emitter<CameraState> emit,
      ) async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      emit(CameraInitialized(_cameraController!));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  Future<void> _onStartRecording(
      StartRecording event,
      Emitter<CameraState> emit,
      ) async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.startVideoRecording();
      emit(CameraRecording(_cameraController!));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  Future<void> _onStopRecording(
      StopRecording event,
      Emitter<CameraState> emit,
      ) async {
    if (_cameraController == null) return;

    try {
      final XFile video = await _cameraController!.stopVideoRecording();
      uploadRepository.uploadVideo(video);
      emit(CameraInitialized(_cameraController!));
      print('Video saved at: ${video.path}');
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }


  Future<void> _onDisposeCamera(
      DisposeCamera event,
      Emitter<CameraState> emit,
      ) async {
    await _cameraController?.dispose();
    _cameraController = null;
    emit(CameraInitial());
  }

  @override
  Future<void> close() {
    _cameraController?.dispose();
    return super.close();
  }
}