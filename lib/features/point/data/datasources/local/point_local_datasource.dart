import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PointLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _giftsKey = "gifts";

  PointLocalDataSource({required this.sharedPreferences});

  // 기프티콘 저장하기
  Future<void> saveGift(String giftId, String giftImageUrl) async {
    final List<String> currentGifts = sharedPreferences.getStringList(_giftsKey) ?? [];
    final newGift = jsonEncode({'id': giftId, 'imageUrl': giftImageUrl});
    currentGifts.add(newGift);

    await sharedPreferences.setStringList(_giftsKey, currentGifts);
  }

  // 모든 기프티콘 가져오기
  Future<List<Map<String, dynamic>>> getGifts() async {
    final List<String> currentGifts = sharedPreferences.getStringList(_giftsKey) ?? [];
    return currentGifts.map((gift) => jsonDecode(gift) as Map<String, dynamic>).toList();
  }

  // 기프티콘 삭제하기 (사용 완료)
  Future<void> removeGift(String giftId) async {
    final List<String> currentGifts = sharedPreferences.getStringList(_giftsKey) ?? [];
    currentGifts.removeWhere((gift) {
      final giftData = jsonDecode(gift) as Map<String, dynamic>;
      return giftData['id'] == giftId;
    });

    await sharedPreferences.setStringList(_giftsKey, currentGifts);
  }

  // 모든 기프티콘 초기화
  Future<void> clearGifts() async {
    await sharedPreferences.remove(_giftsKey);
  }
}
