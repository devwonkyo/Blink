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
              'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
          thumbnailUrl:
              'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.webp',
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
              'https://firebasestorage.googleapis.com/v0/b/blink-app-8d6ca.firebasestorage.app/o/videos%2FIMG_3011.mp4?alt=media&token=c5580bdf-8a3e-4bb7-a445-1788d7d205dd',
          thumbnailUrl: 'https://example.com/thumb2.jpg',
          caption: 'meow! meow! meow! .... \n#cat #kitty #meow',
          musicName: '체리필터 - 낭만고양이',
          userName: 'gamza_butler',
          likes: 2000,
          comments: 200,
          shares: 100,
        ),
        Video(
          id: '3',
          videoUrl:
              'https://firebasestorage.googleapis.com/v0/b/blink-app-8d6ca.firebasestorage.app/o/videos%2F%EC%B2%B4%EC%9D%B8%EB%93%9C%20%ED%88%AC%EA%B2%8C%EB%8D%94%20%EA%B2%9C%EC%8B%9D%EA%B0%80.mp4?alt=media&token=88602350-0da4-4ca7-a978-8f6eb6aa4043',
          thumbnailUrl: 'https://example.com/thumb2.jpg',
          caption: '체인드 투게더',
          musicName: 'Original Soundtrack',
          userName: 'abeul25',
          likes: 2000,
          comments: 200,
          shares: 100,
        ),
        Video(
          id: '4',
          videoUrl:
              'https://firebasestorage.googleapis.com/v0/b/blink-app-8d6ca.firebasestorage.app/o/videos%2F%EA%B2%9C%EC%8B%9D%EA%B0%80%20%EC%96%BC%EC%B9%98%ED%99%80.mp4?alt=media&token=a06c5a78-5a53-4b76-8c32-81e21f10cf24',
          thumbnailUrl: 'https://example.com/thumb2.jpg',
          caption: '체인드 투게더',
          musicName: 'Original Soundtrack',
          userName: 'abeul25',
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
