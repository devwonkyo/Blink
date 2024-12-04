import 'package:blink/features/point/domain/repositories/point_repository.dart';

class GetUserPoints {
  final PointRepository repository;

  GetUserPoints({required this.repository});

  Future<int> call(String userId) async {
    return await repository.getUserPoints(userId);
  }
}
