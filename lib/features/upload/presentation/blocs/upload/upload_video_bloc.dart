import 'package:blink/features/upload/domain/repositories/upload_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'upload_video_event.dart';
part 'upload_video_state.dart';

class UploadVideoBloc extends Bloc<UploadVideoEvent, UploadVideoState> {
  final UploadRepository uploadRepository;

  UploadVideoBloc({required this.uploadRepository}) : super(UploadVideoInitial()) {
    on<InitializeVideo>(_onInitializeVideo);
    on<UploadVideo>(_onUploadVideo);
    on<SaveVideoAsDraft>(_onSaveVideoAsDraft);
  }


  Future<void> _onInitializeVideo(
      InitializeVideo event,
      Emitter<UploadVideoState> emit,
      ) async {
    try {
      emit(UploadVideoInitialLoading());

      print("upload 로딩중");
      // 썸네일 생성
      final _thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: event.videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path, // path_provider 패키지 필요
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );
      print("썸네일 path : $_thumbnailPath");

      if (_thumbnailPath != null) {
        print("upload 썸네일 성공");
        emit(UploadVideoInitialSuccess(thumbnailPath: _thumbnailPath));
      } else {
        print("upload 썸네일 실패");
        emit(UploadVideoInitialError(error: "썸네일 생성 실패"));
      }
    } catch (e) {
      print("upload 썸네일 실패 에러");
      emit(UploadVideoInitialError(error: e.toString()));
    }
  }


  Future<void> _onUploadVideo(
      UploadVideo event,
      Emitter<UploadVideoState> emit,
      ) async {
    try {
      emit(UploadVideoLoading());
      final result = await uploadRepository.uploadVideo(event.videoPath, event.thumbnailImage, event.videoTitle, event.description);

      if(result.isSuccess){
        emit(UploadVideoSuccess(message: result.message ?? ""));
      }else{
        print("업로드 실패");
        emit(UploadVideoError(error: '업로드 실패'));
      }
    } catch (e) {
      emit(UploadVideoError(error: 'error'));
    }
  }

  Future<void> _onSaveVideoAsDraft(
      SaveVideoAsDraft event,
      Emitter<UploadVideoState> emit,
      ) async {
    // TODO: 임시저장 로직 구현
  }
}