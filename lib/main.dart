import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:blink/core/utils/fcm.dart';
import 'package:blink/core/utils/notification_util.dart';
import 'package:blink/features/home/presentation/screens/home_screen.dart';
import 'package:blink/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:blink/features/point/presentation/blocs/point_bloc/point_bloc.dart';
import 'package:blink/features/upload/presentation/blocs/upload/upload_video_bloc.dart';
import 'package:blink/features/user/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/routes/app_router.dart' show AppRouter, navigatorKey;
import 'injection_container.dart' as di;
import 'package:blink/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'core/theme/app_theme.dart';
import 'package:blink/features/video/presentation/blocs/video/video_bloc.dart';
// search
import 'package:blink/features/search/presentation/blocs/search/search_bloc.dart';
import 'package:blink/features/search/domain/usecases/search_query.dart';
import 'package:blink/features/search/domain/usecases/save_search_query.dart';
import 'package:blink/features/search/domain/usecases/delete_search_query.dart';
// point
import 'package:blink/features/point/domain/repositories/point_repository.dart';
// intl
import 'package:intl/date_symbol_data_local.dart';
import 'package:blink/features/share/presentation/blocs/share_bloc/share_bloc.dart';
import 'package:blink/features/share/data/repositories/share_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM Token 설정
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print('fcmToken : $fcmToken');

  if (fcmToken != null) {
    BlinkSharedPreference().setToken(fcmToken);
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((fcmServerToken) {
    fcmToken ??= fcmServerToken;
    BlinkSharedPreference().setToken(fcmToken ?? "");
    print('fcmToken : $fcmToken');
  }).onError((err) {
    print('error : Firebase token error');
  });

  // 권한 설정, 버전관리
  await NotificationUtil().requestNotificationPermission();
  await NotificationUtil().initialize();

  // FCM 설정
  setupForegroundFirebaseMessaging();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await di.init();

  // ShareBloc 및 다이나믹 링크 처리 초기화
  final shareRepository = ShareRepositoryImpl();

  // 초기 다이나믹 링크 처리
  final initialVideoId = await shareRepository.handleInitialDynamicLink();
  print('Main: Initial video ID from dynamic link: $initialVideoId');

  // 초기 비디오 ID를 AppRouter에 설정
  if (initialVideoId != null) {
    AppRouter.initialVideoId = initialVideoId;
  }

  // 앱 실행
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Blink',
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          // 초기 다이나믹 링크가 있는 경우 처리
          if (initialVideoId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppRouter.router.go('/main', extra: {'videoId': initialVideoId});
            });
          }

          return MultiProvider(
            providers: [
              Provider(create: (context) => di.sl<SearchQuery>()),
              Provider(create: (context) => di.sl<SaveSearchQuery>()),
              Provider(create: (context) => di.sl<DeleteSearchQuery>()),
              Provider(create: (context) => di.sl<PointRepository>()),
              BlocProvider<PointBloc>(
                create: (context) => PointBloc(context.read<PointRepository>()),
              ),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => di.sl<NavigationBloc>()),
                BlocProvider(create: (context) => di.sl<AuthBloc>()),
                BlocProvider(create: (context) => di.sl<UploadVideoBloc>()),
                BlocProvider(create: (context) => di.sl<VideoBloc>()),
                BlocProvider(create: (context) => di.sl<NotificationBloc>()),
                BlocProvider(
                  create: (context) => SearchBloc(
                    searchQuery: di.sl<SearchQuery>(),
                    saveSearchQuery: di.sl<SaveSearchQuery>(),
                    deleteSearchQuery: di.sl<DeleteSearchQuery>(),
                  ),
                ),
                BlocProvider(
                  create: (context) => ShareBloc(
                    shareRepository: shareRepository,
                  ),
                ),
              ],
              child: child ?? const SizedBox(),
            ),
          );
        },
      ),
    ),
  );

  // 앱이 실행 중일 때 다이나믹 링크 처리
  shareRepository.handleDynamicLinkStream().listen((videoId) {
    if (videoId != null) {
      print('Main: Received video ID from dynamic link stream: $videoId');
      AppRouter.router.push('/main', extra: {'videoId': videoId});
    }
  });
}
