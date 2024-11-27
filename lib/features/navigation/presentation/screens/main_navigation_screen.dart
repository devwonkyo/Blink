import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blink/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:blink/features/home/presentation/screens/home_screen.dart';
import 'package:blink/features/point/presentation/screens/point_screen.dart';
import 'package:blink/features/upload/presentation/screens/upload_screen.dart';
import 'package:blink/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:blink/features/profile/presentation/screens/profile_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.selectedIndex,
            children: const [
              HomeScreen(),
              PointScreen(),
              UploadScreen(),
              NotificationsScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: state.selectedIndex,
            onTap: (index) {
              context.read<NavigationBloc>().add(NavigationIndexChanged(index));
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
