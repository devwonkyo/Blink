import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UploadDetailScreen extends StatefulWidget {
  final String videoPath;

  const UploadDetailScreen({super.key, required this.videoPath});

  @override
  State<UploadDetailScreen> createState() => _UploadDetailScreenState();
}

class _UploadDetailScreenState extends State<UploadDetailScreen> {
  late final TextEditingController _contentController;

  @override
  void initState() {
    _contentController = TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          '설명을 추가하세요...',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          // Image Preview Section
          Container(
            margin: const EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '미리 보기',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hashtags
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '# 해시태그',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '@ 멘션',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // Add Link Button
          Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, color: Colors.red[400]),
                const SizedBox(width: 8),
                Text(
                  '링크 추가',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Global Visibility
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('모든 사용자가 이 게시물을 볼 수 있습니다'),
            trailing: const Icon(Icons.chevron_right),
          ),

          // Advanced Settings
          ListTile(
            leading: const Icon(Icons.more_horiz),
            title: const Text('고급 설정'),
            subtitle: const Text('업로드 품질 관리'),
            trailing: const Icon(Icons.chevron_right),
          ),

          // Share Section
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('공유'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFE812), // KakaoTalk yellow
                  ),
                  child: const Icon(Icons.chat_bubble, size: 20),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1877F2), // Facebook blue
                  ),
                  child: const Icon(
                    Icons.facebook,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.grey[100],
                    ),
                    child: const Text(
                      '임시 저장',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red[400],
                    ),
                    child: const Text(
                      '게시',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
