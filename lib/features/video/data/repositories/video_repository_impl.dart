import 'package:blink/features/video/data/models/video_model.dart';
import 'package:blink/features/video/domain/repositories/video_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoRepositoryImpl implements VideoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<VideoModel>> getVideosByUserId(String userId) async {
    final querySnapshot = await _firestore
        .collection('videos')
        .where('uploaderId', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => VideoModel.fromJson(doc.data()))
        .toList();
  }
}
