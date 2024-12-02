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

      if (querySnapshot.docs.isEmpty) {
        print('No videos found');
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        print('Processing video: ${doc.id}');
        return VideoModel.fromJson(data);
      }).toList();
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

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return VideoModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching user videos: $e');
      throw Exception('사용자의 비디오를 불러오는데 실패했습니다.');
    }
  }
}
