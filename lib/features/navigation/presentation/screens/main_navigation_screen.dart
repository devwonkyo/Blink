import 'package:blink/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blink/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:blink/features/home/presentation/screens/home_screen.dart';
import 'package:blink/features/point/presentation/screens/point_screen.dart';
import 'package:blink/features/upload/presentation/screens/upload_screen.dart';
import 'package:blink/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:blink/features/profile/presentation/screens/profile_screen.dart';
import 'package:blink/features/user/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        final currentUser = FirebaseAuth.instance.currentUser;

        return Scaffold(
          body: IndexedStack(
            index: state.selectedIndex > 2 ? state.selectedIndex - 1 : state.selectedIndex,
            children: [
              const HomeScreen(),
              const PointScreen(),
              const NotificationsScreen(),
              currentUser == null
                  ? const LoginScreen()
                  : ProfileScreen(userId: currentUser.uid),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: state.selectedIndex,
            onTap: (index) {
              if (index == 2) { // 업로드 버튼 인덱스
                if (currentUser == null) {
                  context.read<NavigationBloc>().add(NavigationIndexChanged(index));
                } else {
                  context.push('/upload_camera');
                }
              } else {
                context.read<NavigationBloc>().add(NavigationIndexChanged(index));
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: '포인트',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: '업로드',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: '알림',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '프로필',
              ),
            ],
          ),
        );
      },
    );
  }
}
