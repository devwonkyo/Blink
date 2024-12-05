import 'package:blink/features/point/data/datasources/local/point_local_datasource.dart';
import 'package:blink/features/point/data/datasources/remote/point_remote_datasource.dart';
import 'package:blink/features/point/data/models/fruit_model.dart';
import 'package:blink/features/point/data/models/tree_model.dart';
import 'package:blink/features/point/domain/repositories/point_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

      // 물 1000이 넘으면 새로운 열매 생성
      if (updatedTree.water == 0) {
        final randomX = (0.1 + 0.8 * (updatedTree.level % 100) / 100).clamp(0.1, 0.9);
        final randomY = (0.15 + 0.7 * (updatedTree.level % 73) / 100).clamp(0.15, 0.85);

        updatedTree.fruits.add(FruitModel(
          id: UniqueKey().toString(),
          x: randomX,
          y: randomY,
          reward: "gs://blink-app-8d6ca.firebasestorage.app/gifticon/gift.jpg",
          status: "fruitForm",
        ));
      }

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
    final treeDoc = firestore.collection('trees').doc(userId);
    final snapshot = await treeDoc.get();

    if (!snapshot.exists) {
      final newTree = TreeModel(
        id: userId,
        userId: userId,
        level: 0,
        water: 0,
        fruits: [],
      );

      await treeDoc.set(newTree.toMap());
      return newTree;
    }

    return TreeModel.fromMap(snapshot.data()!);
  }

  @override
  Future<void> updateTree(String userId, TreeModel tree) async {
    await firestore.collection('trees').doc(userId).update(tree.toMap());
  }
}
