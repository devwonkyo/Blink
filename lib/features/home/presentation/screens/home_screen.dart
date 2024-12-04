import 'package:blink/features/comment/presentation/widgets/comment_bottom_sheet.dart';
import 'package:blink/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:blink/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blink/features/video/presentation/blocs/video/video_bloc.dart';
import 'package:blink/features/video/presentation/widgets/video_player_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:blink/features/video/domain/repositories/video_repository.dart';
import 'package:blink/features/like/domain/repositories/like_repository.dart';
import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:blink/features/comment/domain/repositories/comment_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final Map<int, GlobalKey<VideoPlayerWidgetState>> videoKeys = {};
  bool wasPlaying = true;
  VideoBloc? videoBloc;
  late BlinkSharedPreference _sharedPreference;
  bool _isFollowingMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    videoBloc = VideoBloc(videoRepository: sl<VideoRepository>())
      ..add(LoadVideos());
    _sharedPreference = BlinkSharedPreference();
  }

  @override
  void dispose() {
    for (var key in videoKeys.values) {
      key.currentState?.pause();
    }
    WidgetsBinding.instance.removeObserver(this);
    videoBloc?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      for (var key in videoKeys.values) {
        key.currentState?.pause();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = GoRouter.of(context).routerDelegate.currentConfiguration.last;
    final currentLocation = route.matchedLocation;

    if (currentLocation == '/main' &&
        context.read<NavigationBloc>().state.selectedIndex == 0) {
      resumeVideoIfNeeded();
    } else {
      pauseAllVideos();
    }
  }

  @override
  void deactivate() {
    if (videoBloc != null) {
      final currentState = videoBloc!.state;
      if (currentState is VideoLoaded) {
        final currentKey = getVideoKey(currentState.currentIndex);
        wasPlaying = currentKey.currentState?.isPlaying ?? false;
        currentKey.currentState?.pause();
      }
    }
    super.deactivate();
  }

  void savePlayingState() {
    if (videoBloc != null) {
      final currentState = videoBloc!.state;
      if (currentState is VideoLoaded) {
        final currentKey = getVideoKey(currentState.currentIndex);
        wasPlaying = currentKey.currentState?.isPlaying ?? false;
      }
    }
  }

  void pauseAllVideos() {
    for (var key in videoKeys.values) {
      key.currentState?.pause();
    }
  }

  void resumeVideoIfNeeded() {
    if (wasPlaying && videoBloc != null) {
      final currentState = videoBloc!.state;
      if (currentState is VideoLoaded) {
        final currentKey = getVideoKey(currentState.currentIndex);
        currentKey.currentState?.resume();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        videoBloc = VideoBloc(videoRepository: sl<VideoRepository>())
          ..add(LoadVideos());
        return videoBloc!;
      },
      child: BlocListener<NavigationBloc, NavigationState>(
        listener: (context, state) {
          if (state.selectedIndex != 0) {
            wasPlaying = videoKeys.values
                .any((key) => key.currentState?.isPlaying ?? false);
            for (var key in videoKeys.values) {
              key.currentState?.pause();
            }
          } else {
            if (wasPlaying) {
              final currentState = videoBloc?.state;
              if (currentState is VideoLoaded) {
                final currentKey = getVideoKey(currentState.currentIndex);
                currentKey.currentState?.resume();
              }
            }
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            title: SizedBox(
              width: 150.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFollowingMode = true;
                      });
                      videoBloc?.add(LoadFollowingVideos());
                    },
                    child: Text(
                      '팔로잉',
                      style: TextStyle(
                        color: _isFollowingMode ? Colors.white : Colors.white60,
                        fontSize: 16.sp,
                        fontWeight: _isFollowingMode
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFollowingMode = false;
                      });
                      videoBloc?.add(LoadVideos());
                    },
                    child: Text(
                      '추천',
                      style: TextStyle(
                        color:
                            !_isFollowingMode ? Colors.white : Colors.white60,
                        fontSize: 16.sp,
                        fontWeight: !_isFollowingMode
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: IconButton(
                  icon: Icon(
                    CupertinoIcons.search,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  onPressed: () async {
                    if (videoBloc != null) {
                      final currentState = videoBloc!.state;
                      if (currentState is VideoLoaded) {
                        final currentKey =
                            getVideoKey(currentState.currentIndex);
                        wasPlaying =
                            currentKey.currentState?.isPlaying ?? false;
                        currentKey.currentState?.pause();
                      }
                    }
                    await GoRouter.of(context).push('/search');
                    if (wasPlaying && mounted) {
                      final currentState = videoBloc?.state;
                      if (currentState is VideoLoaded) {
                        final currentKey =
                            getVideoKey(currentState.currentIndex);
                        currentKey.currentState?.resume();
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          body: BlocBuilder<VideoBloc, VideoState>(
            builder: (context, state) {
              if (state is VideoLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is VideoLoaded) {
                return PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: state.videos.length,
                  onPageChanged: (index) {
                    context.read<VideoBloc>().add(ChangeVideo(index: index));
                  },
                  itemBuilder: (context, index) {
                    final video = state.videos[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () {
                            getVideoKey(index).currentState?.togglePlayPause();
                          },
                          child: VideoPlayerWidget(
                            key: getVideoKey(index),
                            videoUrl: video.videoUrl,
                            isPlaying: index == state.currentIndex,
                          ),
                        ),
                        Positioned(
                          right: 16.w,
                          bottom: MediaQuery.of(context).size.height * 0.3,
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  getVideoKey(index).currentState?.pause();
                                  context.push('/profile/${video.uploaderId}');
                                },
                                icon: Material(
                                  color: Colors.transparent,
                                  elevation: 8,
                                  shadowColor: Colors.black.withOpacity(0.4),
                                  child: Icon(CupertinoIcons.person,
                                      color: Colors.white, size: 24.sp),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final currentUser =
                                          await _sharedPreference
                                              .getCurrentUserId();

                                      try {
                                        await LikeRepository().toggleLike(
                                          currentUser ?? '',
                                          video.id,
                                        );
                                        if (mounted) {
                                          setState(
                                              () {}); // FutureBuilder 리빌드 트리거
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    '좋아요 처리 중 오류가 발생했습니다: $e')),
                                          );
                                        }
                                      }
                                    },
                                    icon: Material(
                                      color: Colors.transparent,
                                      elevation: 8,
                                      shadowColor:
                                          Colors.black.withOpacity(0.4),
                                      child: FutureBuilder<bool>(
                                        future: _sharedPreference
                                            .getCurrentUserId()
                                            .then((userId) => LikeRepository()
                                                .hasUserLiked(
                                                    userId ?? '', video.id)),
                                        builder: (context, snapshot) {
                                          final bool isLiked =
                                              snapshot.data ?? false;
                                          return Icon(
                                            isLiked
                                                ? CupertinoIcons.heart_fill
                                                : CupertinoIcons.heart,
                                            color: isLiked
                                                ? Colors.red
                                                : Colors.white,
                                            size: 24.sp,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Material(
                                    color: Colors.transparent,
                                    elevation: 8,
                                    shadowColor: Colors.black.withOpacity(0.4),
                                    child: FutureBuilder<int>(
                                      future: LikeRepository()
                                          .getLikeCount(video.id),
                                      builder: (context, snapshot) {
                                        return Text(
                                          '${snapshot.data ?? 0}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final currentUser =
                                          await _sharedPreference
                                              .getCurrentUserId();

                                      if (mounted) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor:
                                              Colors.black.withOpacity(0.9),
                                          builder: (context) =>
                                              CommentBottomSheet(
                                            videoId: video.id,
                                          ),
                                        );
                                      }
                                    },
                                    icon: Material(
                                      color: Colors.transparent,
                                      elevation: 8,
                                      shadowColor:
                                          Colors.black.withOpacity(0.4),
                                      child: Icon(CupertinoIcons.chat_bubble,
                                          color: Colors.white, size: 24.sp),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Material(
                                    color: Colors.transparent,
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.2),
                                    child: FutureBuilder<int>(
                                      future: CommentRepository()
                                          .getCommentCount(video.id),
                                      builder: (context, snapshot) {
                                        return Text(
                                          '${snapshot.data ?? 0}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Material(
                                      color: Colors.transparent,
                                      elevation: 4,
                                      shadowColor:
                                          Colors.black.withOpacity(0.2),
                                      child: Icon(CupertinoIcons.paperplane,
                                          color: Colors.white, size: 24.sp),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Material(
                                    color: Colors.transparent,
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.2),
                                    child: Text(
                                      '${video.shares}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16.w,
                          right: 100.w,
                          bottom: 50.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Material(
                                color: Colors.transparent,
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.4),
                                child: Text(
                                  '@${video.userNickName}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Material(
                                color: Colors.transparent,
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.4),
                                child: Text(
                                  video.musicName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Material(
                                color: Colors.transparent,
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.4),
                                child: Text(
                                  video.caption,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Material(
                                color: Colors.transparent,
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Original Sound',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              }

              if (state is VideoError) {
                return Center(child: Text(state.message));
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  GlobalKey<VideoPlayerWidgetState> getVideoKey(int index) {
    return videoKeys.putIfAbsent(
        index, () => GlobalKey<VideoPlayerWidgetState>());
  }
}
