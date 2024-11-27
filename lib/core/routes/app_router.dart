import 'package:blink/features/user/presentation/screens/login_screen.dart';
import 'package:blink/features/user/presentation/screens/signup_screen.dart';
import 'package:go_router/go_router.dart';
import '../../features/navigation/presentation/pages/main_navigation_screen.dart';

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

    ],
  );
}
