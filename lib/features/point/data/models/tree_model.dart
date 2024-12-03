class TreeModel {
  // 나무의 고유 ID
  final String id;

  // 나무 소유자의 ID
  final String userId;

  // 현재 나무의 레벨
  final int level;

  // 현재 물의 양 (1000일 때마다 0으로 초기화)
  final int water;

  TreeModel({
    required this.id,
    required this.userId,
    this.level = 0,
    this.water = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'level': level,
      'water': water,
    };
  }

  factory TreeModel.fromMap(Map<String, dynamic> map) {
    return TreeModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      level: map['level'] as int? ?? 0,
      water: map['water'] as int? ?? 0,
    );
  }

  TreeModel updateWaterAndLevel(int addedWater) {
    final newWater = water + addedWater;
    if (newWater >= 1000) {
      return TreeModel(
        id: id,
        userId: userId,
        level: level + 1,
        water: newWater - 1000,
      );
    } else {
      return TreeModel(
        id: id,
        userId: userId,
        level: level,
        water: newWater,
      );
    }
  }
}
