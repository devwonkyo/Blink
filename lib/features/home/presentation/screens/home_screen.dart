import 'package:blink/core/theme/colors.dart';
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
import 'package:blink/features/share/presentation/blocs/share_bloc/share_bloc.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  final String? initialVideoId;

  const HomeScreen({super.key, this.initialVideoId});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final Map<int, GlobalKey<VideoPlayerWidgetState>> videoKeys = {};
  bool wasPlaying = true;
  VideoBloc? videoBloc;
  late BlinkSharedPreference _sharedPreference;
  String _currentTab = 'recommended'; // 'latest', 'following', 'recommended'
  final Map<String, int> _commentCounts = {}; // 비디오 ID를 키로 하는 댓글 수 맵
  final _commentRepository = CommentRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sharedPreference = BlinkSharedPreference();

    // VideoBloc 초기화
    videoBloc = VideoBloc(videoRepository: sl<VideoRepository>());

    // 화면이 완전히 빌드된 후에 비디오 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.initialVideoId != null) {
          print('HomeScreen: Loading shared video: ${widget.initialVideoId}');
          videoBloc?.add(LoadRecommendedVideosWithShared(
            sharedVideoId: widget.initialVideoId,
          ));
        } else {
          print('HomeScreen: Loading recommended videos');
          videoBloc?.add(LoadRecommendedVideos());
        }
      }
    });
  }

  @override
  void dispose() {
    // 비디오 키 정리 전에 블록 dispose
    if (videoBloc != null) {
      videoBloc!.close();
      videoBloc = null;
    }
    for (var key in videoKeys.values) {
      key.currentState?.pause();
    }
    videoKeys.clear();
    WidgetsBinding.instance.removeObserver(this);
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

  Future<void> _loadCommentCount(String videoId) async {
    final count = await _commentRepository.getCommentCount(videoId);
    if (mounted) {
      setState(() {
        _commentCounts[videoId] = count;
      });
    }
  }

  void _showCommentBottomSheet(String videoId, String uploaderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(
          videoId: videoId,
          onCommentUpdated: () {
            _loadCommentCount(videoId); // 댓글 수 업데이트
          },
          uploaderId: uploaderId),
    );
  }

  void _handleShare(String videoId) async {
    final shareBloc = context.read<ShareBloc>();
    shareBloc.add(CreateShareLink(videoId));

    try {
      // shares 카운트 증가
      await sl<VideoRepository>().incrementShareCount(videoId);

      // 현재 VideoBloc의 상태를 가져와서 해당 비디오의 shares 카운트 업데이트
      if (videoBloc?.state is VideoLoaded) {
        final state = videoBloc?.state as VideoLoaded;
        final updatedVideos = state.videos.map((video) {
          if (video.id == videoId) {
            return video.copyWith(shares: video.shares + 1);
          }
          return video;
        }).toList();

        // 업데이트된 비디오 목록으로 상태 업데이트
        videoBloc?.add(UpdateVideos(updatedVideos));
      }
    } catch (e) {
      print('Error updating share count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: videoBloc!,
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
        child: BlocListener<ShareBloc, ShareState>(
          listener: (context, state) {
            if (state is ShareLinkCreated) {
              Share.share(state.link, subject: '동영상 공유');
            } else if (state is ShareLinkError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
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
                          _currentTab = 'recommended';
                        });
                        videoBloc?.add(LoadRecommendedVideos());
                      },
                      child: Text(
                        '추천',
                        style: TextStyle(
                          color: _currentTab == 'recommended'
                              ? Colors.white
                              : Colors.white60,
                          fontSize: 16.sp,
                          fontWeight: _currentTab == 'recommended'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentTab = 'following';
                        });
                        videoBloc?.add(LoadFollowingVideos());
                      },
                      child: Text(
                        '팔로잉',
                        style: TextStyle(
                          color: _currentTab == 'following'
                              ? Colors.white
                              : Colors.white60,
                          fontSize: 16.sp,
                          fontWeight: _currentTab == 'following'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentTab = 'latest';
                        });
                        videoBloc?.add(LoadVideos());
                      },
                      child: Text(
                        '최신',
                        style: TextStyle(
                          color: _currentTab == 'latest'
                              ? Colors.white
                              : Colors.white60,
                          fontSize: 16.sp,
                          fontWeight: _currentTab == 'latest'
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
                  if (state.videos.isEmpty) {
                    return Center(
                      child: Text(
                        '최신 영상이 없습니다.',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 16.sp,
                        ),
                      ),
                    );
                  }
                  return PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: state.videos.length,
                    onPageChanged: (index) {
                      context.read<VideoBloc>().add(ChangeVideo(index: index));
                    },
                    itemBuilder: (context, index) {
                      final video = state.videos[index];
                      // 댓글 수 초기 로드
                      if (!_commentCounts.containsKey(video.id)) {
                        _loadCommentCount(video.id);
                      }

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            onTap: () {
                              getVideoKey(index)
                                  .currentState
                                  ?.togglePlayPause();
                            },
                            child: VideoPlayerWidget(
                              key: getVideoKey(index),
                              videoUrl: video.videoUrl,
                              isPlaying: index == state.currentIndex,
                              onVideoComplete: () async {
                                // 현재 사용자 ID 가져오기
                                final currentUserId =
                                    await _sharedPreference.getCurrentUserId();
                                if (currentUserId.isNotEmpty &&
                                    currentUserId != 'not defined user') {
                                  print('🎥 비디오 시청 완료: ${video.id}');
                                  // watch_list에 추가
                                  await sl<VideoRepository>()
                                      .addToWatchList(currentUserId, video.id);
                                }
                              },
                            ),
                          ),
                          Positioned(
                            right: 16.w,
                            bottom: MediaQuery.of(context).size.height * 0.3,
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final currentUser =
                                            await _sharedPreference
                                                .getCurrentUserId();

                                        if (currentUser.isEmpty ||
                                            currentUser == 'not defined user') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('로그인 후 이용 가능합니다.')),
                                          );
                                          return;
                                        }

                                        try {
                                          // 좋아요 추가/제거 시 카테고리 ID 전달
                                          await LikeRepository().toggleLike(
                                            currentUser,
                                            video.id,
                                            video.uploaderId,
                                            video.categoryId, // 비디오의 카테고리 ID 전달
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
                                      shadowColor:
                                          Colors.black.withOpacity(0.4),
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
                                      onPressed: () => _showCommentBottomSheet(
                                          video.id, video.uploaderId),
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
                                    Text(
                                      '${_commentCounts[video.id] ?? 0}', // FutureBuilder 대 상태 값 사용
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () => _handleShare(video.id),
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
                                      shadowColor:
                                          Colors.black.withOpacity(0.2),
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
                                GestureDetector(
                                  onTap: () {
                                    getVideoKey(index).currentState?.pause();
                                    context
                                        .push('/profile/${video.uploaderId}');
                                  },
                                  child: Material(
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
                                      fontSize: 15.sp,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
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
                  return Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/blink_logo.png',
                          width: 300.w,
                          height: 300.h,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              context.push('/login');
                            },
                            child: const Text('로그인 하기')),
                      ],
                    ),
                  ));
                }

                return const SizedBox();
              },
            ),
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
