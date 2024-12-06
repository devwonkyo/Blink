import 'package:blink/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
          String? followSubTitle;
          String? activeSubTitle;
          if (state is NotificationLoading) {
            followSubTitle = "데이터를 가져오는 중입니다...";
            activeSubTitle = "데이터를 가져오는 중입니다...";
          }

          if (state is NotificationError) {
            followSubTitle = "데이터를 가져오는데 실패했습니다.";
            activeSubTitle = "데이터를 가져오는데 실패했습니다.";
          }

          if (state is NotificationLoaded) {

            if (state.followNotifications.isEmpty) {
              followSubTitle = "팔로워의 메시지가 여기에 표시됩니다.";
            } else{
              followSubTitle = state.followNotifications[0].body;
            }

            if (state.activeNotifications.isEmpty) {
              activeSubTitle = "활동이 여기에 표시됩니다.";
            } else{
              activeSubTitle = state.activeNotifications[0].body;
            }
          }
          return ListView(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            children: [
              _buildNotificationTile(
                leadingIcon: Icons.group,
                title: '새 팔로워',
                subtitle: followSubTitle ?? "팔로워의 메시지가 여기에 표시됩니다." ,
                backgroundColor: Colors.blue,
              ),
              _buildNotificationTile(
                leadingIcon: Icons.notifications,
                title: '활동',
                subtitle: activeSubTitle ?? "활동이 여기에 표시됩니다.",
                backgroundColor: Colors.pink,
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
