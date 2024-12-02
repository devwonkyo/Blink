import 'package:blink/core/theme/colors.dart';
import 'package:blink/features/follow/domain/repositories/follow_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blink/features/user/domain/repositories/auth_repository.dart';
import 'package:blink/features/video/data/repositories/video_repository_impl.dart';
import 'package:blink/features/profile/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:blink/features/profile/presentation/blocs/profile_bloc/profile_event.dart';
import 'package:blink/features/profile/presentation/blocs/profile_bloc/profile_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileBloc _profileBloc;
  final AuthRepository _authRepository = AuthRepository();
  final BlinkSharedPreference _sharedPreference = BlinkSharedPreference();
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
    _checkIfFollowing();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _initializeBloc();
      _checkIfFollowing();
    }
  }

  void _initializeBloc() {
    _profileBloc = ProfileBloc(
      authRepository: _authRepository,
      videoRepository: VideoRepositoryImpl(),
    )..add(LoadProfile(userId: widget.userId));
  }

  Future<void> _checkIfFollowing() async {
    final currentUserId = await _sharedPreference.getCurrentUserId();
    final isFollowed =
        await FollowRepository().isFollowing(currentUserId, widget.userId);
    setState(() {
      isFollowing = isFollowed;
    });
  }

  Future<void> _toggleFollow() async {
    final currentUserId = await _sharedPreference.getCurrentUserId();
    if (isFollowing) {
      await FollowRepository().unfollow(currentUserId, widget.userId);
    } else {
      await FollowRepository().follow(currentUserId, widget.userId);
    }
    setState(() {
      isFollowing = !isFollowing;
    });
    _profileBloc.add(LoadProfile(userId: widget.userId));
  }

  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("로그아웃"),
        content: const Text("정말 로그아웃 하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("아니요"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("예"),
          ),
        ],
      ),
    );

    if (result == true) {
      await _authRepository.signOut();
      await _sharedPreference.clearPreference();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _profileBloc,
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return Text(
                  state.user.name,
                  style: TextStyle(fontSize: 18.sp),
                );
              }
              return const Text("프로필");
            },
          ),
          centerTitle: true,
          actions: [
            FutureBuilder<String>(
              future: _sharedPreference.getCurrentUserId(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (snapshot.data == widget.userId) {
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        _showLogoutDialog();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text("로그아웃"),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              final user = state.user;
              final videos = state.videos ?? [];

              return FutureBuilder<String>(
                future: _sharedPreference.getCurrentUserId(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final isCurrentUser = snapshot.data == widget.userId;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // 프로필 이미지
                        CircleAvatar(
                          radius: 70.r,
                          child: CachedNetworkImage(
                            imageUrl: user.profileImageUrl?.isNotEmpty == true ? user.profileImageUrl! : "",
                            placeholder: (context, url) => CircularProgressIndicator(
                              strokeWidth: 2.w,
                            ),
                            errorWidget: (context, url, error) => CircleAvatar(
                              radius: 70.r,
                              backgroundImage: const AssetImage("assets/images/default_profile.png"),
                            ),
                            imageBuilder: (context, imageProvider) => CircleAvatar(
                              radius: 70.r,
                              backgroundImage: imageProvider,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // 사용자 username(nickname)
                        Text(
                          "@${user.nickname}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // 통계
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem(
                              user.followingList?.length.toString() ?? "0",
                              "팔로잉",
                              () {
                                GoRouter.of(context).push(
                                  '/follow_list',
                                  extra: {'type': 'following', 'userId': user.id},
                                );
                              },
                            ),
                            SizedBox(width: 20.w),
                            _buildStatItem(
                              user.followerList?.length.toString() ?? "0",
                              "팔로워",
                              () {
                                GoRouter.of(context).push(
                                  '/follow_list',
                                  extra: {'type': 'follower', 'userId': user.id},
                                );
                              },
                            ),
                            SizedBox(width: 20.w),
                            _buildStatItem(
                              videos
                                  .map((video) => video.likeList.length)
                                  .fold(0, (a, b) => a + b)
                                  .toString(),
                              "좋아요",
                              () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // 프로필 편집 또는 팔로우 버튼
                        isCurrentUser
                            ? ElevatedButton(
                                onPressed: () async {
                                  final updated = await GoRouter.of(context)
                                      .push('/profile_edit', extra: user);
                                  if (updated == true) {
                                    _profileBloc.add(LoadProfile(userId: widget.userId));
                                  }
                                },
                                child: const Text("프로필 편집"),
                              )
                            : ElevatedButton(
                                onPressed: _toggleFollow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing ? AppColors.primaryLightColor : AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  isFollowing ? '언팔로우' : '팔로우',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        SizedBox(height: 10.h),

                        // 소개 및 링크
                        if (user.introduction != null && user.introduction!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              user.introduction!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(height: 10.h),

                        if (user.linkList != null && user.linkList!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: GestureDetector(
                              onTap: () {
                                // 링크 클릭 동작
                              },
                              child: Text(
                                user.linkList!.first,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),

                        // 동영상 섹션
                        SizedBox(height: 20.h),
                        Divider(thickness: 1.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "동영상",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.filter_list, size: 20.sp),
                                onPressed: () {
                                  // 필터 버튼 동작
                                },
                              ),
                            ],
                          ),
                        ),

                        // 동영상 리스트
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                          ),
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final video = videos[index];
                            return _buildVideoItem(
                              video.thumbnailUrl ?? "assets/images/default_image.png",
                              "${video.views} 조회수",
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('프로필을 불러오는 중입니다'));
            }
          },
        ),
      ),
    );
  }

  // 통계 항목 빌드
  Widget _buildStatItem(String value, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.transparent,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 동영상 항목 빌드
  Widget _buildVideoItem(String imagePath, String views) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: imagePath,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          views,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
