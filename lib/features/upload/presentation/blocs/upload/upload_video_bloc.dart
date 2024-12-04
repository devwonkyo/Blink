import 'package:blink/features/upload/domain/repositories/upload_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';

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
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = '${tempDir.path}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // FFmpeg 명령어로 첫 프레임 추출
      final session = await FFmpegKit.execute(
          '-i "${event.videoPath}" -vframes 1 -an -s 1024x768 -ss 0 "$thumbnailPath"'
      );

      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        emit(UploadVideoInitialSuccess(thumbnailPath: thumbnailPath));
      } else {
        emit(UploadVideoInitialError(error: "error"));
        print('Error generating thumbnail: ${await session.getLogsAsString()}');
      }
    } catch (e) {
      emit(UploadVideoInitialError(error: "error"));
      print('Error: $e');
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