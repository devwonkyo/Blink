import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blink/features/user/domain/repositories/auth_repository.dart';
import 'package:blink/features/video/data/repositories/video_repository_impl.dart';
import 'package:blink/features/profile/presentation/blocs/profile_bloc/profile_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc(
      authRepository: _authRepository,
      videoRepository: VideoRepositoryImpl(),
    )..add(LoadProfile(userId: widget.userId));
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
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
            PopupMenuButton<String>(
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
              final isCurrentUser = widget.userId == user.id;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // 프로필 이미지
                    CircleAvatar(
                      radius: 50.r,
                      backgroundImage: user.profileImageUrl != null &&
                              user.profileImageUrl!.isNotEmpty
                          ? NetworkImage(user.profileImageUrl!) as ImageProvider
                          : const AssetImage("assets/images/default_profile.png"),
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

                    // 통계 (팔로잉, 팔로워, 좋아요)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatItem(
                          user.followingList?.length.toString() ?? "0",
                          "팔로잉",
                        ),
                        SizedBox(width: 20.w),
                        _buildStatItem(
                          user.followerList?.length.toString() ?? "0",
                          "팔로워",
                        ),
                        SizedBox(width: 20.w),
                        _buildStatItem(
                          videos
                              .where((video) => video.uploaderId == user.id)
                              .map((video) => video.likeList.length)
                              .fold(0, (a, b) => a + b)
                              .toString(),
                          "좋아요",
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

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
                            onPressed: () {
                              // 팔로우 버튼 동작
                            },
                            child: const Text("팔로우"),
                          ),

                    // 소개 및 링크
                    if (user.introduction != null &&
                        user.introduction!.isNotEmpty)
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
                          video.thumbnailUrl ??
                              "assets/images/default_image.png",
                          "${video.views} 조회수",
                        );
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('오류가 발생했습니다.'));
            }
          },
        ),
      ),
    );
  }

  // 통계 항목 빌드
  Widget _buildStatItem(String value, String label) {
    return Column(
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
              image: DecorationImage(
                image: imagePath == 'assets/images/default_image.png' ? AssetImage(imagePath) : NetworkImage(imagePath),
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
