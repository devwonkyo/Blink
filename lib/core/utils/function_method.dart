import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:cloud_functions/cloud_functions.dart';

/*
Future<void> sendNotification({required String title, required String body, required String userId, String screen = "/main"}) async {
  try {
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('sendPushNotification3');
    print('send noti : $userId');
    final result = await callable.call({
      'title': title,
      'body': body,
      'token': "eok1heuzTgG_IeKA_u47ZW:APA91bGfksrOjzq_HWPCqExBa0bh8tT-pM1a40AclX8LrqrGtkIylGcRANwJnWDvkipt4Xb_0U6-v70D0xlQLiOxxoT-SO78n31FjrYyUoF-SQ30hKQ8DCA",
      'screen': screen
    });
    print("success : ${result.data}");
  } catch (e) {
    print('Caught generic exception: $e');
  }
}
*/


Future<void> sendNotification({required String title, required String body, required String destinationUserId, String screen = "/main"}) async {
  try {
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('sendPushNotification4');
    final result = await callable.call({
      'title': title,
      'body': body,
      'userId': destinationUserId,
      'screen': screen
    });
    print("success : ${result.data}");
  } catch (e) {
    print('Caught generic exception: $e');
  }
}
