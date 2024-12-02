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
// search
import 'package:blink/features/search/presentation/screens/search_screen.dart';
import 'package:blink/features/search/presentation/screens/searched_screen.dart';
// home
import 'package:blink/features/home/presentation/screens/home_screen.dart';
// video
import 'package:blink/features/video/presentation/blocs/video/video_bloc.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/main',
    observers: [
      VideoRouteObserver(),
    ],
    routes: [
      GoRoute(
        path: '/main',
        name: '/',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      // user
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
