import 'package:blink/features/point/presentation/blocs/point_bloc/point_bolc.dart';
import 'package:blink/features/point/presentation/blocs/point_bloc/point_event.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // 상태 관리용 패키지
import 'package:blink/features/point/domain/repositories/point_repository.dart';
import 'package:blink/features/point/data/models/tree_model.dart';

class PointScreen extends StatelessWidget {
  final String userId;

  PointScreen({required this.userId});

  Future<TreeModel> _fetchTreeData(BuildContext context) async {
    final repository = Provider.of<PointRepository>(context, listen: false);
    return await repository.getTree(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트'),
      ),
      body: FutureBuilder<TreeModel>(
        future: _fetchTreeData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Tree data not found.'));
          }

          final tree = snapshot.data!;
          final waterLevel = tree.water;

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '현재 보유 포인트: ${tree.level * 1000 + waterLevel}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/point/tree.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  LinearProgressIndicator(
                    value: waterLevel / 1000, // 현재 물 레벨 비율
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 32.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<PointBloc>().add(WaterTreeEvent(userId, 100));
                      },
                      child: const Text('물 주기'),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 16.0,
                top: MediaQuery.of(context).size.height * 0.07,
                child: FloatingActionButton(
                  onPressed: () {
                    context.push('/point-rewards');
                  },
                  child: const Icon(Icons.shopping_basket),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
