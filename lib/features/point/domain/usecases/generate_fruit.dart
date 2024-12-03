import 'dart:math';

import 'package:blink/features/point/domain/repositories/point_repository.dart';

class GenerateFruit {
  final PointRepository repository;

  GenerateFruit({required this.repository});

  Future<List<Map<String, dynamic>>> call(String userId, int waterCount) async {
    return await repository.generateFruit(userId, waterCount);
  }

  List<Map<String, dynamic>> generateRandomFruits(int count) {
    final random = Random();
    return List<Map<String, dynamic>>.generate(count, (index) {
      final id = 'fruit_${DateTime.now().millisecondsSinceEpoch}_$index';
      return {
        'id': id,
        'position': {
          'x': random.nextDouble() * 500, // 0~500 범위 랜덤
          'y': random.nextDouble() * 500,
        },
      };
    });
  }
}
