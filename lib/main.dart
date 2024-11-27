import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'injection_container.dart' as di;
import 'package:blink/features/navigation/presentation/bloc/navigation_bloc.dart';

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
        designSize: const Size(375, 812), // 디자인 기준 크기
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Blink',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            routerConfig: AppRouter.router,
          );
        },
      )
    );
  }
}
