import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:blink/core/utils/function_method.dart';
import 'package:blink/features/notifications/data/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../like/data/models/like_model.dart';

class LikeRepository {
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<void> toggleLike(String userId, String videoId, String uploadUserId) async {
    final likeRef = _firestore.collection('likes');
    final videoRef = _firestore.collection('videos');

    // 기존 좋아요 확인
    final existingLike = await likeRef
        .where('user_id', isEqualTo: userId)
        .where('video_id', isEqualTo: videoId)
        .get();

    if (existingLike.docs.isEmpty) {
      // 좋아요 추가
      final likeModel = LikeModel(
        id: _uuid.v4(),
        userId: userId,
        videoId: videoId,
        type: LikeStatus.like,
        createdAt: DateTime.now(),
      );

      await likeRef.doc(likeModel.id).set(likeModel.toJson());
      await videoRef.doc(videoId).update({
        'like_list': FieldValue.arrayUnion([userId])
      });

      //wowo
      final nickName = await BlinkSharedPreference().getNickname();
      final userProfileImageUrl = await BlinkSharedPreference().getUserProfileImageUrl();

      //알림 데이터베이스 등록
      final notificationsRef = FirebaseFirestore.instance.collection('notifications');

      final newNotificationRef = notificationsRef.doc();

      NotificationModel notificationModel = NotificationModel(id: newNotificationRef.id, type: "activity", destinationUserId: uploadUserId, body: "$nickName 님이 좋아요를 눌렀습니다!", notificationImageUrl: userProfileImageUrl);

      await newNotificationRef.set(notificationModel.toMap());

      //푸시 알림
      sendNotification(title: "알림", body: "$nickName 님이 좋아요를 눌렀습니다!", destinationUserId: uploadUserId);

    } else {
      // 좋아요 취소
      final likeDoc = existingLike.docs.first;
      await likeRef.doc(likeDoc.id).delete();
      await videoRef.doc(videoId).update({
        'like_list': FieldValue.arrayRemove([userId])
      });
    }
  }

  Future<bool> hasUserLiked(String userId, String videoId) async {
    if (userId.isEmpty) return false;

    try {
      final querySnapshot = await _firestore
          .collection('likes')
          .where('user_id', isEqualTo: userId)
          .where('video_id', isEqualTo: videoId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  // 좋아요 수를 가져오는 메서드 추가
  Future<int> getLikeCount(String videoId) async {
    try {
      final videoDoc = await _firestore.collection('videos').doc(videoId).get();
      final likeList = List<String>.from(videoDoc.data()?['like_list'] ?? []);
      return likeList.length;
    } catch (e) {
      print('Error getting like count: $e');
      return 0;
    }
  }
}
