class NotificationModel {
  final String? id;
  final String type;
  final String destinationUserId;
  final String body;
  final String? notificationImageUrl;
  final bool isRead; // 추가

  NotificationModel({
    this.id,
    required this.type,
    required this.destinationUserId,
    required this.body,
    this.notificationImageUrl,
    this.isRead = false, // 기본값 false
  });

  // copyWith 수정
  NotificationModel copyWith({
    String? id,
    String? type,
    String? destinationUserId,
    String? body,
    String? notificationImageUrl,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      destinationUserId: destinationUserId ?? this.destinationUserId,
      body: body ?? this.body,
      notificationImageUrl: notificationImageUrl ?? this.notificationImageUrl,
      isRead: isRead ?? this.isRead,
    );
  }

  // toMap 수정
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'destinationUserId': destinationUserId,
      'body': body,
      'notificationImageUrl': notificationImageUrl,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String?,
      type: map['type'] as String,
      destinationUserId: map['destinationUserId'] as String,
      body: map['body'] as String,
      notificationImageUrl: map['notificationImageUrl'] as String?,
      isRead: map['isRead'] as bool? ?? false,
    );
  }
}