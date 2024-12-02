import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/repositories/video_repository.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository _videoRepository;

  VideoBloc({required VideoRepository videoRepository})
      : _videoRepository = videoRepository,
        super(VideoInitial()) {
    on<LoadVideos>(_onLoadVideos);
    on<ChangeVideo>(_onChangeVideo);
  }

  Future<void> _onLoadVideos(LoadVideos event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    try {
      final videos = await _videoRepository.getVideos();
      print('Loaded ${videos.length} videos');
      if (videos.isEmpty) {
        emit(VideoError(message: '비디오가 없습니다.'));
      } else {
        emit(VideoLoaded(
          videos: videos.map((model) => model.toEntity()).toList(),
          currentIndex: 0,
        ));
      }
    } catch (e, stackTrace) {
      print('Error in VideoBloc: $e');
      print('StackTrace: $stackTrace');
      emit(VideoError(message: e.toString()));
    }
  }

  void _onChangeVideo(ChangeVideo event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      _videoRepository.incrementViews(currentState.videos[event.index].id);
      emit(currentState.copyWith(currentIndex: event.index));
    }
  }
}
