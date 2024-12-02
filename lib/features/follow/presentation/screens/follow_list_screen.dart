import 'package:blink/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blink/features/follow/data/models/follow_model.dart';
import 'package:blink/features/follow/domain/repositories/follow_repository.dart';
import 'package:blink/features/user/data/models/user_model.dart';
import 'package:blink/features/user/domain/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FollowListScreen extends StatefulWidget {
  final String type; // 'following' or 'follower'
  final String userId;

  const FollowListScreen({Key? key, required this.type, required this.userId})
      : super(key: key);

  @override
  _FollowListScreenState createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  late List<FollowModel> followList = [];
  late List<String> followingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowData();
  }

  Future<void> _loadFollowData() async {
    try {
      final fetchedFollowList =
          await FollowRepository().getFollowList(widget.userId, widget.type);
      final currentUser =
          await AuthRepository().getUserDataWithUserId(widget.userId);
      if (currentUser != null) {
        setState(() {
          followList = fetchedFollowList;
          followingList = currentUser.followingList ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow(String targetUserId) async {
    final currentUserId = widget.userId;
    if (followingList.contains(targetUserId)) {
      await FollowRepository().unfollow(currentUserId, targetUserId);
    } else {
      await FollowRepository().follow(currentUserId, targetUserId);
    }

    final currentUser = await AuthRepository().getUserDataWithUserId(widget.userId);
    setState(() {
      followingList = currentUser?.followingList ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 'following' ? '팔로잉' : '팔로워',
          style: TextStyle(color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.backgroundBlackColor,
        iconTheme: const IconThemeData(color: AppColors.iconWhite),
      ),
      body: Container(
        color: AppColors.backgroundBlackColor,
        child: ListView.builder(
          itemCount: followList.length,
          itemBuilder: (context, index) {
            final followModel = followList[index];
            final targetUserId = widget.type == 'following'
                ? followModel.followedId
                : followModel.followerId;

            return FutureBuilder<UserModel?>(
              future: AuthRepository().getUserDataWithUserId(targetUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('로딩 중...'),
                  );
                }

                if (!snapshot.hasData) {
                  return const ListTile(
                    title: Text('사용자 정보를 가져올 수 없습니다.'),
                  );
                }

                final user = snapshot.data!;
                final isFollowing = followingList.contains(targetUserId);

                return _buildFollowItem(
                  user,
                  followModel.createdAt,
                  context,
                  isFollowing,
                  () => _toggleFollow(targetUserId),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFollowItem(
    UserModel user,
    DateTime createdAt,
    BuildContext context,
    bool isFollowing,
    VoidCallback onToggleFollow,
  ) {
    final profileImageUrl = user.profileImageUrl ?? 'assets/images/default_profile.png';
    final nickname = user.nickname;
    final targetUserId = user.id;

    final formattedDate = DateFormat('yy/MM/dd a h시 m분', 'ko_KR').format(createdAt);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightGrey,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25.r,
          backgroundImage: profileImageUrl.startsWith('http')
              ? NetworkImage(profileImageUrl)
              : AssetImage(profileImageUrl) as ImageProvider,
        ),
        title: Text(
          '@$nickname',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textWhite,
          ),
        ),
        subtitle: Text(
          '팔로우한 날짜\n$formattedDate',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textGrey,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: onToggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isFollowing ? AppColors.primaryLightColor : AppColors.primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            isFollowing ? '언팔로우' : '팔로우',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textWhite),
          ),
        ),
        onTap: () {
          GoRouter.of(context).push('/profile/$targetUserId');
        },
      ),
    );
  }
}
