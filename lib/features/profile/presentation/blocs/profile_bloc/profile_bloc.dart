import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:blink/features/user/domain/entities/user_entity.dart';
import 'package:blink/features/video/data/models/video_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blink/features/user/domain/repositories/auth_repository.dart';
import 'package:blink/features/video/domain/repositories/video_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;
  final VideoRepository videoRepository;

  ProfileBloc({
    required this.authRepository,
    required this.videoRepository,
  }) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final userModel = await authRepository.getUserDataWithUserId(event.userId);
        final videos = await videoRepository.getVideosByUserId(event.userId);

        if (userModel == null) {
          throw Exception("UserModel이 null입니다. 유효한 사용자 ID를 전달했는지 확인하세요.");
        }

        emit(ProfileLoaded(
          user: userModel.toEntity(),
          videos: videos,
        ));
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });
  }
}
