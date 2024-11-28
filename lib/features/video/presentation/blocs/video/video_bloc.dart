import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/video.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoBloc() : super(VideoInitial()) {
    on<LoadVideos>(_onLoadVideos);
    on<ChangeVideo>(_onChangeVideo);
  }

  void _onLoadVideos(LoadVideos event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    try {
      // 임시 테스트용 샘플 비디오 데이터
      final videos = [
        Video(
          id: '1',
          videoUrl:
              'https://firebasestorage.googleapis.com/v0/b/blink-app-8d6ca.firebasestorage.app/o/videos%2FIMG_3011.MOV?alt=media&token=7a55ff48-940b-4d88-b49f-0a8819cd5e82',
          thumbnailUrl: 'https://example.com/thumb1.jpg',
          caption: '나비 영상',
          musicName: '자연의 소리',
          userName: 'nature_lover',
          likes: 1000,
          comments: 100,
          shares: 50,
        ),
        Video(
          id: '2',
          videoUrl:
              'https://firebasestorage.googleapis.com/v0/b/blink-app-8d6ca.firebasestorage.app/o/IMG_3011.mp4?alt=media&token=95275209-6087-4083-94f2-18e2f9aea50e',
          thumbnailUrl: 'https://example.com/thumb2.jpg',
          caption: 'meow! meow! meow! .... \n#cat #kitty #meow',
          musicName: '체리필터 - 낭만고양이',
          userName: 'gamza_butler',
          likes: 2000,
          comments: 200,
          shares: 100,
        ),
      ];
      emit(VideoLoaded(videos: videos, currentIndex: 0));
    } catch (e) {
      emit(VideoError(message: e.toString()));
    }
  }

  void _onChangeVideo(ChangeVideo event, Emitter<VideoState> emit) {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      emit(currentState.copyWith(currentIndex: event.index));
    }
  }
}
