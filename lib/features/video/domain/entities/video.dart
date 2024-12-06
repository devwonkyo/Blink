class Video {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final String musicName;
  final String userName;
  final String userNickName;
  final String uploaderId;
  final int likes;
  final String categoryId;
  final int comments;
  final int shares;
  final double score;

  Video({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    required this.musicName,
    required this.userName,
    required this.userNickName,
    required this.uploaderId,
    required this.likes,
    required this.categoryId,
    required this.comments,
    required this.shares,
    required this.score,
  });

  Video copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    String? musicName,
    String? userName,
    String? userNickName,
    String? uploaderId,
    String? categoryId,
    int? likes,
    int? shares,
    int? comments,
    double? score,
  }) {
    return Video(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      musicName: musicName ?? this.musicName,
      userName: userName ?? this.userName,
      userNickName: userNickName ?? this.userNickName,
      uploaderId: uploaderId ?? this.uploaderId,
      categoryId: categoryId ?? this.categoryId,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      comments: comments ?? this.comments,
      score: score ?? this.score,
    );
  }
}
