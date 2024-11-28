import 'package:blink/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'injection_container.dart' as di;
import 'package:blink/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:blink/features/video/presentation/blocs/video/video_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => di.sl<NavigationBloc>()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Blink',
              theme: AppTheme.darkTheme,
              routerConfig: AppRouter.router,
            );
          },
        ));
  }
}

// GoRouter 설정 예시
final router = GoRouter(
  observers: [
    GoRouterObserver(), // 커스텀 observer
  ],
  routes: [
    // ... 라우트 설정
  ],
);

// 커스텀 라우터 observer
class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // 새로운 화면으로 이동할 때
    if (previousRoute?.settings.name == '/') {
      // HomeScreen의 비디오 일시정지
      final homeState = previousRoute?.navigator?.context
          .findAncestorStateOfType<HomeScreenState>();
      homeState?.videoKeys.values.forEach((key) => key.currentState?.pause());
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // 이전 화면으로 돌아갈 때
    if (previousRoute?.settings.name == '/') {
      // HomeScreen으로 돌아왔을 때 비디오 재생 재개
      final homeState = previousRoute?.navigator?.context
          .findAncestorStateOfType<HomeScreenState>();
      if (homeState?.wasPlaying == true) {
        final currentState = homeState?.videoBloc?.state;
        if (currentState is VideoLoaded) {
          final currentKey = homeState?.getVideoKey(currentState.currentIndex);
          currentKey?.currentState?.resume();
        }
      }
    }
  }
}
