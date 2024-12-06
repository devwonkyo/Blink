import 'package:blink/core/theme/colors.dart';
import 'package:blink/features/video/data/models/video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WatchHistoryScreen extends StatefulWidget {
  final String userId;

  const WatchHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  List<VideoModel> watchList = [];
  Map<String, String> uploaderNames = {}; // 업로더 ID와 이름 매핑
  bool isLoading = true; // 로딩 상태를 나타내는 변수

  @override
  void initState() {
    super.initState();
    _fetchWatchHistory();
  }

  Future<void> _fetchWatchHistory() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final watchListData = userDoc.data()?['watch_list'] as List<dynamic>? ?? [];

        final List<VideoModel> videos = [];
        for (String videoId in watchListData.cast<String>()) {
          final videoDoc = await FirebaseFirestore.instance
              .collection('videos')
              .doc(videoId)
              .get();

          if (videoDoc.exists) {
            final videoModel = VideoModel.fromJson(videoDoc.data()!);
            videos.add(videoModel);
          }
        }

        setState(() {
          watchList = videos;
        });

        _fetchUploaderNames();
      }
    } catch (e) {
      debugPrint("시청 기록 가져오기 실패: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUploaderNames() async {
    for (var video in watchList) {
      if (!uploaderNames.containsKey(video.uploaderId)) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(video.uploaderId)
              .get();
          if (userDoc.exists) {
            setState(() {
              uploaderNames[video.uploaderId] = userDoc['nickname'] ?? '알 수 없음';
            });
          }
        } catch (e) {
          debugPrint("업로더 이름 가져오기 실패: $e");
        }
      }
    }
  }

  void _deleteWatchItem(VideoModel video) async {
    try {
      setState(() {
        watchList.remove(video);
      });

      final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
      await userRef.update({
        'watch_list': watchList.map((video) => video.toJson()).toList(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "시청 기록에서 삭제했습니다.",
            style: TextStyle(color: AppColors.textWhite),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.backgroundDarkGrey,
        ),
      );
    } catch (e) {
      debugPrint("시청 기록 삭제 실패: $e");
    }
  }

  void _clearAllWatchHistory() async {
    try {
      setState(() {
        watchList.clear();
      });

      final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
      await userRef.update({'watch_list': []});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "전체 시청 기록이 삭제되었습니다.",
            style: TextStyle(color: AppColors.textWhite),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.backgroundDarkGrey,
        ),
      );
    } catch (e) {
      debugPrint("전체 시청 기록 삭제 실패: $e");
    }
  }

  Widget _buildWatchHistoryItem(VideoModel video) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryDarkColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: video.thumbnailUrl,
            width: 100.w,
            height: 70.h,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/default_image.png',
              width: 100.w,
              height: 70.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  uploaderNames[video.uploaderId] ?? '업로더 정보 없음',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  video.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textLightGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: AppColors.errorRed),
            onPressed: () => _deleteWatchItem(video),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlackColor,
        title: const Text("시청 기록"),
        actions: [
          PopupMenuButton<String>(
            color: AppColors.backgroundDarkGrey,
            onSelected: (value) {
              if (value == 'clear') {
                _clearAllWatchHistory();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Text(
                  "전체 삭제",
                  style: TextStyle(color: AppColors.textWhite),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundBlackColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : watchList.isEmpty
              ? Center(
                  child: Text(
                    "시청 기록이 없습니다.",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: watchList.length,
                  itemBuilder: (context, index) {
                    return _buildWatchHistoryItem(watchList[index]);
                  },
                ),
    );
  }
}
