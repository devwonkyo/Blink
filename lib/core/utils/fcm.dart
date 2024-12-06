//fcm 정리
//notification 포함 -> 알림은 뜨지만 헤드업 알림은 안뜸, AppOpenlistenter 호출
//notification 미포함 -> 알림 헤드업 알림 둘다 안뜸, 헤드업 알림(notification) 띄울 시 AppOpenlistener 호출 안됨

// 포그라운드에서 푸시 알림을 수신 했을 때 처리/
import 'package:blink/core/utils/notification_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void setupForegroundFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    NotificationUtil().showNotification(message);
  });
}

// 백그라운드 상태에서 메시지를 수신했을 때 실행되는 코드
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification == null) {
    NotificationUtil().showNotification(message);
  }
}
