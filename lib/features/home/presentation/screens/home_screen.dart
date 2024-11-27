import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '팔로잉',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 20),
            Text(
              '추천',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 비디오 배경 (임시로 검은 배경으로 대체)
              Container(
                color: Colors.black87,
              ),

              // 우측 액션 버튼들
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).size.height * 0.3,
                child: Column(
                  children: [
                    // 프로필 이미지
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.person,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    // 좋아요 버튼
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(CupertinoIcons.heart,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          '1.3M',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 댓글 버튼
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(CupertinoIcons.chat_bubble,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          '10.7M',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 공유 버튼
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(CupertinoIcons.share,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          '30.9K',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 하단 설명
              const Positioned(
                left: 16,
                right: 100,
                bottom: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 사용자 이름
                    Text(
                      '@gamza_butler',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    // 비디오 설명
                    Text(
                      'meow! meow! meow! .... \n#cat #kitty #meow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    // 음악 정보
                    Row(
                      children: [
                        Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '체리필터 - 낭만고양이',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
