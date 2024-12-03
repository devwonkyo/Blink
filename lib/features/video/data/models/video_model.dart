import 'package:blink/features/video/domain/entities/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  // 비디오 아이디
  final String id;

  // 비디오 올린 유저 아이디 (필수)
  final String uploaderId;

  // 유저 닉네임 (필수)
  final String userNicName;

  // 비디오 제목 (필수)
  final String title;

  // 비디오 설명 (필수)
  final String description;

  // 비디오 영상 링크 (필수)
  final String videoUrl;

  // 썸네일 사진 링크 (필수)
  final String thumbnailUrl;

  // 조회수
  final int views;

  // 카테고리 아이디
  final String categoryId;

  // 댓글 리스트 (댓글 ID 목록)
  final List<String> commentList;

  // 좋아요 리스트 (좋아요 ID 목록)
  final List<String> likeList;

  // 해시태그 리스트
  final List<String> hashTagList;

  // 생성일
  final DateTime? createdAt;

  // 수정일
  final DateTime? updatedAt;

  VideoModel({
    this.id = '', // 기본값 설정
    required this.uploaderId,
    required this.userNicName,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.views = 0, // 기본값 설정
    this.categoryId = '', // 기본값 설정
    this.commentList = const [],
    this.likeList = const [],
    this.hashTagList = const [],
    this.createdAt,
    this.updatedAt,
  });

  // JSON -> VideoModel
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.tryParse(value);
      }
      return null; // 유효하지 않은 경우 null 반환
    }

    return VideoModel(
      id: json['id'] ?? '',
      uploaderId: json['uploader_id'] ?? '',
      userNicName: json['user_nic_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      views: json['views'] ?? 0,
      categoryId: json['category_id'] ?? '',
      commentList: (json['comment_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      likeList: (json['like_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      hashTagList: (json['hash_tag_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
    );
  }

  // VideoModel -> JSON
  Map<String, dynamic> toJson() {
    Timestamp? toTimestamp(DateTime? dateTime) {
      return dateTime != null ? Timestamp.fromDate(dateTime) : null;
    }

    return {
      'id': id.isNotEmpty ? id : null,
      'uploader_id': uploaderId,
      'user_nic_name': userNicName,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'views': views,
      'category_id': categoryId.isNotEmpty ? categoryId : null,
      'comment_list': commentList.isNotEmpty ? commentList : [],
      'like_list': likeList.isNotEmpty ? likeList : [],
      'hash_tag_list': hashTagList.isNotEmpty ? hashTagList : [],
      'created_at': toTimestamp(createdAt),
      'updated_at': toTimestamp(updatedAt),
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