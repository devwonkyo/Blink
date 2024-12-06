import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/share_repository.dart';

part 'share_event.dart';
part 'share_state.dart';

class ShareBloc extends Bloc<ShareEvent, ShareState> {
  final ShareRepository _shareRepository;
  StreamSubscription? _dynamicLinkSubscription;

  ShareBloc({required ShareRepository shareRepository})
      : _shareRepository = shareRepository,
        super(ShareInitial()) {
    on<CreateShareLink>(_onCreateShareLink);
    on<HandleInitialDynamicLink>(_onHandleInitialDynamicLink);
    on<HandleDynamicLink>(_onHandleDynamicLink);
  }

  Future<void> _onCreateShareLink(
    CreateShareLink event,
    Emitter<ShareState> emit,
  ) async {
    emit(ShareLinkCreating());
    try {
      final link = await _shareRepository.createDynamicLink(event.videoId);
      if (link != null) {
        emit(ShareLinkCreated(link));
      } else {
        emit(const ShareLinkError('공유 링크 생성에 실패했습니다.'));
      }
    } catch (e) {
      emit(ShareLinkError(e.toString()));
    }
  }

  Future<void> _onHandleInitialDynamicLink(
    HandleInitialDynamicLink event,
    Emitter<ShareState> emit,
  ) async {
    try {
      final videoId = await _shareRepository.handleInitialDynamicLink();
      if (videoId != null) {
        emit(VideoIdReceived(videoId));
      }
    } catch (e) {
      emit(ShareLinkError(e.toString()));
    }
  }

  Future<void> _onHandleDynamicLink(
    HandleDynamicLink event,
    Emitter<ShareState> emit,
  ) async {
    _dynamicLinkSubscription?.cancel();
    _dynamicLinkSubscription =
        _shareRepository.handleDynamicLinkStream().listen((videoId) {
      if (videoId != null) {
        emit(VideoIdReceived(videoId));
      }
    });
  }

  @override
  Future<void> close() {
    _dynamicLinkSubscription?.cancel();
    return super.close();
  }
}
