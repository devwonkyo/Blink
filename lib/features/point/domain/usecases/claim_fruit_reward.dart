import 'package:blink/features/point/domain/repositories/point_repository.dart';

class ClaimFruitReward {
  final PointRepository repository;

  ClaimFruitReward({required this.repository});

  Future<void> call(String userId, String fruitId, String giftUrl) async {
    await repository.claimFruitReward(userId, fruitId, giftUrl);
  }
}
