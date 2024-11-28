import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final List<String>? followingList;
  final List<String>? followerList;
  final List<String>? watchList;
  final String? recommendId;
  final String? pushToken;
  final int? point;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.followingList,
    this.followerList,
    this.watchList,
    this.recommendId,
    this.pushToken,
    this.point,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      followingList: (json['following_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      followerList: (json['follower_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      watchList: (json['watch_list'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      recommendId: json['recommend_id'] as String?,
      pushToken: json['push_token'] as String?,
      point: json['point'] as int?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'following_list': followingList,
      'follower_list': followerList,
      'watch_list': watchList,
      'recommend_id': recommendId,
      'push_token': pushToken,
      'point': point,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    List<String>? followingList,
    List<String>? followerList,
    List<String>? watchList,
    String? recommendId,
    String? pushToken,
    int? point,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followingList: followingList ?? this.followingList,
      followerList: followerList ?? this.followerList,
      watchList: watchList ?? this.watchList,
      recommendId: recommendId ?? this.recommendId,
      pushToken: pushToken ?? this.recommendId,
      point: point ?? this.point,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
