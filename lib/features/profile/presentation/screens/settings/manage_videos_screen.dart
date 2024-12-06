import 'package:blink/core/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ManageVideosScreen extends StatelessWidget {
  final String userId;

  const ManageVideosScreen({Key? key, required this.userId}) : super(key: key);

  Future<void> _deleteVideo(BuildContext context, String videoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDarkGrey,
        title: Text(
          "삭제 확인",
          style: TextStyle(color: AppColors.textWhite),
        ),
        content: Text(
          "정말 이 동영상을 삭제하시겠습니까?",
          style: TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("아니요", style: TextStyle(color: AppColors.primaryLightColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("예", style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('videos').doc(videoId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "동영상이 삭제되었습니다.",
              style: TextStyle(color: AppColors.textWhite),
            ),
            backgroundColor: AppColors.backgroundDarkGrey,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "동영상 삭제 중 오류가 발생했습니다.",
              style: TextStyle(color: AppColors.textWhite),
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlackColor,
        title: Text(
          "내 동영상 관리",
          style: TextStyle(fontSize: 18.sp, color: AppColors.textWhite),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundBlackColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .where('uploader_id', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "올린 동영상이 없습니다.",
                style: TextStyle(color: AppColors.textGrey, fontSize: 16.sp),
              ),
            );
          }

          final videos = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final videoId = video.id;
              final videoTitle = video['title'] ?? "제목 없음";
              final videoDescription = video['description'] ?? "설명 없음";
              final videoCategory = video['category_id'] ?? "기타";
              final videoHashtags = (video['hash_tag_list'] as List<dynamic>?)
                      ?.map((e) => e as String)
                      .toList() ??
                  [];
              final videoThumbnail = video['thumbnail_url'] ?? "";
              final videoUrl = video['video_url'] ?? "";

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundBlackColor,
                  border: Border.all(color: AppColors.primaryDarkColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: videoThumbnail,
                        width: 80.w,
                        height: 60.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(
                          Icons.video_library,
                          size: 40.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              videoTitle,
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              videoDescription,
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14.sp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: AppColors.primaryColor),
                            onPressed: () {
                              context.push(
                                '/video-info-update',
                                extra: {
                                  'videoId': videoId,
                                  'videoPath': videoUrl,
                                  'thumbnailPath': videoThumbnail,
                                  'initialTitle': videoTitle,
                                  'initialDescription': videoDescription,
                                  'initialCategory': videoCategory,
                                  'initialHashtags': videoHashtags,
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: AppColors.errorRed),
                            onPressed: () {
                              _deleteVideo(context, videoId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
