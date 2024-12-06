import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blink/features/navigation/presentation/screens/main_navigation_screen.dart';
// user
import 'package:blink/features/user/presentation/screens/login_screen.dart';
import 'package:blink/features/user/presentation/screens/signup_screen.dart';
// profile
import 'package:blink/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:blink/features/profile/presentation/screens/profile_screen.dart';
import 'package:blink/features/follow/presentation/screens/follow_list_screen.dart';
// profile // settings
import 'package:blink/features/profile/presentation/screens/settings/manage_videos_screen.dart';
import 'package:blink/features/profile/presentation/screens/settings/settings_screen.dart';
import 'package:blink/features/profile/presentation/screens/settings/video_info_update.dart';
import 'package:blink/features/profile/presentation/screens/settings/watch_history_screen.dart';
// search
import 'package:blink/features/search/presentation/screens/search_screen.dart';
import 'package:blink/features/search/presentation/screens/searched_screen.dart';
import 'package:blink/features/search/presentation/screens/hashtag_videos_screen.dart';
// home
import 'package:blink/features/home/presentation/screens/home_screen.dart';
// upload
import 'package:blink/features/upload/presentation/screens/upload_detail_screen.dart';
import 'package:blink/features/upload/presentation/screens/upload_preview_screen.dart';
import 'package:blink/features/upload/presentation/screens/upload_screen.dart';
// video
import 'package:blink/features/video/presentation/blocs/video/video_bloc.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static String? initialVideoId;

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/main',
    observers: [
      VideoRouteObserver(),
    ],
    redirect: (context, state) {
      // 초기 비디오 ID가 있고 메인 화면으로 가는 경우에만 리다이렉트
      if (initialVideoId != null && state.matchedLocation == '/main') {
        return state.uri.toString();
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/main',
        name: '/',
        builder: (context, state) {
          // extra가 Map인 경우와 int인 경우를 모두 처리
          final extra = state.extra;
          String? videoId;

          if (extra is Map<String, dynamic>) {
            videoId = extra['videoId'] as String?;
          }

          videoId ??= initialVideoId;

          // 사용 후 초기 비디오 ID 초기화
          if (initialVideoId != null) {
            print('Using initial video ID: $initialVideoId');
            initialVideoId = null;
          }

          // extra가 int인 경우 해당 인덱스를 사용
          final index = (extra is int) ? extra : 0;

          print(
              'AppRouter: Building MainNavigationScreen with index: $index, videoId: $videoId');
          return MainNavigationScreen(initialIndex: index);
        },
      ),
      GoRoute(
        path: '/main-navigation/:index',
        builder: (context, state) {
          final index = int.tryParse(state.pathParameters['index'] ?? '0') ?? 0;
          return MainNavigationScreen(initialIndex: index);
        },
      ),
      // user
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final destinationIndex = state.extra as int?;
          return LoginScreen(destinationIndex: destinationIndex);
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      // profile
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile_edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/follow_list',
        builder: (context, state) {
          final args = state.extra as Map<String, String>;
          return FollowListScreen(type: args['type']!, userId: args['userId']!);
        },
      ),
      // profile // settings
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/watch-history/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return WatchHistoryScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/manage-videos/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ManageVideosScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/video-info-update',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return VideoInfoUpdateScreen(
            videoId: extra['videoId'],
            videoPath: extra['videoPath'],
            thumbnailPath: extra['thumbnailPath'],
            initialTitle: extra['initialTitle'],
            initialDescription: extra['initialDescription'],
            initialCategory: extra['initialCategory'],
            initialHashtags: List<String>.from(extra['initialHashtags']),
          );
        },
      ),
      // search
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/search/results/:query',
        builder: (context, state) {
          final query = state.pathParameters['query'] ?? '';
          return SearchedScreen(query: query);
        },
      ),
      // upload
      GoRoute(
        path: '/upload_camera',
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: '/upload_preview',
        builder: (context, state) {
          String videoPath = "";
          if (state.extra != null && state.extra is String) {
            videoPath = state.extra as String;
          }
          return UploadPreviewScreen(videoPath: videoPath);
        },
      ),
      GoRoute(
        path: '/upload_detail',
        builder: (context, state) {
          final args = state.extra as Map<String, String>;
          final videoPath = args['videoPath'];
          final thumbnailPath = args['thumbnailPath'];

          return UploadDetailScreen(
            videoPath: videoPath ?? "",
            thumbnailPath: thumbnailPath ?? "",
          );
        },
      ),
      GoRoute(
        path: '/hashtag_videos',
        builder: (context, state) {
          final hashtag = state.extra as String;
          return HashtagVideosScreen(hashtag: hashtag);
        },
      ),
    ],
  );
}

class VideoRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pauseVideoIfNeeded(previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.navigator?.context != null) {
      final homeState = previousRoute!.navigator!.context
          .findAncestorStateOfType<HomeScreenState>();
      if (homeState != null) {
        final currentState = homeState.videoBloc?.state;
        if (currentState is VideoLoaded && homeState.wasPlaying) {
          final currentKey = homeState.getVideoKey(currentState.currentIndex);
          currentKey.currentState?.resume();
        }
      }
    }
  }

  void _pauseVideoIfNeeded(Route<dynamic>? route) {
    if (route == null) return;

    final context = route.navigator?.context;
    if (context == null) return;

    // HomeScreen의 State를 찾아서 비디오 일시정지
    final homeState = context.findAncestorStateOfType<HomeScreenState>();
    if (homeState != null) {
      for (var key in homeState.videoKeys.values) {
        key.currentState?.pause();
      }
    }
  }
}
