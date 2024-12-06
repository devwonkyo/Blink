import 'dart:io';

import 'package:blink/core/routes/app_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationUtil {
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final GoRouter _router = AppRouter.router;

  // Singleton pattern to ensure a single instance
  static final NotificationUtil _instance = NotificationUtil._internal();

  factory NotificationUtil() => _instance;

  NotificationUtil._internal();

  Future<void> initialize() async {
    AndroidInitializationSettings android = const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings = InitializationSettings(android: android, iOS: ios);


    await _local.initialize(settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },);
  }

  Future<void> requestNotificationPermission() async {

    if(await Permission.notification.isDenied) {
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }
    }

    if(Platform.isIOS){
      _local.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.
      requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

  }


  Future<void> showNotification(RemoteMessage message) async {
    const NotificationDetails details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,

      ),
      android: AndroidNotificationDetails(
        "Nomal", //채널 아이디 별로 알림 특성 설정 가능(방 같은 개념)
        "Nomal", //채널의 용도를 설명하는 이름
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    //앞의 int값이 알림 고유 번호 -> 상수값 넣으면 한개만 덮어씀
    await _local.show(0, message.notification?.title ?? "알림",
        message.notification?.body ?? "",
        details,
        payload: message.data['screen'] );
  }


  //사용방법 "/home?parameter"
  void _handleNotificationTap(String? payload) {
    print('payload = $payload');
    if (payload != null) {
      final screenAndParameter = splitScreenParameter(payload);

      if(screenAndParameter[1].isEmpty){
        _router.push(screenAndParameter[0]);
      }else{
        _router.push(screenAndParameter[0],extra: screenAndParameter[1]);
      }
    }
  }



  List<String> splitScreenParameter(String data) {
    String screen;
    String parameter;

    int questionMarkIndex = data.indexOf('?');

    if (questionMarkIndex != -1) {
      // '?'가 존재하는 경우
      screen = data.substring(0, questionMarkIndex);
      parameter = data.substring(questionMarkIndex + 1);
    } else {
      // '?'가 없는 경우
      screen = data;
      parameter = '';
    }
    return [screen, parameter];
  }

}
