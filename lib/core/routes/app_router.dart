import 'package:blink/features/user/presentation/screens/login_screen.dart';
import 'package:blink/features/user/presentation/screens/signup_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:blink/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:blink/features/search/presentation/screens/searched_screen.dart';

//search
import 'package:blink/features/search/presentation/screens/search_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

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
