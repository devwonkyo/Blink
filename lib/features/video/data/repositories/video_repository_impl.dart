import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blink/features/video/data/models/video_model.dart';
import 'package:blink/features/video/domain/repositories/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<VideoModel>> getVideos() async {
    try {
      final querySnapshot = await _firestore
          .collection('videos')
          .orderBy('created_at', descending: true)
          .get();

      final List<VideoModel> videos = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // 사용자 정보 가져오기
        final userDoc =
            await _firestore.collection('users').doc(data['uploader_id']).get();

        if (userDoc.exists) {
          data['user_name'] = userDoc.data()?['nickname'] ?? '';
          data['user_nickname'] = userDoc.data()?['nickname'] ?? '';
        }

        videos.add(VideoModel.fromJson(data));
      }

      return videos;
    } catch (e) {
      print('Error fetching videos: $e');
      rethrow;
    }
  }

  @override
  Future<void> incrementViews(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('videos')
          .where('uploader_id', isEqualTo: userId)
          .get();

      final List<VideoModel> videos = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // 사용자 정보 가져오기
        final userDoc =
            await _firestore.collection('users').doc(data['uploader_id']).get();

        if (userDoc.exists) {
          data['user_name'] = userDoc.data()?['nickname'] ?? '';
          data['user_nickname'] = userDoc.data()?['nickname'] ?? '';
        }

        videos.add(VideoModel.fromJson(data));
      }

      return videos;
    } catch (e) {
      print('Error fetching user videos: $e');
      throw Exception('사용자의 비디오를 불러오는데 실패했습니다.');
    }
  }
}
