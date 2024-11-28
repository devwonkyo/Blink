import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:blink/features/user/domain/entities/user_entity.dart';
import 'package:blink/features/video/data/models/video_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blink/features/user/domain/repositories/user_repository.dart';
import 'package:blink/features/video/domain/repositories/video_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;
  final VideoRepository videoRepository;

  ProfileBloc({
    required this.userRepository,
    required this.videoRepository,
  }) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final userModel = await userRepository.getUserById(event.userId);
        final videos = await videoRepository.getVideosByUserId(event.userId);
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
