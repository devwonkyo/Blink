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

  @override
  Future<List<VideoModel>> getFollowingVideos(String userId) async {
    try {
      print('Fetching following videos for user: $userId'); // 사용자 ID 로그

      // 1. 먼저 사용자가 팔로우하는 유저 목록을 가져옵니다.
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('User document does not exist for ID: $userId');
        throw Exception('사용자를 찾을 수 없습니다.');
      }

      final userData = userDoc.data();
      print('User data: $userData'); // 전체 사용자 데이터 로그

      if (userData == null) {
        print('User data is null');
        throw Exception('사용자 데이터를 찾을 수 없습니다.');
      }

      // following 필드의 실제 데이터 타입을 확인
      print('Following field type: ${userData['following_list']?.runtimeType}');
      print('Following field value: ${userData['following_list']}');

      List<String> following = [];
      var followingData = userData['following_list'];

      if (followingData is List) {
        following = List<String>.from(followingData);
      } else if (followingData is Map) {
        following = followingData.keys.map((key) => key.toString()).toList();
      } else {
        following = [];
      }

      print('Processed following list: $following');

      if (following.isEmpty) {
        print('No following users found');
        return [];
      }

      // 2. 팔로우하는 유저들의 비디오를 가져옵니다.
      print('Fetching videos for following users: $following');

      final querySnapshot = await _firestore
          .collection('videos')
          .where('uploader_id', whereIn: following)
          .orderBy('created_at', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} videos from following users');

      final List<VideoModel> videos = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        print(
            'Processing video: ${data['id']} from user: ${data['uploader_id']}');

        // 사용자 정보 가져오기
        final uploaderDoc =
            await _firestore.collection('users').doc(data['uploader_id']).get();

        if (uploaderDoc.exists) {
          data['user_name'] = uploaderDoc.data()?['nickname'] ?? '';
          data['user_nickname'] = uploaderDoc.data()?['nickname'] ?? '';
          print('Added user info - nickname: ${data['user_nickname']}');
        }

        videos.add(VideoModel.fromJson(data));
      }

      print('Successfully processed ${videos.length} videos');
      return videos;
    } catch (e) {
      print('Error fetching following videos: $e');
      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');
        throw Exception('데이터베이스 오류: ${e.message}');
      }
      throw Exception('팔로잉한 유저의 비디오를 불러오는데 실패했습니다: $e');
    }
  }

  @override
  Future<List<VideoModel>> getRecommendedVideos(String? userId) async {
    try {
      // 1. 모든 비디오 가져오기
      final querySnapshot = await _firestore.collection('videos').get();

      final List<VideoModel> allVideos = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // 사용자 정보 가져오기
        final uploaderDoc =
            await _firestore.collection('users').doc(data['uploader_id']).get();

        if (uploaderDoc.exists) {
          data['user_name'] = uploaderDoc.data()?['nickname'] ?? '';
          data['user_nickname'] = uploaderDoc.data()?['nickname'] ?? '';
        }

        allVideos.add(VideoModel.fromJson(data));
      }

      // 2. 기본 점수 계산 (조회수, 좋아요, 댓글)
      final List<VideoModel> scoredVideos = allVideos.map((video) {
        final double baseScore = (video.views * 0.05) +
            (video.likeList.length * 0.7) +
            (video.commentList.length * 5.0);

        return video.copyWith(score: baseScore);
      }).toList();

      // 3. 비로그인 유저 처리
      if (userId == null || userId.isEmpty || userId == 'not defined user') {
        return scoredVideos..sort((a, b) => b.score.compareTo(a.score));
      }

      // 4. 로그인 유저 데이터 가져오기
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('사용자 문서를 찾을 수 없습니다.');
      }

      final userData = userDoc.data();

      // 시청 기록 가져오기
      final List<String> watchList = List<String>.from(userData?['watch_list'] ?? []);

      // 시청한 영상을 필터링하여 제거
      List<VideoModel> filteredVideos = scoredVideos.where((video) {
        return !watchList.contains(video.id);
      }).toList();

      // 시청한 영상 제외 후 영상이 없다면 과정을 생략
      if (filteredVideos.isEmpty) {
        filteredVideos = scoredVideos;
      }

      // 사용자 데이터 추출
      final likedUploaderIds = userData?['liked_uploader_ids'] ?? [];
      final likedCategoryIds = userData?['liked_category_ids'] ?? [];
      final frequentlyWatchedCategories = userData?['frequently_watched_categories'] ?? [];

      // 카테고리별 빈도 계산
      final categoryFrequency = <String, int>{};
      for (final category in frequentlyWatchedCategories) {
        categoryFrequency[category] = (categoryFrequency[category] ?? 0) + 1;
      }

      // 5. 개인화 점수 추가
      final personalizedVideos = filteredVideos.map((video) {
        double personalizedScore = video.score;

        // 직접 좋아요 누른 업로더의 영상에 추가 점수
        if (likedUploaderIds.contains(video.uploaderId)) {
          personalizedScore += 300; // 가중치 300
        }

        // 직접 좋아요 누른 카테고리의 영상에 추가 점수
        if (likedCategoryIds.contains(video.categoryId)) {
          personalizedScore += 2.0; // 가중치 2.0
        }

        // 본인이 많이 시청한 카테고리의 영상에 빈도를 기반으로 추가 점수
        if (video.categoryId is String) {
          final frequency = categoryFrequency[video.categoryId] ?? 0;
          personalizedScore += frequency * 0.5; // 카테고리 빈도에 비례한 점수 추가
        }

        // 최근 업로드된 영상에 추가 점수
        if (video.createdAt != null) {
          final durationSinceUpload = DateTime.now().difference(video.createdAt!);
          if (durationSinceUpload.inHours <= 24) {
            personalizedScore *= 1.2; // 24시간 이내
          } else if (durationSinceUpload.inDays <= 7) {
            personalizedScore *= 1.1; // 1주 이내
          } else {
            personalizedScore *= 0.9; // 1주 이상
          }
        }

        return video.copyWith(score: personalizedScore);
      }).toList();

      // 6. 점수 기반 정렬
      personalizedVideos.sort((a, b) => b.score.compareTo(a.score));

      return personalizedVideos;
    } catch (e) {
      throw Exception('추천 영상을 불러오는데 실패했습니다.');
    }
  }

  @override
  Future<void> addToWatchList(String userId, String videoId) async {
    try {
      if (userId.isEmpty) {
        print('비로그인 상태에서는 시청 목록을 업데이트하지 않습니다.');
        return;
      }

      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          print('사용자 문서를 찾을 수 없습니다. userId: $userId');
          return;
        }

        List<String> watchList =
            List<String>.from(userDoc.data()?['watch_list'] ?? []);

        // 이미 시청 목록에 있는 경우 추가하지 않음
        if (!watchList.contains(videoId)) {
          watchList.add(videoId);
          transaction.update(userRef, {'watch_list': watchList});

          // 조회수도 함께 증가
          final videoRef = _firestore.collection('videos').doc(videoId);
          transaction.update(videoRef, {
            'views': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      print('Error adding to watch list: $e');
      rethrow;
    }
  }

  @override
  Future<VideoModel?> getVideoById(String videoId) async {
    try {
      final videoDoc = await _firestore.collection('videos').doc(videoId).get();

      if (!videoDoc.exists) {
        return null;
      }

      final data = videoDoc.data()!;
      data['id'] = videoDoc.id;

      // 사용자 정보 가져오기
      final userDoc =
          await _firestore.collection('users').doc(data['uploader_id']).get();

      if (userDoc.exists) {
        data['user_name'] = userDoc.data()?['nickname'] ?? '';
        data['user_nickname'] = userDoc.data()?['nickname'] ?? '';
      }

      return VideoModel.fromJson(data);
    } catch (e) {
      print('Error fetching video by ID: $e');
      return null;
    }
  }

  @override
  Future<void> incrementShareCount(String videoId) async {
    try {
      final videoRef = _firestore.collection('videos').doc(videoId);
      await videoRef.update({
        'shares': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing share count: $e');
      throw Exception('Failed to increment share count');
    }
  }
}
