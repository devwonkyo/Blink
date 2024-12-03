import 'package:blink/features/point/domain/repositories/point_repository.dart';

class WaterTree {
  final PointRepository repository;

  WaterTree({required this.repository});

  Future<void> call(String userId, int waterAmount) async {
    // 트리 정보 가져오기
    final tree = await repository.getTree(userId);
    // 물 추가 및 레벨 업데이트
    final updatedTree = tree.updateWaterAndLevel(waterAmount);
    // Firestore에 업데이트
    await repository.updateTree(userId, updatedTree);
  }
}
