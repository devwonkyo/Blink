import 'package:blink/core/routes/app_router.dart';
import 'package:blink/features/notifications/data/notification_model.dart';
import 'package:blink/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String? followSubTitle;
  String? activeSubTitle;
  int unreadFollowCount = 0;
  int unreadActivityCount =  0;
  List<NotificationModel> followNotifications = [];
  List<NotificationModel> activityNotifications = [];
  @override
  void initState() {
    context.read<NotificationBloc>().add(LoadNotifications());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '알림',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            followSubTitle = "데이터를 가져오는 중입니다...";
            activeSubTitle = "데이터를 가져오는 중입니다...";
          }

          if (state is NotificationError) {
            print("notification error : ${state.message}");
            followSubTitle = "데이터를 가져오는데 실패했습니다.";
            activeSubTitle = "데이터를 가져오는데 실패했습니다.";
          }

          if (state is NotificationLoaded) {

            if (state.followNotifications.isEmpty) {
              followSubTitle = "팔로워의 메시지가 여기에 표시됩니다.";
            } else{
              followSubTitle = state.followNotifications[0].body;
              followNotifications = state.followNotifications;
              unreadFollowCount = state.unreadFollowCount;
            }

            if (state.activeNotifications.isEmpty) {
              activeSubTitle = "활동이 여기에 표시됩니다.";
            } else{
              activeSubTitle = state.activeNotifications[0].body;
              activityNotifications = state.activeNotifications;
              unreadActivityCount = state.unreadActivityCount;
            }
          }
          return ListView(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            children: [
              GestureDetector(
                onTap: (){
                  context.push("/notification_detail", extra: {
                    'notificationList': followNotifications,
                    'type': "follow",
                  });
                },
                child: _buildNotificationTile(
                  leadingIcon: Icons.group,
                  title: '새 팔로워',
                  subtitle: followSubTitle ?? "팔로워의 메시지가 여기에 표시됩니다." ,
                  backgroundColor: Colors.blue,
                  badgeCount: unreadFollowCount
                ),
              ),
              GestureDetector(
                onTap: (){
                  context.push("/notification_detail", extra: {
                    'notificationList': activityNotifications,
                    'type': "activity",
                  });
                },
                child: _buildNotificationTile(
                  leadingIcon: Icons.notifications,
                  title: '활동',
                  subtitle: activeSubTitle ?? "활동이 여기에 표시됩니다.",
                  backgroundColor: Colors.pink,
                    badgeCount: unreadActivityCount
                ),
              ),
              /*_buildSystemNotificationTile(
            title: '시스템 알림',
            subtitle: '계정 업데이트: 더 긴 동영상 업로드 · 11/27',
          ),*/
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData leadingIcon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    int? badgeCount,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        radius: 20.r,
        backgroundColor: backgroundColor,
        child: Icon(
          leadingIcon,
          color: Colors.white,
          size: 20.r,
        ),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (badgeCount != null && badgeCount > 0) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 24.r,
      ),
    );
  }

  Widget _buildSystemNotificationTile({
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        radius: 20.r,
        backgroundColor: Colors.black,
        child: Icon(
          Icons.folder,
          color: Colors.white,
          size: 20.r,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 24.r,
      ),
    );
  }
}
