import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blink/core/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HashtagVideosScreen extends StatelessWidget {
  final String hashtag;

  const HashtagVideosScreen({Key? key, required this.hashtag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "#$hashtag",
          style: TextStyle(fontSize: 18.sp, color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.backgroundBlackColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .where('hash_tag_list', arrayContains: hashtag)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final videoDocs = snapshot.data!.docs;

          if (videoDocs.isEmpty) {
            return Center(
              child: Text(
                "관련 비디오가 없습니다.",
                style: TextStyle(fontSize: 16.sp, color: AppColors.textGrey),
              ),
            );
          }

          return ListView.builder(
            itemCount: videoDocs.length,
            itemBuilder: (context, index) {
              final videoData = videoDocs[index].data() as Map<String, dynamic>;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryColor, width: 1.5.w),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ListTile(
                  leading: videoData['thumbnail_url'] != null &&
                        videoData['thumbnail_url']!.trim().isNotEmpty &&
                        Uri.tryParse(videoData['thumbnail_url']!)?.hasAbsolutePath == true
                    ? CachedNetworkImage(
                        imageUrl: videoData['thumbnail_url']!.trim(),
                        placeholder: (context, url) => Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDarkGrey,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/default_image.png',
                          width: 50.w,
                          height: 50.w,
                          fit: BoxFit.cover,
                        ),
                        imageBuilder: (context, imageProvider) => Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                      : Image.asset(
                          'assets/images/default_image.png',
                          width: 50.w,
                          height: 50.w,
                          fit: BoxFit.cover,
                        ),
                  title: Text(
                    videoData['title'] ?? '제목 없음',
                    style: TextStyle(color: AppColors.textWhite),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    videoData['description'] ?? '설명 없음',
                    style: TextStyle(color: AppColors.textGrey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
