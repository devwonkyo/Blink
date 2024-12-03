import 'package:blink/features/point/data/datasources/local/point_local_datasource.dart';
import 'package:blink/features/point/data/datasources/remote/point_remote_datasource.dart';
import 'package:blink/features/point/data/models/tree_model.dart';
import 'package:blink/features/point/domain/repositories/point_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PointRepositoryImpl implements PointRepository {
  final PointRemoteDataSource remoteDataSource;
  final PointLocalDataSource localDataSource;
  final FirebaseFirestore firestore;

  PointRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.firestore,
  });

  @override
  Future<int> getUserPoints(String userId) => remoteDataSource.getUserPoints(userId);

  @override
  Future<void> addPoints(String userId, int points) => remoteDataSource.addPoints(userId, points);

  @override
  Future<void> updateUserPoints(String userId, int points) async {
    await firestore.collection('users').doc(userId).update({
      'point': FieldValue.increment(points),
    });
  }

  @override
  Future<void> waterTree(String userId, int waterAmount) async {
    try {
      final treeDoc = firestore.collection('trees').doc(userId);
      final treeSnapshot = await treeDoc.get();

      if (!treeSnapshot.exists) {
        throw Exception('Tree not found for userId: $userId');
      }

      final tree = TreeModel.fromMap(treeSnapshot.data()!);
      final updatedTree = tree.updateWaterAndLevel(waterAmount);

      await treeDoc.update(updatedTree.toMap());
      await updateUserPoints(userId, -waterAmount);
    } catch (e) {
      throw Exception("Failed to water tree for userId $userId: ${e.toString()}");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> generateFruit(String userId, int waterCount) =>
      remoteDataSource.generateFruit(userId, waterCount);

  @override
  Future<void> claimFruitReward(String userId, String fruitId, String giftUrl) =>
      remoteDataSource.claimFruitReward(userId, fruitId, giftUrl);

  @override
  Future<TreeModel> getTree(String userId) async {
    final snapshot = await firestore.collection('trees').doc(userId).get();
    if (!snapshot.exists) {
      throw Exception('Tree not found for userId: $userId');
    }
    return TreeModel.fromMap(snapshot.data()!);
  }

  @override
  Future<void> updateTree(String userId, TreeModel tree) async {
    await firestore.collection('trees').doc(userId).update(tree.toMap());
  }
}
