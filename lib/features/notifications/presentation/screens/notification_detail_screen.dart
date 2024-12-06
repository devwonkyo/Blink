import 'package:blink/features/notifications/data/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationDetailScreen extends StatefulWidget {
  final List<NotificationModel> notificationList;
  final String type;

  const NotificationDetailScreen({super.key, required this.notificationList, required this.type});

  @override
  State<NotificationDetailScreen> createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  String? title;
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    if(widget.type == "follow"){
      title = "새 팔로워";
    }else{
      title = "활동";
    }
    _notifications = List.from(widget.notificationList);
  }

  Future<void> _markAsRead(String notificationId) async {
    // 로컬 상태 업데이트
    setState(() {
      _notifications = _notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
    });

    // 파이어스토어 업데이트
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Failed to update Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title ?? "",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: widget.notificationList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        itemCount: _notifications.length,  // 여기 변경
        itemBuilder: (context, index) {
          final notification = _notifications[index];  // 여기 변경
          return _buildActivityItem(notification);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
      if(widget.type == "follow"){
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 60.r,
                color: Colors.grey,
              ),
              SizedBox(height: 16.h),
              Text(
                '새 팔로워',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '다른 사용자가 나를 팔로우하면 여기에 해당 사용자가 표시됩니다',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }else{
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active_rounded,
                size: 60.r,
                color: Colors.grey,
              ),
              SizedBox(height: 16.h),
              Text(
                '활동 기록 없음',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '사용자의 활동기록이 추가되면 표시됩니다.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
  }

  Widget _buildActivityItem(NotificationModel notification) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead && notification.id != null) {
          _markAsRead(notification.id!);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundImage: notification.notificationImageUrl != null
                  ? NetworkImage(notification.notificationImageUrl!)
                  : null,
              child: notification.notificationImageUrl == ""
                  ? Icon(Icons.person_outline, size: 30.r)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: ' ${notification.body}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
