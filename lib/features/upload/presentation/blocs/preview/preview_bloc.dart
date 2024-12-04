import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

part 'preview_event.dart';
part 'preview_state.dart';

class PreviewBloc extends Bloc<PreviewEvent, PreviewState> {
  VideoPlayerController? _controller;
  bool _isDisposed = false;

  PreviewBloc() : super(VideoPlayerInitial()) {
    on<InitializeVideo>(_onInitializeVideo);
    on<PlayVideo>(_onPlayVideo);
    on<PauseVideo>(_onPauseVideo);
    on<DisposeVideo>(_onDisposeVideo);
  }

  Future<void> _onInitializeVideo(
      InitializeVideo event,
      Emitter<PreviewState> emit,
      ) async {
    try {
      emit(VideoPlayerLoading());
      _controller = VideoPlayerController.file(File(event.videoPath));
      await _controller!.initialize();
      await _controller!.setLooping(true);

      emit(VideoPlayerReady(
        controller: _controller!,
        isPlaying: true,
        position: _controller!.value.position,
        duration: _controller!.value.duration,
      ));

      _controller!.play();
    } catch (e) {
      emit(VideoPlayerError(e.toString()));
    }
  }

  Future<void> _onPlayVideo(
      PlayVideo event,
      Emitter<PreviewState> emit,
      ) async {
    if (state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;
      emit(currentState.copyWith(
        isPlaying: true,
        position: _controller!.value.position,
      ));
      await _controller!.play();
    }
  }

  Future<void> _onPauseVideo(
      PauseVideo event,
      Emitter<PreviewState> emit,
      ) async {
    if (state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;
      emit(currentState.copyWith(
        isPlaying: false,
        position: _controller!.value.position,
      ));
      await _controller!.pause();
    }
  }

  Future<void> _onDisposeVideo(
      DisposeVideo event,
      Emitter<PreviewState> emit,
      ) async {
    if (!_isDisposed && _controller != null) {  // 체크 추가
      _isDisposed = true;
      await _controller!.dispose();
      _controller = null;
      emit(VideoPlayerInitial());
    }
  }

  @override
  Future<void> close() async {
    if (!_isDisposed && _controller != null) {  // 체크 추가
      _isDisposed = true;
      await _controller!.dispose();
      _controller = null;
    }
    return super.close();
  }
}
