import 'package:blink/features/video/data/models/video_model.dart';

abstract class VideoRepository {
  Future<List<VideoModel>> getVideosByUserId(String userId);
}
