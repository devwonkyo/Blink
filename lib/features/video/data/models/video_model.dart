import 'package:blink/features/video/domain/entities/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  // 비디오 아이디
  final String id;

  // 비디오 올린 유저 아이디
  final String uploaderId;

  // 비디오 제목
  final String title;

  // 비디오 설명
  final String description;

  // 비디오 영상 링크 // 파이어 스토리지와 연결?
  final String videoUrl;

  // 썸네일 사진 링크 // 파이어 스토리지와 연결
  final String thumbnailUrl;

  // 조회수
  final int views;

  // 카테고리 아이디
  final String categoryId;

  // 댓글 리스트 (댓글 ID 목록)
  final List<String> commentList;

  // 좋아요 리스트 (좋아요 ID 목록)
  final List<String> likeList;

  // 생성일
  final DateTime createdAt;

  // 수정일
  final DateTime updatedAt;

  VideoModel({
    required this.id,
    required this.uploaderId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.views,
    required this.categoryId,
    this.commentList = const [],
    this.likeList = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON -> VideoModel
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
      throw Exception('Invalid datetime format');
    }

    return VideoModel(
      id: json['id'],
      uploaderId: json['uploader_id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
      thumbnailUrl: json['thumbnail_url'],
      views: json['views'],
      categoryId: json['category_id'],
      commentList: (json['comment_list'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      likeList: (json['like_list'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  // VideoModel -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uploader_id': uploaderId,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'views': views,
      'category_id': categoryId,
      'comment_list': commentList,
      'like_list': likeList,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // VideoModel 클래스 내부에 추가
  Video toEntity() {
    return Video(
      id: id,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      caption: description,
      musicName: title,
      userName: uploaderId,
      likes: likeList.length,
      comments: commentList.length,
      shares: views,
    );
  }
}
