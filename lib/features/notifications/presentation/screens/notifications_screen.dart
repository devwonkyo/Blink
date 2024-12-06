import 'package:blink/core/utils/blink_sharedpreference.dart';
import 'package:blink/core/utils/function_method.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () async {
            try {
              final userId = await BlinkSharedPreference().getCurrentUserId();
              await sendNotification(
                title: "알림",
                body: "테스트",
                destinationUserId: userId,
              );
            } catch (e) {
              print('알림 전송 실패: $e');
            }
          },
          child: const Text(
            '알림',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )
    );
  }
}
