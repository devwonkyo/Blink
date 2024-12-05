import 'dart:async';
import 'package:blink/core/theme/colors.dart';
import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:blink/features/point/presentation/blocs/point_bloc/point_bloc.dart';
import 'package:blink/features/point/presentation/blocs/point_bloc/point_event.dart';
import 'package:blink/features/point/presentation/blocs/point_bloc/point_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blink/features/user/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PointScreen extends StatefulWidget {
  const PointScreen({super.key});

  @override
  _PointScreenState createState() => _PointScreenState();
}

class _PointScreenState extends State<PointScreen> {
  final AuthRepository _authRepository = AuthRepository();
  Timer? _wateringTimer;
  int _currentWaterAmount = 1;
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    final userIdFuture = BlinkSharedPreference().getCurrentUserId();
    userIdFuture.then((userId) {
      if (userId != 'not defined user') {
        context.read<PointBloc>().add(LoadPoints(userId));
      }
    }).catchError((error) {});
  }

  void _startWatering(String userId, int waterLevel, int points) {
    if (points <= 0) {
      _showDialog("물 부족", "포인트가 없습니다!");
      return;
    }

    setState(() {
      _isPressing = true;
    });

    _wateringTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (points <= 0) {
        timer.cancel();
        _showDialog("물 부족", "더 이상 물을 줄 수 없습니다.");
      } else if (waterLevel >= 1000) {
        timer.cancel();
        context
            .read<PointBloc>()
            .add(WaterTreeEvent(userId, 1000 - waterLevel));
        _showDialog("레벨 업!", "레벨이 상승하고 물이 초기화되었습니다.");
      } else {
        context
            .read<PointBloc>()
            .add(WaterTreeEvent(userId, _currentWaterAmount));

        setState(() {
          _currentWaterAmount += _currentWaterAmount;
        });
      }
    });
  }

  void _stopWatering() {
    if (_wateringTimer != null) {
      _wateringTimer!.cancel();
      _wateringTimer = null;
    }
    setState(() {
      _currentWaterAmount = 1;
      _isPressing = false;
    });
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '포인트',
          style: TextStyle(color: AppColors.textWhite, fontSize: 20.sp),
        ),
        backgroundColor: AppColors.backgroundDarkGrey,
      ),
      backgroundColor: AppColors.backgroundBlackColor,
      body: MultiBlocListener(
        listeners: [
          BlocListener<PointBloc, PointState>(
            listener: (context, state) {
              if (state is PointError) {
                _showDialog("오류", state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<PointBloc, PointState>(
          builder: (context, state) {
            if (state is PointsLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 30.h),
                    Text(
                      '로그인 정보를 불러올 수 없습니다.',
                      style: TextStyle(color: AppColors.textWhite, fontSize: 16.sp),
                    ),
                    Text(
                      '아래 버튼을 눌러주세요',
                      style: TextStyle(color: AppColors.textWhite, fontSize: 16.sp),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () async {
                        final userId = await BlinkSharedPreference().getCurrentUserId();
                        if (userId != 'not defined user') {
                          context.read<PointBloc>().add(LoadPoints(userId));
                        } else {
                          _showDialog("로그인 필요", "로그인 정보가 없습니다. 다시 로그인해주세요.");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.textWhite,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      ),
                      child: Text("로그인 정보 불러오기", style: TextStyle(fontSize: 14.sp)),
                    ),
                  ],
                ),
              );
            }

            if (state is PointError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: AppColors.textWhite, fontSize: 16.sp),
                ),
              );
            }

            if (state is PointsAndTreeUpdated) {
              final points = state.points;
              final waterLevel = state.water;

              return Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: 0,
                    right: 0,
                    child: Text(
                      '현재 보유 포인트: $points',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.13,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/images/point/tree.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.135,
                    left: 16.w,
                    right: 16.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 35.h,
                          child: LinearProgressIndicator(
                            value: waterLevel / 1000,
                            backgroundColor: AppColors.backgroundLightGrey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.secondaryLightColor),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '$waterLevel / 1000',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.068,
                    left: 32.w,
                    right: 32.w,
                    child: GestureDetector(
                      onLongPressStart: (_) =>
                          _startWatering(state.userId, waterLevel, points),
                      onLongPressEnd: (_) => _stopWatering(),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPressing
                              ? AppColors.primaryLightColor
                              : AppColors.primaryColor,
                          foregroundColor: AppColors.textWhite,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () {},
                        child: Text('물 주기', style: TextStyle(fontSize: 16.sp)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16.w,
                    top: MediaQuery.of(context).size.height * 0.05,
                    child: FloatingActionButton(
                      backgroundColor: AppColors.secondaryColor,
                      onPressed: () {
                        context.push('/point-rewards');
                      },
                      child: Icon(
                        Icons.shopping_basket,
                        color: AppColors.iconWhite,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              );
            }
            // 상태가 PointsAndTreeUpdated가 아닌 경우
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 4.w,
              ),
            );
          },
        ),
      ),
    );
  }
}
