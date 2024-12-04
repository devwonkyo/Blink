class FruitModel {
  final String id; // 고유 ID
  final double x; // X 좌표
  final double y; // Y 좌표
  final String reward; // 보상 정보 (기프티콘)

  FruitModel({
    required this.id,
    required this.x,
    required this.y,
    required this.reward,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'reward': reward,
    };
  }

  factory FruitModel.fromMap(Map<String, dynamic> map) {
    return FruitModel(
      id: map['id'] as String,
      x: map['x'] as double,
      y: map['y'] as double,
      reward: map['reward'] as String,
    );
  }
}
