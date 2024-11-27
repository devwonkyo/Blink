import 'package:go_router/go_router.dart';
import 'package:blink/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:blink/features/search/presentation/screens/searched_screen.dart';

//search
import 'package:blink/features/search/presentation/screens/search_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/main',
    routes: [
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainNavigationScreen(),
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
