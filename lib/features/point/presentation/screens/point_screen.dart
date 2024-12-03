import 'package:blink/core/theme/colors.dart'; // AppColors 사용
import 'package:blink/features/point/presentation/blocs/point_bloc/point_bolc.dart';
import 'package:blink/features/point/presentation/blocs/point_bloc/point_event.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
        title: const Text(
          '포인트',
          style: TextStyle(
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.backgroundDarkGrey,
        iconTheme: const IconThemeData(color: AppColors.iconWhite),
      ),
      backgroundColor: AppColors.backgroundBlackColor,
      body: FutureBuilder<TreeModel>(
        future: _fetchTreeData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.textGrey),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Tree data not found.',
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 20.0,
                          child: LinearProgressIndicator(
                            value: waterLevel / 1000,
                            backgroundColor: AppColors.backgroundLightGrey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.secondaryLightColor),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          '${waterLevel.toStringAsFixed(2)} / 1000',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.textWhite,
                      ),
                      onPressed: () {
                        context
                            .read<PointBloc>()
                            .add(WaterTreeEvent(userId, 100));
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
                  backgroundColor: AppColors.secondaryDeepDarkColor,
                  onPressed: () {
                    context.push('/point-rewards');
                  },
                  child: const Icon(
                    Icons.shopping_basket,
                    color: AppColors.iconWhite,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
